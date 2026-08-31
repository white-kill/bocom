import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bocom/pages/other/change_nav/change_nav_view.dart';
import 'package:bocom/pages/other/fixed_nav/fixed_nav_view.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import './children/account_manage/account_manage_view.dart';
import './children/user_info_manage/user_info_manage_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      // 个人主页
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
    }else if(index == 1) {
      // 待办
      Get.to(() => FixedNavPage(), arguments: {
        'image': 'bg_wddb',
        'title': '待办',
      });
    }else if(index == 2) {
      // 个人信息
      Get.to(() => UserInfoManagePage());
    }else if(index == 3) {
      // 账户管理
      Get.to(() => AccountManagePage());
    }else if(index == 4) {
      // 活动中心
    }else if(index == 5) {
      // 我的足迹
      Get.to(() => FixedNavPage(), arguments: {
        'image': 'bg_wdzj',
        'title': '我的足迹',
        'rightWidget': [
          SizedBox(width: 15.w,),
          const Center(
            child: BaseText(text: '编辑', fontSize: 16, color: Color(0XFF005DDA),),
          ),
          SizedBox(width: 15.w,),
        ]
      });
    }else if(index == 6) {
      // 我的收藏
      Get.to(() => FixedNavPage(), arguments: {
        'image': 'bg_wdsc',
        'title': '我的收藏',
        'rightWidget': [
          SizedBox(width: 15.w,),
          Center(
            child: Image.asset(
              'assets/images/home_nav_search_light.png',
              width: 16.w,
              height: 16.w,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 15.w,),
        ]
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
