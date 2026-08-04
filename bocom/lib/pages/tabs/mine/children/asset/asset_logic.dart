import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'asset_state.dart';

class AssetLogic extends GetxController {
  final AssetState state = AssetState();

  var navActionColor = Colors.white.obs;
  var navActionFlag = false.obs;
  final RxBool amountVisible = true.obs;
  var nowDate = "".obs;

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
