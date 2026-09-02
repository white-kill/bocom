import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'jjkjf_state.dart';

class JjkjfLogic extends GetxController {
  final JjkjfState state = JjkjfState();

  var navActionColor = Color(0xffF5F5F5).obs;
  var navActionFlag = false.obs;

  @override
  void onInit() {
    super.onInit();
  }
}
