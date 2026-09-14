import 'package:bocom/config/app_config.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/pages/component/password_keyboard_sheet.dart';
import '../../account_asset/bank_detail_dialog.dart';

import 'account_all_logic.dart';
import 'account_all_state.dart';

class AccountAllPage extends BaseStateless {
  AccountAllPage({super.key}) : super(title: '全部账户');

  final AccountAllLogic logic = Get.put(AccountAllLogic());
  final AccountAllState state = Get.find<AccountAllLogic>().state;

  @override
  Color? get navColor => const Color(0xffFFFFFF);

  @override
  List<Widget>? get rightAction => [];

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
              image: 'bg_account_all'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(425),
                left: position.getX(400),
                child: BaseText(
                  text: AppConfig.config.abcLogic.memberInfo.openTime
                      .replaceAll('-', '.'),
                  fontSize: 15,
                  color: const Color(0xFF777777),
                )),
            Positioned(
                top: position.getY(510),
                left: position.getX(198),
                child: BaseText(
                  text: AppConfig.config.abcLogic.card2(),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.black,
                )),
            Positioned(
                top: position.getY(490),
                right: position.getX(260),
                child: Container(
                  width: position.getWidth(200),
                  height: position.getHeight(80),
                ).withOnTap(
                    onTap: () => PasswordKeyboardSheet.show(
                          context,
                          onCompleted: () async {
                            await BankDetailDialog.show(context);
                          },
                        ))),
          ],
        ),
      ],
    );
  }
}
