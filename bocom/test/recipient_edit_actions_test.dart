import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/pages/tabs/home/transfer/account_transfer/account_transfer_support_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

ContactsModel _recipient(String name, String card) => ContactsModel()
  ..name = name
  ..bankName = '测试银行'
  ..bankCard = card;

void main() {
  tearDown(Get.reset);

  Future<void> openRecipients(WidgetTester tester) async {
    tester.view.physicalSize = const Size(579, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(GetMaterialApp(
      home: AccountTransferRecipientsPage(
        contactsLoader: () async => [
          _recipient('A组测试收款人', 'TEST****0001'),
          _recipient('Z组测试收款人', 'TEST****0002'),
        ],
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('编辑显示等宽删除与下一步，删除更新对应记录、分组和空态', (tester) async {
    await openRecipients(tester);
    await tester.tap(find.bySemanticsLabel('编辑A组测试收款人'));
    await tester.pumpAndSettle();

    final deleteRect = tester.getRect(
      find.byKey(const Key('edit-recipient-delete-button')),
    );
    final nextRect = tester.getRect(
      find.byKey(const Key('add-recipient-next-button')),
    );
    expect(deleteRect.width, closeTo(nextRect.width, 0.1));
    expect(deleteRect.top, nextRect.top);
    expect(deleteRect.right, lessThan(nextRect.left));

    // 删除不依赖编辑中的必填字段，始终删除最初打开的那一条记录。
    await tester.enterText(find.widgetWithText(TextField, 'A组测试收款人'), '');
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.byType(AddRecipientPage), findsNothing);
    expect(find.text('A组测试收款人'), findsNothing);
    expect(find.byKey(const Key('recipient-section-A')), findsNothing);
    expect(find.text('Z组测试收款人'), findsOneWidget);
    expect(find.byKey(const Key('recipient-section-Z')), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('编辑Z组测试收款人'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('暂无收款人'), findsOneWidget);
    expect(
        find.byKey(const Key('recipient-alphabet-rail-items')), findsNothing);
  });

  testWidgets('返回不删除，编辑下一步正常保存，新增只有下一步', (tester) async {
    await openRecipients(tester);
    await tester.tap(find.bySemanticsLabel('编辑A组测试收款人'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    expect(find.text('A组测试收款人'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('编辑A组测试收款人'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'A组测试收款人'),
      'B组测试收款人',
    );
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    expect(find.text('A组测试收款人'), findsNothing);
    expect(find.text('B组测试收款人'), findsOneWidget);
    expect(find.text('Z组测试收款人'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('添加收款人'));
    await tester.pumpAndSettle();
    expect(find.text('删除'), findsNothing);
    expect(find.text('下一步'), findsOneWidget);
  });
}
