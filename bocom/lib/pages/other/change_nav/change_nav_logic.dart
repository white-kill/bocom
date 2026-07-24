import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'change_nav_state.dart';

class ChangeNavLogic extends GetxController {
  var navActionColor = const Color(0xFF333333).obs;

  final ChangeNavState state = ChangeNavState();

  @override
  void onInit() {
    super.onInit();
    navActionColor.value = Get.arguments?['defTitleColor']??const Color(0xFF333333);
    state.assetsImagePath = Get.arguments?['image']??'';
    state.fullImagePath = Get.arguments?['fullImagePath']??'';
    state.assetsImagePathList = Get.arguments?['imageList']??[];

  }
}
