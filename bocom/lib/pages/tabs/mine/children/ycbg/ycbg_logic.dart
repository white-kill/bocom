import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'ycbg_state.dart';

class YcbgLogic extends GetxController {
  final YcbgState state = YcbgState();

  var navActionColor = Color(0xffF5F5F5).obs;
  var navActionFlag = false.obs;

  @override
  void onInit() {
    super.onInit();
  }
}
