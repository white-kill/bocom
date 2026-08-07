import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_mock_data.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  test('八月假数据汇总与参考图一致', () {
    final august = transactionDetailMockSections.first;

    expect(august.monthKey, '2026-08');
    expect(august.income, 0);
    expect(august.expense, closeTo(342.15, 0.001));
  });

  testWidgets('跨月滚动会更新固定月份并显示回顶入口', (tester) async {
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

    Text selectedMonth() => tester.widget<Text>(
          find.byKey(
            const ValueKey('transaction_detail_selected_month'),
          ),
        );

    expect(selectedMonth().data, '本月');

    await tester.drag(
      find.byKey(const ValueKey('transaction_detail_list')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(selectedMonth().data, '2026-07');
    expect(find.bySemanticsLabel('返回顶部'), findsOneWidget);
  });

  testWidgets('首屏文字层级和交易行高度保持参考图比例', (tester) async {
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

    Text text(String value) => tester.widget<Text>(find.text(value).first);

    expect(text('交易明细').style?.fontSize, 17);
    expect(text('交通银行 II类账户 (**2910)').style?.fontSize, 16);
    expect(text('本月').style?.fontSize, 14);
    expect(text('2026-08').style?.fontSize, 14);
    expect(text('上海华莱士贸易有限公司').style?.fontSize, 16);
    expect(text('抖音支付').style?.fontSize, 14);
    expect(text('2026-08-05 18:19:01').style?.fontSize, 14);
    expect(text('-8.50').style?.fontSize, 16);
    expect(text('余额2,194.92').style?.fontSize, 14);
    expect(text('导出交易明细').style?.fontSize, 16);
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('transaction_row_上海华莱士贸易有限公司'),
            ),
          )
          .height,
      94,
    );
  });
}
