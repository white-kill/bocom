import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'account_jiebang_logic.dart';
import 'account_jiebang_state.dart';

class AccountJiebangPage extends BaseStateless {
  AccountJiebangPage({super.key}) : super(title: '账户解绑');

  final AccountJiebangLogic logic = Get.put(AccountJiebangLogic());
  final AccountJiebangState state = Get.find<AccountJiebangLogic>().state;

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
              image: 'bg_account_jiebang'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(210),
                right: position.getX(30),
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
