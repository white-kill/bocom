import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'lc_state.dart';

class LcLogic extends GetxController {
  final LcState state = LcState();

  var navActionColor = Color(0xffF5F5F5).obs;
  var navActionFlag = false.obs;

  @override
  void onInit(){
    super.onInit();
  }
}
