import 'package:get/get.dart';

import 'life_state.dart';

class LifeLogic extends GetxController {
  final LifeState state = LifeState();

  final isNavDark = false.obs;

  void setNavDark(bool value) {
    isNavDark.value = value;
  }
}
