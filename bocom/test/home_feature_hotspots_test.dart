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
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
}
