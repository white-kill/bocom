import 'dart:math';

import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import 'print_logic.dart';
import 'print_state.dart';
import 'print_bill_list/print_bill_list_view.dart';
import 'print_record/print_record_view.dart';

// 社区页
// 说明：当前页面使用不含导航栏和分类栏的推荐内容切图，顶部导航与横向分类栏由 Flutter 单独绘制。
class PrintPage extends BaseStateless {
  PrintPage({Key? key}) : super(key: key, title: "交易明细清单");

  final PrintLogic logic = Get.put(PrintLogic());
  final PrintState state = Get.find<PrintLogic>().state;

  @override
  Color? get navColor => Color(0xffFFFFFF);

  @override
  List<Widget>? get rightAction => const [];

  @override
  Widget initBody(BuildContext context) {
    StackPosition stackPosition =
        StackPosition(designWidth: 1080, designHeight: 2168, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_print'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            // Image(image: 'bg_print_1'.png3x, width: 1.sw, fit: BoxFit.fitWidth,),
            Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: 1.sw,
                  height: stackPosition.getHeight(400),
                ).withOnTap(onTap: () {
                  Get.to(() => PrintBillListPage());
                })),
            Positioned(
                left: 0,
                top: stackPosition.getY(410),
                child: SizedBox(
                  width: 1.sw,
                  height: stackPosition.getHeight(400),
                ).withOnTap(onTap: () {
                  Get.to(() => PrintBillListPage());
                })),
            Positioned(
                left: 0,
                top: stackPosition.getY(840),
                width: 1.sw,
                height: stackPosition.getHeight(130),
                child: Row(
                  children: [
                    // 申请记录
                    Container().withOnTap(onTap: () {
                      Get.to(() => PrintRecordPage());
                    }).expanded(),
                    // 查看样例
                    Container().withOnTap(onTap: () {
                      logic.showIndex.value = 1;
                    }).expanded(),
                  ],
                )),
            Obx(() {
              if (logic.showIndex.value == 1)
                return Positioned.fill(
                  child: Stack(
                    children: [
                      Image(
                        image: 'bg_print_1'.png3x,
                        width: 1.sw,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned.fill(child: Column(
                        children: [
                          Container().withOnTap(onTap: () {
                            logic.showIndex.value = 0;
                          }).expanded(),
                          Container(height: 50.w).withOnTap(onTap: (){
                            logic.showIndex.value = 2;
                          })
                        ],
                      ))
                    ],
                  ),
                );
              if (logic.showIndex.value == 2)
                return Positioned.fill(
                  child: Stack(
                    children: [
                      Image(
                        image: 'bg_print_2'.png3x,
                        width: 1.sw,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned.fill(child: Column(
                        children: [
                          Container().withOnTap(onTap: () {
                            logic.showIndex.value = 0;
                          }).expanded(),
                          Container(height: 50.w).withOnTap(onTap: (){
                            logic.showIndex.value = 1;
                          })
                        ],
                      ))
                    ],
                  ),
                );
              return SizedBox.shrink();
            })
          ],
        )
      ],
    );
  }
}
