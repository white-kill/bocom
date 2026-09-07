import 'dart:async';

import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_model.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_repository.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

void main() {
  testWidgets('页面加载并把日期与高级筛选组合发送到接口', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final requests = <Map<String, dynamic>>[];
    Future<TransactionBillPage> loader(Map<String, dynamic> params) async {
      requests.add(Map<String, dynamic>.from(params));
      return _billPage();
    }

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => GetMaterialApp(home: child),
        child: TransactionDetailPage(
          billLoader: loader,
          today: DateTime(2026, 8, 15),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requests.single, {
      'pageNum': 1,
      'pageSize': 10,
      'orderSort': '1',
    });
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const ValueKey('transaction_detail_selected_month'),
            ),
          )
          .data,
      '本月',
    );
    expect(find.text('接口交易'), findsOneWidget);
    expect(find.text('手机银行'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('transaction_detail_selected_month')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('近一周'));
    await tester.pumpAndSettle();

    expect(requests.length, 2);
    expect(requests.last['beginTime'], '2026-08-09');
    expect(requests.last['endTime'], '2026-08-15');

    await tester.tap(find.text('筛选'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('全部支出'));
    await tester.tap(
      find.byKey(const ValueKey('advanced_filter_choice_1百以下')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(requests.length, 3);
    expect(requests.last['beginTime'], '2026-08-09');
    expect(requests.last['endTime'], '2026-08-15');
    expect(requests.last['type'], 2);
    expect(requests.last['maxAmount'], 100);
  });

  testWidgets('未筛选时补齐当前月至首个数据月之间的空月份', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Map<String, dynamic>? request;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => GetMaterialApp(home: child),
        child: TransactionDetailPage(
          today: DateTime(2026, 11, 5),
          billLoader: (params) async {
            request = Map<String, dynamic>.from(params);
            return _pagedBillPage(1);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(request, {
      'pageNum': 1,
      'pageSize': 10,
      'orderSort': '1',
    });
    final monthText = tester.widget<Text>(
      find.byKey(
        const ValueKey('transaction_detail_selected_month'),
      ),
    );
    expect(monthText.data, '本月');
    expect(monthText.style?.color, const Color(0xFF303030));
    expect(find.text('2026-11'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('transaction_empty_month_image')),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('本月无交易明细记录'), findsOneWidget);
    expect(find.text('导出交易明细'), findsOneWidget);

    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byKey(const ValueKey('transaction_detail_list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    scrollable.position.jumpTo(358);
    await tester.pump();
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('transaction_detail_selected_month')),
          )
          .data,
      '2026-10',
    );
    expect(find.text('该月无交易明细记录'), findsAtLeastNWidgets(1));

    scrollable.position.jumpTo(715);
    await tester.pump();
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('transaction_detail_selected_month')),
          )
          .data,
      '2026-09',
    );

    scrollable.position.jumpTo(1072);
    await tester.pump();
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('transaction_detail_selected_month')),
          )
          .data,
      '2026-08',
    );
    expect(find.text('第1页交易0'), findsOneWidget);
  });

  testWidgets('有筛选且无数据时不补本月空态', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => GetMaterialApp(home: child),
        child: TransactionDetailPage(
          today: DateTime(2026, 11, 5),
          billLoader: (params) async => params.containsKey('beginTime')
              ? _emptyBillPage()
              : _singleMonthPage(DateTime(2026, 8, 24, 15, 19, 32)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本月无交易明细记录'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('transaction_detail_selected_month')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('近一周'));
    await tester.pumpAndSettle();

    expect(find.text('本月无交易明细记录'), findsNothing);
    expect(find.text('无交易明细记录'), findsOneWidget);
    expect(find.text('导出交易明细'), findsNothing);
  });

  testWidgets('加载更多使用第二页接口并显示三点波浪动画', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final requestedPages = <int>[];
    final secondPage = Completer<TransactionBillPage>();
    Future<TransactionBillPage> loader(Map<String, dynamic> params) async {
      final pageNum = params['pageNum'] as int;
      requestedPages.add(pageNum);
      if (pageNum == 1) return _pagedBillPage(pageNum);
      return secondPage.future;
    }

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => GetMaterialApp(home: child),
        child: TransactionDetailPage(billLoader: loader),
      ),
    );
    await tester.pumpAndSettle();
    expect(requestedPages, [1]);

    final refresher = tester.widget<SmartRefresher>(
      find.byType(SmartRefresher),
    );
    refresher.controller.requestLoading(needMove: false);
    await tester.pump(const Duration(milliseconds: 80));

    expect(requestedPages, [1, 2]);
    expect(
      find.byKey(const ValueKey('transaction_load_more_wave')),
      findsOneWidget,
    );

    final firstDot = find.byKey(
      const ValueKey('transaction_load_more_dot_0'),
    );
    final scaleBefore = tester.widget<Transform>(firstDot).transform.storage[0];
    await tester.pump(const Duration(milliseconds: 180));
    final scaleAfter = tester.widget<Transform>(firstDot).transform.storage[0];
    expect(scaleAfter, isNot(closeTo(scaleBefore, 0.001)));

    secondPage.complete(_pagedBillPage(2));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('transaction_detail_list')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(find.text('第2页交易'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('transaction_load_more_wave')),
      findsNothing,
    );
  });

  testWidgets('点击列表记录先展示预览并刷新完整详情', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, child) => GetMaterialApp(home: child),
        child: TransactionDetailPage(
          billLoader: (_) async => _billPage(),
          billDetailLoader: (_) async => _billPage().entries.single.detail!,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('接口交易'));
    await tester.pumpAndSettle();

    expect(find.text('明细详情'), findsOneWidget);
    expect(find.text('接口商户'), findsNWidgets(2));
    expect(find.text('622262****2910'), findsOneWidget);
  });
}

