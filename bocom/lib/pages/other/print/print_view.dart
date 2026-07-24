import 'package:bocom/pages/other/print/print_records/print_records_view.dart';
import 'package:bocom/pages/other/fixed_nav/fixed_nav_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'apply/apply_view.dart';
import 'print_logic.dart';
import 'print_state.dart';

class PrintPage extends BaseStateless {
  PrintPage({Key? key}) : super(key: key);

  final PrintLogic logic = Get.put(PrintLogic());
  final PrintState state = Get.find<PrintLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 45;

  @override
  Color? get backColor => Colors.transparent;

  @override
  Color? get background => Colors.white;

  @override
  bool get showBackgroundColor => false;

  @override
  Widget initBody(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1.sw,
          height: ScreenUtil().statusBarHeight,
          color: Colors.white,
        ),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image(image: 'print_bg'.png3x),
                Positioned(
                  left: 13.w,
                  top: 8.w,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20.w,
                  ).withContainer(
                      width: 30.w,
                      height: 30.w,
                      onTap: () {
                        Get.back();
                      }),
                ),
                Positioned(
                  top: 12.w,
                  child: BaseText(
                      text: '交易流水打印',
                      style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),

                Positioned(
                    top: 330.w,
                    child: Container(
                  width: 1.sw,
                  height: 65.w,
                ).withOnTap(onTap: (){
                      Get.to(() => ApplyPage());
                    })),

                Positioned(
                    top: 330.w+ 65.w,
                    child: Container(
                      width: 1.sw,
                      height: 65.w,
                    ).withOnTap(onTap: (){
                      Get.to(() => PrintRecordsPage());
                    })),

                Positioned(
                    top: 190.w,
                    left: 20.w,
                    child: Container(
                  width: 80.w,
                  height: 30.w,
                ).withOnTap(onTap: () {
                  Get.to(() => FixedNavPage(), arguments: {
                    'image': 'print_example',
                    'title': '样例预览',
                  });                    })),
                Positioned(
                  top: 520.w,
                  left: 0.w,
                  child: Obx(() => Image(
                    image: state.isExpanded.value ? 'print_title'.png3x : 'print_title_all'.png3x,
                    fit: BoxFit.fitWidth,
                    width: 1.sw,
                  ).withOnTap(onTap: () {
                    if (!state.isExpanded.value) {
                      state.isExpanded.value = true;
                    }
                  })),
                )
              ],
            ),

          ],
        ).expanded()
      ],
    );
  }
}
