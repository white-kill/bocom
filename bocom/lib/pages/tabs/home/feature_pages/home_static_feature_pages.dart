import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../config/abc_config/account_city_builder.dart';
import '../../../../routes/app_pages.dart';

// 城市专区页
// 说明：当前页面使用不含导航栏的内容切图，白色导航栏由 Flutter 固定绘制。
class HomeCityZonePage extends StatelessWidget {
  const HomeCityZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FixedNavigationReferencePage(
      assetPath: 'assets/images/home_city_zone_body.png',
      sourceWidth: 1080,
      sourceHeight: 2779,
      title: '城市专区',
      backgroundColor: Color(0xFFF8F8F8),
      navigationKey: Key('home-city-zone-fixed-navigation'),
      trailing: _CityZoneAccountCity(),
      trailingRight: 17,
    );
  }
}

// 全部理财产品页
// 说明：当前页面使用不含导航栏的内容切图，返回与搜索导航由 Flutter 固定绘制。
class HomePreferredProductsPage extends StatelessWidget {
  const HomePreferredProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FixedNavigationReferencePage(
      assetPath: 'assets/images/home_preferred_products_body.png',
      sourceWidth: 1080,
      sourceHeight: 3172,
      title: '全部理财产品',
      backgroundColor: Color(0xFFF8F8F8),
      navigationKey: Key('home-preferred-products-fixed-navigation'),
      trailing: _StaticNavigationAction(
        key: Key('home-preferred-products-search-action'),
        semanticLabel: '搜索',
        assetPath: 'assets/images/finance_nav_search.png',
        size: 23,
      ),
    );
  }
}

// 活动中心页
// 说明：首屏保留 Slice 中的沉浸式导航，滚出源导航后显示固定白色导航栏。
class HomeActivityCenterPage extends StatelessWidget {
  const HomeActivityCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImmersiveCampaignPage(
      pageKey: Key('home-activity-center-page'),
      assetPath: 'assets/images/home_activity_center_page.png',
      sourceWidth: 944,
      sourceHeight: 4096,
      title: '活动中心',
      pinnedNavigationKey: Key('home-activity-center-pinned-navigation'),
      pinnedAction: _PinnedNavigationAction.search,
      backgroundColor: Color(0xFFF4FAFC),
      backWidth: 110,
      navigationHeight: 150,
      trailingLabel: '搜索',
      trailingWidth: 110,
    );
  }
}

// 交行福利季页
// 说明：首屏保留 Slice 中的紫色沉浸式导航，滚出源导航后显示固定白色导航栏。
class HomeWelfareSeasonPage extends StatelessWidget {
  const HomeWelfareSeasonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImmersiveCampaignPage(
      pageKey: Key('home-welfare-season-page'),
      assetPath: 'assets/images/home_welfare_season_page.png',
      sourceWidth: 730,
      sourceHeight: 4096,
      title: '交行福利季',
      pinnedNavigationKey: Key('home-welfare-season-pinned-navigation'),
      backgroundColor: Color(0xFFD88EFF),
      backWidth: 100,
      navigationHeight: 140,
      lightStatusBar: true,
    );
  }
}

// 一站式授信页
// 说明：首屏保留 Slice 中的沉浸式导航，滚出源导航后显示固定白色导航栏。
class HomeOneStopCreditPage extends StatelessWidget {
  const HomeOneStopCreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImmersiveCampaignPage(
      pageKey: Key('home-one-stop-credit-page'),
      assetPath: 'assets/images/home_one_stop_credit_page.png',
      sourceWidth: 1080,
      sourceHeight: 2376,
      title: '一站式授信',
      pinnedNavigationKey: Key('home-one-stop-credit-pinned-navigation'),
      pinnedAction: _PinnedNavigationAction.service,
      backgroundColor: Color(0xFFEAF7FF),
      backWidth: 150,
      navigationHeight: 220,
      trailingLabel: '客服',
      trailingWidth: 150,
      trailingOpensCustomerService: true,
    );
  }
}

// 养老专区页
// 说明：首屏保留 Slice 中的沉浸式导航，滚出源导航后显示固定白色导航栏。
class HomePensionZonePage extends StatelessWidget {
  const HomePensionZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImmersiveCampaignPage(
      pageKey: Key('home-pension-zone-page'),
      assetPath: 'assets/images/home_pension_zone_page.png',
      sourceWidth: 575,
      sourceHeight: 4096,
      title: '养老专区',
      pinnedNavigationKey: Key('home-pension-zone-pinned-navigation'),
      pinnedAction: _PinnedNavigationAction.share,
      backgroundColor: Color(0xFFF7F7F7),
      backWidth: 78,
      navigationHeight: 118,
      trailingLabel: '分享',
      trailingWidth: 78,
    );
  }
}

