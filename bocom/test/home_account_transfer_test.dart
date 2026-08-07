import 'package:bocom/config/model/contacts_model.dart';
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

  testWidgets('账号转账表单支持预填、输入金额并进入确认页', (tester) async {
    final recipient = ContactsModel()
      ..name = '张三'
      ..bankCard = '6222000012345678'
      ..bankName = '交通银行';
    await tester.pumpWidget(
      GetMaterialApp(
        home: HomeAccountTransferPage(
          initialRecipient: recipient,
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
    expect(find.text('0手续费'), findsOneWidget);

    final nextButton = find.bySemanticsLabel('下一步').first;
    await tester.ensureVisible(nextButton);
    await tester.pump();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.text('确认转账信息'), findsOneWidget);
    expect(find.text('¥ 100'), findsOneWidget);
  });
}
