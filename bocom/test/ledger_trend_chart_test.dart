import 'package:bocom/pages/tabs/mine/children/ledger/component/ledger_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpChart(
    WidgetTester tester, {
    required int year,
    required List<String> dates,
    List<double>? incomeValues,
    List<double>? expenseValues,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: LedgerTrendChart(
              isYearMode: true,
              year: year,
              dateValues: dates,
              incomeValues:
                  incomeValues ?? List<double>.filled(dates.length, 0),
              expenseValues:
                  expenseValues ?? List<double>.filled(dates.length, 0),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('当年年度趋势仅显示起始年月和结束月份', (tester) async {
    await pumpChart(
      tester,
      year: DateTime.now().year,
      dates: const [
        '2025-09',
        '2025-10',
        '2025-11',
        '2025-12',
        '2026-01',
        '2026-02',
        '2026-03',
        '2026-04',
        '2026-05',
        '2026-06',
        '2026-07',
        '2026-08',
      ],
    );

    expect(find.text('9月'), findsOneWidget);
    expect(find.text('2025'), findsOneWidget);
    expect(find.text('8月'), findsOneWidget);
    expect(find.text('7月'), findsNothing);

    final startMonth = tester.widget<Text>(find.text('9月'));
    final endMonth = tester.widget<Text>(find.text('8月'));
    expect(startMonth.style?.color, const Color(0xFFA6ADB7));
    expect(endMonth.style?.color, const Color(0xFF222222));
  });

  testWidgets('历史年度趋势额外显示第七个月', (tester) async {
    await pumpChart(
      tester,
      year: 2025,
      dates: List<String>.generate(
        12,
        (index) => '2025-${(index + 1).toString().padLeft(2, '0')}',
      ),
    );

    expect(find.text('1月'), findsOneWidget);
    expect(find.text('2025'), findsOneWidget);
    expect(find.text('7月'), findsOneWidget);
    expect(find.text('12月'), findsOneWidget);

    final middleMonth = tester.widget<Text>(find.text('7月'));
    expect(middleMonth.style?.color, const Color(0xFF222222));

    final startRect = tester.getRect(find.text('1月'));
    final middleRect = tester.getRect(find.text('7月'));
    final endRect = tester.getRect(find.text('12月'));
    final chartRect = tester.getRect(find.byKey(const ValueKey(true)));
    expect(startRect.top, closeTo(middleRect.top, 0.5));
    expect(startRect.top, closeTo(endRect.top, 0.5));
    expect(startRect.top - chartRect.bottom, greaterThanOrEqualTo(5));
  });

  testWidgets('年度大额数值会扩宽提示框并完整显示', (tester) async {
    const largeIncome = 1234567890123.45;
    final dates = List<String>.generate(
      12,
      (index) => '2025-${(index + 1).toString().padLeft(2, '0')}',
    );
    await pumpChart(
      tester,
      year: 2025,
      dates: dates,
      incomeValues: [
        ...List<double>.filled(11, 0),
        largeIncome,
      ],
    );

    expect(find.text('收入 1234567890123.45'), findsOneWidget);
    final tooltipRect = tester.getRect(
      find.byKey(const Key('ledger-trend-tooltip')),
    );
    final chartRect = tester.getRect(find.byKey(const ValueKey(true)));
    expect(tooltipRect.width, greaterThan(115));
    expect(tooltipRect.right, lessThanOrEqualTo(chartRect.right));
  });
}
