import 'package:flutter/widgets.dart';
import 'package:flutter_cast_framework/cast/CastContext.dart';
import 'package:flutter_cast_framework/flutter_cast_framework.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CastIcon extends StatefulWidget {
  @override
  _CastIconState createState() => _CastIconState();
}

Widget _getButton(String assetName) {
  return SvgPicture.asset(
    assetName,
    package: 'flutter_cast_framework',
    semanticsLabel: 'Cast Button',
  );
}

class _CastIconState extends State<CastIcon> with TickerProviderStateMixin {
  CastState _castState = CastState.unavailable;

  CastState get castState => _castState;

  @override
  void initState() {
    super.initState();

    FlutterCastFramework.castContext.state.addListener(_onCastStateChanged);
  }

  void _onCastStateChanged() {
    setState(() {
      _castState = FlutterCastFramework.castContext.state.value;
    });
  }

  Widget _getEmpty() => Container();

  Widget _getAnimatedButton() => _ConnectingIcon();

  @override
  Widget build(BuildContext context) {
    switch (_castState) {
      case CastState.unavailable:
        return _getEmpty();

      case CastState.unconnected:
        return _getButton("assets/ic_cast_24dp.svg");

      case CastState.connecting:
        return _getAnimatedButton();

      case CastState.connected:
        return _getButton("assets/ic_cast_connected_24dp.svg");

      case CastState.idle:
      default:
        debugPrint("State not handled: $_castState");
        return _getEmpty();
    }
  }
}

class _ConnectingIcon extends StatefulWidget {
  @override
  _ConnectingIconState createState() => _ConnectingIconState();
}

class _ConnectingIconState extends State<_ConnectingIcon> {
  static final List<String> _connectingAnimationFrames = [
    "assets/ic_cast0_24dp.svg",
    "assets/ic_cast1_24dp.svg",
    "assets/ic_cast2_24dp.svg",
  ];

  int _frameIndex = 0;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  _start() {
    if (!this.mounted) return;

    setState(() {
      _frameIndex = 0;
      isAnimating = true;
    });
  }

  _nextFrame() async {
    if (!mounted) return;

    if (_frameIndex < _connectingAnimationFrames.length - 1) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _frameIndex += 1;
      });
    } else {
      // When I reach the end, I re-start from the beginning
      await Future.delayed(const Duration(seconds: 1));
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    String frame;
    if (_frameIndex < _connectingAnimationFrames.length) {
      frame = _connectingAnimationFrames[_frameIndex];
    } else {
      // FIXME: sometimes this number is over the length
      debugPrint("_ConnectingIconState: FrameIndex overflow");
      frame = _connectingAnimationFrames.last;
    }

    if (isAnimating) {
      _nextFrame();
    }

    return _getButton(frame);
  }
}