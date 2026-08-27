import 'package:bocom/pages/tabs/home/transaction_detail/filter/transaction_advanced_filter_model.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/transaction_detail_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('高级筛选完整映射为交易明细接口参数', () {
    final params = TransactionBillQuery.build(
      pageNum: 2,
      beginTime: DateTime(2026, 7, 1),
      endTime: DateTime(2026, 7, 29),
      filter: const TransactionAdvancedFilterValue(
        direction: '全部支出',
        commonType: '转账',
        amountRange: '自定义',
        minAmount: '100.50',
        maxAmount: '300',
        channel: '手机银行',
        bank: '自定义',
        customBankName: '测试银行',
        accountName: '张三',
        accountNumber: '6222',
        summary: '工资',
      ),
    );

    expect(params, {
      'pageNum': 2,
      'pageSize': 10,
      'orderSort': '1',
      'beginTime': '2026-07-01',
      'endTime': '2026-07-29',
      'type': 2,
      'keyWord': '转账',
      'minAmount': 100.5,
      'maxAmount': 300,
      'transactionChannel': '手机银行',
      'oppositeBankName': '测试银行',
      'oppositeName': '张三',
      'oppositeAccount': '6222',
      'excerpt': '工资',
    });
  });

  test('预设金额和银行按钮使用接口约定值', () {
    final params = TransactionBillQuery.build(
      pageNum: 1,
      filter: const TransactionAdvancedFilterValue(
        direction: '全部收入',
        amountRange: '1万-5万',
        bank: '建设银行',
      ),
    );

    expect(params['type'], 1);
    expect(params['minAmount'], 10000);
    expect(params['maxAmount'], 50000);
    expect(params['oppositeBankName'], '建设银行');
  });

  test('接口分页响应兼容字符串金额并修正支出符号', () {
    final page = TransactionBillPage.fromJson({
      'data': {
        'list': [
          {
            'id': 10001,
            'title': '服务端交易标题',
            'excerpt': '转账',
            'detailTemplate': 'PAYMENT_WITH_OPPOSITE',
            'oppositeName': '张三',
            'amount': '500.00',
            'accountBalance': '8,000.00',
            'merchantBranch': '手机银行',
            'transactionChannel': '支付宝',
            'month': '2026-07',
            'day': '2026-07-29 10:30:00',
            'monthIncomeTotal': '715.82',
            'monthExpensesTotal': '792.47',
            'type': 2,
            'billDetail': {
              'id': 10001,
              'bankCard': '622262****2910',
              'transactionTime': '2026-07-29 10:30:00',
              'transactionChannel': '支付宝',
              'transactionCategory': '快捷支付',
              'transactionDescription': '其他商家消费',
              'merchantName': '拼多多平台商户',
              'transactionAccount': '支付宝',
              'merchantBranch': '拼多多平台商户',
              'oppositeName': '拼多多平台商户',
              'postscriptno': 'ORDER-10001',
              'transactionLogno': 'FLOW-10001',
              'excerpt': '网上支付',
              'remark': '测试摘要',
            },
          },
        ],
        'total': '1',
        'pages': 1,
        'incomeTotal': '715.82',
        'expensesTotal': 792.47,
      },
    });

    expect(page.total, 1);
    expect(page.pages, 1);
    expect(page.incomeTotal, 715.82);
    expect(page.entries.single.id, 10001);
    expect(page.entries.single.record.title, '服务端交易标题');
    expect(page.entries.single.record.channel, '支付宝');
    expect(page.entries.single.record.amount, -500);
    expect(page.entries.single.record.balance, 8000);
    expect(page.entries.single.monthExpensesTotal, 792.47);
    expect(page.entries.single.detail?.bankCard, '622262****2910');
    expect(page.entries.single.detail?.transactionCategory, '快捷支付');
    expect(
      page.entries.single.detail?.transactionDescription,
      '其他商家消费',
    );
    expect(page.entries.single.detail?.postscriptno, 'ORDER-10001');
    expect(page.entries.single.detail?.transactionLogno, 'FLOW-10001');
    expect(page.entries.single.detail?.excerpt, '网上支付');
    expect(page.entries.single.detail?.detailTemplate, 'PAYMENT_WITH_OPPOSITE');
    expect(page.entries.single.detail?.transactionAccount, '支付宝');
    expect(page.entries.single.detail?.merchantBranch, '拼多多平台商户');
    expect(page.entries.single.detail?.remark, '测试摘要');
    expect(
      page.entries.single.detail?.kind,
      TransactionBillDetailKind.paymentWithOpposite,
    );
  });

  test('单笔详情兼容 data 包装并保留顶层收支符号', () {
    final detail = TransactionBillDetail.fromJson({
      'data': {
        'id': 9,
        'amount': -35,
        'accountBalance': '1,044.00',
        'type': 2,
        'detailTemplate': 'ONLINE_PAYMENT',
        'transactionDescription': '其他商家消费',
        'billDetail': {
          'bankCard': '622262****2910',
          'transactionTime': '2026-08-15 12:54:23',
          'transactionChannel': '支付宝',
          'transactionCategory': '快捷支付',
          'merchantName': '拼多多平台商户',
          'transactionAccount': '支付宝',
          'merchantBranch': '拼多多平台商户',
          'oppositeName': '拼多多平台商户',
          'postscriptno': '20260815110100010539160975713552',
          'transactionLogno': '2026081506840308560516090110306',
          'excerpt': '网上支付',
          'remark': '周末购物',
        },
      },
    });

    expect(detail.id, 9);
    expect(detail.merchantName, '拼多多平台商户');
    expect(detail.amount, -35);
    expect(detail.balance, 1044);
    expect(detail.transactionTime, DateTime(2026, 8, 15, 12, 54, 23));
    expect(detail.postscriptno, '20260815110100010539160975713552');
    expect(detail.transactionChannel, '支付宝');
    expect(detail.excerpt, '网上支付');
    expect(detail.detailTemplate, 'ONLINE_PAYMENT');
    expect(detail.transactionAccount, '支付宝');
    expect(detail.merchantBranch, '拼多多平台商户');
    expect(detail.remark, '周末购物');
    expect(detail.kind, TransactionBillDetailKind.onlinePayment);
  });

  test('detailTemplate 是唯一模板来源且未知值回落普通支付模板', () {
    expect(
      TransactionBillDetailKind.fromTemplate('PAYMENT_WITH_OPPOSITE'),
      TransactionBillDetailKind.paymentWithOpposite,
    );
    expect(
      TransactionBillDetailKind.fromTemplate('TRANSFER_OUT'),
      TransactionBillDetailKind.transferOut,
    );
    expect(
      TransactionBillDetailKind.fromTemplate('TRANSFER_IN'),
      TransactionBillDetailKind.transferIn,
    );
    expect(
      TransactionBillDetailKind.fromTemplate('未来新增模板'),
      TransactionBillDetailKind.onlinePayment,
    );
  });
}
