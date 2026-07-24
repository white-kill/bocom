import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import '../../component/placeholder_search_widget.dart';
import '‌finance‌_logic.dart';
import '‌finance‌_state.dart';

class FinancePage extends BaseStateless {
  FinancePage({Key? key}) : super(key: key);

  final FinanceLogic logic = Get.put(FinanceLogic());
  final FinanceState state = Get.find<FinanceLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  Widget? get titleWidget => PlaceholderSearchWidget(
        width: 220.w,
        contentList: const ['账单', '优惠活动', '明细查询'],
        border: Border.all(color: Colors.grey.withOpacity(0.4), width: 0.5),
        textColor: Colors.black,
      );

  @override
  List<Widget>? get rightAction => [];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    return Container();
  }
}
