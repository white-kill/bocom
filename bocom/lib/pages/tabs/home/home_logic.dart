import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  final isNavDark = false.obs;

  bool _isPulling = false;
  bool _isTwoLevelOpen = false;

  void setNavDark(bool value) {
    isNavDark.value = value;
  }

  void setPulling(bool value) {
    if (_isPulling == value) return;
    _isPulling = value;
    state.appBarController.changeTabTitle(!value && !_isTwoLevelOpen);
  }

  void setTwoLevelOpen(bool value) {
    _isTwoLevelOpen = value;
    if (value) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      state.appBarController.changeTabTitle(false);
      return;
    }

    SystemChrome.setSystemUIOverlayStyle(
      isNavDark.value ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );

    Future<void>.delayed(const Duration(milliseconds: 560), () {
      if (!_isPulling && !_isTwoLevelOpen) {
        state.appBarController.changeTabTitle(true);
      }
    });
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