TransactionBillPage _billPage() {
  return TransactionBillPage(
    entries: [
      TransactionBillEntry(
        id: 1,
        record: TransactionRecord(
          title: '接口交易',
          channel: '手机银行',
          occurredAt: DateTime(2026, 8, 14, 11, 30),
          amount: -50,
          balance: 1079,
        ),
        detail: TransactionBillDetail(
          id: 1,
          merchantName: '接口商户',
          amount: -50,
          balance: 1079,
          bankCard: '622262****2910',
          transactionTime: DateTime(2026, 8, 14, 11, 30),
          transactionChannel: '手机银行',
          transactionCategory: '快捷支付',
          transactionDescription: '消费',
          oppositeName: '',
          oppositeAccount: '',
          oppositeBankName: '',
          postscriptno: 'ORDER-1',
          transactionLogno: 'FLOW-1',
          excerpt: '网上支付',
          detailTemplate: 'ONLINE_PAYMENT',
          transactionAccount: '接口商户',
          merchantBranch: '接口商户',
        ),
        monthIncomeTotal: 0,
        monthExpensesTotal: 50,
      ),
    ],
    total: 1,
    pages: 2,
    incomeTotal: 0,
    expensesTotal: 50,
  );
}

TransactionBillPage _singleMonthPage(DateTime occurredAt) {
  return TransactionBillPage(
    entries: [
      TransactionBillEntry(
        id: 7,
        record: TransactionRecord(
          title: '七月交易',
          channel: '支付宝',
          occurredAt: occurredAt,
          amount: -13.96,
          balance: 3133.07,
        ),
        monthIncomeTotal: 0,
        monthExpensesTotal: 13.96,
      ),
    ],
    total: 1,
    pages: 1,
    incomeTotal: 0,
    expensesTotal: 13.96,
  );
}

TransactionBillPage _emptyBillPage() {
  return const TransactionBillPage(
    entries: [],
    total: 0,
    pages: 0,
    incomeTotal: 0,
    expensesTotal: 0,
  );
}

TransactionBillPage _pagedBillPage(int pageNum) {
  final entries = pageNum == 1
      ? [
          for (var index = 0; index < 10; index++)
            TransactionBillEntry(
              id: index + 1,
              record: TransactionRecord(
                title: '第1页交易$index',
                channel: '手机银行',
                occurredAt: DateTime(2026, 8, 14, 11, 30 - index),
                amount: -10,
                balance: 1000 + index.toDouble(),
              ),
            ),
        ]
      : [
          TransactionBillEntry(
            id: 11,
            record: TransactionRecord(
              title: '第2页交易',
              channel: '网银',
              occurredAt: DateTime(2026, 7, 31, 10),
              amount: -20,
              balance: 900,
            ),
          ),
        ];
  return TransactionBillPage(
    entries: entries,
    total: 11,
    pages: 2,
    incomeTotal: 0,
    expensesTotal: 120,
  );
}
