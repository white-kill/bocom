import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/pages/tabs/home/feature_pages/home_static_feature_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('城市专区的导航栏在内容滚动后仍固定', (tester) async {
    final accountLogic = Get.put<BocLogic>(_TestBocLogic());
    accountLogic.memberInfo.city = '南京';

    await tester.pumpWidget(
      const GetMaterialApp(home: HomeCityZonePage()),
    );
    await tester.pumpAndSettle();

    final navigation = find.byKey(
      const Key('home-city-zone-fixed-navigation'),
    );
    final initialTop = tester.getTopLeft(navigation).dy;

    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(navigation).dy, initialTop);
    expect(find.text('城市专区'), findsOneWidget);
    expect(find.text('南京'), findsOneWidget);

    final cityText = tester.widget<Text>(
      find.byKey(const Key('home-city-zone-account-city')),
    );
    final logicalWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(
        cityText.style?.fontSize, closeTo(42.5 * logicalWidth / 1080, 0.001));
    expect(cityText.style?.fontWeight, FontWeight.w400);
    expect(cityText.style?.color, const Color(0xFF222222));

    accountLogic.memberInfo.city = '武汉';
    accountLogic.update(['updateUI']);
    await tester.pump();

    expect(find.text('武汉'), findsOneWidget);
    expect(find.text('南京'), findsNothing);
  });

  testWidgets('活期盈的图片导航与长内容一起滚动', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: HomeDemandDepositPlusPage()),
    );
    await tester.pumpAndSettle();

    final page = find.byKey(
      const Key('home-demand-deposit-plus-scrolling-page'),
    );
    final image = find.byType(Image);
    final initialTop = tester.getTopLeft(image).dy;
    expect(initialTop, 0);

    await tester.drag(page, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(image).dy, lessThan(initialTop - 300));
    final pinnedNavigation = tester.widget<AnimatedOpacity>(
      find.byKey(const Key('home-full-image-pinned-navigation')),
    );
    expect(pinnedNavigation.opacity, 1);
    expect(find.text('活期盈'), findsOneWidget);
    expect(find.bySemanticsLabel('返回'), findsNWidgets(2));
  });

  testWidgets('存款页保留搜索和客服导航元素', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: HomeDepositPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('存款'), findsOneWidget);
    expect(find.byKey(const Key('home-deposit-search-action')), findsOneWidget);
    expect(
        find.byKey(const Key('home-deposit-service-action')), findsOneWidget);
    expect(
      find.byKey(const Key('home-deposit-fixed-navigation')),
      findsOneWidget,
    );
  });

  testWidgets('新增首页二级页逐页保留返回导航和各自操作', (tester) async {
    final pages = <Widget>[
      const HomeActivityCenterPage(),
      const HomePreferredProductsPage(),
      const HomeWelfareSeasonPage(),
      const HomeOneStopCreditPage(),
      const HomePensionZonePage(),
      const HomeSalaryZonePage(),
      const HomeCouponCenterPage(),
    ];

    for (final page in pages) {
      await tester.pumpWidget(GetMaterialApp(home: page));
      await tester.pump();
      expect(find.bySemanticsLabel('返回'), findsOneWidget);
    }

    await tester.pumpWidget(
      const GetMaterialApp(home: HomeActivityCenterPage()),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('搜索'), findsOneWidget);

    await tester.pumpWidget(
      const GetMaterialApp(home: HomeOneStopCreditPage()),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('客服'), findsOneWidget);

    await tester.pumpWidget(
      const GetMaterialApp(home: HomePreferredProductsPage()),
    );
    await tester.pump();
    expect(find.text('全部理财产品'), findsOneWidget);
    expect(
      find.byKey(const Key('home-preferred-products-search-action')),
      findsOneWidget,
    );
  });

  testWidgets('沉浸式二级页按参考图导航高度切换固定 AppBar', (tester) async {
    final pages = <({
      Widget page,
      Key pageKey,
      Key pinnedKey,
      String title,
      double sourceWidth,
      double navigationHeight,
    })>[
      (
        page: const HomeActivityCenterPage(),
        pageKey: const Key('home-activity-center-page'),
        pinnedKey: const Key('home-activity-center-pinned-navigation'),
        title: '活动中心',
        sourceWidth: 944,
        navigationHeight: 150,
      ),
      (
        page: const HomeWelfareSeasonPage(),
        pageKey: const Key('home-welfare-season-page'),
        pinnedKey: const Key('home-welfare-season-pinned-navigation'),
        title: '交行福利季',
        sourceWidth: 730,
        navigationHeight: 140,
      ),
      (
        page: const HomeOneStopCreditPage(),
        pageKey: const Key('home-one-stop-credit-page'),
        pinnedKey: const Key('home-one-stop-credit-pinned-navigation'),
        title: '一站式授信',
        sourceWidth: 1080,
        navigationHeight: 220,
      ),
      (
        page: const HomePensionZonePage(),
        pageKey: const Key('home-pension-zone-page'),
        pinnedKey: const Key('home-pension-zone-pinned-navigation'),
        title: '养老专区',
        sourceWidth: 575,
        navigationHeight: 118,
      ),
      (
        page: const HomeSalaryZonePage(),
        pageKey: const Key('home-salary-zone-page'),
        pinnedKey: const Key('home-salary-zone-pinned-navigation'),
        title: '交薪通',
        sourceWidth: 711,
        navigationHeight: 140,
      ),
      (
        page: const HomeCouponCenterPage(),
        pageKey: const Key('home-coupon-center-page'),
        pinnedKey: const Key('home-coupon-center-pinned-navigation'),
        title: '领券中心',
        sourceWidth: 612,
        navigationHeight: 150,
      ),
    ];

    for (final item in pages) {
      await tester.pumpWidget(GetMaterialApp(home: item.page));
      await tester.pumpAndSettle();

      final pinnedFinder = find.byKey(item.pinnedKey);
      expect(
        tester.widget<AnimatedOpacity>(pinnedFinder).opacity,
        0,
        reason: '${item.title} 首屏不应覆盖原图沉浸式导航',
      );
      expect(tester.getTopLeft(find.byKey(item.pageKey)).dy, 0);

      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(item.pageKey),
          matching: find.byType(Scrollable),
        ),
      );
      final sourceScale =
          tester.getSize(find.byKey(item.pageKey)).width / item.sourceWidth;
      final revealOffset = item.navigationHeight * sourceScale;

      scrollable.position.jumpTo(revealOffset - 0.5);
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedOpacity>(pinnedFinder).opacity,
        0,
        reason: '${item.title} 在源图导航尚未完全滚出时不应显示 AppBar',
      );

      scrollable.position.jumpTo(revealOffset + 0.5);
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedOpacity>(pinnedFinder).opacity,
        1,
        reason: '${item.title} 滚出原图导航后应显示固定 AppBar',
      );
      expect(find.text(item.title), findsOneWidget);
      final pinnedTop = tester.getTopLeft(pinnedFinder).dy;

      scrollable.position.jumpTo(revealOffset + 300);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(pinnedFinder).dy,
        pinnedTop,
        reason: '${item.title} 的 AppBar 应固定在屏幕顶部',
      );
    }
  });
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
