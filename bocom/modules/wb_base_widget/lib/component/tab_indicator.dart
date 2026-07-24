import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabIndicator extends Decoration {
  final double indWidth;
  final double indHeight;
  final double? indPadding;
  final Color? color;
  final double radius;

  const TabIndicator({
    this.indWidth = 30.0,
    this.indHeight = 2.0,
    this.radius = 1,
    this.color,
    this.indPadding = 0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomBoxPainter(
      this,
      onChanged,
      indWidth,
      indHeight,
      radius,
      color,
      indPadding,
    );
  }
}

class _CustomBoxPainter extends BoxPainter {
  final TabIndicator decoration;
  final double indWidth;
  final double indHeight;
  final double radius;
  final Color? color;
  final double? indPadding;

  _CustomBoxPainter(
      this.decoration,
      VoidCallback? onChanged,
      this.indWidth,
      this.indHeight,
      this.radius,
      this.color,
      this.indPadding,
      ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size!;
    final newOffset = Offset(offset.dx + (size.width - indWidth - (indPadding??0)) / 2,
        size.height - indHeight.h - 2.w);
    final Rect rect = newOffset & Size(indWidth, indHeight);
    final Paint paint = Paint();
    paint.color = color ?? Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius.w)), // 圆角半径
      paint,
    );
  }
}
