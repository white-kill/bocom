import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import '../../../../../config/dio/network.dart';
import '../../../../../config/model/contacts_model.dart';
import '../../../../../config/net_config/apis.dart';
import '../../../../../routes/app_pages.dart';
import '../account_transfer/account_transfer_result_pages.dart';
import '../account_transfer/home_account_transfer_view.dart';

const _detailBlue = Color(0xFF2C68E1);
const _detailMuted = Color(0xFF929DAD);
const _detailBackground = Color(0xFFF7F7F7);

typedef TransferRecordDetailLoader = Future<dynamic> Function(int billId);

class TransferRecordDetailData {
  const TransferRecordDetailData({
    required this.amount,
    required this.recipientName,
    required this.recipientAccount,
    required this.recipientBank,
    required this.transferredAt,
    required this.sourceAccount,
    required this.transferRoute,
    required this.fee,
    required this.channel,
    required this.arrivalTime,
    required this.serialNumber,
    this.status = '转账成功',
    this.postscript = '',
    this.billId = 0,
    this.payerName = '小明',
    this.payerAccount = '6222620000002910',
    this.payerBank = '交通银行',
  });

  final double amount;
  final String status;
  final String recipientName;
  final String recipientAccount;
  final String recipientBank;
  final DateTime transferredAt;
  final String sourceAccount;
  final String transferRoute;
  final double fee;
  final String channel;
  final String arrivalTime;
  final String serialNumber;
  final String postscript;
  final int billId;
  final String payerName;
  final String payerAccount;
  final String payerBank;

  TransferRecordDetailData copyWith({
    double? amount,
    String? status,
    String? recipientName,
    String? recipientAccount,
    String? recipientBank,
    DateTime? transferredAt,
    String? sourceAccount,
    String? transferRoute,
    double? fee,
    String? channel,
    String? arrivalTime,
    String? serialNumber,
    String? postscript,
    int? billId,
    String? payerName,
    String? payerAccount,
    String? payerBank,
  }) {
    return TransferRecordDetailData(
      amount: amount ?? this.amount,
      status: status ?? this.status,
      recipientName: recipientName ?? this.recipientName,
      recipientAccount: recipientAccount ?? this.recipientAccount,
      recipientBank: recipientBank ?? this.recipientBank,
      transferredAt: transferredAt ?? this.transferredAt,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      transferRoute: transferRoute ?? this.transferRoute,
      fee: fee ?? this.fee,
      channel: channel ?? this.channel,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      serialNumber: serialNumber ?? this.serialNumber,
      postscript: postscript ?? this.postscript,
      billId: billId ?? this.billId,
      payerName: payerName ?? this.payerName,
      payerAccount: payerAccount ?? this.payerAccount,
      payerBank: payerBank ?? this.payerBank,
    );
  }
}

// 转账记录详情页
// 说明：当前页面参照用户提供的完整截图由 Flutter 原生绘制，两张详情卡片中的 key/value 均为动态数据。
class TransferRecordDetailPage extends StatefulWidget {
  const TransferRecordDetailPage({
    super.key,
    required this.data,
    this.detailLoader,
    this.onReceiptTap,
    this.onTransferAgainTap,
  });

  final TransferRecordDetailData data;
  final TransferRecordDetailLoader? detailLoader;
  final VoidCallback? onReceiptTap;
  final VoidCallback? onTransferAgainTap;

  @override
  State<TransferRecordDetailPage> createState() =>
      _TransferRecordDetailPageState();
}

