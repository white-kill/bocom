import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'account_huoqi_yue_logic.dart';
import 'account_huoqi_yue_state.dart';

class AccountHuoQiYuEPage extends BaseStateless {
  AccountHuoQiYuEPage({super.key}) : super(title: '活期余额');

  final AccountHuoQiYuELogic logic = Get.put(AccountHuoQiYuELogic());
  final AccountHuoQiYuEState state = Get.find<AccountHuoQiYuELogic>().state;

  @override
  Color? get navColor => const Color(0xffffffff);

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
              image: 'bg_account_hqye'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(90),
                right: position.getX(90),
                child: BaseText(
                  text: AppConfig.config.abcLogic.memberInfo.accountBalance.bankBalance,
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                )
            ),
            Positioned(
                top: position.getY(235),
                right: position.getX(130),
                child: BaseText(
                  text: AppConfig.config.abcLogic.memberInfo.accountBalance.bankBalance,
                  fontSize: 15,
                  color: Colors.black,
                )
            ),
            Positioned(
                top: position.getY(233),
                left: position.getX(258),
                child: BaseText(
                  text: AppConfig.config.abcLogic.cardFour(),
                  color: Colors.black,
                  fontSize: 15,
                )
            ),
            Positioned(
                top: position.getY(440),
                right: position.getX(90),
                child: const BaseText(
                  text: '0.00',
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                )
            ),
          ],
        ),
      ],
    );
  }
}
