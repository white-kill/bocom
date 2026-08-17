import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/member_info_model.dart';
import 'package:bocom/pages/tabs/home/transfer/record/transfer_record_repository.dart';
import 'package:bocom/pages/tabs/home/transfer/record/transfer_record_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  TransferRecordEntry entry({
    required int id,
    required String name,
    required DateTime time,
    double amount = -1,
  }) {
    return TransferRecordEntry(
      id: id,
      bankCard: '6222620000002910',
      amount: amount,
      oppositeName: name,
      oppositeAccount: '6217001630076962353',
      oppositeBankName: '中国建设银行',
      excerpt: '跨行汇款',
      transactionDescription: '转账汇款',
      type: 2,
      transactionTime: time,
      accountsTime: time.add(const Duration(minutes: 1)),
    );
  }

  void registerMember() {
    final logic = Get.put(BocLogic());
    logic.memberInfo.realName = '沈田田';
    logic.memberInfo.bankList = [
      MemberInfoBankList()
        ..bankCard = '6222620000002910'
        ..bankName = '交通银行'
        ..realName = '沈田田'
        ..cardType = '借记卡',
    ];
  }

  test('转账记录返回值兼容外层data和字符串汇总', () {
    final page = TransferRecordPageData.fromJson({
      'data': {
        'list': [
          {
            'id': 10020,
            'bankCard': '6222620000002910',
            'amount': '-1.00',
            'oppositeName': '沈光德',
            'oppositeAccount': '6217001630076962353',
            'oppositeBankName': '中国建设银行',
            'excerpt': '跨行汇款',
            'transactionDescription': '转账汇款',
            'type': 2,
            'transactionTime': '2026-08-12 11:43:23',
            'accountsTime': '2026-08-12 11:44:23',
          },
        ],
        'total': 1,
        'pages': 1,
        'incomeTotal': '0.00',
        'expensesTotal': '1.00',
      },
    });

    expect(page.total, 1);
    expect(page.expensesTotal, 1);
    expect(page.records.single.id, 10020);
    expect(page.records.single.amount, -1);
    expect(
        page.records.single.transactionTime, DateTime(2026, 8, 12, 11, 43, 23));
  });

  testWidgets('正式入口请求转账记录并服务端搜索', (tester) async {
    registerMember();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final requests = <Map<String, dynamic>>[];

    await tester.pumpWidget(
      GetMaterialApp(
        home: TransferRecordPage(
          today: DateTime(2026, 8, 17),
          pageLoader: (params) async {
            requests.add(Map<String, dynamic>.from(params));
            return TransferRecordPageData(
              records: [
                entry(
                  id: 10020,
                  name: '沈光德',
                  time: DateTime(2026, 8, 12, 11, 43, 23),
                ),
              ],
              total: 5,
              pages: 1,
              incomeTotal: 0,
              expensesTotal: 4.77,
            );
          },
          detailLoader: (_) async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requests.first, {
      'pageNum': 1,
      'pageSize': 10,
      'beginTime': '2026-07-18',
      'endTime': '2026-08-17',
      'bankCard': '6222620000002910',
    });
    expect(find.text('成功  5 笔'), findsOneWidget);
    expect(find.text('共  4.77 元'), findsOneWidget);
    expect(find.text('沈光德(**2353)'), findsOneWidget);
    expect(find.text('借记卡(**2910)'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('transfer_record_search')),
      '沈光德',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(requests.last['keyword'], '沈光德');
  });

  testWidgets('转账记录滚动到底加载下一页', (tester) async {
    registerMember();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final requestedPages = <int>[];

    await tester.pumpWidget(
      GetMaterialApp(
        home: TransferRecordPage(
          today: DateTime(2026, 8, 17),
          pageLoader: (params) async {
            final page = params['pageNum'] as int;
            requestedPages.add(page);
            final records = page == 1
                ? [
                    for (var index = 0; index < 10; index++)
                      entry(
                        id: 10020 - index,
                        name: '沈光德',
                        time: DateTime(2026, 8, 12, 11, 43 - index),
                      ),
                  ]
                : [
                    entry(
                      id: 10010,
                      name: '第二页',
                      time: DateTime(2026, 7, 20, 10),
                    ),
                  ];
            return TransferRecordPageData(
              records: records,
              total: 11,
              pages: 2,
              incomeTotal: 0,
              expensesTotal: 11,
            );
          },
          detailLoader: (_) async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('transfer_record_list')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();

    expect(requestedPages, containsAllInOrder([1, 2]));
    expect(find.text('第二页(**2353)'), findsOneWidget);
  });
}
