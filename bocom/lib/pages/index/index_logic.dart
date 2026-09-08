import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/local_notifications.dart';
import '../../config/app_config.dart';
import '../tabs/mine/mine_logic.dart';
import 'index_state.dart';

class IndexLogic extends GetxController {
  final IndexState state = IndexState();

  /// 默认选择第一个页面
  var taBarIdx = 0.obs;

  bool showTabBar = true;

  @override
  void onClose() {
    super.onClose();
    NotificationHelper.getInstance().closeSubject();
  }

  @override
  void onInit() {
    super.onInit();
    NotificationHelper.getInstance().initPermission();
    AppConfig.config.abcLogic.memberInfoData();
    state.item = state.appBarList.map((data) {
      return BottomNavigationBarItem(
        icon: Obx(() => Image(
              image: AssetImage(
                'assets/images/tabbar_'
                '${taBarIdx.value == data["index"] ? 'select' : 'normal'}'
                '${data["index"]}@3x.png',
              ),
              width: 22.w,
              height: 22.w,
            )),
        label: data["title"],
      );
    }).toList();
  }

  /// navigationBar设置
  Widget navigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      onTap: selectIndex,
      currentIndex: taBarIdx.value,
      selectedFontSize: 10.w,
      unselectedFontSize: 10.w,
      selectedLabelStyle:
          const TextStyle(height: 18 / 11, fontWeight: FontWeight.w400),
      unselectedLabelStyle:
          const TextStyle(height: 18 / 11, fontWeight: FontWeight.w400),
      selectedItemColor: Color(state.appBarList[taBarIdx.value]['selectColor']),
      unselectedItemColor: const Color(0xFF4D4D4D),
      type: BottomNavigationBarType.fixed,
      items: state.item,
    );
  }

  void selectIndex(int index) {
    if (taBarIdx.value == index) return;
    taBarIdx.value = index;
    if (index == 4 && Get.isRegistered<MineLogic>()) {
      Get.find<MineLogic>().onPageVisible();
    }
    update(['updateTabBar']);
  }

  void setTabBarVisible(bool visible) {
    if (showTabBar == visible) return;
    showTabBar = visible;
    update(['updateTabBar']);
  }
}
