import 'package:bocom/config/app_config.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import './account_manage_two_view.dart';
import './account_all/account_all_view.dart';

import 'account_manage_logic.dart';
import 'account_manage_state.dart';

class AccountManagePage extends BaseStateless {
  AccountManagePage({super.key}) : super(title: '账户管理');

  final AccountManageLogic logic = Get.put(AccountManageLogic());
  final AccountManageState state = Get.find<AccountManageLogic>().state;

  @override
  Color? get navColor => const Color(0xffFFFFFF);

  @override
  List<Widget>? get rightAction => [];

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 1080, designHeight: 2168, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_account_manage1'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ).withOnTap(onTap: (){
              Get.to(() => AccountManageTwoPage());
            }),
            Positioned(
              top: position.getY(280),
              left: position.getX(195),
              child: BaseText(
                text: AppConfig.config.abcLogic.card2(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 19.sp,
                  letterSpacing: 1.3, // 增加字间距
                ),
              )
            ),
            Positioned(
              top: position.getY(580),
              right: position.getX(250),
              width: position.getWidth(300),
              height: position.getHeight(100),
              child: Container().withOnTap(onTap: (){
                // 跳转全部账户页面
                Get.to(() => AccountAllPage());
              })
            )
          ],
        ),
      ],
    );
  }
}
