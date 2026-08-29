import 'package:bocom/pages/tabs/home/transfer/record/transfer_record_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      GetMaterialApp(
        home: TransferRecordPage(
          records: TransferRecordPage.previewRecords,
          today: DateTime(2026, 8, 17),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('转账记录默认展示五笔和4.77元汇总', (tester) async {
    await pumpPage(tester);

    expect(find.text('转账记录'), findsOneWidget);
    expect(find.text('成功  5 笔'), findsOneWidget);
    expect(find.text('共  4.77 元'), findsOneWidget);
    expect(find.text('小光(**2353)'), findsNWidgets(5));
    expect(find.text('温馨提示'), findsOneWidget);
  });

  testWidgets('账户与时间面板互斥且保留选中态', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('借记卡(**2910)'));
    await tester.pumpAndSettle();
    expect(find.text('交通银行 借记卡(**2910)'), findsOneWidget);
    final accountTextCenter = tester.getCenter(
      find.text('交通银行 借记卡(**2910)'),
    );
    final accountCheckCenter = tester.getCenter(
      find.byKey(const ValueKey('transfer_record_account_check')),
    );
    expect((accountTextCenter.dy - accountCheckCenter.dy).abs(), lessThan(1));
    expect(
      find.byKey(const ValueKey('transfer_record_filter_scrim')),
      findsOneWidget,
    );

    await tester.tap(find.text('交通银行 借记卡(**2910)'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('transfer_record_range_button')),
    );
    await tester.pumpAndSettle();

    for (final label in ['近7天', '近一个月', '近三个月', '近半年', '自定义']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('交通银行 借记卡(**2910)'), findsNothing);
  });

  testWidgets('自定义当天范围应用后进入空状态', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_range_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_start_date')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListWheelScrollView), findsNWidgets(3));
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(find.text('2026-08-17'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('transfer_record_end_date')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(find.text('2026/08/17-2026/08/17'), findsOneWidget);
    expect(find.text('没有转账记录，换个条件试试'), findsOneWidget);
    expect(find.text('成功  0 笔'), findsNothing);
  });

  testWidgets('自定义起始日晚于终止日时展示纠错弹窗', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_range_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('transfer_record_start_date')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_end_date')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('2026/08/17-2026/08/17'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_range_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('transfer_record_end_date')),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(ListWheelScrollView).at(2),
      const Offset(0, 50),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(
      find.text('您的起始时间晚于终止时间，请重新选择时间'),
      findsOneWidget,
    );
    expect(find.text('我知道了'), findsOneWidget);
    await tester.tap(find.text('我知道了'));
    await tester.pumpAndSettle();
    expect(find.text('2026-08-16'), findsOneWidget);
    expect(find.text('2026/08/17-2026/08/17'), findsOneWidget);
  });

  testWidgets('近半年展示跨月假数据并保持筛选标题', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_range_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('近半年'));
    await tester.pumpAndSettle();

    expect(find.text('近半年'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('transfer_record_month_divider_2026-07')),
      findsOneWidget,
    );
    expect(find.text('成功  7 笔'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('transfer_record_list')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('2026-07'), findsOneWidget);
  });
}
