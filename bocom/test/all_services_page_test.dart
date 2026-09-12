import 'package:bocom/pages/tabs/home/all_services/all_services_view.dart';
import 'package:bocom/pages/tabs/mine/children/zxzm/zxzm_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => GetMaterialApp(
          getPages: AppPages.routes,
          home: const AllServicesPage(),
        ),
      ),
    );
    await tester.pump();
  }

  Text menuText(WidgetTester tester, String label) {
    return tester.widget<Text>(find.text(label));
  }

  testWidgets('页面由固定顶部、左侧菜单和右侧切图区组成', (tester) async {
    await pumpPage(tester);

    expect(find.text('全部服务'), findsOneWidget);
    expect(find.byKey(const Key('all-services-common-header')), findsOneWidget);
    expect(find.byKey(const Key('all-services-menu')), findsOneWidget);
    expect(find.byKey(const Key('all-services-content')), findsOneWidget);
    expect(menuText(tester, '最近使用').style?.color, const Color(0xFF0878F9));
  });

  testWidgets('点击左侧分类会定位右侧对应切图', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('支付'));
    await tester.pumpAndSettle();

    expect(menuText(tester, '支付').style?.color, const Color(0xFF0878F9));
    final contentTop = tester.getTopLeft(
      find.byKey(const Key('all-services-content')),
    );
    final paymentTop = tester.getTopLeft(
      find.byKey(const Key('all-services-section-payment')),
    );
    expect((paymentTop.dy - contentTop.dy).abs(), lessThan(1));
  });

  testWidgets('滑动右侧内容会自动更新左侧焦点', (tester) async {
    await pumpPage(tester);

    await tester.drag(
      find.byKey(const Key('all-services-content')),
      const Offset(0, -1300),
    );
    await tester.pumpAndSettle();

    expect(menuText(tester, '支付').style?.color, const Color(0xFF0878F9));
    expect(
      menuText(tester, '最近使用').style?.color,
      const Color(0xFF595959),
    );
  });

  testWidgets('右侧滑动到底时左侧聚焦工具', (tester) async {
    await pumpPage(tester);

    await tester.fling(
      find.byKey(const Key('all-services-content')),
      const Offset(0, -100000),
      10000,
    );
    await tester.pumpAndSettle();

    expect(menuText(tester, '工具').style?.color, const Color(0xFF0878F9));
  });

  testWidgets('已实现的服务入口会在对应切图上提供热点', (tester) async {
    await pumpPage(tester);

    expect(
      find.byKey(const Key('all-services-service-recent-账户/资产')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('all-services-service-recent-交易明细')),
      findsOneWidget,
    );

    await tester.tap(find.text('转账'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('all-services-service-transfer-账号转账')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('all-services-service-transfer-全部收款人')),
      findsOneWidget,
    );
  });

  testWidgets('点击服务热点会进入现有目标页', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.byKey(const Key('all-services-service-recent-存款')),
    );
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.homeDeposit);
  });

  testWidgets('点击查询中的资信证明会进入资信证明页', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('查询'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('all-services-service-query-资信证明')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ZxzmPage), findsOneWidget);
    expect(find.text('资信证明'), findsOneWidget);
  });
}
