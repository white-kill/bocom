import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import 'tips_page_state.dart';

class TipsPageLogic extends GetxController {
  final TipsPageState state = TipsPageState();

  String content = '';
  String cancel = '';
  String title = '';
  String sure = '';
  bool showCancel = true;
  Color sureColor = const Color(0xffCF0000);

  @override
  void onInit() {
    super.onInit();
    content = Get.arguments['content'] ?? '';
    title = Get.arguments['title'] ?? '温馨提示';
    cancel = Get.arguments['cancel'] ?? '取消';
    sure = Get.arguments['sure'] ?? '确定';
    showCancel = Get.arguments['showCancel'] ?? true;
    sureColor = Get.arguments['sureColor'] ?? const Color(0xffCF0000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      '\n$content\n'.dialog(
          title: title,
          cancelText: cancel,
          sureText: sure,
          showCancel: showCancel,
          sureColor: sureColor,
          onBack: (v) {
            Get.back(result: v);
          });
    });
  }
}
