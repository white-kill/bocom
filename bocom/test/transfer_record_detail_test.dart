import 'package:bocom/pages/tabs/home/transfer/record/transfer_record_detail_view.dart';
import 'package:bocom/pages/tabs/home/transfer/record/transfer_record_view.dart';
import 'package:bocom/pages/tabs/home/transfer/account_transfer/account_transfer_result_pages.dart';
import 'package:bocom/pages/tabs/home/transfer/account_transfer/home_account_transfer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  final detail = TransferRecordDetailData(
    amount: -1,
    recipientName: '小光',
    recipientAccount: '6217 0016 3007 6962 353',
    recipientBank: '中国建设银行',
    transferredAt: DateTime(2026, 8, 12, 11, 43, 23),
    sourceAccount: '交通银行 借记卡(**2910)',
    transferRoute: '超级网银快速汇款',
    fee: 0,
    channel: '手机银行',
    arrivalTime: '预计实时到账',
    serialNumber: '2005000420260812436002416952',
    postscript: '',
  );

  testWidgets('转账记录详情展示动态key/value并响应底部操作', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    var receiptTapped = false;
    var transferAgainTapped = false;
    await tester.pumpWidget(
      GetMaterialApp(
        home: TransferRecordDetailPage(
          data: detail,
          onReceiptTap: () => receiptTapped = true,
          onTransferAgainTap: () => transferAgainTapped = true,
        ),
      ),
    );

    expect(find.text('转账记录详情'), findsOneWidget);
    expect(find.text('-1.00'), findsOneWidget);
    expect(find.text('小光'), findsOneWidget);
    expect(find.text('6217 0016 3007 6962 353'), findsOneWidget);
    expect(find.text('2026-08-12 11:43:23'), findsOneWidget);
    expect(find.text('20050004202608\n12436002416952'), findsOneWidget);

    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('transfer_record_detail_overview_card')),
          )
          .height,
      254,
    );
    expect(
      tester
          .getSize(
            find.byKey(
                const ValueKey('transfer_record_detail_information_card')),
          )
          .height,
      greaterThanOrEqualTo(316),
    );

    final amount = tester.widget<Text>(
      find.byKey(const ValueKey('transfer_record_detail_amount')),
    );
    final serialNumber = tester.widget<Text>(
      find.byKey(const ValueKey('transfer_record_detail_流水号')),
    );
    expect(amount.style?.fontSize, 36);
    expect(serialNumber.style?.fontSize, 17);
    expect(serialNumber.data, '20050004202608\n12436002416952');
    expect(serialNumber.maxLines, isNull);
    expect(serialNumber.overflow, isNull);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('transfer_record_detail_流水号')),
          )
          .height,
      greaterThan(30),
    );

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_detail_receipt')),
    );
    await tester.tap(
      find.byKey(const ValueKey('transfer_record_detail_transfer_again')),
    );
    expect(receiptTapped, isTrue);
    expect(transferAgainTapped, isTrue);
  });

  testWidgets('点击转账记录进入对应详情', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: TransferRecordPage(
          records: TransferRecordPage.previewRecords,
          today: DateTime(2026, 8, 17),
          detailLoader: (_) async => null,
        ),
      ),
    );

    await tester.tap(find.text('小光(**2353)').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('transfer_record_detail_page')),
      findsOneWidget,
    );
    expect(find.text('2026-08-12 11:43:23'), findsOneWidget);
  });

  testWidgets('详情页按billId请求接口并保留本人卡号', (tester) async {
    int? requestedBillId;
    await tester.pumpWidget(
      GetMaterialApp(
        home: TransferRecordDetailPage(
          data: detail.copyWith(billId: 10020),
          detailLoader: (billId) async {
            requestedBillId = billId;
            return {
              'data': {
                'id': billId,
                'amount': -8.88,
                'merchantBranch': '手机银行',
                'billDetail': {
                  'bankName': '交通银行',
                  'bankCard': '6222***5678',
                  'transactionTime': '2026-08-12 12:01:02',
                  'oppositeAccount': '6217001630076962353',
                  'oppositeBankName': '中国建设银行',
                  'transactionLogno': 'DETAIL20260812120102',
                  'remark': '测试附言',
                },
              },
            };
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requestedBillId, 10020);
    expect(find.text('-8.88'), findsOneWidget);
    expect(find.text('2026-08-12 12:01:02'), findsOneWidget);
    expect(find.text('交通银行 借记卡(**2910)'), findsOneWidget);
    expect(find.text('超级网银快速汇款'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('预计实时到账'), findsOneWidget);
    expect(find.text('DETAIL20260812\n120102'), findsOneWidget);
    expect(find.text('测试附言'), findsOneWidget);
  });

  testWidgets('查看回执打开动态回执页', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(home: TransferRecordDetailPage(data: detail)),
    );

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_detail_receipt')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccountTransferReceiptPage), findsOneWidget);
    expect(find.text('小光'), findsOneWidget);
    expect(find.text('621700****2353'), findsOneWidget);
    expect(find.text('1.00元'), findsOneWidget);
    expect(find.text('2005000420260812436002416952'), findsOneWidget);
  });

  testWidgets('再转一笔回填收款人和金额', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(home: TransferRecordDetailPage(data: detail)),
    );

    await tester.tap(
      find.byKey(const ValueKey('transfer_record_detail_transfer_again')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeAccountTransferPage), findsOneWidget);
    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller?.text, '小光');
    expect(
      tester.widget<TextField>(fields.at(1)).controller?.text,
      '6217001630076962353',
    );
    expect(
      tester.widget<TextField>(fields.at(2)).controller?.text,
      '中国建设银行',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('transfer-amount-field')),
          )
          .controller
          ?.text,
      '1.00',
    );
  });
}
