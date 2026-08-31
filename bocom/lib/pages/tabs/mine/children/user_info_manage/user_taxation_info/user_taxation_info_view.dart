import 'dart:math' as math;
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bocom/pages/other/fixed_nav/fixed_nav_view.dart';
import 'package:bocom/pages/other/change_nav/change_nav_view.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_taxation_info_logic.dart';
import 'user_taxation_info_state.dart';

class UserTaxationInfoPage extends BaseStateless {
  UserTaxationInfoPage({super.key}) : super(title: '个人税务信息');

  final UserTaxationInfoLogic logic = Get.put(UserTaxationInfoLogic());
  final UserTaxationInfoState state = Get.find<UserTaxationInfoLogic>().state;

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
  List<Widget>? get rightAction => [];

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
              image: 'bg_user_‌taxation'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ],
    );
  }
}