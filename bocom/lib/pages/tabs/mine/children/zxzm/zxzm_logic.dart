import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'zxzm_state.dart';

class ZxzmLogic extends GetxController {
  final ZxzmState state = ZxzmState();

  var navActionColor = Color(0xffF5F5F5).obs;
  var navActionFlag = false.obs;

  @override
  void onInit() {
    super.onInit();
  }
}
