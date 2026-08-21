import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'account_diushi_logic.dart';
import 'account_diushi_state.dart';

class AccountDiushiPage extends BaseStateless {
  AccountDiushiPage({super.key}) : super(title: '银行卡挂失');

  final AccountDiushiLogic logic = Get.put(AccountDiushiLogic());
  final AccountDiushiState state = Get.find<AccountDiushiLogic>().state;

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
              image: 'bg_account_diushi'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(165),
                right: position.getX(60),
                child: BaseText(
                  text: AppConfig.config.abcLogic.card2(),
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
