import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/config/model/member_info_model.dart';
import 'package:bocom/pages/tabs/home/transfer/account_transfer/home_account_transfer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('账号转账页使用原生表单并可滚动', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: HomeAccountTransferPage()),
    );

    expect(find.bySemanticsLabel('返回'), findsOneWidget);
    expect(find.bySemanticsLabel('客服'), findsOneWidget);
    expect(find.text('账号转账'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    final contactIcon = find.image(
      const AssetImage(
        'assets/images/account_transfer/icons/recipient_contact.png',
      ),
    );
    final scanIcon = find.image(
      const AssetImage(
        'assets/images/account_transfer/icons/card_scan.png',
      ),
    );
    final bankChevron = find.image(
      const AssetImage(
        'assets/images/account_transfer/icons/row_chevron.png',
      ),
    );
    expect(contactIcon, findsOneWidget);
    expect(scanIcon, findsOneWidget);
    expect(bankChevron, findsOneWidget);
    final contactRight = tester.getTopRight(contactIcon).dx;
    expect(tester.getTopRight(scanIcon).dx, closeTo(contactRight, 0.01));
    expect(tester.getTopRight(bankChevron).dx, closeTo(contactRight, 0.01));
    expect(find.byIcon(Icons.contacts_outlined), findsNothing);
    expect(find.byIcon(Icons.document_scanner_outlined), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(
      find.image(
        const AssetImage(
          'assets/images/account_transfer/account_transfer_initial.jpg',
        ),
      ),
      findsNothing,
    );

    await tester.drag(
      find.byType(ListView),
      const Offset(0, -400),
    );
    await tester.pump();

    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(find.bySemanticsLabel('返回'), findsOneWidget);
  });

  testWidgets('账号转账表单完成两步校验后直接进入本地结果页', (tester) async {
    final recipient = ContactsModel()
      ..name = '张三'
      ..bankCard = '6222000012345678'
      ..bankName = '交通银行';
    final steps = <String>[];
    await tester.pumpWidget(
      GetMaterialApp(
        home: HomeAccountTransferPage(
          initialRecipient: recipient,
          passwordVerificationLauncher: (_, transaction) async {
            steps.add('password');
            expect(transaction.primaryText, '转给 张三 100.00');
            return true;
          },
          smsVerificationLauncher: (_, __, ___) async {
            steps.add('sms');
            return true;
          },
        ),
      ),
    );

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(5));

    await tester.enterText(fields.at(3), '100');
    await tester.pump();

    expect(find.text('张三'), findsOneWidget);
    expect(find.text('6222000012345678'), findsOneWidget);
    expect(find.text('交通银行'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('transfer-amount-field')),
          )
          .controller
          ?.text,
      '100',
    );

    final nextButton = find.bySemanticsLabel('下一步').first;
    await tester.ensureVisible(nextButton);
    await tester.pump();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('account-transfer-success-page')),
      findsOneWidget,
    );
    expect(find.text('确认转账信息'), findsNothing);
    expect(steps, ['sms', 'password']);
    expect(find.text('张三'), findsOneWidget);
    expect(find.text('交通银行(**5678)'), findsOneWidget);
  });

  testWidgets('本地结果页保留用户选择的到账时间', (tester) async {
    final recipient = ContactsModel()
      ..name = '张三'
      ..bankCard = '6222000012345678'
      ..bankName = '交通银行';
    await tester.pumpWidget(
      GetMaterialApp(
        home: HomeAccountTransferPage(
          initialRecipient: recipient,
          now: () => DateTime(2026, 8, 12, 10, 30),
          passwordVerificationLauncher: (_, __) async => true,
          smsVerificationLauncher: (_, __, ___) async => true,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('transfer-amount-field')),
      '100',
    );
    await tester.tap(find.text('更换到账时间'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('预计2小时后到账'));
    await tester.pumpAndSettle();
    final nextButton = find.widgetWithText(ElevatedButton, '下一步');
    await tester.scrollUntilVisible(
      nextButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('预计2小时后到账，实际到账时间取决于收款银行'), findsOneWidget);
  });

  testWidgets('金额空态、聚焦和失焦格式与补图一致', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: HomeAccountTransferPage()),
    );

    final title = tester.widget<Text>(find.text('转账金额'));
    expect(title.style?.fontSize, 18);

    final amountField = find.byKey(const Key('transfer-amount-field'));
    expect(
      tester.widget<TextField>(amountField).decoration?.hintText,
      '0手续费',
    );
    await tester.tap(amountField);
    await tester.enterText(amountField, '1000');
    await tester.pump();

    expect(find.text('1000'), findsOneWidget);
    expect(find.byKey(const Key('amount-unit-tooltip')), findsOneWidget);
    expect(find.text('千'), findsOneWidget);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.text('1,000.00'), findsOneWidget);
  });

  testWidgets('超出余额显示红色提示并支持说明快捷标签', (tester) async {
    final logic = Get.put(BocLogic());
    final bank = MemberInfoBankList()
      ..bankName = '交通银行'
      ..bankCard = '6217001630076962353'
      ..cardType = 'II类账户'
      ..accountBalance = 1195.67;
    logic.memberInfo.bankList = [bank];

    await tester.pumpWidget(
      const GetMaterialApp(home: HomeAccountTransferPage()),
    );

    final amountField = find.byKey(const Key('transfer-amount-field'));
    await tester.tap(amountField);
    await tester.enterText(amountField, '1000000');
    await tester.pump();
    expect(
      find.byKey(const Key('amount-insufficient-message')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('amount-insufficient-tip-shape')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Positioned>(
            find.byKey(const Key('amount-insufficient-message')),
          )
          .bottom,
      -7,
    );
    expect(
      tester
          .widget<Positioned>(
            find.byKey(const Key('amount-insufficient-message')),
          )
          .left,
      23,
    );
    expect(
      tester
          .widget<Transform>(find.byKey(const Key('transfer-currency-symbol')))
          .transform
          .getTranslation()
          .y,
      4,
    );
    expect(find.text('余额不足，更换付款卡或补充资金'), findsOneWidget);
    expect(find.text('百万'), findsOneWidget);

    final description = find.byKey(const Key('transfer-description-field'));
    await tester.tap(description);
    await tester.pump();
    expect(find.text('选填，对方可见，60字内'), findsOneWidget);
    expect(find.text('生活费'), findsOneWidget);
    expect(find.text('归还欠款'), findsOneWidget);

    await tester.tap(amountField);
    await tester.enterText(amountField, '10000000');
    await tester.tap(description);
    await tester.pump();
    expect(find.text('10,000,000.00'), findsOneWidget);
    expect(find.text('千万'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().startsWith('实时提交，预计1小时内到账'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('付款账户与到账说明弹层可打开并关闭', (tester) async {
    final logic = Get.put(BocLogic());
    final bank = MemberInfoBankList()
      ..bankName = '交通银行'
      ..bankCard = '6217001630076962353'
      ..cardType = 'II类账户'
      ..accountBalance = 1195.67;
    logic.memberInfo.bankList = [bank];

    await tester.pumpWidget(
      const GetMaterialApp(home: HomeAccountTransferPage()),
    );

    await tester.tap(find.byKey(const Key('payer-account-card')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('payer-account-sheet')), findsOneWidget);
    expect(find.text('选择付款账户'), findsOneWidget);
    expect(find.text('添加付款账户'), findsOneWidget);
    final payerOption = find.byKey(const Key('payer-account-option'));
    final viewportWidth = MediaQuery.sizeOf(tester.element(payerOption)).width;
    expect(
      tester.getSize(payerOption).height,
      closeTo(viewportWidth / 1206 * 222, .5),
    );
    final payerClose = find.byTooltip('关闭');
    final payerSheetLeft =
        tester.getTopLeft(find.byKey(const Key('payer-account-sheet'))).dx;
    expect(tester.getTopLeft(payerClose).dx, lessThan(payerSheetLeft + 30));
    await tester.tap(payerClose);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('arrival-summary-text')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('arrival-explanation-sheet')), findsNothing);

    final arrivalInfoButton = find.byKey(
      const Key('arrival-explanation-button'),
    );
    expect(tester.getSize(arrivalInfoButton), const Size(36, 36));
    await tester.tap(arrivalInfoButton);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('arrival-explanation-sheet')), findsOneWidget);
    expect(find.text('到账说明'), findsOneWidget);
    final arrivalSheetLeft = tester
        .getTopLeft(find.byKey(const Key('arrival-explanation-sheet')))
        .dx;
    expect(
      tester.getTopLeft(find.byTooltip('关闭')).dx,
      lessThan(arrivalSheetLeft + 30),
    );
  });
}
