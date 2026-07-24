import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import '../../../component/right_widget.dart';
import 'account_print_logic.dart';
import 'account_print_state.dart';

class AccountPrintPage extends BaseStateless {
  AccountPrintPage({Key? key}) : super(key: key,title: '账户明细打印');

  final Account_printLogic logic = Get.put(Account_printLogic());
  final Account_printState state = Get.find<Account_printLogic>().state;


  @override
  bool get isChangeNav => true;

  @override
  Color? get titleColor => Colors.black;


  @override
  Widget initBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            Image(image: 'zhmxdy'.png3x),
            Positioned(top: 238.w,child: Column(
              children: [
                // Container().expanded(onTap: ()=>Get.to(() => PrintPage())),
                // Container().expanded(onTap: ()=>Get.to(() => ApplyRecordPage()))
              ],
            ).withContainer(
              width: 1.sw,
              height: 120.w,
            ))
          ],
        )
      ],
    );
  }
}
