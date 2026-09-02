import 'dart:math' as math;
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'jjkjf_logic.dart';
import 'jjkjf_state.dart';

class JjkjfPage extends BaseStateless {
  JjkjfPage({super.key}) : super(title: '借记卡积分');

  final JjkjfLogic logic = Get.put(JjkjfLogic());
  final JjkjfState state = Get.find<JjkjfLogic>().state;

  // @override
  // Color? get navColor => const Color(0xffF5F5F5);

  @override
  Color? get titleColor => const Color(0xff181818);

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 56.w;

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          Obx(
            () => SizedBox(
              width: 30.w,
              height: 30.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_back_white'.png,
                        height: 15.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: 'nav_back_light_white'.png,
                        width: 29.5.w,
                        height: 29.5.w,
                        fit: BoxFit.contain,
                      ),
              ),
            ).withOnTap(onTap: () => Get.back()),
          ),
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Obx(
          () => Semantics(
            button: true,
            label: '客服',
            child: SizedBox(
              width: 30.w,
              height: 30.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_kf_white'.png,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: 'nav_kf_light_white'.png,
                        width: 29.w,
                        height: 29.w,
                        fit: BoxFit.contain,
                      ),
              ),
            ).withOnTap(
              onTap: () => Get.toNamed(Routes.customerService),
            ),
          ),
        ),
        SizedBox(
          width: 15.w,
        )
      ];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionFlag.value = v;
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 825, designHeight: 4096, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_mine_jjkjf'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                left: position.getX(50),
                top: position.getY(300),
                child: BaseText(
                        text: '${AppConfig.config.abcLogic.memberInfo.points}',
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: const StrutStyle(fontSize: 26, height: 1),
                        color: const Color(0xFF181818),
                      )
            ),
          ],
        ),
      ],
    );
  }
}
