import 'dart:async';
import 'dart:typed_data';

import 'package:bocom/pages/tabs/home/transfer/account_transfer/account_transfer_result_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  final result = AccountTransferResultData(
    billId: 10020,
    recipientName: '张三',
    recipientAccount: '6217001630076962353',
    recipientBank: '中国建设银行',
    amount: 1,
    payerName: '李四',
    payerAccount: '6222620000002910',
    payerBank: '交通银行',
    transactionTime: DateTime(2026, 8, 12, 11, 29, 52),
    arrivalText: '预计实时到账',
    purpose: '货款',
    serialNumber: '2005000420260812436002307520',
  );

  testWidgets('转账成功页显示真实数据并进入回执页', (tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 956));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GetMaterialApp(
        home: AccountTransferSuccessPage(
          data: result,
          billDetailLoader: (_) async => {
            'billDetail': {
              'transactionTime': '2026-08-12 11:30:00',
              'transactionLogno': 'DETAIL202608121130',
            },
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('¥1.00'), findsOneWidget);
    expect(find.text('张三'), findsOneWidget);
    expect(find.text('中国建设银行(**2353)'), findsOneWidget);
    expect(find.text('设置卡(**2910)为转账默认付款卡'), findsOneWidget);
    expect(find.bySemanticsLabel('通知收款人'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('通知收款人'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('account-transfer-receipt-page')), findsOneWidget);
    expect(find.text('621700****2353'), findsOneWidget);
    expect(find.text('622262****2910'), findsOneWidget);
    expect(find.text('DETAIL202608121130'), findsOneWidget);
    expect(find.text('2026-08-12 11:30:00'), findsOneWidget);
    expect(find.text('人民币壹元整'), findsOneWidget);
  });

  testWidgets('回执中间独立滚动且底部切换完整卡号', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: AccountTransferReceiptPage(data: result)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('receipt-fixed-navigation')), findsOneWidget);
    expect(find.byKey(const Key('receipt-fixed-footer')), findsOneWidget);
    expect(find.text('621700****2353'), findsOneWidget);
    expect(find.text('622262****2910'), findsOneWidget);

    final footerBefore = tester.getTopLeft(
      find.byKey(const Key('receipt-fixed-footer')),
    );
    await tester.drag(
      find.byKey(const Key('receipt-content-scroll-view')),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const Key('receipt-fixed-footer'))),
      footerBefore,
    );

    await tester.tap(find.bySemanticsLabel('隐藏收付款卡号'));
    await tester.pumpAndSettle();
    expect(find.text('6217 0016 3007 6962 353'), findsOneWidget);
    expect(find.text('6222 6200 0000 2910'), findsOneWidget);
    expect(find.text('621700****2353'), findsNothing);
    expect(find.bySemanticsLabel('保存图片'), findsOneWidget);
    expect(find.bySemanticsLabel('通知微信好友'), findsOneWidget);
  });

  testWidgets('保存回执入口使用动态模板并进入保存状态', (tester) async {
    final saveCompleter = Completer<bool>();
    Uint8List? savedBytes;
    await tester.binding.setSurfaceSize(const Size(440, 956));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: AccountTransferReceiptPage(
          data: result,
          receiptSaver: (bytes) async {
            savedBytes = bytes;
            return saveCompleter.future;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.bySemanticsLabel('保存图片'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('保存图片').hitTestable(), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('保存图片'));
    await tester.pump();

    expect(find.bySemanticsLabel('正在保存图片'), findsOneWidget);
    saveCompleter.complete(true);
    await tester.pumpAndSettle();
    if (savedBytes != null) {
      expect(savedBytes!.length, greaterThan(10000));
    }
    expect(
        find.byKey(const Key('account-transfer-receipt-page')), findsOneWidget);
  });
}