// 交薪通专区页
// 说明：首屏保留 Slice 中的蓝色沉浸式导航，滚出源导航后显示固定白色导航栏。
class HomeSalaryZonePage extends StatelessWidget {
  const HomeSalaryZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImmersiveCampaignPage(
      pageKey: Key('home-salary-zone-page'),
      assetPath: 'assets/images/home_salary_zone_page.png',
      sourceWidth: 711,
      sourceHeight: 4096,
      title: '交薪通',
      pinnedNavigationKey: Key('home-salary-zone-pinned-navigation'),
      pinnedAction: _PinnedNavigationAction.share,
      backgroundColor: Color(0xFFF6F6F6),
      backWidth: 95,
      navigationHeight: 140,
      trailingLabel: '分享',
      trailingWidth: 95,
      lightStatusBar: true,
    );
  }
}

class _CityZoneAccountCity extends StatelessWidget {
  const _CityZoneAccountCity();

  @override
  Widget build(BuildContext context) {
    final sourceScale = MediaQuery.sizeOf(context).width / 1080;
    return AccountCityBuilder(
      builder: (_, city) => Semantics(
        button: true,
        label: '当前城市，$city',
        child: Transform.translate(
          offset: Offset(0, -3.2 * sourceScale),
          child: SizedBox(
            width: 119 * sourceScale,
            height: 50 * sourceScale,
            child: Stack(
              children: [
                Positioned(
                  left: -3.2 * sourceScale,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Transform.scale(
                      scaleX: 103 / 100,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        city,
                        key: const Key('home-city-zone-account-city'),
                        maxLines: 1,
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 42.5 * sourceScale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 75.95 * sourceScale,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 59.5 * sourceScale,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 存款页
// 说明：当前页面使用不含导航栏的内容切图，搜索和客服导航栏由 Flutter 固定绘制。
class HomeDepositPage extends StatelessWidget {
  const HomeDepositPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FixedNavigationReferencePage(
      assetPath: 'assets/images/home_deposit_body.png',
      sourceWidth: 1042,
      sourceHeight: 3885,
      title: '存款',
      backgroundColor: Color(0xFFF6F6F6),
      navigationKey: Key('home-deposit-fixed-navigation'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StaticNavigationAction(
            key: Key('home-deposit-search-action'),
            semanticLabel: '搜索',
            assetPath: 'assets/images/finance_nav_search.png',
            size: 22,
          ),
          SizedBox(width: 14),
          _StaticNavigationAction(
            key: Key('home-deposit-service-action'),
            semanticLabel: '客服',
            assetPath: 'assets/images/finance_nav_service.png',
            size: 24,
          ),
        ],
      ),
    );
  }
}

// 惠民贷页
// 说明：当前页面保留参考图中的定制导航栏，导航与内容一起滑动。
class HomeConsumerLoanPage extends StatelessWidget {
  const HomeConsumerLoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ScrollingReferencePage(
      pageKey: Key('home-consumer-loan-scrolling-page'),
      assetPath: 'assets/images/home_consumer_loan_page.png',
      sourceWidth: 1080,
      sourceHeight: 2376,
      title: '惠民贷',
      pinnedAction: _PinnedNavigationAction.service,
      backTapWidth: 150,
      backTapHeight: 220,
      initialStatusBarIconBrightness: Brightness.dark,
    );
  }
}

// 活期盈页
// 说明：当前页面保留参考图中的渐变导航栏，导航与内容一起滑动。
class HomeDemandDepositPlusPage extends StatelessWidget {
  const HomeDemandDepositPlusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ScrollingReferencePage(
      pageKey: Key('home-demand-deposit-plus-scrolling-page'),
      assetPath: 'assets/images/home_demand_deposit_plus_page.png',
      sourceWidth: 1080,
      sourceHeight: 3922,
      title: '活期盈',
      pinnedAction: _PinnedNavigationAction.share,
      backTapWidth: 150,
      backTapHeight: 210,
      initialStatusBarIconBrightness: Brightness.dark,
    );
  }
}

// 资讯页
// 说明：当前页面保留参考图中的导航和横向分类栏，整页一起滑动。
class HomeNewsPage extends StatelessWidget {
  const HomeNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ScrollingReferencePage(
      pageKey: Key('home-news-scrolling-page'),
      assetPath: 'assets/images/home_news_page.png',
      sourceWidth: 1080,
      sourceHeight: 2376,
      title: '资讯',
      pinnedAction: _PinnedNavigationAction.search,
      backTapWidth: 150,
      backTapHeight: 220,
      initialStatusBarIconBrightness: Brightness.dark,
    );
  }
}

// 领券中心页
// 说明：首屏保留参考图中的红色沉浸式导航，滚出源导航后显示固定白色导航栏。
class HomeCouponCenterPage extends StatelessWidget {
  const HomeCouponCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImmersiveCampaignPage(
      pageKey: Key('home-coupon-center-page'),
      assetPath: 'assets/images/home_coupon_center_page.png',
      sourceWidth: 612,
      sourceHeight: 4096,
      title: '领券中心',
      pinnedNavigationKey: Key('home-coupon-center-pinned-navigation'),
      pinnedAction: _PinnedNavigationAction.share,
      backgroundColor: Color(0xFFFFF7F5),
      backWidth: 92,
      navigationHeight: 150,
      trailingLabel: '分享',
      trailingWidth: 92,
      lightStatusBar: true,
    );
  }
}

class _ImmersiveCampaignPage extends StatefulWidget {
  const _ImmersiveCampaignPage({
    required this.pageKey,
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.title,
    required this.pinnedNavigationKey,
    required this.backgroundColor,
    required this.backWidth,
    required this.navigationHeight,
    this.trailingLabel,
    this.trailingWidth = 0,
    this.pinnedAction,
    this.lightStatusBar = false,
    this.trailingOpensCustomerService = false,
  });

  final Key pageKey;
  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final String title;
  final Key pinnedNavigationKey;
  final Color backgroundColor;
  final double backWidth;
  final double navigationHeight;
  final String? trailingLabel;
  final double trailingWidth;
  final _PinnedNavigationAction? pinnedAction;
  final bool lightStatusBar;
  final bool trailingOpensCustomerService;

  @override
  State<_ImmersiveCampaignPage> createState() => _ImmersiveCampaignPageState();
}

class _ImmersiveCampaignPageState extends State<_ImmersiveCampaignPage> {
  late final ScrollController _scrollController;
  bool _showPinnedNavigation = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false)
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final sourceScale = MediaQuery.sizeOf(context).width / widget.sourceWidth;
    final sourceNavigationHeight = widget.navigationHeight * sourceScale;
    final shouldShow = _scrollController.offset >= sourceNavigationHeight;
    if (shouldShow == _showPinnedNavigation) return;
    setState(() => _showPinnedNavigation = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _showPinnedNavigation
            ? Brightness.dark
            : widget.lightStatusBar
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness: _showPinnedNavigation
            ? Brightness.light
            : widget.lightStatusBar
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarColor: widget.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        extendBodyBehindAppBar: true,
        body: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final scale = constraints.maxWidth / widget.sourceWidth;
                    return SingleChildScrollView(
                      key: widget.pageKey,
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: widget.sourceHeight * scale,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                widget.assetPath,
                                fit: BoxFit.fill,
                                gaplessPlayback: true,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              width: widget.backWidth * scale,
                              height: widget.navigationHeight * scale,
                              child: Semantics(
                                button: true,
                                label: '返回',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: Get.back,
                                ),
                              ),
                            ),
                            if (widget.trailingLabel != null)
                              Positioned(
                                right: 0,
                                top: 0,
                                width: widget.trailingWidth * scale,
                                height: widget.navigationHeight * scale,
                                child: Semantics(
                                  button: true,
                                  label: widget.trailingLabel,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: widget.trailingOpensCustomerService
                                        ? () => Get.toNamed(
                                              Routes.customerService,
                                            )
                                        : widget.trailingLabel == '搜索'
                                            ? () => Get.toNamed(
                                                  Routes.search,
                                                )
                                            : () {},
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  ignoring: !_showPinnedNavigation,
                  child: AnimatedOpacity(
                    key: widget.pinnedNavigationKey,
                    opacity: _showPinnedNavigation ? 1 : 0,
                    duration: const Duration(milliseconds: 140),
                    child: _PinnedWhiteNavigation(
                      title: widget.title,
                      action: widget.pinnedAction,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FixedNavigationReferencePage extends StatelessWidget {
  const _FixedNavigationReferencePage({
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.title,
    required this.backgroundColor,
    required this.navigationKey,
    required this.trailing,
    this.trailingRight = 16,
  });

  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final String title;
  final Color backgroundColor;
  final Key navigationKey;
  final Widget trailing;
  final double trailingRight;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                key: navigationKey,
                width: double.infinity,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Semantics(
                        button: true,
                        label: '返回',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: Get.back,
                          child: const SizedBox(
                            width: 54,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 23,
                              color: Color(0xFF1D1D1D),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: trailingRight,
                      top: 0,
                      bottom: 0,
                      child: Center(child: trailing),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final scale = constraints.maxWidth / sourceWidth;
                    return SingleChildScrollView(
                      key: PageStorageKey(assetPath),
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      child: Image.asset(
                        assetPath,
                        width: constraints.maxWidth,
                        height: sourceHeight * scale,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticNavigationAction extends StatelessWidget {
  const _StaticNavigationAction({
    super.key,
    required this.semanticLabel,
    required this.assetPath,
    required this.size,
  });

  final String semanticLabel;
  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

enum _PinnedNavigationAction { share, search, service }

class _ScrollingReferencePage extends StatefulWidget {
  const _ScrollingReferencePage({
    required this.pageKey,
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.title,
    required this.pinnedAction,
    required this.backTapWidth,
    required this.backTapHeight,
    required this.initialStatusBarIconBrightness,
  });

  final Key pageKey;
  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final String title;
  final _PinnedNavigationAction pinnedAction;
  final double backTapWidth;
  final double backTapHeight;
  final Brightness initialStatusBarIconBrightness;

  @override
  State<_ScrollingReferencePage> createState() =>
      _ScrollingReferencePageState();
}

class _ScrollingReferencePageState extends State<_ScrollingReferencePage> {
  late final ScrollController _scrollController;
  bool _showPinnedNavigation = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false)
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = screenWidth / widget.sourceWidth;
    final shouldShow = _scrollController.offset >= widget.backTapHeight * scale;
    if (shouldShow == _showPinnedNavigation) return;
    setState(() => _showPinnedNavigation = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _showPinnedNavigation
            ? Brightness.dark
            : widget.initialStatusBarIconBrightness,
        statusBarBrightness: _showPinnedNavigation
            ? Brightness.light
            : widget.initialStatusBarIconBrightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarColor: const Color(0xFFF7F7F7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final scale = constraints.maxWidth / widget.sourceWidth;
                    return SingleChildScrollView(
                      key: widget.pageKey,
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: widget.sourceHeight * scale,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                widget.assetPath,
                                fit: BoxFit.fill,
                                gaplessPlayback: true,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              width: widget.backTapWidth * scale,
                              height: widget.backTapHeight * scale,
                              child: Semantics(
                                button: true,
                                label: '返回',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: Get.back,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  ignoring: !_showPinnedNavigation,
                  child: AnimatedOpacity(
                    key: const Key('home-full-image-pinned-navigation'),
                    opacity: _showPinnedNavigation ? 1 : 0,
                    duration: const Duration(milliseconds: 140),
                    child: _PinnedWhiteNavigation(
                      title: widget.title,
                      action: widget.pinnedAction,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedWhiteNavigation extends StatelessWidget {
  const _PinnedWhiteNavigation({
    required this.title,
    required this.action,
  });

  final String title;
  final _PinnedNavigationAction? action;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: statusBarHeight + 48,
        child: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF202020),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Semantics(
                  button: true,
                  label: '返回',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: Get.back,
                    child: const SizedBox(
                      width: 54,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 23,
                        color: Color(0xFF1D1D1D),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: _buildAction(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction() {
    switch (action) {
      case _PinnedNavigationAction.share:
        return _PinnedIconAction(
          semanticLabel: '分享',
          icon: Icons.ios_share_outlined,
          onTap: () {},
        );
      case _PinnedNavigationAction.search:
        return _PinnedIconAction(
          semanticLabel: '搜索',
          icon: Icons.search_rounded,
          onTap: () => Get.toNamed(Routes.search),
        );
      case _PinnedNavigationAction.service:
        return _PinnedAssetAction(
          semanticLabel: '客服',
          assetPath: 'assets/images/finance_nav_service.png',
          onTap: () => Get.toNamed(Routes.customerService),
        );
      case null:
        return const SizedBox(width: 48);
    }
  }
}

class _PinnedIconAction extends StatelessWidget {
  const _PinnedIconAction({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 48,
          child: Icon(icon, size: 25, color: const Color(0xFF1D1D1D)),
        ),
      ),
    );
  }
}

class _PinnedAssetAction extends StatelessWidget {
  const _PinnedAssetAction({
    required this.semanticLabel,
    required this.assetPath,
    required this.onTap,
  });

  final String semanticLabel;
  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 48,
          child: Center(
            child: Image.asset(
              assetPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
