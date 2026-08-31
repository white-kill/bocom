import 'dart:math' as math;
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bocom/pages/other/fixed_nav/fixed_nav_view.dart';
import 'package:bocom/pages/other/change_nav/change_nav_view.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'setting_logic.dart';
import 'setting_state.dart';

class SettingPage extends BaseStateless {
  SettingPage({super.key}) : super(title: '设置');

  final SettingLogic logic = Get.put(SettingLogic());
  final SettingState state = Get.find<SettingLogic>().state;

  // @override
  // Color? get navColor => const Color(0xffF5F5F5);

  @override
  Color? get titleColor => const Color(0xff181818);

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 56.w;

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          Obx(
            () => SizedBox(
              width: 30.w,
              height: 30.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_back_white'.png,
                        height: 15.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                  image: 'nav_back_light_white'.png,
                  width: 29.5.w,
                  height: 29.5.w,
                  fit: BoxFit.contain,
                ),
              ),
            ).withOnTap(onTap: () => Get.back()),
          ),
        ],
      );

  @override
  List<Widget>? get rightAction => [];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionFlag.value = v;
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Widget initBody(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    StackPosition position =
        StackPosition(designWidth: 1080, designHeight: 2172, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.only(top: 44.h + statusBarHeight),
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_setting'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(20),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 登录管理
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_dlgl',
                  'title': '登录管理',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(150),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 账号管理
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_zhgl',
                  'title': '账号管理',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(280),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 账号管理
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_xxwh',
                  'title': '信息维护',
                });
              }),
            ),

            Positioned(
              right: position.getX(0),
              top: position.getY(450),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 版本切换
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_bbqh',
                  'title': '版本切换',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(580),
              height: position.getHeight(190),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 主题中心
                Get.to(() => ChangeNavPage(), arguments: {
                  'image': 'bg_set_ztzx',
                  'title': '',
                  'hideRightAction': true,
                  'isOffset': true,
                  'navColor': Colors.white,
                  'changeTitleColor': Colors.transparent,
                  'defTitleColor': Colors.transparent,
                  'showBackgroundColor': false,
                });
              }),
            ),
            
            Positioned(
              right: position.getX(0),
              top: position.getY(940),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 字体大小设置
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_ztdxsz',
                  'title': '字体大小设置',
                });
              }),
            ),

            Positioned(
              right: position.getX(0),
              top: position.getY(1110),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 支付设置
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_zfsz',
                  'title': '支付设置',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(1240),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 转账设置
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_zzsz',
                  'title': '转账设置',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(1370),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 消息设置
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_xxsz',
                  'title': '消息设置',
                });
              }),
            ),

            Positioned(
              right: position.getX(0),
              top: position.getY(1540),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 签约管理
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_qygl',
                  'title': '签约管理',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(1670),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 隐私管理
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_ysgl',
                  'title': '隐私管理',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(1800),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 生物识别管理
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_swsbgl',
                  'title': '生物识别管理',
                });
              }),
            ),

            Positioned(
              right: position.getX(0),
              top: position.getY(1960),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 个性化设置
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_gxhsz',
                  'title': '个性化设置',
                });
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(2090),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 清楚缓存
                _showQchcSheet(context);
              }),
            ),
            Positioned(
              right: position.getX(0),
              top: position.getY(2220),
              height: position.getHeight(130),
              width: 1.sw,
              child: Container().withOnTap(onTap: (){
                // 关于app
                Get.to(() => FixedNavPage(), arguments: {
                  'image': 'bg_set_gy',
                  'title': '关于app',
                });
              }),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showQchcSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) {
        final bottom = MediaQuery.paddingOf(context).bottom;
        return Image(image: 'bg_set_qchc_sheet'.png3x, width: 1.sw, fit: BoxFit.fitWidth);
      },
    );
  }
}