class _TransferRecordDetailPageState extends State<TransferRecordDetailPage> {
  late TransferRecordDetailData _data = widget.data;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (_data.billId <= 0 && widget.detailLoader == null) return;
    try {
      final response = await (widget.detailLoader?.call(_data.billId) ??
          Http.post(
            '${Apis.billDetail}/${_data.billId}',
            isLoading: false,
          ));
      if (!mounted || response is! Map) return;
      final root = Map<String, dynamic>.from(response);
      final rawData = root['data'];
      final source = rawData is Map ? Map<String, dynamic>.from(rawData) : root;
      final rawDetail = source['billDetail'];
      final detail = rawDetail is Map
          ? Map<String, dynamic>.from(rawDetail)
          : const <String, dynamic>{};

      final ownBankCard = _firstText([
        _data.payerAccount,
        detail['bankCard'],
        source['bankCard'],
      ]);
      final ownBankName = _firstText([
        detail['bankName'],
        source['bankName'],
        _data.payerBank,
      ], fallback: '交通银行');
      final lastFour = _lastFourDigits(ownBankCard);
      final amount = _number(source['amount']) ??
          _number(detail['amount']) ??
          _data.amount;
      final transactionTime = _dateTime(
        detail['transactionTime'] ?? source['transactionTime'] ?? source['day'],
      );

      setState(() {
        _data = _data.copyWith(
          amount: amount,
          status: '转账成功',
          recipientAccount: _data.recipientAccount.isNotEmpty
              ? _data.recipientAccount
              : _firstText([detail['oppositeAccount']]),
          recipientBank: _data.recipientBank.isNotEmpty
              ? _data.recipientBank
              : _firstText([detail['oppositeBankName']]),
          transferredAt: transactionTime,
          sourceAccount: '$ownBankName 借记卡(**$lastFour)',
          transferRoute: '超级网银快速汇款',
          fee: 0,
          channel: _firstText([
            detail['merchantBranch'],
            source['merchantBranch'],
            detail['transactionAccount'],
          ], fallback: _data.channel),
          arrivalTime: '预计实时到账',
          serialNumber: _firstText([
            detail['transactionLogno'],
            source['transactionLogno'],
          ], fallback: _data.serialNumber),
          postscript: _firstText([
            detail['remark'],
            source['remark'],
          ], fallback: _data.postscript),
          payerAccount: ownBankCard,
          payerBank: ownBankName,
        );
      });
    } catch (error, stackTrace) {
      debugPrint('加载转账记录详情失败: $error\n$stackTrace');
    }
  }

  String get _amountText => _data.amount.toStringAsFixed(2);

  String get _timeText {
    final value = _data.transferredAt;
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  void _openReceipt() {
    final callback = widget.onReceiptTap;
    if (callback != null) {
      callback();
      return;
    }
    Get.to<void>(
      () => AccountTransferReceiptPage(
        data: AccountTransferResultData(
          billId: _data.billId,
          recipientName: _data.recipientName,
          recipientAccount: _data.recipientAccount,
          recipientBank: _data.recipientBank,
          amount: _data.amount.abs(),
          payerName: _data.payerName,
          payerAccount: _data.payerAccount,
          payerBank: _data.payerBank,
          transactionTime: _data.transferredAt,
          arrivalText: _data.arrivalTime,
          purpose: _data.postscript,
          serialNumber: _data.serialNumber,
        ),
      ),
    );
  }

  void _transferAgain() {
    final callback = widget.onTransferAgainTap;
    if (callback != null) {
      callback();
      return;
    }
    final recipient = ContactsModel()
      ..name = _data.recipientName
      ..bankName = _data.recipientBank
      ..bankCard = _data.recipientAccount.replaceAll(' ', '');
    Get.to<void>(
      () => HomeAccountTransferPage(
        initialRecipient: recipient,
        initialAmount: _data.amount.abs(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _detailBackground,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final unit = constraints.maxWidth / 402;
          return Scaffold(
            key: const ValueKey('transfer_record_detail_page'),
            backgroundColor: _detailBackground,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _TransferDetailNavigation(unit: unit),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const ValueKey('transfer_record_detail_scroll'),
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        15 * unit,
                        14.3 * unit,
                        15 * unit,
                        22 * unit,
                      ),
                      child: Column(
                        children: [
                          _TransferOverviewCard(
                            unit: unit,
                            amount: _amountText,
                            status: _data.status,
                            rows: [
                              _DetailRowData('收款人户名', _data.recipientName),
                              _DetailRowData('收款人账号', _data.recipientAccount),
                              _DetailRowData('收款人银行', _data.recipientBank),
                            ],
                          ),
                          SizedBox(height: 10 * unit),
                          _TransferInformationCard(
                            unit: unit,
                            rows: [
                              _DetailRowData('转账时间', _timeText),
                              _DetailRowData('转出账号', _data.sourceAccount),
                              _DetailRowData('转账路径', _data.transferRoute),
                              _DetailRowData(
                                  '手续费', _data.fee.toStringAsFixed(2)),
                              _DetailRowData('转账渠道', _data.channel),
                              _DetailRowData('到账时间', _data.arrivalTime),
                              _DetailRowData(
                                '流水号',
                                _data.serialNumber,
                                copyable: true,
                              ),
                              _DetailRowData('转账附言', _data.postscript),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _TransferDetailActions(
              unit: unit,
              onReceiptTap: _openReceipt,
              onTransferAgainTap: _transferAgain,
            ),
          );
        },
      ),
    );
  }
}

class _TransferDetailNavigation extends StatelessWidget {
  const _TransferDetailNavigation({required this.unit});

  final double unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44 * unit,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '转账记录详情',
            style: TextStyle(
              color: const Color(0xFF111111),
              fontSize: 19 * unit,
              fontWeight: FontWeight.w600,
            ),
          ),
          Positioned(
            left: 8 * unit,
            top: 0,
            bottom: 0,
            width: 42 * unit,
            child: Semantics(
              button: true,
              label: '返回',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: Get.back,
                child: Center(
                  child: Container(
                    width: 30 * unit,
                    height: 30 * unit,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11 * unit),
                    ),
                    child: Image.asset(
                      'assets/images/nav_back_white.png',
                      width: 8 * unit,
                      height: 15 * unit,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 15 * unit,
            top: 0,
            bottom: 0,
            child: Semantics(
              button: true,
              label: '客服',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.toNamed(Routes.customerService),
                child: Center(
                  child: Container(
                    width: 30 * unit,
                    height: 30 * unit,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11 * unit),
                    ),
                    child: Image.asset(
                      'assets/images/nav_right_kf.png',
                      width: 18 * unit,
                      height: 18 * unit,
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

class _TransferOverviewCard extends StatelessWidget {
  const _TransferOverviewCard({
    required this.unit,
    required this.amount,
    required this.status,
    required this.rows,
  });

  final double unit;
  final String amount;
  final String status;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('transfer_record_detail_overview_card'),
      width: double.infinity,
      height: 254 * unit,
      padding: EdgeInsets.fromLTRB(
        15 * unit,
        29.7 * unit,
        15 * unit,
        5.5 * unit,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * unit),
      ),
      child: Column(
        children: [
          Text(
            amount,
            key: const ValueKey('transfer_record_detail_amount'),
            style: TextStyle(
              color: const Color(0xFF292929),
              fontSize: 36 * unit,
              height: 1,
            ),
          ),
          SizedBox(height: 12.7 * unit),
          Text(
            status,
            key: const ValueKey('transfer_record_detail_status'),
            style: TextStyle(
              color: _detailMuted,
              fontSize: 17 * unit,
            ),
          ),
          const Spacer(),
          for (final row in rows)
            _TransferDetailRow(unit: unit, row: row, height: 34 * unit),
        ],
      ),
    );
  }
}

class _TransferInformationCard extends StatelessWidget {
  const _TransferInformationCard({required this.unit, required this.rows});

  final double unit;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('transfer_record_detail_information_card'),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 316 * unit),
      padding: EdgeInsets.fromLTRB(
        15 * unit,
        12.5 * unit,
        15 * unit,
        5.5 * unit,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * unit),
      ),
      child: Column(
        children: [
          for (final row in rows)
            _TransferDetailRow(
              unit: unit,
              row: row,
              height: row.copyable ? 52 * unit : 34 * unit,
            ),
        ],
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value, {this.copyable = false});

  final String label;
  final String value;
  final bool copyable;
}

class _TransferDetailRow extends StatelessWidget {
  const _TransferDetailRow({
    required this.unit,
    required this.row,
    required this.height,
  });

  final double unit;
  final _DetailRowData row;
  final double height;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: row.value));
    '复制成功'.showToast;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112 * unit,
            child: Text(
              row.label,
              style: TextStyle(
                color: _detailMuted,
                fontSize: 17 * unit,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.copyable ? _serialNumberDisplayText(row.value) : row.value,
              key: ValueKey('transfer_record_detail_${row.label}'),
              maxLines: row.copyable ? null : 1,
              overflow: row.copyable ? null : TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF303030),
                fontSize: 17 * unit,
                height: 1.35,
              ),
            ),
          ),
          if (row.copyable) ...[
            SizedBox(width: 10 * unit),
            Semantics(
              button: true,
              label: '复制流水号',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _copy,
                child: Container(
                  key: const ValueKey('transfer_record_detail_copy'),
                  width: 67 * unit,
                  height: 29 * unit,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: _detailBlue, width: unit),
                    borderRadius: BorderRadius.circular(6 * unit),
                  ),
                  child: Text(
                    '复制',
                    style: TextStyle(color: _detailBlue, fontSize: 14 * unit),
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

class _TransferDetailActions extends StatelessWidget {
  const _TransferDetailActions({
    required this.unit,
    required this.onReceiptTap,
    required this.onTransferAgainTap,
  });

  final double unit;
  final VoidCallback onReceiptTap;
  final VoidCallback onTransferAgainTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(
          15 * unit,
          7.5 * unit,
          15 * unit,
          7.5 * unit,
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomActionButton(
                key: const ValueKey('transfer_record_detail_receipt'),
                unit: unit,
                label: '查看回执',
                filled: false,
                onTap: onReceiptTap,
              ),
            ),
            SizedBox(width: 15 * unit),
            Expanded(
              child: _BottomActionButton(
                key: const ValueKey('transfer_record_detail_transfer_again'),
                unit: unit,
                label: '再转一笔',
                filled: true,
                onTap: onTransferAgainTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    super.key,
    required this.unit,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final double unit;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 52 * unit,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? _detailBlue : Colors.white,
            border: Border.all(color: _detailBlue, width: unit),
            borderRadius: BorderRadius.circular(12 * unit),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : _detailBlue,
              fontSize: 18 * unit,
            ),
          ),
        ),
      ),
    );
  }
}

String _firstText(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String _serialNumberDisplayText(String value) {
  const firstLineLength = 14;
  final text = value.trim();
  if (text.length <= firstLineLength || text.contains('\n')) return text;
  return '${text.substring(0, firstLineLength)}\n'
      '${text.substring(firstLineLength)}';
}

double? _number(dynamic value) => switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text.replaceAll(',', '').trim()),
      _ => null,
    };

DateTime? _dateTime(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

String _lastFourDigits(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 4) return digits;
  return digits.substring(digits.length - 4);
}
