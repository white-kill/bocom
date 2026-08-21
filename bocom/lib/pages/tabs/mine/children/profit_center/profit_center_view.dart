import 'dart:math' as math;
import 'package:bocom/config/app_config.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'profit_center_logic.dart';
import 'profit_center_state.dart';
import '../comprehensive_bill/comprehensive_bill_view.dart';
import '../ledger/ledger_view.dart';

class ProfitCenterPage extends BaseStateless {
  ProfitCenterPage({super.key}) : super(title: '');

  final ProfitCenterLogic logic = Get.put(ProfitCenterLogic());
  final ProfitCenterState state = Get.find<ProfitCenterLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 56.w;

  @override
  Widget? get titleWidget => Obx(() => BaseText(
    text: '收益中心',
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: logic.navActionColor.value,
  ));

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          Obx(
            () => SizedBox(
              width: 26.w,
              height: 26.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_back_white'.png,
                        height: 15.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: 'nav_back_light'.png,
                        width: 26.w,
                        height: 26.w,
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
              width: 27.w,
              height: 27.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_kf_white'.png,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: 'nav_kf_light'.png,
                        width: 27.w,
                        height: 27.w,
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
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 1789, deviceWidth: 1.sw);
    StackPosition position2 =
        StackPosition(designWidth: 1080, designHeight: 1481, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          key: const Key('profit-center-status-bar-gradient-spacer'),
          width: 1.sw,
          height: statusBarHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF267CF0),
                Color(0xFF277AF1),
                Color(0xFF2C79EF),
                Color(0xFF277AF1),
                Color(0xFF287BF2),
                Color(0xFF2A7CF3),
                Color(0xFF2479F2),
                Color(0xFF2C7DF7),
                Color(0xFF317EF4),
                Color(0xFF367DF4),
                Color(0xFF4680F7),
                Color(0xFF4F7FF8),
                Color(0xFF4C81FA),
              ],
              stops: [
                0,
                0.0833,
                0.1667,
                0.25,
                0.3333,
                0.4167,
                0.5,
                0.5833,
                0.6667,
                0.75,
                0.8333,
                0.9167,
                1,
              ],
            ),
          ),
        ),
        Stack(
          children: [
            Image(
              image: 'bg_profit_center_1'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              left: position1.getX(200),
              top: position1.getY(180),
              child: Obx(
                () => Row(
                  children: [
                    BaseText(
                      text: logic.amountVisible.value
                          ? AppConfig.config.abcLogic.memberInfo.accountBalance
                          .bankBalance
                          : '****',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w,),
                    Image(image: 'ic_amount_right'.png, width: 5.w, fit: BoxFit.fitWidth,),
                  ],
                ),
              ),
            ),
            Positioned(
              left: position1.getX(55),
              top: position1.getY(250),
              child: BaseText(
                text:
                '${AppConfig.config.abcLogic.memberInfo.realName}交行资产更新至${logic.nowDate.value}',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: const Color(0xFFADCBFF),
              ),
            ),
            Positioned(
              right: position1.getX(0),
              top: position1.getY(180),
              child: SizedBox(
                width: 40.w,
                height: position1.getHeight(100),
              ).withOnTap(onTap: (){
                logic.amountVisible.value = !logic.amountVisible.value;
              }),
            ),
            Positioned(
              left: position1.getX(60),
              top: position1.getY(650),
              child: Row(
                children: [
                  Container().withOnTap(onTap: (){
                    Get.to(
                      () => ComprehensiveBillPage(initialBillType: 2),
                    );
                  }).expanded(),
                  Container().withOnTap(onTap: (){
                    Get.to(
                      () => LedgerPage(initialLedgerType: 1),
                    );
                  }).expanded(),
                  Container().withOnTap(onTap: (){
                    Get.to(
                      () => ComprehensiveBillPage(initialBillType: 1),
                    );
                  }).expanded(),
                  Container().expanded(),
                ],
              ).withContainer(width: 1.sw - position1.getX(120), height: position1.getHeight(170))
            ),
          ],
        ),
        Stack(
          children: [
            Image(
              image: 'bg_profit_center_2'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ],
    );
  }
}
