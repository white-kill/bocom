import 'dart:async';

import 'package:bocom/pages/tabs/home/transaction_detail/transaction_bill_detail_view.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('传入列表详情时直接展示且不重复请求', (tester) async {
    var loadCount = 0;
    await _pumpPage(
      tester,
      TransactionBillDetailPage(
        billId: 9,
        initialDetail: _detail,
        detailLoader: (_) async {
          loadCount++;
          return _detail;
        },
      ),
    );

    expect(loadCount, 0);
    expect(find.text('明细详情'), findsOneWidget);
    expect(find.text('拼多多平台商户'), findsNWidgets(2));
    expect(find.text('-35.00'), findsOneWidget);
    expect(find.text('余额： 1,044.00'), findsOneWidget);
    expect(find.text('622262****2910'), findsOneWidget);
    expect(find.text('网上支付'), findsOneWidget);
  });

  testWidgets('未传详情时根据 billId 加载并显示加载状态', (tester) async {
    final completer = Completer<TransactionBillDetail>();
    int? requestedId;
    await _pumpPage(
      tester,
      TransactionBillDetailPage(
        billId: 9,
        detailLoader: (billId) {
          requestedId = billId;
          return completer.future;
        },
      ),
      settle: false,
    );

    expect(requestedId, 9);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_detail);
    await tester.pumpAndSettle();
    expect(find.text('-35.00'), findsOneWidget);
  });

  testWidgets('详情请求失败后可以重试', (tester) async {
    var attempts = 0;
    await _pumpPage(
      tester,
      TransactionBillDetailPage(
        billId: 9,
        detailLoader: (_) async {
          attempts++;
          if (attempts == 1) throw Exception('failed');
          return _detail;
        },
      ),
    );

    expect(find.text('加载失败，点击重试'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('transaction_bill_detail_retry')),
    );
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('-35.00'), findsOneWidget);
  });

  testWidgets('参考图字号、广告比例和固定导航保持一致', (tester) async {
    await _pumpPage(
      tester,
      TransactionBillDetailPage(
        billId: 9,
        initialDetail: _detail,
      ),
    );

    Text text(String value) => tester.widget<Text>(find.text(value).first);
    expect(text('明细详情').style?.fontSize, 18);
    expect(text('拼多多平台商户').style?.fontSize, 17);
    expect(text('-35.00').style?.fontSize, 32);
    expect(text('交易卡号').style?.fontSize, 16);

    final banner = tester.getSize(
      find.byKey(const ValueKey('transaction_bill_detail_banner')),
    );
    expect(banner.width / banner.height, closeTo(1120 / 300, 0.01));

    final titleBefore = tester.getCenter(find.text('明细详情'));
    expect(
      tester.getCenter(find.bySemanticsLabel('返回')).dx,
      lessThan(titleBefore.dx),
    );
    await tester.drag(
      find.byKey(const ValueKey('transaction_bill_detail_scroll')),
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.text('明细详情')), titleBefore);
  });

  testWidgets('网上支付按字段决定是否展示对方户名且长编号完整换行', (tester) async {
    await _pumpPage(
      tester,
      TransactionBillDetailPage(
        billId: 10,
        initialDetail: _wechatDetail,
      ),
    );

    expect(find.text('微信转账'), findsNWidgets(2));
    expect(find.text('对方户名'), findsOneWidget);
    expect(find.text('微信支付'), findsNWidgets(2));
    expect(find.text(_wechatDetail.postscriptno), findsOneWidget);
    expect(find.text(_wechatDetail.transactionLogno), findsOneWidget);

    final orderText = tester.widget<Text>(
      find.byKey(
        const ValueKey('transaction_bill_detail_订单编号'),
      ),
    );
    final flowText = tester.widget<Text>(
      find.byKey(
        const ValueKey('transaction_bill_detail_交易流水号'),
      ),
    );
    expect(orderText.maxLines, isNull);
    expect(orderText.overflow, isNull);
    expect(flowText.maxLines, isNull);
    expect(flowText.overflow, isNull);
  });

  testWidgets('网上支付没有对方户名时不展示该行', (tester) async {
    await _pumpPage(
      tester,
      TransactionBillDetailPage(
        billId: 9,
        initialDetail: _detail,
      ),
    );

    expect(find.text('对方户名'), findsNothing);
  });

  testWidgets('转账汇款展示对方账户区和专属底部操作', (tester) async {
    var transferTapped = false;
    await _pumpPage(
      tester,
      TransactionBillDetailPage(
        billId: 11,
        initialDetail: _transferDetail,
        onTransferTap: () => transferTapped = true,
      ),
    );

    expect(find.text('沈光德'), findsNWidgets(2));
    expect(find.text('对方账户'), findsOneWidget);
    expect(find.text('621700****2353'), findsOneWidget);
    expect(find.text('对方开户行'), findsOneWidget);
    expect(find.text('中国建设银行总行'), findsOneWidget);
    expect(find.text('交易商户'), findsNothing);
    expect(find.text('订单编号'), findsNothing);
    expect(find.text('交易流水号'), findsNothing);
    expect(find.text('对此交易有疑问?'), findsNothing);
    expect(
      find.byKey(const ValueKey('transaction_bill_detail_transfer_tip')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('transaction_bill_detail_transfer_button'),
      ),
    );
    expect(transferTapped, isTrue);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 750),
      builder: (_, child) => GetMaterialApp(home: child),
      child: page,
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

final _detail = TransactionBillDetail(
  id: 9,
  merchantName: '拼多多平台商户',
  amount: -35,
  balance: 1044,
  bankCard: '622262****2910',
  transactionTime: DateTime(2026, 8, 15, 12, 54, 23),
  transactionChannel: '支付宝',
  transactionCategory: '快捷支付',
  transactionDescription: '其他商家消费',
  oppositeName: '',
  oppositeAccount: '',
  oppositeBankName: '',
  postscriptno: '20260815110100010539160975713552',
  transactionLogno: '2026081506840308560516090110306',
  excerpt: '网上支付',
);

final _wechatDetail = TransactionBillDetail(
  id: 10,
  merchantName: '微信转账',
  amount: -500,
  balance: 2537.07,
  bankCard: '622262****2910',
  transactionTime: DateTime(2026, 7, 28, 16, 51, 6),
  transactionChannel: '微信支付',
  transactionCategory: '快捷支付',
  transactionDescription: '实物商品租购',
  oppositeName: '微信支付',
  oppositeAccount: '',
  oppositeBankName: '',
  postscriptno: '532607285515509565658',
  transactionLogno: '0728632781945346',
  excerpt: '网上支付',
);

final _transferDetail = TransactionBillDetail(
  id: 11,
  merchantName: '',
  amount: -1,
  balance: 1179,
  bankCard: '622262****2910',
  transactionTime: DateTime(2026, 8, 12, 11, 43, 23),
  transactionChannel: '手机银行',
  transactionCategory: '转账',
  transactionDescription: '',
  oppositeName: '沈光德',
  oppositeAccount: '621700****2353',
  oppositeBankName: '中国建设银行总行',
  postscriptno: '',
  transactionLogno: '',
  excerpt: '转账汇款',
);
