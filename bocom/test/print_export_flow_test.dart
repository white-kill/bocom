import 'package:bocom/pages/tabs/home/print/print_confim/print_confim_logic.dart';
import 'package:bocom/pages/tabs/home/print/print_confim/print_export_repository.dart';
import 'package:bocom/pages/tabs/home/print/print_bill_list/print_bill_list_logic.dart';
import 'package:bocom/pages/tabs/home/transaction_detail/filter/transaction_advanced_filter_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('导出筛选参数不包含分页且按时间正序', () {
    final logic = PrintBillListLogic();
    logic.beginTime.value = DateTime(2026, 8, 1);
    logic.endTime.value = DateTime(2026, 8, 20);
    logic.selectedCurrencyLabel.value = '人民币CNY';
    logic.advancedFilter.value = const TransactionAdvancedFilterValue(
      direction: '全部收入',
      commonType: '工资',
      amountRange: '自定义',
      minAmount: '100',
      maxAmount: '5000',
      channel: '手机银行',
      bank: '自定义',
      customBankName: '中国银行',
      accountName: '测试用户',
      accountNumber: '6222',
      summary: '转账',
    );

    final params = logic.buildPrintExportFilters();

    expect(params, containsPair('orderSort', '2'));
    expect(params, containsPair('beginTime', '2026-08-01'));
    expect(params, containsPair('endTime', '2026-08-20'));
    expect(params, containsPair('currency', '人民币 CNY'));
    expect(params, containsPair('type', 1));
    expect(params, containsPair('keyWord', '工资'));
    expect(params, containsPair('minAmount', 100));
    expect(params, containsPair('maxAmount', 5000));
    expect(params.containsKey('pageNum'), isFalse);
    expect(params.containsKey('pageSize'), isFalse);
    logic.onClose();
  });

  test('showType按 0-4 顺序拼接并与邮箱一起提交', () async {
    Map<String, dynamic>? submitted;
    final logic = PrintConfimLogic(
      exportParams: const {'orderSort': '2'},
      exportSubmitter: (params) async {
        submitted = params;
        return const PrintExportResult(
          email: 'abcdef@qq.com',
          code: '012345',
        );
      },
    );
    logic.state.emailController.text = 'abcdef@qq.com';
    logic.showLocation.value = false;
    logic.showOppositeAccount.value = true;

    final result = await logic.submit();

    expect(submitted, {
      'orderSort': '2',
      'email': 'abcdef@qq.com',
      'showType': '0,3,4',
    });
    expect(result.code, '012345');
    logic.onClose();
  });

  test('解压码按字符串解析并保留六位', () {
    final result = PrintExportResult.fromJson({
      'email': 'abcdef@qq.com',
      'code': 12345,
      'pdfUrl': 'https://example.com/detail.pdf',
    });

    expect(result.email, 'abcdef@qq.com');
    expect(result.code, '012345');
    expect(result.pdfUrl, 'https://example.com/detail.pdf');
  });

  test('申请记录分页解析外层状态和 detail 详情', () {
    final page = PrintRecordPageData.fromJson({
      'list': [
        {
          'id': 10001,
          'bankCard': '6222***5678',
          'dateTimeRange': '2026.07.01-2026.07.31',
          'status': '已完成',
          'fileUrl': 'https://example.com/10001.zip',
          'createTime': '2026-08-03 10:30:15',
          'detail': {
            'id': 10001,
            'email': 'user@example.com',
            'code': '012345',
            'beginTime': '2026-07-01',
            'endTime': '2026-07-31',
          },
        },
      ],
      'total': 1,
      'pages': 1,
    });

    expect(page.total, 1);
    expect(page.pages, 1);
    expect(page.records.single.bankCard, '6222***5678');
    expect(page.records.single.status, '已完成');
    expect(page.records.single.detail.email, 'user@example.com');
    expect(page.records.single.detail.code, '012345');
  });
}
