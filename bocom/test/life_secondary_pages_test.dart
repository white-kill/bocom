import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/pages/tabs/life/life_secondary_pages.dart';
import 'package:bocom/pages/tabs/life/life_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
  }

  testWidgets('生活二级页逐页使用完整参考图并保留退出方式', (tester) async {
    await setPhoneViewport(tester);
    final pages = <Widget>[
      const LifePaymentPage(),
      const LifeMoviePage(),
      const LifePartyFeePage(),
      const LifeVipPage(),
      const LifeSocialSecurityPage(),
      const LifeRideCodePage(),
      const LifeCultureTourismPage(),
      const LifeCreditPointsPage(),
      const LifeTongchengPage(),
      const LifeSupermarketPage(),
      const LifeBookstorePage(),
      const LifeJdZonePage(),
      const LifeAppliancesPage(),
      const LifeTeaZonePage(),
      const LifeNewEnergyPaymentPage(),
      const LifeFundCollectionPage(),
      const LifeCarbonGloryPage(),
      const LifeMoreServicesPage(),
    ];

    for (final page in pages) {
      await tester.pumpWidget(GetMaterialApp(home: page));
      await tester.pump();
      expect(find.byType(Image), findsWidgets,
          reason: page.runtimeType.toString());
      expect(
        find.bySemanticsLabel('返回').evaluate().isNotEmpty ||
            find.bySemanticsLabel('点击任意位置返回').evaluate().isNotEmpty,
        isTrue,
        reason: page.runtimeType.toString(),
      );
    }
  });

  testWidgets('参考图中的固定城市被账号城市按源图比例覆盖', (tester) async {
    await setPhoneViewport(tester);
    final logic = Get.put<BocLogic>(_TestBocLogic());
    logic.memberInfo.city = '南京';

    await tester.pumpWidget(const GetMaterialApp(home: LifePaymentPage()));
    await tester.pump();
    final paymentText = tester.widget<Text>(
      find.byKey(const Key('life-payment-account-city')),
    );
    expect(paymentText.data, '南京');
    expect(paymentText.style?.fontSize, closeTo(20.5 * 393 / 645, 0.001));

    await tester.pumpWidget(const GetMaterialApp(home: LifeMoviePage()));
    await tester.pump();
    expect(find.text('南京'), findsOneWidget);
    expect(find.text('上海'), findsNothing);

    await tester.pumpWidget(const GetMaterialApp(home: LifeTongchengPage()));
    await tester.pump();
    expect(find.text('南京出发'), findsNWidgets(4));
    expect(find.text('上海出发'), findsNothing);

    logic.memberInfo.city = '武汉';
    logic.update(['updateUI']);
    await tester.pump();
    expect(find.text('武汉出发'), findsNWidgets(4));
    expect(find.text('南京出发'), findsNothing);
  });

  testWidgets('参考图已弹出弹窗的页面点击任意位置直接退出', (tester) async {
    await setPhoneViewport(tester);
    final modalRoutes = <(String, Key)>[
      (Routes.lifePartyFee, const Key('life-party-fee-dismiss')),
      (Routes.lifeRideCode, const Key('life-ride-code-dismiss')),
      (Routes.lifeCreditPoints, const Key('life-credit-points-dismiss')),
      (Routes.lifeNewEnergyPayment, const Key('life-new-energy-dismiss')),
    ];

    for (final item in modalRoutes) {
      await tester.pumpWidget(
        GetMaterialApp(
          getPages: AppPages.routes,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Get.toNamed<void>(item.$1),
              child: const Text('打开'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, item.$1);

      await tester.tap(find.byKey(item.$2));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, isNot(item.$1));
    }
  });

  testWidgets('沉浸式长页按源图导航高度显示固定 AppBar', (tester) async {
    await setPhoneViewport(tester);
    final pages = <({
      Widget page,
      Key pageKey,
      Key pinnedKey,
      double sourceWidth,
      double sourceNavigationHeight,
    })>[
      (
        page: const LifeTeaZonePage(),
        pageKey: const Key('life-tea-zone-page'),
        pinnedKey: const Key('life-tea-zone-pinned-navigation'),
        sourceWidth: 1080,
        sourceNavigationHeight: 176,
      ),
      (
        page: const LifeCarbonGloryPage(),
        pageKey: const Key('life-carbon-glory-page'),
        pinnedKey: const Key('life-carbon-glory-pinned-navigation'),
        sourceWidth: 638,
        sourceNavigationHeight: 110,
      ),
    ];

    for (final item in pages) {
      await tester.pumpWidget(GetMaterialApp(home: item.page));
      await tester.pumpAndSettle();
      final pinned = find.byKey(item.pinnedKey);
      final opacity = tester.widget<AnimatedOpacity>(pinned);
      expect(opacity.opacity, 0);
      expect(tester.getTopLeft(find.byKey(item.pageKey)).dy, 0);

      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(item.pageKey),
          matching: find.byType(Scrollable),
        ),
      );
      final threshold = item.sourceNavigationHeight * 393 / item.sourceWidth;
      scrollable.position.jumpTo(threshold - 0.5);
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedOpacity>(pinned).opacity, 0);

      scrollable.position.jumpTo(threshold + 0.5);
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedOpacity>(pinned).opacity, 1);
      expect(tester.getTopLeft(pinned).dy, 0);
    }
  });

  testWidgets('生活服务更多页分类与右侧切图联动且热点可跳转', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.routes,
        home: const LifeMoreServicesPage(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('life-more-menu')), findsOneWidget);
    expect(find.byKey(const Key('life-more-content')), findsOneWidget);

    const scale = 393 / 1080;
    final menuTop =
        tester.getTopLeft(find.byKey(const Key('life-more-menu'))).dy;
    final firstLabelTop = tester
        .getTopLeft(find.byKey(const Key('life-more-menu-label-payment')))
        .dy;
    final firstIndicator =
        find.byKey(const Key('life-more-menu-indicator-payment'));
    expect((firstLabelTop - menuTop) / scale, closeTo(17.3, 0.1));
    expect(
      (tester.getTopLeft(firstIndicator).dy - menuTop) / scale,
      closeTo(10, 0.1),
    );
    expect(tester.getSize(firstIndicator).height / scale, closeTo(49, 0.1));

    await tester.tap(find.text('政务服务'));
    await tester.pumpAndSettle();
    final contentTop = tester.getTopLeft(
      find.byKey(const Key('life-more-content')),
    );
    final sectionTop = tester.getTopLeft(
      find.byKey(const Key('life-more-section-government')),
    );
    expect((contentTop.dy - sectionTop.dy).abs(), lessThan(1));

    final hotspotRoutes = <({String section, String label, String route})>[
      (section: 'payment', label: '生活缴费', route: Routes.lifePayment),
      (section: 'transport', label: '文旅专区', route: Routes.lifeCultureTourism),
      (section: 'transport', label: '同程', route: Routes.lifeTongcheng),
      (section: 'transport', label: '乘车码', route: Routes.lifeRideCode),
      (section: 'shopping', label: '商超立减', route: Routes.lifeSupermarket),
      (section: 'shopping', label: '京东专区', route: Routes.lifeJdZone),
      (section: 'shopping', label: '唯品会', route: Routes.lifeVip),
      (section: 'shopping', label: '博库商城', route: Routes.lifeBookstore),
      (section: 'government', label: '社保专区', route: Routes.lifeSocialSecurity),
      (section: 'government', label: '党费', route: Routes.lifePartyFee),
      (section: 'entertainment', label: '电影票', route: Routes.lifeMovie),
      (section: 'entertainment', label: '淘票票电影', route: Routes.lifeMovie),
      (section: 'entertainment', label: '茶饮专区', route: Routes.lifeTeaZone),
      (section: 'local', label: '新能源缴费', route: Routes.lifeNewEnergyPayment),
    ];

    const menuTitles = <String, String>{
      'payment': '充值缴费',
      'transport': '交通出行',
      'shopping': '甄选购物',
      'government': '政务服务',
      'entertainment': '餐饮娱乐',
      'local': '本地生活',
    };
    for (final entry in hotspotRoutes) {
      await tester.tap(find.text(menuTitles[entry.section]!));
      await tester.pumpAndSettle();
      final hotspot = find.byKey(
        Key('life-more-service-${entry.section}-${entry.label}'),
      );
      expect(hotspot, findsOneWidget, reason: entry.label);
      await tester.ensureVisible(hotspot);
      await tester.tap(hotspot);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, entry.route, reason: entry.label);
      Get.back<void>();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('生活首页热区位于各自源图单元并跳转正确路由', (tester) async {
    tester.view.physicalSize = const Size(393, 2400);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 47);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => GetMaterialApp(
          getPages: AppPages.routes,
          home: LifePage(),
        ),
      ),
    );
    await tester.pump();

    final expectedRoutes = <String, String>{
      '生活缴费': Routes.lifePayment,
      '碳星荣耀': Routes.lifeCarbonGlory,
      '淘票票': Routes.lifeMovie,
      '博库商城': Routes.lifeBookstore,
      '京东专区': Routes.lifeJdZone,
      '同程': Routes.lifeTongcheng,
      '商超立减': Routes.lifeSupermarket,
      '文旅专区': Routes.lifeCultureTourism,
      '党费': Routes.lifePartyFee,
      '电影票': Routes.lifeMovie,
      '乘车码': Routes.lifeRideCode,
      '唯品会': Routes.lifeVip,
      '更多': Routes.lifeMoreServices,
      '智慧文旅用星出游': Routes.lifeCultureTourism,
      '家电数码': Routes.lifeAppliances,
      '用星出游': Routes.lifeCultureTourism,
      '新能源缴费': Routes.lifeNewEnergyPayment,
      '资金归集': Routes.lifeFundCollection,
      '精选推荐机场服务': Routes.lifeCultureTourism,
      '精选推荐春秋出行': Routes.lifeCultureTourism,
      '精选推荐商超立减': Routes.lifeSupermarket,
      '推荐文旅专区': Routes.lifeCultureTourism,
      '推荐商超立减': Routes.lifeSupermarket,
      '推荐乘车码': Routes.lifeRideCode,
    };
    for (final label in expectedRoutes.keys) {
      expect(
        find.byKey(Key('life-home-hotspot-$label')),
        findsOneWidget,
        reason: label,
      );
    }

    final payment = find.byKey(const Key('life-home-hotspot-生活缴费'));
    final carbon = find.byKey(const Key('life-home-hotspot-碳星荣耀'));
    expect(tester.getRect(payment).overlaps(tester.getRect(carbon)), isFalse);

    final primarySection =
        tester.getRect(find.byKey(const Key('life-home-primary-section')));
    final primaryScale = primarySection.width / 1080;
    final measuredSourceRects = <String, Rect>{
      '智慧文旅用星出游': const Rect.fromLTWH(40, 1001, 1002, 264),
      '家电数码': const Rect.fromLTWH(40, 1295, 244, 349),
      '用星出游': const Rect.fromLTWH(284, 1295, 245, 349),
      '新能源缴费': const Rect.fromLTWH(553, 1295, 244, 349),
      '资金归集': const Rect.fromLTWH(797, 1295, 245, 349),
      '精选推荐机场服务': const Rect.fromLTWH(80, 1800, 230, 333),
      '精选推荐春秋出行': const Rect.fromLTWH(310, 1800, 230, 333),
      '精选推荐商超立减': const Rect.fromLTWH(770, 1800, 230, 333),
    };
    for (final entry in measuredSourceRects.entries) {
      final rendered =
          tester.getRect(find.byKey(Key('life-home-hotspot-${entry.key}')));
      final sourceRect = Rect.fromLTWH(
        (rendered.left - primarySection.left) / primaryScale,
        (rendered.top - primarySection.top) / primaryScale,
        rendered.width / primaryScale,
        rendered.height / primaryScale,
      );
      expect(sourceRect.left, closeTo(entry.value.left, 0.1),
          reason: entry.key);
      expect(sourceRect.top, closeTo(entry.value.top, 0.1), reason: entry.key);
      expect(sourceRect.width, closeTo(entry.value.width, 0.1),
          reason: entry.key);
      expect(sourceRect.height, closeTo(entry.value.height, 0.1),
          reason: entry.key);
    }

    for (final entry in expectedRoutes.entries) {
      await tester.tap(find.byKey(Key('life-home-hotspot-${entry.key}')));
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
