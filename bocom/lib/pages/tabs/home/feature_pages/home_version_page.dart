import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

// 版本切换页
// 说明：保留完整的不含导航栏的内容切图，白色导航栏由 BaseStateless 绘制。
class HomeVersionPage extends BaseStateless {
  const HomeVersionPage({super.key}) : super(title: '版本切换');

  static const _sourceWidth = 1080.0;
  static const _sourceHeight = 3063.0;

  @override
  Color get background => const Color(0xFFF7F7F7);

  @override
  Color get navColor => Colors.white;

  @override
  double get lefItemWidth => 54.w;

  @override
  Widget get leftItem => Semantics(
        button: true,
        label: '返回',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: Get.back,
          child: Center(
            child: Image.asset(
              'assets/images/nav_back_white.png',
              width: 10.w,
              height: 18.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );

  @override
  Widget initBody(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => SingleChildScrollView(
        key: const PageStorageKey('home-version-scroll'),
        physics: const ClampingScrollPhysics(),
        child: Image.asset(
          'assets/images/home_version_body.png',
          width: constraints.maxWidth,
          height: _sourceHeight * constraints.maxWidth / _sourceWidth,
          fit: BoxFit.contain,
          semanticLabel: '标准版，当前版本；关爱版；English Version；普惠版；简洁版',
        ),
      ),
    );
  }
}
