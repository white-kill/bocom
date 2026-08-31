import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../config/abc_config/account_city_builder.dart';

const _financeSecondaryAssetRoot = 'assets/images/finance_secondary';

class FinanceWealthIndexPage extends StatelessWidget {
  const FinanceWealthIndexPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceNativeImagePage(
        pageKey: Key('finance-wealth-index-page'),
        assetPath: '$_financeSecondaryAssetRoot/wealth_index.png',
        sourceWidth: 847,
        sourceHeight: 3932,
        sourceCropTop: 164,
        title: '交银财富指数',
        backgroundColor: Color(0xFFF7F7F7),
      );
}

class FinanceTradingStarsPage extends StatelessWidget {
  const FinanceTradingStarsPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceImmersiveImagePage(
        pageKey: Key('finance-trading-stars-page'),
        pinnedNavigationKey: Key('finance-trading-stars-pinned-navigation'),
        assetPath: '$_financeSecondaryAssetRoot/trading_stars.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        sourceNavigationHeight: 220,
        sourceBackWidth: 150,
        title: '明星收益排行榜',
        backgroundColor: Color(0xFF18171D),
        initialLightStatusBar: true,
        showShareAction: true,
      );
}

class FinancePensionSeasonPage extends StatelessWidget {
  const FinancePensionSeasonPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceNativeImagePage(
        pageKey: Key('finance-pension-season-page'),
        assetPath: '$_financeSecondaryAssetRoot/pension_season.png',
        sourceWidth: 1080,
        sourceHeight: 2167,
        sourceCropTop: 209,
        title: '盛夏狂欢季',
        backgroundColor: Color(0xFF14A5EE),
      );
}

class FinanceWealthForYouPage extends StatelessWidget {
  const FinanceWealthForYouPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceImmersiveImagePage(
        pageKey: Key('finance-wealth-for-you-page'),
        pinnedNavigationKey: Key('finance-wealth-for-you-pinned-navigation'),
        assetPath: '$_financeSecondaryAssetRoot/wealth_for_you.png',
        sourceWidth: 778,
        sourceHeight: 4096,
        sourceNavigationHeight: 105,
        sourceBackWidth: 82,
        sourceBackRect: Rect.fromLTWH(0, 55, 115, 115),
        title: '“交”夏理财季',
        backgroundColor: Color(0xFFFFB661),
      );
}

class FinanceFlashNewsPage extends StatelessWidget {
  const FinanceFlashNewsPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceNativeImagePage(
        pageKey: Key('finance-flash-news-page'),
        assetPath: '$_financeSecondaryAssetRoot/flash_news.png',
        sourceWidth: 1080,
        sourceHeight: 3161,
        sourceCropTop: 209,
        title: '7X24快讯',
        backgroundColor: Color(0xFFF7F7F7),
      );
}

class FinanceFlexibleInvestmentPage extends StatelessWidget {
  const FinanceFlexibleInvestmentPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceImmersiveImagePage(
        pageKey: Key('finance-flexible-investment-page'),
        pinnedNavigationKey:
            Key('finance-flexible-investment-pinned-navigation'),
        assetPath: '$_financeSecondaryAssetRoot/flexible_investment.png',
        sourceWidth: 1080,
        sourceHeight: 3802,
        sourceNavigationHeight: 220,
        sourceBackWidth: 155,
        title: '活钱+',
        backgroundColor: Color(0xFFF7F7F7),
        showShareAction: true,
      );
}

class FinanceIndexZonePage extends StatelessWidget {
  const FinanceIndexZonePage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceNativeImagePage(
        pageKey: Key('finance-index-zone-page'),
        assetPath: '$_financeSecondaryAssetRoot/index_zone.png',
        sourceWidth: 651,
        sourceHeight: 3954,
        sourceCropTop: 142,
        title: '指数专区',
        backgroundColor: Color(0xFFF7F7F7),
        actions: _FinanceNavigationActions.searchAndService,
      );
}

class FinanceRecurringInvestmentPage extends StatelessWidget {
  const FinanceRecurringInvestmentPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceImmersiveImagePage(
        pageKey: Key('finance-recurring-investment-page'),
        pinnedNavigationKey:
            Key('finance-recurring-investment-pinned-navigation'),
        assetPath: '$_financeSecondaryAssetRoot/recurring_investment.png',
        sourceWidth: 966,
        sourceHeight: 4096,
        sourceNavigationHeight: 205,
        sourceBackWidth: 140,
        title: '定投专区',
        backgroundColor: Color(0xFFF7F7F7),
        pinnedActions: _FinanceNavigationActions.searchAndService,
      );
}

