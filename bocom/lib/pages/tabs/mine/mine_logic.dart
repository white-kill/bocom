import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mine_state.dart';

class MineLogic extends GetxController {
  final MineState state = MineState();

  var navActionColor = Colors.white.obs;

  final PageController funcPageController = PageController(
    viewportFraction: 1 / 5,
  );
  final RxDouble funcScrollProgress = 0.0.obs;

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
