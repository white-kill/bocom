import 'package:bocom/pages/tabs/home/print/print_bill_list/component/print_bill_advanced_filter_panel.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/filter/transaction_advanced_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPanel(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => MaterialApp(home: child),
        child: Scaffold(
          body: PrintBillAdvancedFilterPanel(
            initialValue: const TransactionAdvancedFilterValue(),
            onComplete: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('金额选项以四列单行展示', (tester) async {
    await pumpPanel(tester);

    final amountSection = find.byKey(
      const ValueKey('advanced_filter_section_金额'),
    );
    final choices = [
      '小于1万',
      '1万-5万',
      '5万以上',
      '自定义',
    ].map((label) {
      return find.descendant(
        of: amountSection,
        matching: find.byKey(ValueKey('advanced_filter_choice_$label')),
      );
    }).toList();

    for (final choice in choices) {
      expect(choice, findsOneWidget);
    }
    expect(
      choices.map((choice) => tester.getRect(choice).top).toSet().length,
      1,
    );
  });

  testWidgets('自定义金额使用带边框的金额输入框', (tester) async {
    await pumpPanel(tester);

    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();

    for (final key in const [
      ValueKey('advanced_filter_min_amount'),
      ValueKey('advanced_filter_max_amount'),
    ]) {
      final field = tester.widget<TextField>(find.byKey(key));
      expect(field.decoration?.hintText, '请输入金额');
    }
    expect(find.text('至'), findsOneWidget);
  });

  testWidgets('地点、方式和开户行初始折叠并可按标题展开', (tester) async {
    await pumpPanel(tester);

    expect(find.text('手机银行'), findsNothing);
    expect(find.text('转账'), findsNothing);
    expect(find.text('交通银行'), findsNothing);
    expect(find.text('对方开户名'), findsOneWidget);

    await tester.tap(find.text('交易地点'));
    await tester.pumpAndSettle();
    expect(find.text('手机银行'), findsOneWidget);
  });
}