class FinanceIndustryFundPage extends StatelessWidget {
  const FinanceIndustryFundPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceNativeImagePage(
        pageKey: Key('finance-industry-fund-page'),
        assetPath: '$_financeSecondaryAssetRoot/industry_fund.png',
        sourceWidth: 730,
        sourceHeight: 3951,
        sourceCropTop: 145,
        title: '行业基会',
        backgroundColor: Color(0xFFF6F6F6),
        actions: _FinanceNavigationActions.miniProgram,
      );
}

class FinanceWealthSelectionPage extends StatelessWidget {
  const FinanceWealthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceNativeImagePage(
        pageKey: Key('finance-wealth-selection-page'),
        assetPath: '$_financeSecondaryAssetRoot/wealth_selection.png',
        sourceWidth: 628,
        sourceHeight: 3972,
        sourceCropTop: 124,
        title: '8月好基会',
        backgroundColor: Color(0xFFF2F2F2),
        actions: _FinanceNavigationActions.share,
      );
}

class FinanceLoanRecommendationPage extends StatelessWidget {
  const FinanceLoanRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) => const _FinanceImmersiveImagePage(
        pageKey: Key('finance-loan-recommendation-page'),
        pinnedNavigationKey:
            Key('finance-loan-recommendation-pinned-navigation'),
        assetPath: '$_financeSecondaryAssetRoot/loan_recommendation.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        sourceNavigationHeight: 220,
        sourceBackWidth: 155,
        title: '智能贷款推荐',
        backgroundColor: Color(0xFFF7F7F7),
        initialLightStatusBar: true,
        pinnedActions: _FinanceNavigationActions.service,
        showAccountCity: true,
      );
}

enum _FinanceNavigationActions {
  none,
  share,
  service,
  searchAndService,
  miniProgram,
}

class _FinanceNativeImagePage extends StatelessWidget {
  const _FinanceNativeImagePage({
    required this.pageKey,
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.sourceCropTop,
    required this.title,
    required this.backgroundColor,
    this.actions = _FinanceNavigationActions.none,
  });

