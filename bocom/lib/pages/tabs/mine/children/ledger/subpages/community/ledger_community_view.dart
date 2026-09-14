import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 帖子内容使用完整长图，导航独立覆盖在图片上方。
class LedgerCommunityPage extends StatelessWidget {
  LedgerCommunityPage({super.key});

  final RxDouble _scrollOffset = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            bottom: MediaQuery.paddingOf(context).bottom,
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (notification.depth == 0 &&
                    notification.metrics.axis == Axis.vertical) {
                  _scrollOffset.value = notification.metrics.pixels;
                }
                return false;
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Image.asset(
                  'assets/images/bg_fanfan_zhangben@3x.png',
                  width: MediaQuery.sizeOf(context).width,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Obx(() {
              final opacity = (_scrollOffset.value / 100.w).clamp(0.0, 1.0).toDouble();
              final iconProgress = ((opacity - .5) * 2).clamp(0.0, 1.0).toDouble();
              final iconColor = Color.lerp(Colors.white, const Color(0xFF222222), iconProgress)!;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: (opacity > .2 ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light).copyWith(
                  statusBarColor: Colors.transparent,
                  systemStatusBarContrastEnforced: false,
                ),
                child: Container(
                  height: statusBarHeight + 44.w,
                  padding: EdgeInsets.only(top: statusBarHeight, left: 15.w, right: 15.w),
                  color: Colors.white.withValues(alpha: opacity),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _navButton(
                        label: '返回',
                        opacity: opacity,
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 22.w),
                      ),
                      _navButton(
                        label: '分享',
                        opacity: opacity,
                        child: CustomPaint(size: Size(23.w, 23.w), painter: _ShareIconPainter(iconColor)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _navButton({required String label, required double opacity, required Widget child, VoidCallback? onTap}) =>
      Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 32.w,
            height: 44.w,
            child: Center(
              child: Container(
                width: 30.w,
                height: 30.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .12 * (1 - opacity)),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
}

/// 与参考图一致的方框右上分享箭头。
class _ShareIconPainter extends CustomPainter {
  const _ShareIconPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()
      ..moveTo(11, 4)
      ..lineTo(6, 4)
      ..quadraticBezierTo(3, 4, 3, 7)
      ..lineTo(3, 19)
      ..quadraticBezierTo(3, 21, 6, 21)
      ..lineTo(18, 21)
      ..quadraticBezierTo(21, 21, 21, 18)
      ..lineTo(21, 13), paint);
    canvas.drawPath(Path()..moveTo(10, 14)..lineTo(21, 3)..moveTo(14, 3)..lineTo(21, 3)..lineTo(21, 10), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShareIconPainter oldDelegate) => oldDelegate.color != color;
}
