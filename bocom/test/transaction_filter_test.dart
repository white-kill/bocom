import 'package:bocom/pages/tabs/home/transaction_detail/filter/transaction_filter_model.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('自定义交易日期规则', () {
    test('开始日期晚于结束日期时禁止确认', () {
      final result = TransactionDateRules.validate(
        DateTime(2026, 8, 5),
        DateTime(2026, 7, 5),
      );

      expect(result, TransactionDateValidationError.startAfterEnd);
    });

    test('查询跨度超过两年时禁止确认', () {
      final result = TransactionDateRules.validate(
        DateTime(2023, 8, 5),
        DateTime(2025, 10, 9),
      );

      expect(result, TransactionDateValidationError.overTwoYears);
    });

    test('两年边界当天允许确认', () {
      final result = TransactionDateRules.validate(
        DateTime(2024, 8, 5),
        DateTime(2026, 8, 5),
      );

      expect(result, isNull);
    });

    test('未来日期在确认后单独拦截', () {
      expect(
        TransactionDateRules.containsFutureDate(
          DateTime(2026, 8, 5),
          DateTime(2026, 10, 5),
          DateTime(2026, 8, 5),
        ),
        isTrue,
      );
    });
  });

  testWidgets('快捷面板包含六种范围并能进入自定义筛选', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 750);
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

    expect(
      find.byKey(const ValueKey('transaction_filter_icon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('transaction_export_icon')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('transaction_detail_selected_month')),
    );
    await tester.pumpAndSettle();

    final scrim = find.byKey(
      const ValueKey('transaction_quick_filter_scrim'),
    );
    final exportText = find.text('导出交易明细');
    expect(scrim, findsOneWidget);
    expect(
      tester.getBottomRight(scrim).dy,
      tester.view.physicalSize.height,
    );
    expect(
      tester.getRect(scrim).contains(tester.getCenter(exportText)),
      isTrue,
    );

    for (final label in ['本月', '近一周', '近一个月', '近三个月', '近一年', '自定义']) {
      expect(find.text(label), findsWidgets);
    }

    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('custom_date_range_tip')), findsOneWidget);
    expect(find.text('月度'), findsOneWidget);
    expect(find.text('年度'), findsOneWidget);
    expect(find.text('自定义'), findsOneWidget);
    expect(find.byKey(const ValueKey('custom_start_date')), findsOneWidget);
    expect(find.byKey(const ValueKey('custom_end_date')), findsOneWidget);

    final monthMode = tester.widget<Text>(find.text('月度'));
    final rangeTip = tester.widget<Text>(find.text('一次查询的跨度不能超过2年'));
    expect(monthMode.style?.fontSize, 14);
    expect(rangeTip.style?.fontSize, 13);
  });

  testWidgets('选择近一周会更新标题、笔数和汇总结果', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 750);
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

    await tester.tap(
      find.byKey(const ValueKey('transaction_detail_selected_month')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('近一周'));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(
      find.byKey(const ValueKey('transaction_detail_selected_month')),
    );
    expect(title.data, '近一周');
    expect(find.text('共10笔'), findsOneWidget);
    expect(find.textContaining('支出-342.15'), findsOneWidget);
  });

  testWidgets('日期筛选后跨月滚动不再联动日期栏', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 750);
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

    await tester.tap(
      find.byKey(const ValueKey('transaction_detail_selected_month')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('近三个月'));
    await tester.pumpAndSettle();

    Text selectedDate() => tester.widget<Text>(
          find.byKey(
            const ValueKey('transaction_detail_selected_month'),
          ),
        );
    expect(selectedDate().data, '近三个月');
    expect(selectedDate().style?.color, const Color(0xFF0077DF));

    await tester.drag(
      find.byKey(const ValueKey('transaction_filtered_list')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    expect(selectedDate().data, '近三个月');
    expect(selectedDate().style?.color, const Color(0xFF0077DF));
  });
}
