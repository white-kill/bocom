import 'package:bocom/pages/tabs/home/transfer/home_transfer_view.dart';
import 'package:bocom/pages/tabs/home/transfer/transfer_secondary_pages.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('转账首页提供五个新增页面入口', (tester) async {
    tester.view.physicalSize = const Size(1080, 2388);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.routes,
        home: HomeTransferPage(contactsLoader: () async => const []),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in const [
      '预约转账',
      '单笔资金转入',
      '定期资金转入',
      '转账限额',
      '跨境支付通',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }

    await tester.tap(find.bySemanticsLabel('单笔资金转入'));
    await tester.pumpAndSettle();
    expect(find.byType(SingleFundsTransferPage), findsOneWidget);
    expect(find.text('资金转入'), findsOneWidget);
  });

  testWidgets('单笔资金转入可选择卡片并输入金额', (tester) async {
    tester.view.physicalSize = const Size(1080, 2388);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const GetMaterialApp(home: SingleFundsTransferPage()),
    );

    await tester.tap(find.bySemanticsLabel('收款卡'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('示例收款卡（****0000）'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('付款卡'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('示例付款卡（****0000）'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('single-funds-amount-field')),
      '100',
    );
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(const Key('single-funds-next-button')),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('静态转入页面保留切图并提供热区', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: PeriodicTransferPlanPage()),
    );
    expect(
      find.image(
        const AssetImage(
          'assets/images/transfer_secondary/periodic_transfer_plan_body.png',
        ),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('签约卡管理'), findsOneWidget);
    expect(find.bySemanticsLabel('添加计划'), findsOneWidget);
  });

  testWidgets('预约转账滚动后显示固定导航', (tester) async {
    tester.view.physicalSize = const Size(1080, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(home: AppointmentTransferPage()),
    );
    expect(find.text('预约转账'), findsNothing);
    await tester.drag(
      find.byKey(const Key('appointment-transfer-scroll')),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    expect(find.text('预约转账'), findsOneWidget);
  });

  testWidgets('限额页不把参考截图额度当作默认数据', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: TransferLimitPage()));

    expect(find.text('查询手机转账限额'), findsOneWidget);
    expect(find.text('10,000.00'), findsNothing);
    expect(find.text('2,000.00'), findsNothing);
    expect(find.text('--'), findsWidgets);
  });

  testWidgets('跨境支付通使用原生表单和隐私安全占位信息', (tester) async {
    tester.view.physicalSize = const Size(1080, 2388);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const GetMaterialApp(home: CrossBorderPaymentPage()),
    );

    expect(find.text('跨境支付通'), findsOneWidget);
    await tester.tap(find.text('手机号'));
    await tester.pump();
    expect(find.text('手机号'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('汇款人信息'),
      250,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('cross-border-payment-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pump();
    expect(find.text('DEMO USER'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('cross-border-payment-scroll')),
      const Offset(0, -1500),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('同意汇款服务协议'), findsOneWidget);
  });
}
