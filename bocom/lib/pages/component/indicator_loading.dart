import 'dart:math' as math;

import 'package:flutter/material.dart';

class BocomLoading {
  BocomLoading._();

  static const Duration _duration = Duration(seconds: 2);

  static Future<void> show(BuildContext context) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(builder: (_) => const _ArcLoadingOverlay());
    overlay.insert(entry);

    try {
      await Future<void>.delayed(_duration);
    } finally {
      entry.remove();
      entry.dispose();
    }
  }
}

class _ArcLoadingOverlay extends StatelessWidget {
  const _ArcLoadingOverlay();

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
          builder: (context, child) {
            return CustomPaint(
              painter: _ArcLoadingPainter(
                rotation: _rotationController.value,
                sweepAngle: _sweepAnimation.value,
                color: widget.color,
                strokeWidth: widget.strokeWidth,
              ),
            );
          },
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
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
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
  bool shouldRepaint(covariant _ArcLoadingPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
