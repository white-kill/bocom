import 'package:bocom/config/app_config.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/pages/other/change_nav/change_nav_view.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/sp_util.dart';
import 'children/account_asset/account_asset_view.dart';
import 'children/comprehensive_bill/comprehensive_bill_view.dart';
import 'children/ledger/ledger_view.dart';
import 'children/user_info/user_info_view.dart';
import 'children/profit_center/profit_center_view.dart';
import 'children/settting/setting_view.dart';
import 'mine_logic.dart';
import 'mine_state.dart';

class MinePage extends BaseStateless {
  MinePage({super.key}) : super(title: '');

  final MineLogic logic = Get.put(MineLogic());
  final MineState state = Get.find<MineLogic>().state;
  final List<_MineFuncItem> _funcItems = const [
    _MineFuncItem(title: '个人主页', icon: 'mine_func_1'),
    _MineFuncItem(title: '待办', icon: 'mine_func_2'),
    _MineFuncItem(title: '个人信息', icon: 'mine_func_3'),
    _MineFuncItem(title: '账户管理', icon: 'mine_func_4'),
    _MineFuncItem(title: '活动中心', icon: 'mine_func_5'),
    _MineFuncItem(title: '我的足迹', icon: 'mine_func_6'),
    _MineFuncItem(title: '我的收藏', icon: 'mine_func_7'),
    _MineFuncItem(title: '财富规划', icon: 'mine_func_8'),
    _MineFuncItem(title: '代扣管理', icon: 'mine_func_9'),
    _MineFuncItem(title: '我的支付', icon: 'mine_func_10'),
    _MineFuncItem(title: '资信证明', icon: 'mine_func_11'),
    _MineFuncItem(title: '隐私管理', icon: 'mine_func_12'),
  ];

