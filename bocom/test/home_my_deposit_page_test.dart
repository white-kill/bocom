import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/member_info_model.dart';
import 'package:bocom/pages/tabs/home/feature_pages/home_my_deposit_page.dart';
import 'package:bocom/pages/tabs/home/feature_pages/home_static_feature_pages.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('存款页的我的存款入口打开二级页', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const HomeDepositPage(),
        getPages: [
          GetPage(
            name: Routes.homeMyDeposit,
            page: () => const HomeMyDepositPage(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('home-deposit-my-deposit-hotspot')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeMyDepositPage), findsOneWidget);
    expect(find.text('我的存款'), findsNWidgets(2));
  });

  testWidgets('我的存款页显示并刷新当前账户数据', (tester) async {
    final logic = Get.put<BocLogic>(_TestBocLogic());
    logic.memberInfo
      ..accountBalance = 100
      ..bankList = [
        _bank(card: '****0000', balance: 12.5),
        _bank(card: '****1111', balance: 87.5),
      ];

    await tester.pumpWidget(
      const GetMaterialApp(home: HomeMyDepositPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('100.00'), findsOneWidget);
    expect(find.text('12.50'), findsOneWidget);
    expect(find.text('人民币 | II类账户(**0000)'), findsOneWidget);

    logic.memberInfo.bankList.first.accountBalance = 22.5;
    logic.update(['updateUI']);
    await tester.pump();

    expect(find.text('110.00'), findsOneWidget);
    expect(find.text('22.50'), findsOneWidget);

    await tester.tap(find.byKey(const Key('my-deposit-account-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('my-deposit-account-option-1')));
    await tester.pumpAndSettle();

    expect(find.text('人民币 | II类账户(**1111)'), findsOneWidget);
    expect(find.text('87.50'), findsOneWidget);
  });

  testWidgets('我的存款沉浸导航滚出后显示固定导航', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: HomeMyDepositPage()),
    );
    await tester.pumpAndSettle();

    AnimatedOpacity pinned() => tester.widget<AnimatedOpacity>(
          find.byKey(const Key('home-my-deposit-pinned-navigation')),
        );

    expect(pinned().opacity, 0);

    await tester.drag(
      find.byKey(const Key('home-my-deposit-scroll-view')),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();

    expect(pinned().opacity, 1);
    expect(find.bySemanticsLabel('返回'), findsNWidgets(2));
  });
}

MemberInfoBankList _bank({required String card, required double balance}) {
  return MemberInfoBankList()
    ..bankCard = card
    ..accountBalance = balance
    ..cardType = 'II类账户';
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
