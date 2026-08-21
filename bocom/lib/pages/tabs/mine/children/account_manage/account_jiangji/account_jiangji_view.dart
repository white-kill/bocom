import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'account_jiangji_logic.dart';
import 'account_jiangji_state.dart';

class AccountJiangjiPage extends BaseStateless {
  AccountJiangjiPage({super.key}) : super(title: '账户升降级');

  final AccountJiangjiLogic logic = Get.put(AccountJiangjiLogic());
  final AccountJiangjiState state = Get.find<AccountJiangjiLogic>().state;

  @override
  Color? get navColor => const Color(0xffFFFFFF);

  @override
  List<Widget>? get rightAction => [];

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 1178, designHeight: 2247, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_account_jiangji'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(270),
                right: position.getX(95),
                child: BaseText(
                  text: AppConfig.config.abcLogic.card2(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    letterSpacing: 1.2, // 增加字间距
                    fontWeight: FontWeight.w500,
                  ),
                )
            ),
            Positioned(
                top: position.getY(350),
                right: position.getX(95),
                child: BaseText(
                  text: '￥${AppConfig.config.abcLogic.balance()}',
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )
            ),
          ],
        ),
      ],
    );
  }
}