  final Key pageKey;
  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final double sourceCropTop;
  final String title;
  final Color backgroundColor;
  final _FinanceNavigationActions actions;

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
        body: LayoutBuilder(
          builder: (_, constraints) {
            final scale = constraints.maxWidth / sourceWidth;
            final sourceNavigationOnScreen = sourceCropTop * scale;
            final safeTop = MediaQuery.paddingOf(context).top;
            final toolbarHeight =
                (sourceNavigationOnScreen - safeTop).clamp(36.0, 64.0);
            return Column(
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: SizedBox(width: double.infinity, height: safeTop),
                ),
                _FinanceNavigationBar(
                  height: toolbarHeight,
                  title: title,
                  actions: actions,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: pageKey,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    child: Image.asset(
                      assetPath,
                      width: constraints.maxWidth,
                      height: sourceHeight * scale,
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FinanceImmersiveImagePage extends StatefulWidget {
  const _FinanceImmersiveImagePage({
    required this.pageKey,
    required this.pinnedNavigationKey,
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.sourceNavigationHeight,
    required this.sourceBackWidth,
    this.sourceBackRect,
    required this.title,
    required this.backgroundColor,
    this.initialLightStatusBar = false,
    this.showShareAction = false,
    this.pinnedActions = _FinanceNavigationActions.none,
    this.showAccountCity = false,
  });

  final Key pageKey;
  final Key pinnedNavigationKey;
  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final double sourceNavigationHeight;
  final double sourceBackWidth;
  final Rect? sourceBackRect;
  final String title;
  final Color backgroundColor;
  final bool initialLightStatusBar;
  final bool showShareAction;
  final _FinanceNavigationActions pinnedActions;
  final bool showAccountCity;

  @override
  State<_FinanceImmersiveImagePage> createState() =>
      _FinanceImmersiveImagePageState();
}

class _FinanceImmersiveImagePageState
    extends State<_FinanceImmersiveImagePage> {
  late final ScrollController _controller;
  bool _showPinnedNavigation = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(keepScrollOffset: false)
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_controller.hasClients) return;
    final scale = MediaQuery.sizeOf(context).width / widget.sourceWidth;
    final next = _controller.offset >= widget.sourceNavigationHeight * scale;
    if (next == _showPinnedNavigation) return;
    setState(() => _showPinnedNavigation = next);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _showPinnedNavigation
        ? Brightness.dark
        : widget.initialLightStatusBar
            ? Brightness.light
            : Brightness.dark;
    final pinnedActions = widget.showShareAction
        ? _FinanceNavigationActions.share
        : widget.pinnedActions;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        statusBarBrightness:
            brightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: widget.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final scale = constraints.maxWidth / widget.sourceWidth;
                  final sourceBackRect = widget.sourceBackRect ??
                      Rect.fromLTWH(
                        0,
                        0,
                        widget.sourceBackWidth,
                        widget.sourceNavigationHeight,
                      );
                  return SingleChildScrollView(
                    key: widget.pageKey,
                    controller: _controller,
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
                              alignment: Alignment.topCenter,
                              gaplessPlayback: true,
                            ),
                          ),
                          if (widget.showAccountCity)
                            _FinanceLoanCityOverlay(scale: scale),
                          Positioned(
                            left: sourceBackRect.left * scale,
                            top: sourceBackRect.top * scale,
                            width: sourceBackRect.width * scale,
                            height: sourceBackRect.height * scale,
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
                  key: widget.pinnedNavigationKey,
                  opacity: _showPinnedNavigation ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: ColoredBox(
                    color: Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: _FinanceNavigationBar(
                        height: 48,
                        title: widget.title,
                        actions: pinnedActions,
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

class _FinanceLoanCityOverlay extends StatelessWidget {
  const _FinanceLoanCityOverlay({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return AccountCityBuilder(
      builder: (_, city) => Positioned(
        left: 950 * scale,
        top: 516 * scale,
        width: 130 * scale,
        height: 80 * scale,
        child: Semantics(
          label: '当前城市，$city',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                city,
                key: const Key('finance-loan-account-city'),
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FinanceNavigationBar extends StatelessWidget {
  const _FinanceNavigationBar({
    required this.height,
    required this.title,
    required this.actions,
  });

  final double height;
  final String title;
  final _FinanceNavigationActions actions;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF171717),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _FinanceNavigationButton(
                label: '返回',
                onTap: Get.back,
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                  color: Color(0xFF171717),
                ),
              ),
            ),
            if (actions != _FinanceNavigationActions.none)
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: _FinanceNavigationActionsView(actions: actions),
              ),
          ],
        ),
      ),
    );
  }
}

class _FinanceNavigationActionsView extends StatelessWidget {
  const _FinanceNavigationActionsView({required this.actions});

  final _FinanceNavigationActions actions;

  @override
  Widget build(BuildContext context) {
    switch (actions) {
      case _FinanceNavigationActions.none:
        return const SizedBox.shrink();
      case _FinanceNavigationActions.share:
        return const _FinanceNavigationButton(
          label: '分享',
          onTap: _emptyTap,
          child: Icon(Icons.ios_share_outlined, size: 22),
        );
      case _FinanceNavigationActions.service:
        return const _FinanceNavigationButton(
          label: '客服',
          onTap: _emptyTap,
          child: Icon(Icons.headset_mic_outlined, size: 22),
        );
      case _FinanceNavigationActions.searchAndService:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FinanceNavigationButton(
              label: '搜索',
              onTap: _emptyTap,
              child: Icon(Icons.search, size: 23),
            ),
            _FinanceNavigationButton(
              label: '客服',
              onTap: _emptyTap,
              child: Icon(Icons.headset_mic_outlined, size: 22),
            ),
          ],
        );
      case _FinanceNavigationActions.miniProgram:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FinanceNavigationButton(
              label: '更多',
              onTap: _emptyTap,
              child: Icon(Icons.more_horiz, size: 25),
            ),
            _FinanceNavigationButton(
              label: '关闭',
              onTap: _emptyTap,
              child: Icon(Icons.radio_button_checked, size: 22),
            ),
          ],
        );
    }
  }
}

class _FinanceNavigationButton extends StatelessWidget {
  const _FinanceNavigationButton({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: double.infinity,
          child: Center(child: child),
        ),
      ),
    );
  }
}

void _emptyTap() {}
