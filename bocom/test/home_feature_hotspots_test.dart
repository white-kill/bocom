import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/pages/tabs/home/home_view.dart';
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
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
