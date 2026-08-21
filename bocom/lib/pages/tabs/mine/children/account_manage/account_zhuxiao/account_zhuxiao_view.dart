import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'account_zhuxiao_logic.dart';
import 'account_zhuxiao_state.dart';

class AccountZhuxiaoPage extends BaseStateless {
  AccountZhuxiaoPage({super.key}) : super(title: '注销银行卡');

  final AccountZhuxiaoLogic logic = Get.put(AccountZhuxiaoLogic());
  final AccountZhuxiaoState state = Get.find<AccountZhuxiaoLogic>().state;

  @override
  Color? get navColor => const Color(0xffF5F5F5);

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
              image: 'bg_account_zhuxiao'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(200),
                left: position.getX(610),
                child: BaseText(
                  text: '(**${AppConfig.config.abcLogic.cardFour()})',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    letterSpacing: 1.2, // 增加字间距
                  ),
                )
            ),
          ],
        ),
      ],
    );
  }
}
