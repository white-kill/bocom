import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'grzy_logic.dart';
import 'grzy_state.dart';

class GrzyPage extends BaseStateless {
  GrzyPage({super.key}) : super(title: '');

  final GrzyLogic logic = Get.put(GrzyLogic());
  final GrzyState state = Get.find<GrzyLogic>().state;

  @override
  bool get isShowAppBar => false;

  @override
  Widget? get leftItem => const SizedBox.shrink();

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
              image: 'bg_personal'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ).withOnTap(onTap: () {
              Get.back();
            }),
            Positioned(
                top: position.getY(290),
                left: position.getX(240),
                child: const BaseText(
                  text: "用户3709003uWk",
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )
            ),
          ],
        ),
      ],
    );
  }
}
