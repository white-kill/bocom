import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/member_info_model.dart';
import 'package:bocom/pages/tabs/home/transfer/phone_transfer/home_phone_transfer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('手机号转账页使用已有银行卡信息且空态不允许下一步', (tester) async {
    _registerBank();

    await tester.pumpWidget(
      const GetMaterialApp(home: HomePhoneTransferPage()),
    );

    expect(find.text('手机号转账'), findsOneWidget);
    expect(find.text('付款卡'), findsOneWidget);
    expect(find.text('交通银行 借记卡(**2910)'), findsOneWidget);
    expect(find.textContaining('II类账户'), findsNothing);
    expect(find.text('可用余额： 37.53元'), findsOneWidget);
    expect(find.text('请输入收款人的真实姓名'), findsOneWidget);
    expect(find.text('请输入收款人手机号'), findsOneWidget);
    expect(find.text('0手续费'), findsOneWidget);
    expect(find.text('限额说明'), findsNothing);

    final nextButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, '下一步'),
    );
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('姓名手机号金额均有效后只触发本地下一步回调', (tester) async {
    _registerBank(balance: 2000);
    var nextCount = 0;

    await tester.pumpWidget(
      GetMaterialApp(
        home: HomePhoneTransferPage(onNext: () => nextCount++),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('phone-transfer-name-field')),
      '小光',
    );
    await tester.enterText(
      find.byKey(const Key('phone-transfer-phone-field')),
      '1311311311',
    );
    await tester.enterText(
      find.byKey(const Key('transfer-amount-field')),
      '1000',
    );
    await tester.pump();

    ElevatedButton button() => tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, '下一步'),
        );
    expect(button().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('phone-transfer-phone-field')),
      '13113113113',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.text('1,000.00'), findsOneWidget);
    expect(button().onPressed, isNotNull);
    await tester.tap(find.widgetWithText(ElevatedButton, '下一步'));
    await tester.pump();
    expect(nextCount, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('付款卡可打开账号转账同款选择弹层', (tester) async {
    _registerBank();

    await tester.pumpWidget(
      const GetMaterialApp(home: HomePhoneTransferPage()),
    );

    await tester.tap(find.byKey(const Key('payer-account-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('payer-account-sheet')), findsOneWidget);
    expect(find.text('选择付款账户'), findsOneWidget);
    expect(find.text('添加付款账户'), findsOneWidget);
  });

  testWidgets('内容滚动时手机号转账导航保持固定', (tester) async {
    _registerBank();

    await tester.pumpWidget(
      const GetMaterialApp(home: HomePhoneTransferPage()),
    );

    final titleBefore = tester.getCenter(find.text('手机号转账'));
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('手机号转账')), titleBefore);
    expect(find.textContaining('7.防范非法集资'), findsOneWidget);
  });
}

void _registerBank({double balance = 37.53}) {
  final logic = Get.put(BocLogic());
  final bank = MemberInfoBankList()
    ..bankName = '交通银行'
    ..bankCard = '6217001630076962910'
    ..cardType = 'II类账户'
    ..accountBalance = balance;
  logic.memberInfo.bankList = [bank];
}
