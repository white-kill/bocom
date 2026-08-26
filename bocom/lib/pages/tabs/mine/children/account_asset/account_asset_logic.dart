import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'account_asset_state.dart';

class AccountAssetLogic extends GetxController {
  final AccountAssetState state = AccountAssetState();

  var navActionColor = Colors.white.obs;
  var navActionFlag = false.obs;
  final RxBool amountVisible = true.obs;
  final RxBool accountExpandVisible = true.obs;
  final RxInt bottomItemIndex = 1.obs;
  var nowDate = "".obs;

  void toggleAmountVisible() {
    amountVisible.value = !amountVisible.value;
  }

  void onBottomItemClick(int type) {
    if (type != 0 && type != 1) return;
    bottomItemIndex.value = type;
  }

  @override
  void onInit(){
    super.onInit();
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy年MM月dd日 hh:mm:ss');
    nowDate = formatter.format(now).obs;
  }
}
