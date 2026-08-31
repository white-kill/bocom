import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_info_manage_logic.dart';
import 'user_info_manage_state.dart';
import 'user_base_info/user_base_info_view.dart';
import 'user_idcard_info/user_idcard_info_view.dart';
import 'user_phone_info/user_phone_info_view.dart';
import 'user_taxation_info/user_taxation_info_view.dart';
import 'user_invest_info/user_invest_info_view.dart';
import 'user_job_info/user_job_info_view.dart';

class UserInfoManagePage extends BaseStateless {
  UserInfoManagePage({super.key}) : super(title: '个人信息管理');

  final UserInfoManageLogic logic = Get.put(UserInfoManageLogic());
  final UserInfoManageState state = Get.find<UserInfoManageLogic>().state;

  @override
  Color? get navColor => const Color(0xffF5F5F5);

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
        StackPosition(designWidth: 1080, designHeight: 2164, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_mine_info_manage'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              left: position.getX(80),
              top: position.getY(65),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  key: const Key('user-info-manage-name'),
                  text: logic.realName(),
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            Positioned(
              left: position.getX(80),
              top: position.getY(170),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  key: const Key('user-info-manage-id-card'),
                  text: UserInfoManageLogic.maskIdCard(
                    logic.memberInfo.idCard,
                  ),
                  fontSize: 16,
                  color: const Color(0xFF555555),
                ),
              ),
            ),
            Positioned(
              right: position.getX(120),
              top: position.getY(510),
              child: const BaseText(
                text: '已实名',
                fontSize: 13,
                color: Color(0xFF777777),
              ),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(360),
              height: position.getHeight(120),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                Get.to(() => UserBaseInfoPage());
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(480),
              height: position.getHeight(120),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                Get.to(() => UserIdcardInfoPage());
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(600),
              height: position.getHeight(120),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                Get.to(() => UserPhoneInfoPage());
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(720),
              height: position.getHeight(120),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                Get.to(() => UserJobInfoPage());
              }),
            ),

            Positioned(
              right: position.getX(0),
              top: position.getY(880),
              height: position.getHeight(120),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                Get.to(() => UserInvestInfoPage());
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(1000),
              height: position.getHeight(120),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                Get.to(() => UserTaxationInfoPage());
              }),
            ),
          ],
        ),
      ],
    );
  }
}
