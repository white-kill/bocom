import 'package:bocom/utils/scale_point_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import '../routes/app_pages.dart';

class CommWidgetUtils {
  /// 单页面更多按钮
  static Widget getMoreIcon({Color? icColor}) {
    return ScalePointWidget(
      left: 112.w,
      dx: 48.w,
      dy: -6.w,
      width: 132.w,
      image: 'ic_nav_more',
      icSize: 18,
      icColor: icColor ?? const Color(0xFF5B6A80),
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7.w),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 44.w,
              alignment: Alignment.center,
              child: BaseText(
                text: '首页',
                fontSize: 13.w,
                color: Colors.black,
              ),
            ).withOnTap(onTap: () {
              Get.offAllNamed(Routes.tabs);
            }),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              color: const Color(0x225B6A80),
              height: 1,
              width: double.infinity,
            ),
            Container(
              width: double.infinity,
              height: 44.w,
              alignment: Alignment.center,
              child: BaseText(
                text: '扫一扫',
                fontSize: 13.w,
                color: Colors.black,
              ),
            ).withOnTap(onTap: () {
              Get.toNamed(Routes.scan);
            }),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              color: const Color(0x225B6A80),
              height: 1,
              width: double.infinity,
            ),
            Container(
              width: double.infinity,
              height: 44.w,
              alignment: Alignment.center,
              child: BaseText(
                text: '退出',
                fontSize: 13.w,
                color: Colors.black,
              ),
            ).withOnTap(onTap: () {
              // TODO 退出登录
            }),
          ],
        ),
      ),
    ).withPadding(right: 20.w);
  }
}
