import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';

class RotatingWidget extends StatefulWidget {
  final ImageProvider image;
  final Function? disCallBack;
  final Color? color;

  const RotatingWidget({
    super.key,
    required this.image,
    this.disCallBack, this.color,
  });

  @override
  State<RotatingWidget> createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<RotatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.disCallBack?.call();
        }
      })
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // 清理资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _animation.value * 2 *pi,
      child: Image(
        image: widget.image,
        color: widget.color,
        width: 11.w,
        height: 11.w,
      ).withOnTap(onTap: () {
        _controller.forward(from: 0);
      }),
    );
  }
}
