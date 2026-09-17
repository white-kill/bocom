import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'jijin_state.dart';

class JijinLogic extends GetxController {
  final JijinState state = JijinState();

  var navActionColor = Color(0xffF5F5F5).obs;
  var navActionFlag = false.obs;

  @override
  void onInit(){
    super.onInit();
  }
}
