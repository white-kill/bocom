import 'dart:math' as math;

import 'package:bocom/config/app_config.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bocom/pages/other/fixed_nav/fixed_nav_view.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/pages/component/password_keyboard_sheet.dart';

import 'setting_logic.dart';
import 'setting_state.dart';

class SettingPage extends BaseStateless {
  SettingPage({super.key}) : super(title: '设置');

  final SettingLogic logic = Get.put(SettingLogic());
  final SettingState state = Get.find<SettingLogic>().state;

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
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 1080, designHeight: 2172, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_phone_manage'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ],
    );
  }
}