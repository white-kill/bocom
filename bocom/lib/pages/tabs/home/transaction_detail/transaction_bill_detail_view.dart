import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/model/contacts_model.dart';
import '../../../../routes/app_pages.dart';
import 'transaction_detail_repository.dart';

// 明细详情页
// 说明：当前页面为 live 接口页面，导航与详情内容均由 Flutter 原生绘制，广告使用参考图独立切图。
class TransactionBillDetailPage extends StatefulWidget {
  const TransactionBillDetailPage({
    super.key,
    required this.billId,
    this.initialDetail,
    this.detailLoader,
    this.onQuestionTap,
    this.onTransferTap,
  });

  final int billId;
  final TransactionBillDetail? initialDetail;
  final TransactionBillDetailLoader? detailLoader;
  final VoidCallback? onQuestionTap;
  final VoidCallback? onTransferTap;

  @override
  State<TransactionBillDetailPage> createState() =>
      _TransactionBillDetailPageState();
}

class _TransactionBillDetailPageState extends State<TransactionBillDetailPage> {
  TransactionBillDetail? _detail;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _detail = widget.initialDetail;
    if (_detail == null) _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (widget.billId <= 0) {
      setState(() => _failed = true);
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final detail = await (widget.detailLoader ?? loadTransactionBillDetail)(
        widget.billId,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _handleTransferTap() {
    final callback = widget.onTransferTap;
    if (callback != null) {
      callback();
      return;
    }
    final detail = _detail;
    if (detail == null) return;
    final recipient = ContactsModel()
      ..name = detail.oppositeName
      ..bankName = detail.oppositeBankName
      ..bankCard = detail.oppositeAccount;
    Get.toNamed<void>(Routes.homeAccountTransfer, arguments: recipient);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF7F7F7),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const ValueKey('transaction_bill_detail_page'),
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ScreenUtil dimensions must rebuild after device metrics settle.
              // ignore: prefer_const_constructors
              _BillDetailNavigationBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }
    if (_failed || _detail == null) {
      return Center(
        child: TextButton(
          key: const ValueKey('transaction_bill_detail_retry'),
          onPressed: _loadDetail,
          child: Text(
            '加载失败，点击重试',
            style: TextStyle(
              color: const Color(0xFF777777),
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('transaction_bill_detail_scroll'),
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: 12.w, bottom: 38.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _BillDetailCard(
              detail: _detail!,
              onTransferTap: _handleTransferTap,
            ),
          ),
          SizedBox(height: 14.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9.w),
              child: AspectRatio(
                // Reference crop: x=43, y=1990, 1120x300 from 1206x2622.
                aspectRatio: 1120 / 300,
                child: Image.asset(
                  'assets/images/transaction_detail/detail_banner.png',
                  key: const ValueKey('transaction_bill_detail_banner'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          if (_detail!.kind !=
              TransactionBillDetailKind.transferRemittance) ...[
            SizedBox(height: 62.w),
            Semantics(
              button: true,
              label: '对此交易有疑问',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onQuestionTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.w,
                  ),
                  child: Text(
                    '对此交易有疑问?',
                    style: TextStyle(
                      color: const Color(0xFF0075E5),
                      fontSize: 17.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BillDetailNavigationBar extends StatelessWidget {
  const _BillDetailNavigationBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '明细详情',
            style: TextStyle(
              color: const Color(0xFF111111),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Positioned(
            left: 4.w,
            top: 0,
            bottom: 0,
            width: 44.w,
            child: Semantics(
              button: true,
              label: '返回',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: Get.back,
                child: Center(
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11.w),
                    ),
                    child: Image.asset(
                      'assets/images/nav_back_white.png',
                      width: 8.w,
                      height: 15.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillDetailCard extends StatelessWidget {
  const _BillDetailCard({
    required this.detail,
    required this.onTransferTap,
  });

  final TransactionBillDetail detail;
  final VoidCallback onTransferTap;

  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String get _amountText {
    final amount = _amountFormat.format(detail.amount.abs());
    if (detail.amount > 0) return '+$amount';
    if (detail.amount < 0) return '-$amount';
    return amount;
  }

  String _value(String value) => value.trim().isEmpty ? '--' : value.trim();

  List<_BillDetailRowData> get _baseRows => [
        _BillDetailRowData('交易卡号', _value(detail.bankCard)),
        _BillDetailRowData(
          '交易时间',
          detail.transactionTime == null
              ? '--'
              : _dateFormat.format(detail.transactionTime!),
        ),
        _BillDetailRowData(
          '交易渠道',
          _value(detail.transactionChannel),
        ),
        _BillDetailRowData(
          '交易类型',
          _value(detail.transactionCategory),
        ),
      ];

  List<_BillDetailRowData> get _rows {
    return switch (detail.kind) {
      TransactionBillDetailKind.onlinePayment => [
          ..._baseRows,
          _BillDetailRowData(
            '交易说明',
            _value(detail.transactionDescription),
          ),
          _BillDetailRowData('交易商户', _value(detail.merchantName)),
          if (detail.oppositeName.trim().isNotEmpty)
            _BillDetailRowData('对方户名', detail.oppositeName.trim()),
          _BillDetailRowData('订单编号', _value(detail.postscriptno)),
          _BillDetailRowData('交易流水号', _value(detail.transactionLogno)),
          _BillDetailRowData('交易场景', _value(detail.excerpt)),
        ],
      TransactionBillDetailKind.transferRemittance => [
          ..._baseRows,
          _BillDetailRowData('对方户名', _value(detail.oppositeName)),
          _BillDetailRowData('对方账户', _value(detail.oppositeAccount)),
          _BillDetailRowData('对方开户行', _value(detail.oppositeBankName)),
          _BillDetailRowData('交易场景', _value(detail.excerpt)),
        ],
      TransactionBillDetailKind.unknown => [
          ..._baseRows,
          if (detail.transactionDescription.trim().isNotEmpty)
            _BillDetailRowData(
              '交易说明',
              detail.transactionDescription.trim(),
            ),
          if (detail.merchantName.trim().isNotEmpty)
            _BillDetailRowData('交易商户', detail.merchantName.trim()),
          if (detail.oppositeName.trim().isNotEmpty)
            _BillDetailRowData('对方户名', detail.oppositeName.trim()),
          if (detail.oppositeAccount.trim().isNotEmpty)
            _BillDetailRowData('对方账户', detail.oppositeAccount.trim()),
          if (detail.oppositeBankName.trim().isNotEmpty)
            _BillDetailRowData('对方开户行', detail.oppositeBankName.trim()),
          if (detail.postscriptno.trim().isNotEmpty)
            _BillDetailRowData('订单编号', detail.postscriptno.trim()),
          if (detail.transactionLogno.trim().isNotEmpty)
            _BillDetailRowData('交易流水号', detail.transactionLogno.trim()),
          if (detail.excerpt.trim().isNotEmpty)
            _BillDetailRowData('交易场景', detail.excerpt.trim()),
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('transaction_bill_detail_card'),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 40.w, 14.w, 22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        children: [
          Text(
            detail.displayName,
            key: const ValueKey('transaction_bill_detail_merchant_name'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF303030),
              fontSize: 17.sp,
            ),
          ),
          SizedBox(height: 19.w),
          Text(
            _amountText,
            key: const ValueKey('transaction_bill_detail_amount'),
            style: TextStyle(
              color: const Color(0xFF262626),
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          SizedBox(height: 10.w),
          Text(
            '余额： ${_amountFormat.format(detail.balance)}',
            key: const ValueKey('transaction_bill_detail_balance'),
            style: TextStyle(
              color: const Color(0xFF999999),
              fontSize: 17.sp,
            ),
          ),
          SizedBox(height: 43.w),
          for (final row in _rows)
            _BillDetailRow(
              label: row.label,
              value: row.value,
            ),
          if (detail.kind == TransactionBillDetailKind.transferRemittance) ...[
            SizedBox(height: 17.w),
            Container(
              key: const ValueKey('transaction_bill_detail_transfer_tip'),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.w),
              color: const Color(0xFFFFFCFA),
              child: Text(
                '温馨提示：请勿相信转账摘要中任何可疑链接',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF9A9191),
                  fontSize: 13.sp,
                  height: 1.25,
                ),
              ),
            ),
            SizedBox(height: 14.w),
            Semantics(
              button: true,
              label: '给Ta转账',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTransferTap,
                child: Container(
                  key: const ValueKey(
                    'transaction_bill_detail_transfer_button',
                  ),
                  width: double.infinity,
                  height: 45.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0075C9),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(7.w),
                  ),
                  child: Text(
                    '给Ta转账',
                    style: TextStyle(
                      color: const Color(0xFF0075C9),
                      fontSize: 17.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BillDetailRowData {
  const _BillDetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _BillDetailRow extends StatelessWidget {
  const _BillDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105.w,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF8C98A8),
                fontSize: 16.sp,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              key: ValueKey('transaction_bill_detail_$label'),
              softWrap: true,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF303030),
                fontSize: 16.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
