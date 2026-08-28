import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/state_widget/app_bar_widget.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import '../../index/index_logic.dart';
import '../mine/children/account_asset/account_asset_view.dart';
import 'home_logic.dart';
import 'home_state.dart';

// 首页
// 说明：当前页面使用 01—08 原始内容切图纵向拼接，顶部导航与二楼下拉交互由 Flutter 单独绘制。
class HomePage extends BaseStateless {
  HomePage({
    this.onIncomeExpenseLedgerTap,
    this.onBillTap,
    super.key,
  });

  final VoidCallback? onIncomeExpenseLedgerTap;
  final VoidCallback? onBillTap;

  static const List<String> _sectionAssets = [
    'assets/images/home_section_01.png',
    'assets/images/home_section_02.png',
    'assets/images/home_section_03.png',
    'assets/images/home_section_04.png',
    'assets/images/home_section_05.png',
    'assets/images/home_section_06.png',
    'assets/images/home_section_07.png',
    'assets/images/home_section_08.png',
  ];

  final HomeLogic logic = Get.put(HomeLogic());
  final HomeState state = Get.find<HomeLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  bool get keepBodyPositionOnOverscroll => true;

  @override
  Color? get background => const Color(0xFFF7F7F7);

  @override
  Color? get navColor => Colors.white;

  @override
  double? get lefItemWidth => 58.w;

  @override
  bool get centerTitle => false;

  @override
  AppBarController? get appBarController => state.appBarController;

