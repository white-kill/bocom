import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/pages/tabs/‌finance‌/finance_secondary_pages.dart';
import 'package:bocom/pages/tabs/‌finance‌/‌finance‌_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<void> setPhoneViewport(
    WidgetTester tester, {
    double height = 852,
  }) async {
    tester.view.physicalSize = Size(393, height);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
  }

  testWidgets('金融二级页逐页使用完整 Slice 并保留返回方式', (tester) async {
    await setPhoneViewport(tester);
    final pages = <Widget>[
      const FinanceWealthIndexPage(),
      const FinanceTradingStarsPage(),
      const FinancePensionSeasonPage(),
      const FinanceWealthForYouPage(),
      const FinanceFlashNewsPage(),
      const FinanceFlexibleInvestmentPage(),
      const FinanceIndexZonePage(),
      const FinanceRecurringInvestmentPage(),
      const FinanceIndustryFundPage(),
      const FinanceWealthSelectionPage(),
      const FinanceLoanRecommendationPage(),
    ];

    for (final page in pages) {
      await tester.pumpWidget(GetMaterialApp(home: page));
      await tester.pump();
      expect(find.byType(Image), findsOneWidget,
          reason: page.runtimeType.toString());
      expect(find.bySemanticsLabel('返回'), findsOneWidget,
          reason: page.runtimeType.toString());
    }
  });

  testWidgets('普通页正文起点严格等于参考图裁切比例', (tester) async {
    await setPhoneViewport(tester);
    final pages = <({
      Widget page,
      Key pageKey,
      double sourceWidth,
      double sourceCropTop,
    })>[
      (
        page: const FinanceWealthIndexPage(),
        pageKey: const Key('finance-wealth-index-page'),
        sourceWidth: 847,
        sourceCropTop: 164,
      ),
      (
        page: const FinancePensionSeasonPage(),
        pageKey: const Key('finance-pension-season-page'),
        sourceWidth: 1080,
        sourceCropTop: 209,
      ),
      (
        page: const FinanceFlashNewsPage(),
        pageKey: const Key('finance-flash-news-page'),
        sourceWidth: 1080,
        sourceCropTop: 209,
      ),
      (
        page: const FinanceIndexZonePage(),
        pageKey: const Key('finance-index-zone-page'),
        sourceWidth: 651,
        sourceCropTop: 142,
      ),
      (
        page: const FinanceIndustryFundPage(),
        pageKey: const Key('finance-industry-fund-page'),
        sourceWidth: 730,
        sourceCropTop: 145,
      ),
      (
        page: const FinanceWealthSelectionPage(),
        pageKey: const Key('finance-wealth-selection-page'),
        sourceWidth: 628,
        sourceCropTop: 124,
      ),
    ];

    for (final item in pages) {
      await tester.pumpWidget(GetMaterialApp(home: item.page));
      await tester.pump();
      final image = find.descendant(
        of: find.byKey(item.pageKey),
        matching: find.byType(Image),
      );
      expect(
        tester.getTopLeft(image).dy,
        closeTo(item.sourceCropTop * 393 / item.sourceWidth, 0.01),
        reason: item.page.runtimeType.toString(),
      );
    }
  });

  testWidgets('贷款推荐中的固定城市按源图比例覆盖为当前账号城市', (tester) async {
    await setPhoneViewport(tester);
    final logic = Get.put<BocLogic>(_TestBocLogic());
    logic.memberInfo.city = '合肥';

    await tester.pumpWidget(
      const GetMaterialApp(home: FinanceLoanRecommendationPage()),
    );
    await tester.pump();

    final city = tester.widget<Text>(
      find.byKey(const Key('finance-loan-account-city')),
    );
    expect(city.data, '合肥');
    expect(city.style?.fontSize, closeTo(52 * 393 / 1080, 0.001));
    expect(find.text('上海'), findsNothing);
  });

  testWidgets('沉浸式页不占顶部安全区且滚动后显示固定导航', (tester) async {
    await setPhoneViewport(tester);
    final pages = <({
      Widget page,
      Key pageKey,
      Key pinnedKey,
      double sourceWidth,
      double sourceNavigationHeight,
    })>[
      (
        page: const FinanceWealthForYouPage(),
        pageKey: const Key('finance-wealth-for-you-page'),
        pinnedKey: const Key('finance-wealth-for-you-pinned-navigation'),
        sourceWidth: 778,
        sourceNavigationHeight: 105,
      ),
      (
        page: const FinanceFlexibleInvestmentPage(),
        pageKey: const Key('finance-flexible-investment-page'),
        pinnedKey: const Key('finance-flexible-investment-pinned-navigation'),
        sourceWidth: 1080,
        sourceNavigationHeight: 220,
      ),
      (
        page: const FinanceRecurringInvestmentPage(),
        pageKey: const Key('finance-recurring-investment-page'),
        pinnedKey: const Key('finance-recurring-investment-pinned-navigation'),
        sourceWidth: 966,
        sourceNavigationHeight: 205,
      ),
    ];

    for (final item in pages) {
      await tester.pumpWidget(GetMaterialApp(home: item.page));
      await tester.pump();
      expect(tester.getTopLeft(find.byKey(item.pageKey)).dy, 0);
      expect(tester.widget<AnimatedOpacity>(find.byKey(item.pinnedKey)).opacity,
          0);

      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(item.pageKey),
          matching: find.byType(Scrollable),
        ),
      );
      final threshold = item.sourceNavigationHeight * 393 / item.sourceWidth;
      scrollable.position.jumpTo(threshold + 1);
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedOpacity>(find.byKey(item.pinnedKey)).opacity,
          1);
      expect(tester.getTopLeft(find.byKey(item.pinnedKey)).dy, 0);
    }
  });

  testWidgets('交夏理财季按源图返回图标中心点可正常返回', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (_) => TextButton(
            key: const Key('open-finance-wealth-for-you'),
            onPressed: () => Get.to<void>(
              () => const FinanceWealthForYouPage(),
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-finance-wealth-for-you')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('finance-wealth-for-you-page')), findsOneWidget);

    const sourceBackIconCenter = Offset(55, 110);
    const scale = 393 / 778;
    await tester.tapAt(sourceBackIconCenter * scale);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('finance-wealth-for-you-page')), findsNothing);
  });

  testWidgets('金融首页每个二级入口都在源图单元内并跳转正确', (tester) async {
    await setPhoneViewport(tester, height: 4300);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => GetMaterialApp(
          getPages: AppPages.routes,
          home: FinancePage(),
        ),
      ),
    );
    await tester.pump();

    final expectedRoutes = <String, String>{
      '上证指数': Routes.financeWealthIndex,
      '深证成指': Routes.financeWealthIndex,
      '黄金(活期金)': Routes.financeWealthIndex,
      '交银指数': Routes.financeWealthIndex,
      '7X24快讯': Routes.financeFlashNews,
      '养“基”活动': Routes.financeWealthSelection,
      '好理给你': Routes.financeWealthForYou,
      '养老保障季': Routes.financePensionSeason,
      '交易明星': Routes.financeTradingStars,
      '行业基会': Routes.financeIndustryFund,
      '财富精选': Routes.financeWealthSelection,
      '省心定投': Routes.financeRecurringInvestment,
      '指数专区': Routes.financeIndexZone,
      '灵活存取': Routes.financeFlexibleInvestment,
      '贷款推荐': Routes.financeLoanRecommendation,
      '更多发现-7X24快讯': Routes.financeFlashNews,
      '闲钱就放活期富': Routes.financeFlexibleInvestment,
    };

    for (final entry in expectedRoutes.entries) {
      final hotspot = find.byKey(Key('finance-entry-${entry.key}'));
      expect(hotspot, findsOneWidget, reason: entry.key);
      await tester.tap(hotspot);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, entry.value, reason: entry.key);
      Get.back<void>();
      await tester.pumpAndSettle();
    }
  });
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
