import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/member_info_model.dart';
import 'package:bocom/pages/tabs/mine/children/account_asset/account_secondary_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('账户二级页只替换参考图已展示的账户数据', (tester) async {
    final logic = Get.put<BocLogic>(_TestBocLogic());
    logic.memberInfo = _memberInfo();

    await tester.pumpWidget(
      const GetMaterialApp(home: AccountFundsTransferPage()),
    );
    await tester.pump();

    expect(find.textContaining('8431'), findsNothing);
    expect(find.text('李晓明'), findsNothing);

    await tester.pumpWidget(
      const GetMaterialApp(home: AccountLossPage()),
    );
    await tester.pump();

    expect(find.text('622260****8431'), findsOneWidget);
    expect(find.text('13866665555'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('账户解绑和排序页不会显示参考图示例尾号', (tester) async {
    final logic = Get.put<BocLogic>(_TestBocLogic());
    logic.memberInfo = _memberInfo();

    await tester.pumpWidget(
      const GetMaterialApp(home: AccountUnbindPage()),
    );
    await tester.pump();
    expect(find.text('**8431'), findsOneWidget);
    expect(find.text('**2910'), findsNothing);

    await tester.pumpWidget(
      const GetMaterialApp(home: AccountSortPage()),
    );
    await tester.pump();
    expect(find.text('(**8431)'), findsOneWidget);
    expect(find.text('(**2910)'), findsNothing);
  });

  testWidgets('所属网点弹窗绑定网点和支付系统行号', (tester) async {
    final logic = Get.put<BocLogic>(_TestBocLogic());
    logic.memberInfo = _memberInfo();

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAccountOutletDialog(context),
            child: const Text('打开'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-outlet-dialog')), findsOneWidget);
    expect(find.text('合肥长江中路支行'), findsOneWidget);
    expect(find.text('301290000123'), findsOneWidget);
  });

  testWidgets('安心付二级页不覆盖协议和开通按钮交互', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: AccountFamilyPayPage()),
    );
    await tester.pump();

    expect(find.byKey(const Key('account-family-pay-agreement')), findsNothing);
    expect(find.byKey(const Key('account-family-pay-open')), findsNothing);
  });

  testWidgets('所有账户二级页都有可用返回导航', (tester) async {
    final pages = <Widget>[
      const AccountFundsTransferPage(),
      const AccountLossPage(),
      const AccountMoreFunctionsPage(),
      const AccountApplicationPage(),
      const AccountActivationPage(),
      const AccountUnbindPage(),
      const AccountSortPage(),
      const AccountFamilyPayPage(),
    ];

    for (final page in pages) {
      await tester.pumpWidget(GetMaterialApp(home: page));
      await tester.pump();
      expect(find.bySemanticsLabel('返回'), findsOneWidget);
    }
  });
}

MemberInfoModel _memberInfo() {
  final bank = MemberInfoBankList()
    ..bankName = '交通银行'
    ..bankCard = '6222601234568431'
    ..realName = '李晓明'
    ..openOutlets = '合肥长江中路支行';
  return MemberInfoModel()
    ..realName = '李晓明'
    ..phone = '13866665555'
    ..bankId = '301290000123'
    ..branchBelongs = '合肥长江中路支行'
    ..bankList = [bank];
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
