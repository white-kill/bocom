import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'mine_pay_logic.dart';
import 'mine_pay_state.dart';

class MinePayPage extends BaseStateless {
  MinePayPage({super.key}) : super(title: '我的支付');

  final MinePayLogic logic = Get.put(MinePayLogic());
  final MinePayState state = Get.find<MinePayLogic>().state;

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
  List<Widget>? get rightAction => [];

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
              image: 'bg_mine_pay'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ],
    );
  }
}
