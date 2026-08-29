import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/tabs/home/transfer/record/transfer_record_detail_view.dart';

void main() {
  runApp(const _TransferRecordDetailDemoApp());
}

class _TransferRecordDetailDemoApp extends StatelessWidget {
  const _TransferRecordDetailDemoApp();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C68E1)),
        fontFamilyFallback: const ['PingFang SC'],
      ),
      home: TransferRecordDetailPage(
        data: TransferRecordDetailData(
          amount: -1,
          recipientName: '沈田田',
          recipientAccount: '6217 8563 0006 0589 317',
          recipientBank: '中国银行',
          transferredAt: DateTime(2026, 8, 26, 10, 45, 26),
          sourceAccount: '交通银行 II类账户(**2910)',
          transferRoute: '超级网银快速汇款',
          fee: 0,
          channel: '手机银行',
          arrivalTime: '预计实时到账',
          serialNumber: '2005000420260826435001450318',
          postscript: '',
        ),
        onReceiptTap: _noop,
        onTransferAgainTap: _noop,
      ),
    );
  }
}

void _noop() {}
