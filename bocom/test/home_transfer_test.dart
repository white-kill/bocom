import 'dart:async';

import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/pages/tabs/home/transfer/account_transfer/home_account_transfer_view.dart';
import 'package:bocom/pages/tabs/home/transfer/home_transfer_view.dart';
import 'package:bocom/pages/tabs/home/transfer/phone_transfer/home_phone_transfer_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('转账页显示参考图并提供返回与客服热区', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: HomeTransferPage(contactsLoader: () async => const []),
      ),
    );

    expect(
      find.image(const AssetImage('assets/images/home_transfer_page.png')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('返回'), findsOneWidget);
    expect(find.bySemanticsLabel('客服'), findsOneWidget);
    expect(find.bySemanticsLabel('账号转账'), findsOneWidget);
    expect(find.bySemanticsLabel('手机号转账'), findsOneWidget);
    expect(find.bySemanticsLabel('转账记录'), findsOneWidget);
    expect(
      find.image(
        const AssetImage(
          'assets/images/account_transfer/icons/recipient_contact.png',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('点击手机号转账进入原生手机号表单', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.routes,
        home: HomeTransferPage(contactsLoader: () async => const []),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('手机号转账'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePhoneTransferPage), findsOneWidget);
    expect(find.byKey(const Key('phone-transfer-name-field')), findsOneWidget);
    expect(find.byKey(const Key('phone-transfer-phone-field')), findsOneWidget);
  });

  testWidgets('常用收款人使用接口数据渲染', (tester) async {
    final contact = ContactsModel()
      ..name = '测试收款人'
      ..bankName = '测试银行'
      ..bankCard = '6222000012345678';

    await tester.pumpWidget(
      GetMaterialApp(
        home: HomeTransferPage(contactsLoader: () async => [contact]),
      ),
    );
    await tester.pump();

    expect(find.text('测试收款人'), findsOneWidget);
    expect(find.text('测试银行 借记卡（**5678）'), findsOneWidget);
  });

  testWidgets('点击常用收款人进入快捷联系人模式', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetPhysicalSize);
    final contact = ContactsModel()
      ..name = '沈光德'
      ..bankName = '中国建设银行'
      ..bankCard = '6217001630076962353';

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.routes,
        home: HomeTransferPage(contactsLoader: () async => [contact]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('沈光德'), findsOneWidget);
    await tester.tap(find.text('沈光德'));
    await tester.pumpAndSettle();

    final page = tester.widget<HomeAccountTransferPage>(
      find.byType(HomeAccountTransferPage),
    );
    expect(page.entryMode, AccountTransferEntryMode.quickRecipient);
    expect(find.byKey(const Key('quick-recipient-card')), findsOneWidget);
    expect(find.text('沈光德'), findsOneWidget);
  });

  testWidgets('常用收款人不会截断为第一条且有加载状态', (tester) async {
    final completer = Completer<List<ContactsModel>>();
    await tester.pumpWidget(
      GetMaterialApp(
        home: HomeTransferPage(contactsLoader: () => completer.future),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final first = ContactsModel()
      ..name = '第一位'
      ..bankName = '银行甲'
      ..bankCard = '1111';
    final second = ContactsModel()
      ..name = '第二位'
      ..bankName = '银行乙'
      ..bankCard = '2222';
    completer.complete([first, second]);
    await tester.pumpAndSettle();

    expect(find.text('第一位'), findsOneWidget);
    expect(find.text('第二位'), findsOneWidget);
  });
}
