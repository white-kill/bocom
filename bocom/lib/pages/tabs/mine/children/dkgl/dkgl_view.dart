import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'dkgl_logic.dart';
import 'dkgl_state.dart';

class DkglPage extends BaseStateless {
  DkglPage({super.key}) : super(title: '代扣管理');

  final DkglLogic logic = Get.put(DkglLogic());
  final DkglState state = Get.find<DkglLogic>().state;

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
              image: 'bg_mine_dkgl'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(35),
                left: position.getX(260),
                right: 0,
                child: Container(
                  color: Colors.white,
                  height: position.getHeight(60),
                  child: BaseText(
                    text: "交通银行 I类账户(**${AppConfig.config.abcLogic.cardFour()})",
                    color: Colors.black,
                    fontSize: 14,
                  ),
                )
            ),
          ],
        ),
      ],
    );
  }
}
