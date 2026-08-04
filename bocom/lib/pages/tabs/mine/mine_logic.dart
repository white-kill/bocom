import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bocom/pages/other/change_nav/change_nav_view.dart';

import 'mine_state.dart';

class MineLogic extends GetxController {
  final MineState state = MineState();

  var navActionColor = Colors.white.obs;

  final PageController funcPageController = PageController(
    viewportFraction: 1 / 5,
  );
  final RxDouble funcScrollProgress = 0.0.obs;
  final RxBool amountVisible = true.obs;

  void toggleAmountVisible() {
    amountVisible.value = !amountVisible.value;
  }

  void onFuncTap({
    required int index,
    required String title,
  }) {
    if(index == 0) {
      Get.to(() => ChangeNavPage(), arguments: {
        'image': 'bg_personal',
        'title': '',
        'hideRightAction': true,
        'isOffset': true,
        'navColor': Colors.white,
        'changeTitleColor': Colors.transparent,
        'defTitleColor': Colors.transparent,
        'showBackgroundColor': false,
      });
    }
  }


  void updateFuncScrollProgress(ScrollMetrics metrics) {
    final maxScrollExtent = metrics.maxScrollExtent;
    if (maxScrollExtent <= 0) {
      funcScrollProgress.value = 0;
      return;
    }
    funcScrollProgress.value =
        (metrics.pixels / maxScrollExtent).clamp(0.0, 1.0);
  }

  @override
  void onClose() {
    funcPageController.dispose();
    super.onClose();
  }
}
