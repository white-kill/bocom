import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../index/index_logic.dart';
import 'mine_logic.dart';

class MinePageVisibilityObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != Routes.tabs ||
        !Get.isRegistered<IndexLogic>() ||
        !Get.isRegistered<MineLogic>() ||
        Get.find<IndexLogic>().taBarIdx.value != 4) {
      return;
    }

    Get.find<MineLogic>().onPageVisible();
  }
}
