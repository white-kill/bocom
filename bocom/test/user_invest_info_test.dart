import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_invest_info/user_invest_info_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_invest_info/user_invest_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

void main() {
  tearDown(Get.reset);

  test('income source starts empty and can be selected', () {
    final logic = UserInvestInfoLogic();

    expect(logic.state.incomeSource.value, '');

    logic.selectIncomeSource('生产经营所得');

    expect(logic.state.incomeSource.value, '生产经营所得');
  });

  test('annual income and investment experience can be selected', () {
    final logic = UserInvestInfoLogic();

    logic.selectAnnualIncome('100（含）-300万');
    logic.selectInvestmentExperience('否');

    expect(logic.state.annualIncome.value, '100（含）-300万');
    expect(logic.state.investmentExperience.value, '否');
  });

  test('no debt is exclusive and any selected debt displays yes', () {
    final logic = UserInvestInfoLogic();

    logic.selectDebts(['没有', '有，亲戚朋友借款']);
    expect(logic.state.debts, ['没有']);
    expect(logic.debtDisplayValue, '没有');

    logic.selectDebts([
      '有，信用卡欠款、消费信贷等短期信用债务',
      '有，住房抵押贷款等长期定额债务',
    ]);
    expect(logic.debtDisplayValue, '有');
  });

  testWidgets('income source sheet confirms a selection and uses ellipsis',
      (tester) async {
    final logic = UserInvestInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserInvestInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-invest-income-source')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('income-source-sheet')), findsOneWidget);
    expect(find.byType(ListWheelScrollView), findsOneWidget);

    const selected = '利息、股息、转让等金融性资产收入';
    await tester.tap(find.text(selected));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    final value = tester.widget<BaseText>(
      find.byKey(const Key('user-invest-income-source-value')),
    );
    expect(value.text, selected);
    expect(value.color, const Color(0xFF181818));
    expect(value.maxLines, 1);
    expect(value.overflow, TextOverflow.ellipsis);
  });

  testWidgets('cancelling the income source sheet keeps the current value',
      (tester) async {
    final logic = UserInvestInfoLogic()
      ..selectIncomeSource('工资、劳务报酬');
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserInvestInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-invest-income-source')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生产经营所得'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(logic.state.incomeSource.value, '工资、劳务报酬');
  });

  testWidgets('annual income sheet confirms and fills the selected value',
      (tester) async {
    final logic = UserInvestInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserInvestInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-invest-annual-income')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('annual-income-sheet')), findsOneWidget);

    const selected = '100（含）-300万';
    await tester.drag(
      find.byKey(const Key('annual-income-picker')),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(selected));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    final value = tester.widget<BaseText>(
      find.byKey(const Key('user-invest-annual-income-value')),
    );
    expect(value.text, selected);
    expect(value.color, const Color(0xFF181818));
  });

  testWidgets('investment experience sheet confirms no', (tester) async {
    final logic = UserInvestInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserInvestInfoPage(logic: logic)),
      ),
    );

    await tester.tap(
      find.byKey(const Key('user-invest-investment-experience')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('investment-experience-sheet')),
      findsOneWidget,
    );

    await tester.tap(find.text('否'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    final value = tester.widget<BaseText>(
      find.byKey(const Key('user-invest-investment-experience-value')),
    );
    expect(value.text, '否');
    expect(value.color, const Color(0xFF181818));
  });

  testWidgets('debt page returns no and fills no on the invest page',
      (tester) async {
    final logic = UserInvestInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserInvestInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-invest-debt')));
    await tester.pumpAndSettle();
    expect(find.text('尚未偿清的数额较大的债务'), findsOneWidget);

    await tester.tap(find.text('没有'));
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    final value = tester.widget<BaseText>(
      find.byKey(const Key('user-invest-debt-value')),
    );
    expect(value.text, '没有');
    expect(value.color, const Color(0xFF181818));
    expect(value.maxLines, 1);
    expect(value.overflow, TextOverflow.ellipsis);
  });
}
