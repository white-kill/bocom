import 'dart:math' as math;
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'jijin_logic.dart';
import 'jijin_state.dart';

class JijinPage extends BaseStateless {
  JijinPage({super.key}) : super(title: '基金');

  final JijinLogic logic = Get.put(JijinLogic());
  final JijinState state = Get.find<JijinLogic>().state;

  // @override
  // Color? get navColor => const Color(0xffF5F5F5);

  @override
  Color? get titleColor => const Color(0xff181818);

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 56.w;

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          Obx(
            () => SizedBox(
              width: 30.w,
              height: 30.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_back_white'.png,
                        height: 15.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                  image: 'nav_back_light_white'.png,
                  width: 29.5.w,
                  height: 29.5.w,
                  fit: BoxFit.contain,
                ),
              ),
            ).withOnTap(onTap: () => Get.back()),
          ),
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Semantics(
          button: true,
          label: '搜索',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(Routes.search),
            child: Center(
              child: SizedBox(
                width: 26.w,
                height: 26.w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/finance_nav_search.png',
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.contain,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
    Obx(
          () => Semantics(
            button: true,
            label: '客服',
            child: SizedBox(
              width: 30.w,
              height: 30.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_kf_white'.png,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                            image: 'nav_kf_light_white'.png,
                            width: 29.w,
                            height: 29.w,
                            fit: BoxFit.contain,
                          ),
              ),
            ).withOnTap(
              onTap: () => Get.toNamed(Routes.customerService),
            ),
          ),
        ),
        SizedBox(
          width: 15.w,
        )
  ];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionFlag.value = v;
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };


  @override
  Widget initBody(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return ListView(
      padding: EdgeInsets.only(top: 44.h + statusBarHeight),
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_jijin'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ],
    );
  }
}
