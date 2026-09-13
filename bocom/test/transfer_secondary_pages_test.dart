import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/member_info_model.dart';
import 'package:bocom/pages/tabs/home/transfer/home_transfer_view.dart';
import 'package:bocom/pages/tabs/home/transfer/transfer_secondary_pages.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('转账首页提供新增二级页入口', (tester) async {
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
      '转账设置',
      '信用卡还款',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }

    await tester.tap(find.bySemanticsLabel('单笔资金转入'));
    await tester.pumpAndSettle();
    expect(find.byType(SingleFundsTransferPage), findsOneWidget);
    expect(find.text('资金转入'), findsOneWidget);
  });

  testWidgets('转账设置使用无导航切图且不添加弹框与开关', (tester) async {
    tester.view.physicalSize = const Size(1080, 2388);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(home: TransferSettingsPage()),
    );

    expect(find.text('转账设置'), findsOneWidget);
    expect(
      find.image(
        const AssetImage(
          'assets/images/transfer_secondary/transfer_settings_body.png',
        ),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('客服'), findsOneWidget);
    expect(find.bySemanticsLabel('查询手机转账限额'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('单笔资金转入保留原功能并默认填入收款卡', (tester) async {
    tester.view.physicalSize = const Size(1080, 2388);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bank = MemberInfoBankList()
      ..bankName = '示例银行'
      ..cardType = 'II类账户'
      ..bankCard = '0000'
      ..accountBalance = 12.34;
    final logic = Get.put(BocLogic());
    logic.memberInfo.bankList = [bank];

    await tester.pumpWidget(
      const GetMaterialApp(home: SingleFundsTransferPage()),
    );

    expect(find.text('示例银行 II类账户(**0000)'), findsOneWidget);
    expect(find.text('可用余额： 12.34元'), findsOneWidget);
    expect(find.text('请选择付款卡'), findsOneWidget);
    expect(find.text('免手续费'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('收款卡'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('示例银行 II类账户(**0000)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('付款卡'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('示例银行 II类账户(**0000)').last);
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
