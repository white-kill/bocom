import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_phone_info_logic.dart';
import 'user_phone_info_state.dart';

class UserPhoneInfoPage extends BaseStateless {
  UserPhoneInfoPage({super.key}) : super(title: '手机号管理');

  final UserPhoneInfoLogic logic = Get.put(UserPhoneInfoLogic());
  final UserPhoneInfoState state = Get.find<UserPhoneInfoLogic>().state;

  @override
  Color? get navColor => const Color(0xfff5f5f5);

  @override
  Widget? get leftItem => Row(
    children: [
      SizedBox(
        width: 15.w,
      ),
      SizedBox(
        width: 30.w,
        height: 30.w,
        child: Center(
          child: Image(
            image: 'nav_back_light_white'.png,
            width: 29.5.w,
            height: 29.5.w,
            fit: BoxFit.contain,
          ),
        ),
      ).withOnTap(onTap: () => Get.back()),
    ],
  );

  @override
  List<Widget>? get rightAction => [
    Semantics(
      button: true,
      label: '客服',
      child: SizedBox(
        width: 30.w,
        height: 30.w,
        child: Center(
          child: Image(
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
    SizedBox(
      width: 15.w,
    )
  ];

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
            Positioned(
              right: position.getX(130),
              top: position.getY(80),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  text: logic.phone(),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF999999),
                ),
              ),
            ),
            Positioned(
              right: position.getX(130),
              top: position.getY(210),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  text: logic.phone(),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF999999),
                ),
              ),
            ),
            Positioned(
              right: position.getX(130),
              top: position.getY(330),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  text: logic.phone(),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF999999),
                ),
              ),
            ),
            Positioned(
              left: position.getX(90),
              top: position.getY(610),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  text: 'I类账户(${logic.cardFour()})',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}