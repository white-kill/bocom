import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';

class CopySuccessTipBanner extends StatefulWidget {
  const CopySuccessTipBanner({
    super.key,
    required this.onDismissed,
  });

  final VoidCallback onDismissed;

  @override
  State<CopySuccessTipBanner> createState() => _CopySuccessTipBannerState();
}

class _CopySuccessTipBannerState extends State<CopySuccessTipBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;
  Timer? _hideTimer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.75, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    ));
    _controller.forward();
    _hideTimer = Timer(const Duration(seconds: 2), _startDismiss);
  }

  void _startDismiss() {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: Center(
          child: Image(
            image: 'copy-success'.png3x,
            width: 131.w,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
