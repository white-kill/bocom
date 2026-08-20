import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import 'print_record_logic.dart';
import 'print_record_state.dart';

// 社区页
// 说明：当前页面使用不含导航栏和分类栏的推荐内容切图，顶部导航与横向分类栏由 Flutter 单独绘制。
class PrintRecordPage extends BaseStateless {
  PrintRecordPage({Key? key}) : super(key: key, title: "申请记录");

  final PrintRecordLogic logic = Get.put(PrintRecordLogic());
  final PrintRecordState state = Get.find<PrintRecordLogic>().state;

  @override
  Color? get navColor => Color(0xffEFEFEF);

  @override
  List<Widget>? get rightAction => const [];

  @override
  Widget initBody(BuildContext context) {
    return Container();
  }
}
