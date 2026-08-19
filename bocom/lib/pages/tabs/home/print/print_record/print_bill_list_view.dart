import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import 'print_bill_list_logic.dart';
import 'print_bill_list_state.dart';

// 社区页
// 说明：当前页面使用不含导航栏和分类栏的推荐内容切图，顶部导航与横向分类栏由 Flutter 单独绘制。
class PrintBillListPage extends BaseStateless {
  PrintBillListPage({Key? key}) : super(key: key, title: "开立交易明细");

  final PrintBillListLogic logic = Get.put(PrintBillListLogic());
  final PrintBillListState state = Get.find<PrintBillListLogic>().state;

  @override
  Color? get navColor => Color(0xffEFEFEF);

  @override
  List<Widget>? get rightAction => const [];

  @override
  Widget initBody(BuildContext context) {

    return Container();
  }
}