  @override
  bool get isChangeNav => true;

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          const BaseText(
            text: '退出',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Color(0xFF181818),
            ),
          ).withOnTap(onTap: () {
            _showLogoutDialog();
          })
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Semantics(
          button: true,
          label: '客服',
          child: Image(
            image: 'nav_right_kf'.png,
            width: 22.w,
            height: 22.w,
          ).withOnTap(
            onTap: () => Get.toNamed(Routes.customerService),
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Image(
          image: 'nav_right_set'.png,
          width: 22.w,
          height: 22.w,
        ).withOnTap(onTap: (){
          Get.to(() => SettingPage());
        }),
        SizedBox(
          width: 15.w,
        ),
        Image(
          image: 'nav_right_msg'.png,
          width: 22.w,
          height: 22.w,
        ),
        SizedBox(
          width: 15.w,
        )
      ];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Color? get background => Colors.white;

  void _showLogoutDialog() {
    Get.dialog(
      const _MineLogoutDialog(),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
    );
  }

  static void _logout() {
    ''.saveToken;
    Get.offAllNamed(Routes.login);
  }

  @override
  Widget initBody(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    // 背景稿按常见约 36px 的状态栏留白制作。系统状态栏更高时
    // 只补超出的部分；其余高度从背景图顶部裁掉，避免首屏整体下移过多。
    const referenceStatusBarHeight = 36.0;
    final backgroundCropTop = statusBarHeight < referenceStatusBarHeight
        ? statusBarHeight
        : referenceStatusBarHeight;
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 650, deviceWidth: 1.sw);
    StackPosition position3 =
        StackPosition(designWidth: 1080, designHeight: 710, deviceWidth: 1.sw);
    StackPosition position4 =
        StackPosition(designWidth: 1080, designHeight: 532, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          key: const Key('mine-status-bar-gradient-spacer'),
          width: 1.sw,
          height: statusBarHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFF2F4F1),
                Color(0xFFF2F7FA),
                Color(0xFFF7F7F5),
                Color(0xFFE7F3FE),
              ],
              stops: [0, 0.34, 0.58, 1],
            ),
          ),
        ),
        SizedBox(
          height: position1.getHeight(650) - backgroundCropTop,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: -backgroundCropTop,
                  height: position1.getHeight(650),
                  child: Image(
                    image: 'bg_mine_1'.png3x,
                    width: 1.sw,
                    fit: BoxFit.fill,
                  ),
                ),
            Positioned(
                left: position1.getX(70),
                top: position1.getY(255) - backgroundCropTop,
                child: Image(
                  image: 'mine_user_icon'.png,
                  width: position1.getWidth(130),
                  fit: BoxFit.fitWidth,
                )),
            Positioned(
                left: position1.getX(250),
                top: position1.getY(240) - backgroundCropTop,
                child: BaseText(
                  text: AppConfig.config.abcLogic.realName(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                    color: Color(0xFF181818),
                  ),
                )),
            Positioned(
                left: position1.getX(250),
                top: position1.getY(330) - backgroundCropTop,
                child: const BaseText(
                  text: '开启财富管理之旅',
                  fontSize: 13,
                  color: Color(0xFF878787),
                )),
                Positioned(
                    left: position1.getX(250),
                    top: position1.getY(330) - backgroundCropTop,
                    child: const BaseText(
                      text: '开启财富管理之旅',
                      fontSize: 13,
                      color: Color(0xFF878787),
                    )),
                Positioned(
                    left: position1.getX(30),
                    top: position1.getY(230) - backgroundCropTop,
                    width: position1.getWidth(700),
                    height: position1.getHeight(170),
                    child: Container().withOnTap(onTap: (){
                      Get.to(() => UserInfoPage());
                    })),
            // 借记卡积分
            Positioned(
                left: position1.getX(80),
                bottom: position1.getY(70),
                child: SizedBox(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(fontSize: 16, height: 1),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )),
            Positioned(
                left: position1.getX(290),
                bottom: position1.getY(70),
                child: SizedBox(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(fontSize: 16, height: 1),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )),
            Positioned(
                left: position1.getX(515),
                bottom: position1.getY(70),
                child: SizedBox(
                  width: position1.getWidth(130),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BaseText(
                        text: '0',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(fontSize: 16, height: 1),
                        color: Color(0xFF181818),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      BaseText(
                        text: '张',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        strutStyle: StrutStyle(fontSize: 16, height: 1),
                        color: Color(0xFF181818),
                      )
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        Stack(
          children: [
            Image(
              image: 'bg_mine_2'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 13.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.w),
                      child: SizedBox(
                        height: 76.w,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            logic
                                .updateFuncScrollProgress(notification.metrics);
                            return false;
                          },
                          child: PageView.builder(
                            controller: logic.funcPageController,
                            padEnds: false,
                            physics: const PageScrollPhysics(
                              parent: ClampingScrollPhysics(),
                            ),
                            itemCount: _funcItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(top: 17.w),
                                child: _MineFuncButton(
                                  item: _funcItems[index],
                                  onTap: () => logic.onFuncTap(
                                    index: index,
                                    title: _funcItems[index].title,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => _MineFuncIndicator(
                      progress: logic.funcScrollProgress.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Image(
              image: 'bg_mine_3'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              left: position3.getX(200),
              top: position3.getY(100),
              child: Image(
                image: 'ic_mine_note'.png,
                width: position3.getWidth(35),
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              left: position3.getX(710),
              top: position3.getY(100),
              child: Image(
                image: 'ic_mine_note'.png,
                width: position3.getWidth(35),
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              right: position3.getX(70),
              top: position3.getY(70),
              child: Obx(
                () => Image(
                  image: (logic.amountVisible.value
                          ? 'ic_mine_eye_open'
                          : 'ic_mine_eye_close')
                      .png,
                  width: position3.getWidth(70),
                  fit: BoxFit.fitWidth,
                ).withOnTap(onTap: logic.toggleAmountVisible),
              ),
            ),
            Positioned(
                left: position3.getX(80),
                top: position3.getY(180),
                child: Row(
                  children: [
                    Obx(
                      () => BaseText(
                        text: logic.amountVisible.value
                            ? AppConfig.config.abcLogic.memberInfo
                                .accountBalance.bankBalance
                            : '****',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Image(
                      image: 'ic_mine_amount_right'.png,
                      width: position3.getWidth(20),
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                )),
            Positioned(
                left: position3.getX(545),
                top: position3.getY(180),
                child: Row(
                  children: [
                    Obx(
                      () => BaseText(
                        text: logic.amountVisible.value ? '--' : '****',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Image(
                      image: 'ic_mine_amount_right'.png,
                      width: position3.getWidth(20),
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                )),
            Positioned(
                left: position3.getX(225),
                top: position3.getY(275),
                child: Obx(
                  () => BaseText(
                    text: logic.amountVisible.value
                        ? AppConfig.config.abcLogic.memberInfo.accountBalance
                            .bankBalance
                        : '****',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                )),
            Positioned(
              left: position3.getX(620),
              top: position3.getY(275),
              child: Obx(
                () => BaseText(
                  text: logic.amountVisible.value ? '0.00' : '****',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: position3.getX(30),
              top: position3.getY(30),
              child: SizedBox(
                width: position3.getWidth(510),
                height: position3.getHeight(350),
              ).withOnTap(onTap: () {
                // 跳转到我的资产tab
                Get.to(() => AccountAssetPage(initialTabIndex: 1));
              }),
            ),
            Positioned(
              right: position3.getX(30),
              top: position3.getY(30),
              child: SizedBox(
                width: position3.getWidth(510),
                height: position3.getHeight(350),
              ).withOnTap(onTap: () {
                // 跳转到收益中心
                Get.to(() => ProfitCenterPage());
              }),
            ),
            Positioned(
              left: position3.getX(30),
              top: position3.getY(380),
              child: SizedBox(
                width: position3.getWidth(510),
                height: position3.getHeight(170),
              ).withOnTap(onTap: () {
                // 跳转到我的账户tab
                Get.to(() => AccountAssetPage(initialTabIndex: 0));
              }),
            ),
            Positioned(
              right: position3.getX(30),
              top: position3.getY(380),
              child: SizedBox(
                width: position3.getWidth(510),
                height: position3.getHeight(170),
              ).withOnTap(onTap: () {
                // 跳转信用卡页面
                Get.to(() => ChangeNavPage(), arguments: {
                  'image': 'bg_mine_xyk',
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
          ],
        ),
        Stack(
          children: [
            Image(
              image: 'bg_mine_4'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              left: position4.getX(80),
              top: position4.getY(370),
              child: Obx(
                () => BaseText(
                  text: logic.amountVisible.value
                      ? AppConfig
                          .config.abcLogic.memberInfo.incomeTotal.bankBalance
                      : '****',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              right: position4.getX(80),
              top: position4.getY(370),
              child: Obx(
                () => BaseText(
                  text: logic.amountVisible.value
                      ? AppConfig
                          .config.abcLogic.memberInfo.expensesTotal.bankBalance
                      : '****',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              left: position4.getX(80),
              top: position4.getY(465),
              child: _MineIncomeExpenseProgress(
                width: position4.getWidth(920),
                height: position4.getHeight(10),
                income: AppConfig.config.abcLogic.memberInfo.incomeTotal,
                expense: AppConfig.config.abcLogic.memberInfo.expensesTotal,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
                width: 1.sw,
                height: position4.getHeight(135),
              ).withOnTap(onTap: () {
                Get.to(() => ComprehensiveBillPage());
              }),
            ),
            Positioned(
              left: 0,
              top: position4.getHeight(135),
              child: SizedBox(
                width: 1.sw,
                height: position4.getHeight(397),
              ).withOnTap(onTap: () {
                Get.to(() => LedgerPage());
              }),
            ),
          ],
        ),
        Image(
          image: 'bg_mine_5'.png3x,
          width: 1.sw,
          fit: BoxFit.fitWidth,
        ),
        Image(
          image: 'bg_mine_6'.png3x,
          width: 1.sw,
          fit: BoxFit.fitWidth,
        ),
      ],
    );
  }
}

class _MineFuncItem {
  const _MineFuncItem({
    required this.title,
    required this.icon,
  });

  final String title;
  final String icon;
}

class _MineLogoutDialog extends StatelessWidget {
  const _MineLogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        height: 220.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 15.w,
              top: 15.w,
              child: SizedBox(
                width: 28.w,
                height: 28.w,
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF999999),
                  size: 26,
                ),
              ).withOnTap(onTap: () => Get.back()),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 42.w,
              child: const BaseText(
                text: '安全退出',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 85.w,
              child: const BaseText(
                text: '请确认是否退出交行手机银行?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 20.w,
              child: Row(
                children: [
                  Expanded(
                    child: _MineLogoutButton(
                      text: '取消',
                      textColor: const Color(0xFF0075F6),
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFF0075F6),
                      onTap: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: _MineLogoutButton(
                      text: '确定',
                      textColor: Colors.white,
                      backgroundColor: const Color(0xFF0075F6),
                      borderColor: const Color(0xFF0075F6),
                      onTap: () {
                        Get.back();
                        MinePage._logout();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MineLogoutButton extends StatelessWidget {
  const _MineLogoutButton({
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(
          color: borderColor,
          width: 1.w,
        ),
      ),
      child: BaseText(
        text: text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    ).withOnTap(onTap: onTap);
  }
}

class _MineFuncButton extends StatelessWidget {
  const _MineFuncButton({
    required this.item,
    required this.onTap,
  });

  final _MineFuncItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 22.w,
            child: Center(
              child: Image(
                image: item.icon.png,
                width: 22.w,
                height: 22.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 8.w),
          BaseText(
            text: item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            fontSize: 13,
            color: const Color(0xFF181818),
          ),
        ],
      ),
    );
  }
}

class _MineFuncIndicator extends StatelessWidget {
  const _MineFuncIndicator({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 22.0;
    const thumbWidth = 8.0;

    return Container(
      width: trackWidth.w,
      height: 3.w,
      margin: EdgeInsets.only(top: 3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF0),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Stack(
        children: [
          Positioned(
            left: (trackWidth - thumbWidth).w * progress,
            top: 0,
            child: Container(
              width: thumbWidth.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: const Color(0xFFBFC5CF),
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MineIncomeExpenseProgress extends StatelessWidget {
  const _MineIncomeExpenseProgress({
    required this.width,
    required this.height,
    required this.income,
    required this.expense,
  });

  final double width;
  final double height;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final incomeValue = income < 0 ? 0.0 : income;
    final expenseValue = expense < 0 ? 0.0 : expense;
    final total = incomeValue + expenseValue;
    final radius = BorderRadius.circular(height / 2);

    if (total <= 0) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFD8DCE2),
          borderRadius: radius,
        ),
      );
    }

    final incomeFlex = _progressFlex(incomeValue, total);
    final expenseFlex = _progressFlex(expenseValue, total);
    final hasBoth = incomeFlex > 0 && expenseFlex > 0;

    return SizedBox(
      width: width,
      height: height,
      child: Row(
        children: [
          if (incomeFlex > 0)
            Expanded(
              flex: incomeFlex,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFFA9D8F3),
                  borderRadius: hasBoth
                      ? BorderRadius.only(
                          topLeft: Radius.circular(height / 2),
                          bottomLeft: Radius.circular(height / 2),
                        )
                      : radius,
                ),
              ),
            ),
          if (hasBoth)
            SizedBox(
              width: 8.w,
            ),
          if (expenseFlex > 0)
            Expanded(
              flex: expenseFlex,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7BD93),
                  borderRadius: hasBoth
                      ? BorderRadius.only(
                          topRight: Radius.circular(height / 2),
                          bottomRight: Radius.circular(height / 2),
                        )
                      : radius,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _progressFlex(double value, double total) {
    if (value <= 0 || total <= 0) return 0;
    final flex = (value / total * 1000).round();
    return flex <= 0 ? 1 : flex;
  }
}