  @override
  Widget? get leftItem => Obx(
        () => Semantics(
          button: true,
          label: '退出登录',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.offAllNamed(Routes.login),
            child: Center(
              child: Text(
                '退出',
                style: TextStyle(
                  color: logic.isNavDark.value
                      ? const Color(0xFF262626)
                      : Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget? get titleWidget => Obx(
        () => _HomeSearchBar(isDark: logic.isNavDark.value),
      );

  @override
  List<Widget>? get rightAction => [
        Obx(
          () => _HomeNavButton(
            semanticLabel: '版本',
            assetName: logic.isNavDark.value
                ? 'home_nav_version_dark.png'
                : 'home_nav_version_light.png',
          ),
        ),
        Obx(
          () => _HomeNavButton(
            semanticLabel: '客服',
            assetName: logic.isNavDark.value
                ? 'home_nav_service_dark.png'
                : 'home_nav_service_light.png',
            onTap: () => Get.toNamed(Routes.customerService),
          ),
        ),
        Obx(
          () => _HomeNavButton(
            semanticLabel: '扫一扫',
            assetName: logic.isNavDark.value
                ? 'home_nav_scan_dark.png'
                : 'home_nav_scan_light.png',
            onTap: () => Get.toNamed(Routes.scan),
          ),
        ),
        SizedBox(width: 5.w),
      ];

  @override
  Function(bool change)? get onNotificationNavChange => logic.setNavDark;

  @override
  Widget initBody(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      context: context,
      enableScrollWhenTwoLevel: true,
      headerTriggerDistance: 48.h,
      twiceTriggerDistance: 108.h,
      maxOverScrollExtent: 160.h,
      child: SmartRefresher(
        controller: state.refreshController,
        enablePullDown: true,
        enablePullUp: false,
        enableTwoLevel: true,
        header: _HomeTwoLevelHeader(
          twoLevelWidget: _HomeFootprintPage(
            onBackHome: state.refreshController.twoLevelComplete,
          ),
          onPullingChanged: logic.setPulling,
        ),
        onRefresh: () {
          Future<void>.delayed(const Duration(milliseconds: 180), () {
            state.refreshController.refreshCompleted();
          });
        },
        onTwoLevel: (isOpen) {
          logic.setTwoLevelOpen(isOpen);
          if (Get.isRegistered<IndexLogic>()) {
            Get.find<IndexLogic>().setTabBarVisible(!isOpen);
          }
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _sectionAssets.length,
          itemBuilder: (_, index) {
            if (index == 0) {
              return _HomeAccountAssetSection(
                assetPath: _sectionAssets[index],
              );
            }
            if (index == 1) {
              return _HomeTransferSection(
                assetPath: _sectionAssets[index],
                onIncomeExpenseLedgerTap: onIncomeExpenseLedgerTap,
                onBillTap: onBillTap,
              );
            }
            return Image.asset(
              _sectionAssets[index],
              width: 1.sw,
              fit: BoxFit.fitWidth,
              gaplessPlayback: true,
            );
          },
        ),
      ),
    );
  }
}

class _HomeTransferSection extends StatelessWidget {
  const _HomeTransferSection({
    required this.assetPath,
    this.onIncomeExpenseLedgerTap,
    this.onBillTap,
  });

  final String assetPath;
  final VoidCallback? onIncomeExpenseLedgerTap;
  final VoidCallback? onBillTap;

  static const double _sourceWidth = 1080;
  static const double _sourceHeight = 397;

  @override
  Widget build(BuildContext context) {
    final featureDestinations = [
      _HomeFeatureDestination(
        semanticsLabel: '转账',
        open: () => Get.toNamed(Routes.homeTransfer),
      ),
      _HomeFeatureDestination(
        semanticsLabel: '惠民贷',
        open: () => Get.toNamed(Routes.homeConsumerLoan),
      ),
      _HomeFeatureDestination(
        semanticsLabel: '活期盈',
        open: () => Get.toNamed(Routes.homeDemandDepositPlus),
      ),
      _HomeFeatureDestination(
        semanticsLabel: '城市专区',
        open: () => Get.toNamed(Routes.homeCityZone),
      ),
      _HomeFeatureDestination(
        semanticsLabel: '资讯',
        open: () => Get.toNamed(Routes.homeNews),
      ),
      _HomeFeatureDestination(
        semanticsLabel: '存款',
        open: () => Get.toNamed(Routes.homeDeposit),
      ),
      _HomeFeatureDestination(
        semanticsLabel: '领券中心',
        open: () => Get.toNamed(Routes.homeCouponCenter),
      ),
      _HomeFeatureDestination(
        hotspotKey: const Key('home-income-expense-ledger-hotspot'),
        semanticsLabel: '收支账本',
        open: () => Get.toNamed(Routes.ledgerPage),
      ),
      _HomeFeatureDestination(
        hotspotKey: const Key('home-bill-hotspot'),
        semanticsLabel: '账单',
        open: () => Get.toNamed(Routes.comprehensiveBillPage),
      ),
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        final scale = constraints.maxWidth / _sourceWidth;
        return SizedBox(
          width: constraints.maxWidth,
          height: _sourceHeight * scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
              for (var index = 0; index < featureDestinations.length; index++)
                Positioned(
                  left: (index % 5) * 216 * scale,
                  top: (index ~/ 5) * 198.5 * scale,
                  width: 216 * scale,
                  height: 198.5 * scale,
                  child: Semantics(
                    key: featureDestinations[index].hotspotKey,
                    button: true,
                    label: featureDestinations[index].semanticsLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: featureDestinations[index].open,
                    ),
                  ),
                ),
              Positioned(
                left: 864 * scale,
                top: 198.5 * scale,
                width: 216 * scale,
                height: 198.5 * scale,
                child: Semantics(
                  button: true,
                  label: '全部服务',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.toNamed(Routes.allServices),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeAccountAssetSection extends StatelessWidget {
  const _HomeAccountAssetSection({required this.assetPath});

  final String assetPath;

  static const double _sourceWidth = 1080;
  static const double _sourceHeight = 538;

  static final List<_HomeFeatureDestination> _destinations = [
    _HomeFeatureDestination(
      semanticsLabel: '账户资产，进入我的账户',
      open: () => Get.to(() => AccountAssetPage(initialTabIndex: 1)),
    ),
    _HomeFeatureDestination(
      semanticsLabel: '信用卡，进入爱宠信用卡',
      open: () => Get.toNamed(Routes.homeCreditCard),
    ),
    _HomeFeatureDestination(
      semanticsLabel: '安全，进入我的安全',
      open: () => Get.toNamed(Routes.homeSecurity),
    ),
    _HomeFeatureDestination(
      semanticsLabel: '付款码，进入付款码开通页面',
      open: () => Get.toNamed(Routes.homePaymentCode),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final scale = constraints.maxWidth / _sourceWidth;
        return SizedBox(
          width: constraints.maxWidth,
          height: _sourceHeight * scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
              for (var index = 0; index < _destinations.length; index++)
                Positioned(
                  left: index * 270 * scale,
                  top: 215 * scale,
                  width: 270 * scale,
                  height: 323 * scale,
                  child: Semantics(
                    button: true,
                    label: _destinations[index].semanticsLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _destinations[index].open,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeFeatureDestination {
  const _HomeFeatureDestination({
    required this.semanticsLabel,
    required this.open,
    this.hotspotKey,
  });

  final String semanticsLabel;
  final VoidCallback open;
  final Key? hotspotKey;
}

void _reservedHomeFeatureTap() {}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isDark ? const Color(0xFF555555) : Colors.white.withValues(alpha: 0.94);
    final suffix = isDark ? 'dark' : 'light';

    return Semantics(
      button: true,
      label: '搜索，碳星每日签到',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(Routes.search),
        child: Container(
          width: 194.w,
          height: 34.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFF4F5F7)
                : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(18.w),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/home_nav_search_$suffix.png',
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  '碳星每日签到',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: foreground, fontSize: 14.sp),
                ),
              ),
              Image.asset(
                'assets/images/home_nav_voice_$suffix.png',
                width: 19.w,
                height: 19.w,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeNavButton extends StatelessWidget {
  const _HomeNavButton({
    required this.semanticLabel,
    required this.assetName,
    this.onTap,
  });

  final String semanticLabel;
  final String assetName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () {},
        child: SizedBox(
          width: 35.w,
          height: 44.w,
          child: Center(
            child: Image.asset(
              'assets/images/$assetName',
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTwoLevelHeader extends StatelessWidget {
  const _HomeTwoLevelHeader({
    required this.twoLevelWidget,
    required this.onPullingChanged,
  });

  final Widget twoLevelWidget;
  final ValueChanged<bool> onPullingChanged;

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      refreshStyle: RefreshStyle.Follow,
      height: 80.h,
      idleText: '下拉刷新',
      releaseText: '继续下拉进入我的足迹',
      refreshingText: '下拉刷新',
      completeText: '',
      canTwoLevelText: '松开刷新',
      idleIcon: const SizedBox.shrink(),
      releaseIcon: const SizedBox.shrink(),
      refreshingIcon: const SizedBox.shrink(),
      completeIcon: const SizedBox.shrink(),
      canTwoLevelIcon: const SizedBox.shrink(),
      textStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
      outerBuilder: (statusWidget) {
        final status = SmartRefresher.of(context)?.controller.headerStatus;
        final isTwoLevel = status == RefreshStatus.twoLevelOpening ||
            status == RefreshStatus.twoLeveling ||
            status == RefreshStatus.twoLevelClosing;
        final isPulling = status == RefreshStatus.canRefresh ||
            status == RefreshStatus.canTwoLevel ||
            status == RefreshStatus.refreshing ||
            isTwoLevel;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          onPullingChanged(isPulling);
        });

        return Container(
          height: SmartRefresher.ofState(context)?.viewportExtent,
          decoration: isTwoLevel
              ? null
              : const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF8F431C), Color(0xFFB5662E)],
                  ),
                ),
          alignment: isTwoLevel ? null : Alignment.bottomCenter,
          child: isTwoLevel
              ? twoLevelWidget
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: MediaQuery.paddingOf(context).top + 18.h,
                      child: Text(
                        '我的足迹',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: statusWidget,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _HomeFootprintPage extends StatelessWidget {
  const _HomeFootprintPage({required this.onBackHome});

  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Color(0xFFEAF2FF), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 18.h,
              left: 0,
              right: 0,
              child: Text(
                '我的足迹',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF171717),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 74.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.manage_search_rounded,
                      size: 68.w,
                      color: const Color(0xFFBDD3EF).withValues(alpha: 0.38),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      '暂无足迹，快去逛逛吧～',
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Semantics(
                button: true,
                label: '回到首页',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBackHome,
                  child: Container(
                    height: 64.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F7),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.w),
                      ),
                    ),
                    child: Text(
                      '回到首页',
                      style: TextStyle(
                        color: const Color(0xFF171717),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
