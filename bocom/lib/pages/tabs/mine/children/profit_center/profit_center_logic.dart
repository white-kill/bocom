import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'profit_center_state.dart';

class ProfitCenterLogic extends GetxController {
  final ProfitCenterState state = ProfitCenterState();

  var navActionColor = Colors.white.obs;
  var navActionFlag = false.obs;
  var nowDate = "".obs;
  final RxBool amountVisible = true.obs;

  void toggleAmountVisible() {
    amountVisible.value = !amountVisible.value;
  }

  @override
  void onInit(){
    super.onInit();
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy年MM月dd日 hh:mm:ss');
    nowDate = formatter.format(now).obs;
  }
}
