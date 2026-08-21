import 'package:bocom/config/app_config.dart';
import 'package:bocom/pages/other/fixed_nav/fixed_nav_view.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import './account_diushi/account_diushi_view.dart';
import './account_jiangji/account_jiangji_view.dart';
import './account_xiane/account_xiane_view.dart';
import './account_jiebang/account_jiebang_view.dart';
import './account_zhuxiao/account_zhuxiao_view.dart';

import 'account_manage_logic.dart';
import 'account_manage_state.dart';

class AccountManageTwoPage extends BaseStateless {
  AccountManageTwoPage({super.key}) : super(title: '账户管理');

  final AccountManageLogic logic = Get.put(AccountManageLogic());
  final AccountManageState state = Get.find<AccountManageLogic>().state;

  @override
  Color? get navColor => const Color(0xffFFFFFF);

  @override
  List<Widget>? get rightAction => [];

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 1080, designHeight: 2168, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_account_manage2'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                top: position.getY(235),
                left: position.getX(155),
                child: BaseText(
                  text: AppConfig.config.abcLogic.card2(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 19.sp,
                    letterSpacing: 1.3, // 增加字间距
                  ),
                )),
            Positioned(
                top: position.getY(300),
                left: position.getX(350),
                child: BaseText(
                  text: '￥${AppConfig.config.abcLogic.balance()}元',
                  color: const Color(0xFF777777),
                  fontSize: 12,
                )),
            Positioned(
                top: position.getY(385),
                left: position.getX(350),
                child: BaseText(
                  text: AppConfig.config.abcLogic.phone(),
                  color: const Color(0xFF777777),
                  fontSize: 12,
                )),
            Positioned(
                top: position.getY(430),
                left: position.getX(350),
                child: const BaseText(
                  text: '柜面',
                  color: Color(0xFF777777),
                  fontSize: 12,
                )),
            Positioned(
                top: position.getY(495),
                left: position.getX(350),
                child: BaseText(
                  text: AppConfig.config.abcLogic.branchBelongs(),
                  color: const Color(0xFF777777),
                  fontSize: 12,
                )),
            Positioned(
                top: position.getY(630),
                left: 0,
                child: Column(
                  children: [
                    Container().withOnTap(onTap: () {
                      Get.to(() => FixedNavPage(), arguments: {
                        'image': 'bg_aqzx',
                        'title': '安全中心',
                      });
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      Get.to(() => FixedNavPage(), arguments: {
                        'image': 'bg_ywkt',
                        'title': '业务开通',
                      });
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      Get.to(() => AccountJiangjiPage());
                    }).expanded(),
                  ],
                ).withContainer(
                    width: 1.sw,
                    height: position.getHeight(390))),
            Positioned(
                top: position.getY(1050),
                left: 0,
                child: Column(
                  children: [
                    Container().withOnTap(onTap: () {
                      Get.to(() => AccountDiushiPage());
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      // _showHuanKaSheet(context);
                      Get.to(() => FixedNavPage(), arguments: {
                        'image': 'bg_account_cqbdchs',
                        'title': '读取证件准备',
                      });
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      Get.to(() => AccountXianePage());
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      _showQrCodeDialog(context);
                    }).expanded(),
                  ],
                ).withContainer(
                    width: 1.sw,
                    height: position.getHeight(510))),
            Positioned(
                top: position.getY(1580),
                left: 0,
                child: Column(
                  children: [
                    Container().withOnTap(onTap: () {
                      Get.to(() => AccountJiebangPage());
                    }).expanded(),
                    Container().withOnTap(onTap: () {
                      Get.to(() => AccountZhuxiaoPage());
                    }).expanded(),
                  ],
                ).withContainer(
                    width: 1.sw,
                    height: position.getHeight(260))),
          ],
        ),
      ],
    );
  }

  Future<void> _showQrCodeDialog(BuildContext context) {
    final position = StackPosition(
      designWidth: 1080,
      designHeight: 831,
      deviceWidth: 1.sw,
    );
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭出示二维码弹窗',
      barrierColor: Colors.black.withValues(alpha: 0.46),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, __) => SafeArea(
        child: Align(
          alignment: const Alignment(0, 0.14),
          child: SizedBox(
            key: const Key('account-qr-code-dialog'),
            width: position.getWidth(740),
            height: position.getHeight(831),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image(
                    image: 'bg_account_chushi_qrcode'.png3x,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: position.getX(18),
                  top: position.getY(18),
                  width: position.getWidth(105),
                  height: position.getHeight(105),
                  child: Semantics(
                    button: true,
                    label: '关闭',
                    child: GestureDetector(
                      key: const Key('account-qr-code-dialog-close'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> _showHuanKaSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) {
        final bottom = MediaQuery.paddingOf(context).bottom;
        return Container(
          height: 200.w + bottom,
          width: 1.sw,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
          ),
          child: Column(
            children: [
              const Expanded(
                  child: Center(
                child: BaseText(
                  maxLines: 100,
                  text:
                      '非常抱歉，由于线上渠道的局限性，无法支持所有卡产品换卡，故该卡片暂无法通过手机银行进行更换，请您前往交通银行任一网点换卡，感谢您的理解与支持！',
                  fontSize: 14,
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                ),
              )),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 45.w,
                  margin: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0075F6),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  alignment: Alignment.center,
                  child: const BaseText(
                    text: '知道了',
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: bottom + 18.w),
            ],
          ),
        );
      },
    );
  }
}
