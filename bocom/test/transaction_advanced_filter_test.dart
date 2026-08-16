import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_view.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/filter/transaction_advanced_filter_model.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/filter/transaction_advanced_filter_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => GetMaterialApp(home: child),
        child: const TransactionDetailPage(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('筛选'));
    await tester.pumpAndSettle();
  }

  testWidgets('第二筛选包含全部分组并覆盖底部导出区域', (tester) async {
    await pumpPage(tester);

    expect(
      find.byKey(const ValueKey('transaction_advanced_filter_panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('transaction_advanced_filter_scrim')),
      findsOneWidget,
    );
    for (final label in ['交易类型', '全部收入', '全部支出', '常用', '金额', '渠道/地点']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('重置'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);

    final scrim = find.byKey(
      const ValueKey('transaction_advanced_filter_scrim'),
    );
    expect(
      tester.getRect(scrim).contains(tester.getCenter(find.text('导出交易明细'))),
      isTrue,
    );
  });

  testWidgets('筛选选项支持选中、取消与重置', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('全部支出'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('advanced_filter_choice_生活缴费')),
    );
    await tester.pumpAndSettle();

    AnimatedContainer choice(String label) => tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byKey(ValueKey('advanced_filter_choice_$label')),
            matching: find.byType(AnimatedContainer),
          ),
        );

    expect(
      (choice('全部支出').decoration as BoxDecoration).color,
      const Color(0xFFE9F3FD),
    );
    expect(
      (choice('生活缴费').decoration as BoxDecoration).color,
      const Color(0xFFE9F3FD),
    );

    await tester.tap(find.text('重置'));
    await tester.pumpAndSettle();
    expect(
      (choice('全部支出').decoration as BoxDecoration).color,
      const Color(0xFFFAFAFA),
    );
    expect(
      (choice('生活缴费').decoration as BoxDecoration).color,
      const Color(0xFFFAFAFA),
    );
  });

  testWidgets('自定义金额显示双列金额输入并保留参考图字号', (tester) async {
    await pumpPage(tester);

    final amountSection = find.byKey(
      const ValueKey('advanced_filter_section_金额'),
    );
    await tester.tap(
      find.descendant(of: amountSection, matching: find.text('自定义')),
    );
    await tester.pumpAndSettle();

    final minField = find.byKey(
      const ValueKey('advanced_filter_min_amount'),
    );
    final maxField = find.byKey(
      const ValueKey('advanced_filter_max_amount'),
    );
    expect(minField, findsOneWidget);
    expect(maxField, findsOneWidget);
    expect(tester.widget<TextField>(minField).style?.fontSize, 16);
    expect(tester.widget<TextField>(maxField).style?.fontSize, 16);
    expect(
      tester.widget<TextField>(minField).decoration?.hintText,
      '最小金额',
    );
    expect(
      tester.widget<TextField>(maxField).decoration?.hintText,
      '最大金额',
    );
    expect(find.text('¥ '), findsNWidgets(2));
    final separator = find.byKey(
      const ValueKey('advanced_filter_amount_separator'),
    );
    expect(find.text('至'), findsOneWidget);
    expect(tester.widget<Text>(separator).style?.fontSize, 14);
    expect(
      tester.getRect(separator).left,
      greaterThan(tester.getRect(minField).right),
    );
    expect(
      tester.getRect(separator).right,
      lessThan(tester.getRect(maxField).left),
    );
    expect(
      tester.getSize(minField).width,
      lessThan(tester.getSize(maxField).width),
    );
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('advanced_filter_custom_amount_fields'),
            ),
          )
          .height,
      48,
    );
  });

  testWidgets('自定义开户行显示整行输入并把两个自定义值回传', (tester) async {
    TransactionAdvancedFilterValue? completed;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => GetMaterialApp(home: child),
        child: Scaffold(
          body: SizedBox(
            height: 527,
            child: TransactionAdvancedFilterPanel(
              initialValue: const TransactionAdvancedFilterValue(
                amountRange: '自定义',
                bank: '自定义',
              ),
              onComplete: (value) => completed = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollView = find.byKey(
      const ValueKey('transaction_advanced_filter_scroll'),
    );
    final minField = find.byKey(
      const ValueKey('advanced_filter_min_amount'),
    );
    await tester.enterText(minField, '100.00');
    await tester.enterText(
      find.byKey(const ValueKey('advanced_filter_max_amount')),
      '300',
    );

    final bankField = find.byKey(
      const ValueKey('advanced_filter_custom_bank'),
    );
    await tester.drag(scrollView, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(tester.getSize(bankField).height, 34);
    expect(tester.widget<TextField>(bankField).style?.fontSize, 14);
    await tester.enterText(bankField, '测试银行');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成'));

    expect(completed?.minAmount, '100.00');
    expect(completed?.maxAmount, '300');
    expect(completed?.customBankName, '测试银行');
  });

  testWidgets('键盘弹出后面板缩短且操作栏停在键盘上方', (tester) async {
    await pumpPage(tester);

    final panel = find.byKey(
      const ValueKey('transaction_advanced_filter_panel'),
    );
    final actions = find.byKey(
      const ValueKey('transaction_advanced_filter_actions'),
    );
    final initialHeight = tester.getSize(panel).height;

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.getSize(panel).height, lessThan(initialHeight));
    expect(
      tester.getBottomLeft(actions).dy,
      closeTo(tester.view.physicalSize.height - 300, 0.01),
    );
  });

  testWidgets('完成后保留筛选选中态并更新假数据结果', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('全部支出'));
    await tester.tap(
      find.byKey(const ValueKey('advanced_filter_choice_1百以下')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('transaction_advanced_filter_panel')),
      findsNothing,
    );
    expect(
        find.byKey(const ValueKey('transaction_filter_count')), findsOneWidget);
    final filterText = tester.widget<Text>(find.text('筛选'));
    final monthText = tester.widget<Text>(find.text('本月'));
    expect(filterText.style?.color, const Color(0xFF0077DF));
    expect(monthText.style?.color, const Color(0xFF303030));

    await tester.tap(find.text('筛选'));
    await tester.pumpAndSettle();
    final selected = tester.widget<Text>(find.text('1百以下'));
    expect(selected.style?.color, const Color(0xFF0077DF));
  });

  testWidgets('没有匹配交易时显示参考图空页面且隐藏汇总栏', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('全部收入'));
    await tester.tap(
      find.byKey(const ValueKey('advanced_filter_choice_5万以上')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.text('共0笔'), findsNothing);
    expect(
      find.byKey(const ValueKey('transaction_empty_result_image')),
      findsOneWidget,
    );
    expect(find.text('无交易明细记录'), findsOneWidget);
    expect(find.text('导出交易明细'), findsNothing);

    final icon = tester.widget<Image>(
      find.byKey(const ValueKey('transaction_filter_icon')),
    );
    expect(icon.width, 9);
    expect(icon.height, 10.5);
  });
}
