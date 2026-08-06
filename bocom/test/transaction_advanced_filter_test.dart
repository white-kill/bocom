import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_view.dart';
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
