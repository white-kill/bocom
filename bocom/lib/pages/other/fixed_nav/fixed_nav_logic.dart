import 'package:get/get.dart';

import 'fixed_nav_state.dart';

class FixedNavLogic extends GetxController {
  final FixedNavState state = FixedNavState();

  @override
  void onInit() {
    super.onInit();
    state.assetsImagePath = Get.arguments?['image']??'';
    state.assetsImagePathList = Get.arguments?['imageList']??[];
  }
}
