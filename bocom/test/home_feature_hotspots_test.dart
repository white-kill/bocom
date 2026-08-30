import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/pages/tabs/home/home_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('收支账本和账单保留独立点击事件', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    var ledgerTapCount = 0;
    var billTapCount = 0;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => RefreshConfiguration(
          child: GetMaterialApp(
            home: HomePage(
              onIncomeExpenseLedgerTap: () => ledgerTapCount++,
              onBillTap: () => billTapCount++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const Key('home-status-bar-placeholder'))),
      const Size(402, 0),
    );
    expect(find.bySemanticsLabel('收支账本'), findsOneWidget);
    expect(find.bySemanticsLabel('账单'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('home-income-expense-ledger-hotspot')),
    );
    await tester.pump();
    expect(ledgerTapCount, 1);
    expect(billTapCount, 0);

    await tester.tap(find.byKey(const Key('home-bill-hotspot')));
    await tester.pump();
    expect(ledgerTapCount, 1);
    expect(billTapCount, 1);
  });

  testWidgets('首页只补系统状态栏高出原图的部分', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => RefreshConfiguration(
          child: GetMaterialApp(home: HomePage()),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const Key('home-status-bar-placeholder'))),
      const Size(360, 20),
    );
  });

  testWidgets('首页账户资产入口打开我的资产 Tab', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    AppConfig.config.abcLogic = Get.put<BocLogic>(_TestBocLogic());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => RefreshConfiguration(
          child: GetMaterialApp(home: HomePage()),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('账户资产，进入我的资产'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('我的资产'), findsOneWidget);
    expect(find.text('我的账户'), findsNothing);
  });

  testWidgets('首页二级页入口位于各自卡片内并跳转到正确页面', (tester) async {
    tester.view.physicalSize = const Size(360, 4000);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    final destinations = <(
      Key,
      String,
      String,
      Size,
    )>[
      (
        const Key('home-activity-center-hotspot'),
        Routes.homeActivityCenter,
        '活动中心页',
        const Size(488 / 3, 697 / 3),
      ),
      (
        const Key('home-city-zone-card-hotspot'),
        Routes.homeCityZone,
        '城市专区页',
        const Size(488 / 3, 697 / 3),
      ),
      (
        const Key('home-preferred-products-hotspot'),
        Routes.homePreferredProducts,
        '全部理财产品页',
        const Size(1002 / 3, 1189 / 3),
      ),
      (
        const Key('home-one-stop-credit-hotspot'),
        Routes.homeOneStopCredit,
        '一站式授信页',
        const Size(1002 / 3, 524 / 3),
      ),
      (
        const Key('home-activity-banner-hotspot'),
        Routes.homeActivityCenter,
        '活动中心页',
        const Size(1002 / 3, 404 / 3),
      ),
      (
        const Key('home-coupon-center-card-hotspot'),
        Routes.homeCouponCenter,
        '领券中心页',
        const Size(150, 71),
      ),
      (
        const Key('home-welfare-season-hotspot'),
        Routes.homeWelfareSeason,
        '交行福利季页',
        const Size(150, 71),
      ),
      (
        const Key('home-pension-zone-hotspot'),
        Routes.homePensionZone,
        '养老专区页',
        const Size(1002 / 3, 820 / 3),
      ),
      (
        const Key('home-salary-zone-hotspot'),
        Routes.homeSalaryZone,
        '交薪通专区页',
        const Size(1002 / 3, 775 / 3),
      ),
    ];

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => RefreshConfiguration(
          child: GetMaterialApp(
            getPages: [
              GetPage(
                name: Routes.homeActivityCenter,
                page: () => const Scaffold(body: Text('活动中心页')),
              ),
              GetPage(
                name: Routes.homeCityZone,
                page: () => const Scaffold(body: Text('城市专区页')),
              ),
              GetPage(
                name: Routes.homePreferredProducts,
                page: () => const Scaffold(body: Text('全部理财产品页')),
              ),
              GetPage(
                name: Routes.homeOneStopCredit,
                page: () => const Scaffold(body: Text('一站式授信页')),
              ),
              GetPage(
                name: Routes.homeCouponCenter,
                page: () => const Scaffold(body: Text('领券中心页')),
              ),
              GetPage(
                name: Routes.homeWelfareSeason,
                page: () => const Scaffold(body: Text('交行福利季页')),
              ),
              GetPage(
                name: Routes.homePensionZone,
                page: () => const Scaffold(body: Text('养老专区页')),
              ),
              GetPage(
                name: Routes.homeSalaryZone,
                page: () => const Scaffold(body: Text('交薪通专区页')),
              ),
            ],
            home: HomePage(),
          ),
        ),
      ),
    );
    await tester.pump();

    final activityRect = tester.getRect(find.byKey(destinations[0].$1));
    final cityRect = tester.getRect(find.byKey(destinations[1].$1));
    final productsRect = tester.getRect(find.byKey(destinations[2].$1));
    final creditRect = tester.getRect(find.byKey(destinations[3].$1));
    final activityBannerRect = tester.getRect(find.byKey(destinations[4].$1));
    final couponRect = tester.getRect(find.byKey(destinations[5].$1));
    final welfareRect = tester.getRect(find.byKey(destinations[6].$1));
    final pensionRect = tester.getRect(find.byKey(destinations[7].$1));
    final salaryRect = tester.getRect(find.byKey(destinations[8].$1));

    expect(activityRect.right, lessThan(cityRect.left));
    expect(activityRect.bottom, lessThan(productsRect.top));
    expect(creditRect.bottom, lessThan(activityBannerRect.top));
    expect(activityBannerRect.bottom, lessThanOrEqualTo(couponRect.top));
    expect(couponRect.right, lessThan(welfareRect.left));
    expect(pensionRect.bottom, lessThan(salaryRect.top));

    for (final destination in destinations) {
      final hotspot = find.byKey(destination.$1);
      final actualSize = tester.getSize(hotspot);
      expect(actualSize.width, closeTo(destination.$4.width, 0.01));
      expect(actualSize.height, closeTo(destination.$4.height, 0.01));

      await tester.tap(hotspot);
      await tester.pumpAndSettle();
      expect(find.text(destination.$3), findsOneWidget);
      Get.back<void>();
      await tester.pumpAndSettle();
    }
  });
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
