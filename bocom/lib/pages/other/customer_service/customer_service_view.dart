import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// 在线客服页
// 说明：主内容切图已包含状态栏预留区与自定义导航，页面从 y=0 绘制；底部快捷问题与输入区使用独立切图固定绘制。
class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  static const double _sourceWidth = 1080;
  static const double _bodySourceHeight = 2084;
  static const double _footerSourceHeight = 292;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF3F4F6),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('customer-service-scaffold'),
        backgroundColor: const Color(0xFFF3F4F6),
        resizeToAvoidBottomInset: false,
        body: ColoredBox(
          color: const Color(0xFFF3F4F6),
          child: LayoutBuilder(
            builder: (_, constraints) {
              final scale = constraints.maxWidth / _sourceWidth;
              final footerHeight = _footerSourceHeight * scale;
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              return Stack(
                key: const Key('customer-service-layout'),
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: _bodySourceHeight * scale,
                    child: Image.asset(
                      'assets/images/customer_service/customer_service_body.png',
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),
                  ),
                  _hotspot(
                    semanticsLabel: '视频客服功能介绍',
                    top: 775 * scale,
                    left: 80 * scale,
                    width: 920 * scale,
                    height: 110 * scale,
                  ),
                  _hotspot(
                    semanticsLabel: '如何查询借记卡交易明细',
                    top: 908 * scale,
                    left: 80 * scale,
                    width: 920 * scale,
                    height: 110 * scale,
                  ),
                  _hotspot(
                    semanticsLabel: '手机银行转账限额',
                    top: 1041 * scale,
                    left: 80 * scale,
                    width: 920 * scale,
                    height: 110 * scale,
                  ),
                  _hotspot(
                    semanticsLabel: '手机银行网银转账遇到问题',
                    top: 1173 * scale,
                    left: 80 * scale,
                    width: 920 * scale,
                    height: 110 * scale,
                  ),
                  _hotspot(
                    semanticsLabel: '投诉处理流程及投诉受理渠道',
                    top: 1305 * scale,
                    left: 80 * scale,
                    width: 920 * scale,
                    height: 110 * scale,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomInset,
                    height: footerHeight,
                    child: Image.asset(
                      'assets/images/customer_service/customer_service_footer.png',
                      key: const Key('customer-service-footer'),
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),
                  ),
                  Positioned(
                    left: 154 * scale,
                    right: 190 * scale,
                    bottom: bottomInset + 69 * scale,
                    height: 58 * scale,
                    child: IgnorePointer(
                      child: ExcludeSemantics(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '请输入您的问题',
                            maxLines: 1,
                            style: TextStyle(
                              color: const Color(0xFFD4D7DD),
                              fontSize: 43 * scale,
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 39 * scale,
                    top: 477 * scale,
                    width: 38 * scale,
                    height: 38 * scale,
                    child: const IgnorePointer(
                      child: CustomPaint(
                        painter: _GreetingCardCornerPainter(),
                      ),
                    ),
                  ),
                  Positioned(
                    key: const Key('customer-service-back'),
                    left: 39 * scale,
                    top: 113 * scale,
                    width: 73 * scale,
                    height: 73 * scale,
                    child: Semantics(
                      button: true,
                      label: '返回',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: Get.back,
                        child: Image.asset(
                          'assets/images/customer_service/customer_service_back.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 39 * scale,
                    top: 113 * scale,
                    width: 73 * scale,
                    height: 73 * scale,
                    child: Semantics(
                      button: true,
                      label: '静音',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Image.asset(
                          'assets/images/customer_service/customer_service_mute.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 34 * scale,
                    right: 34 * scale,
                    bottom: bottomInset + 20 * scale,
                    height: 145 * scale,
                    child: Semantics(
                      button: true,
                      textField: true,
                      label: '请输入您的问题',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _hotspot({
    required String semanticsLabel,
    required double top,
    required double left,
    required double width,
    required double height,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
        ),
      ),
    );
  }
}

class _GreetingCardCornerPainter extends CustomPainter {
  const _GreetingCardCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE6F2FC), Color(0xFFE9F4FC)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width * 2, size.height * 2),
        topLeft: Radius.circular(size.width),
      ),
      Paint()..color = Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GreetingCardCornerPainter oldDelegate) {
    return false;
  }
}
