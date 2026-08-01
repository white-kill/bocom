import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';
import 'mine_logic.dart';
import 'mine_state.dart';

class MinePage extends BaseStateless {
  MinePage({Key? key}) : super(key: key, title: '');

  final MineLogic logic = Get.put(MineLogic());
  final MineState state = Get.find<MineLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          const BaseText(
            text: '退出',
            fontSize: 16,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
            color: Color(0xFF181818),
          ).withOnTap(onTap: () {
            //退出登录
          })
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Image(
          image: 'nav_right_kf'.png,
          width: 22.w,
          height: 22.w,
        ),
        SizedBox(
          width: 15.w,
        ),
        Image(
          image: 'nav_right_set'.png,
          width: 22.w,
          height: 22.w,
        ),
        SizedBox(
          width: 15.w,
        ),
        Image(
          image: 'nav_right_msg'.png,
          width: 22.w,
          height: 22.w,
        ),
        SizedBox(
          width: 15.w,
        )
      ];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 650, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_mine_1'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                left: position1.getX(80),
                top: position1.getY(245),
                child: Image(
                  image: 'mine_user_icon'.png,
                  width: position1.getWidth(150),
                  fit: BoxFit.fitWidth,
                )
            ),
            Positioned(
                left: position1.getX(270),
                top: position1.getY(240),
                child: BaseText(
                  text: AppConfig.config.abcLogic.realName(),
                  fontSize: 20,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  color: const Color(0xFF181818),
                )
            ),
            Positioned(
                left: position1.getX(270),
                top: position1.getY(330),
                child:const BaseText(
                  text: '开启财富管理之旅',
                  fontSize: 13,
                  color: Color(0xFF878787),
                )
            ),
            // 借记卡积分
            Positioned(
                left: position1.getX(80),
                bottom: position1.getY(70),
                child: Container(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 18,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )
            ),
            Positioned(
                left: position1.getX(290),
                bottom: position1.getY(70),
                child: Container(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 18,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )
            ),
            Positioned(
                left: position1.getX(515),
                bottom: position1.getY(70),
                child: Container(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 18,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      BaseText(
                        text: '张',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(
                          fontSize: 18,
                          height: 1
                        ),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )
            ),
          ],
        )
        // Image(image: 'bg_mine_2'.png3x, width: 1.sw, fit: BoxFit.fitWidth,),
        // Image(image: 'bg_mine_3'.png3x, width: 1.sw, fit: BoxFit.fitWidth,),
      ],
    );
  }
}
