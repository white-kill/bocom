import 'package:flutter/material.dart';
import 'dart:async';

/// 封装长按五秒功能的高阶组件
///
/// 参数：
///   - child: 需要添加长按功能的子组件
///   - onLongPressCompleted: 长按五秒完成后执行的回调
///   - duration: 长按持续时间，默认5秒
///   - feedbackBuilder: 可选，构建按压时的反馈UI
///   - onPressedChange: 可选，按压状态变化回调
class LongPressFiveSeconds extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPressCompleted;
  final Duration duration;
  final Widget Function(BuildContext context, double progress)? feedbackBuilder;
  final ValueChanged<bool>? onPressedChange;

  const LongPressFiveSeconds({
    Key? key,
    required this.child,
    required this.onLongPressCompleted,
    this.duration = const Duration(seconds:2),
    this.feedbackBuilder,
    this.onPressedChange,
  }) : super(key: key);

  @override
  _LongPressFiveSecondsState createState() => _LongPressFiveSecondsState();
}

class _LongPressFiveSecondsState extends State<LongPressFiveSeconds>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Timer? _timer;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _cancelTimer();
    super.dispose();
  }

  void _startTimer() {
    _cancelTimer(); // 确保没有正在运行的计时器

    setState(() {
      _isPressed = true;
      widget.onPressedChange?.call(true);
    });

    _controller?.forward();

    _timer = Timer(widget.duration, () {
      if (_isPressed) { // 确保仍然处于按压状态
        _onLongPressCompleted();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    if (_isPressed) {
      setState(() {
        _isPressed = false;
        widget.onPressedChange?.call(false);
      });
    }
    _controller = null;
    // _controller?.reset();
  }

  void _onLongPressCompleted() {
    widget.onLongPressCompleted();
    _cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) => _startTimer(),
      onPanEnd: (_) => _cancelTimer(),
      onPanCancel: () => _cancelTimer(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_isPressed && widget.feedbackBuilder != null)
            Positioned.fill(
              child: widget.feedbackBuilder!(context, _controller?.value??0),
            ),
        ],
      ),
    );
  }
}