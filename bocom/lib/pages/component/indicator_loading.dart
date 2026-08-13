import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 全局遮罩 loading。
///
/// [run] 用于包裹异步任务，[show] 用于固定时长展示；两者都保留转账页
/// 使用的图片旋转样式以及自定义对齐方式。
class BocomLoading {
  BocomLoading._();

  static const _asset =
      'assets/images/account_transfer/transfer_loading_arc.png';

  static const Duration _duration = Duration(seconds: 2);


  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() action, {
    Alignment alignment = Alignment.center,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (_) => _TransferLoadingOverlay(alignment: alignment),
    );
    overlay.insert(entry);
    try {
      return await action();
    } finally {
      entry.remove();
      entry.dispose();
    }
  }

  static Future<void> show(BuildContext context) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(builder: (_) => const _BocomLoadingOverlay());
    overlay.insert(entry);

    try {
      await Future<void>.delayed(_duration);
    } finally {
      entry.remove();
      entry.dispose();
    }
  }
}

class _TransferLoadingOverlay extends StatelessWidget {
  const _TransferLoadingOverlay({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(dismissible: false, color: Colors.transparent),
        Align(alignment: alignment, child: const _TransferLoadingIndicator()),
      ],
    );
  }
}

class _TransferLoadingIndicator extends StatefulWidget {
  const _TransferLoadingIndicator();

  @override
  State<_TransferLoadingIndicator> createState() =>
      _TransferLoadingIndicatorState();
}

class _TransferLoadingIndicatorState extends State<_TransferLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '加载中',
      child: RotationTransition(
        key: const Key('transfer-loading-indicator'),
        turns: _controller,
        child: Image.asset(
          BocomLoading._asset,
          width: 34,
          height: 34,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _BocomLoadingOverlay extends StatelessWidget {
  const _BocomLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(dismissible: false, color: Colors.transparent),
        Center(child: BocomArcLoadingIndicator()),
      ],
    );
  }
}

/// 可直接嵌入页面的圆弧 loading，供下拉刷新等小尺寸场景使用。
class BocomArcLoadingIndicator extends StatefulWidget {
  const BocomArcLoadingIndicator({
    super.key,
    this.dimension = 22,
    this.color = const Color(0xFF606060),
    this.strokeWidth = 2.8,
  });

  final double dimension;
  final Color color;
  final double strokeWidth;

  @override
  State<BocomArcLoadingIndicator> createState() =>
      _BocomArcLoadingIndicatorState();
}

class _BocomArcLoadingIndicatorState extends State<BocomArcLoadingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _sweepController;
  late final Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _sweepAnimation = Tween<double>(
      begin: math.pi / 2,
      end: math.pi * 3 / 2,
    ).animate(
      CurvedAnimation(
        parent: _sweepController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '加载中',
      child: SizedBox.square(
        dimension: widget.dimension,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _rotationController,
            _sweepAnimation,
          ]),
          builder: (context, child) => CustomPaint(
            painter: _ArcLoadingPainter(
              rotation: _rotationController.value,
              sweepAngle: _sweepAnimation.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcLoadingPainter extends CustomPainter {
  const _ArcLoadingPainter({
    required this.rotation,
    required this.sweepAngle,
    required this.color,
    required this.strokeWidth,
  });

  final double rotation;
  final double sweepAngle;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final arcRect = (Offset.zero & size).deflate(strokeWidth / 2);
    const minimumSweepAngle = math.pi / 2;
    final sweepCompensation = (minimumSweepAngle - sweepAngle) / 2;
    final startAngle =
        -math.pi / 2 + rotation * math.pi * 2 + sweepCompensation;

    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcLoadingPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.sweepAngle != sweepAngle ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
