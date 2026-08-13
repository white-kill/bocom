import 'dart:io';
import 'dart:ui' as ui;

import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

const _successTemplate =
    'assets/images/account_transfer/result/transfer_success_template.png';
const _receiptTemplate =
    'assets/images/account_transfer/result/transfer_receipt_template.png';
const _savedReceiptTemplate =
    'assets/images/account_transfer/result/transfer_receipt_saved_template.png';
const _referenceWidth = 1320.0;
const _successTemplateHeight = 2610.0;
const _savedReceiptHeight = 2448.0;
const _receiptInk = Color(0xFF292929);

typedef TransferBillDetailLoader = Future<dynamic> Function(int billId);
typedef TransferReceiptSaver = Future<bool> Function(Uint8List bytes);

class AccountTransferResultData {
  const AccountTransferResultData({
    required this.billId,
    required this.recipientName,
    required this.recipientAccount,
    required this.recipientBank,
    required this.amount,
    required this.payerName,
    required this.payerAccount,
    required this.payerBank,
    required this.transactionTime,
    required this.arrivalText,
    this.purpose = '',
    this.serialNumber = '',
  });

  final int billId;
  final String recipientName;
  final String recipientAccount;
  final String recipientBank;
  final double amount;
  final String payerName;
  final String payerAccount;
  final String payerBank;
  final DateTime transactionTime;
  final String arrivalText;
  final String purpose;
  final String serialNumber;

  factory AccountTransferResultData.fromTransfer({
    required int billId,
    required String recipientName,
    required String recipientAccount,
    required String recipientBank,
    required double amount,
    required DateTime transactionTime,
    required String arrivalText,
    String purpose = '',
  }) {
    var payerName = '';
    var payerAccount = '';
    var payerBank = '交通银行';
    try {
      final member = AppConfig.config.abcLogic.memberInfo;
      payerName = member.realName;
      if (member.bankList.isNotEmpty) {
        final bank = member.bankList.first;
        payerName = bank.realName.isNotEmpty ? bank.realName : payerName;
        payerAccount = bank.bankCard;
        payerBank = bank.bankName.isNotEmpty ? bank.bankName : payerBank;
      }
    } catch (_) {
      // The result page remains usable while member information is refreshing.
    }
    return AccountTransferResultData(
      billId: billId,
      recipientName: recipientName,
      recipientAccount: recipientAccount,
      recipientBank: recipientBank,
      amount: amount,
      payerName: payerName,
      payerAccount: payerAccount,
      payerBank: payerBank,
      transactionTime: transactionTime,
      arrivalText: arrivalText,
      purpose: purpose,
    );
  }

  String get amountText => NumberFormat('0.00').format(amount);
  String get recipientAccountMasked => _maskReceiptCard(recipientAccount);
  String get payerAccountMasked => _maskReceiptCard(payerAccount);
  String get recipientSummary =>
      '$recipientBank(**${_lastFour(recipientAccount)})';
  String get transactionTimeText =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(transactionTime);
  String get displaySerialNumber => serialNumber.trim().isNotEmpty
      ? serialNumber.trim()
      : _fallbackSerialNumber(billId, transactionTime);
  String get uppercaseAmount => _rmbUppercase(amount);

  AccountTransferResultData copyWith({
    DateTime? transactionTime,
    String? serialNumber,
    String? arrivalText,
  }) {
    return AccountTransferResultData(
      billId: billId,
      recipientName: recipientName,
      recipientAccount: recipientAccount,
      recipientBank: recipientBank,
      amount: amount,
      payerName: payerName,
      payerAccount: payerAccount,
      payerBank: payerBank,
      transactionTime: transactionTime ?? this.transactionTime,
      arrivalText: arrivalText ?? this.arrivalText,
      purpose: purpose,
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }
}

class AccountTransferSuccessPage extends StatefulWidget {
  const AccountTransferSuccessPage({
    super.key,
    required this.data,
    this.billDetailLoader,
    this.onContinueTransfer,
  });

  final AccountTransferResultData data;
  final TransferBillDetailLoader? billDetailLoader;
  final VoidCallback? onContinueTransfer;

  @override
  State<AccountTransferSuccessPage> createState() =>
      _AccountTransferSuccessPageState();
}

class _AccountTransferSuccessPageState
    extends State<AccountTransferSuccessPage> {
  late AccountTransferResultData _data = widget.data;

  @override
  void initState() {
    super.initState();
    _loadBillDetail();
  }

  Future<void> _loadBillDetail() async {
    try {
      final response = await (widget.billDetailLoader?.call(_data.billId) ??
          Http.post('${Apis.billDetail}/${_data.billId}', isLoading: false));
      if (!mounted || response is! Map) return;
      final map = Map<String, dynamic>.from(response);
      final detailValue = map['billDetail'];
      final detail = detailValue is Map
          ? Map<String, dynamic>.from(detailValue)
          : const <String, dynamic>{};
      final rawTime =
          detail['transactionTime'] ?? map['transactionTime'] ?? map['day'];
      final parsedTime = rawTime == null
          ? null
          : DateTime.tryParse(rawTime.toString().replaceFirst(' ', 'T'));
      final serial = _firstNonEmpty([
        detail['transactionLogno'],
        detail['certificateNo'],
        detail['postscriptno'],
        map['transactionLogno'],
      ]);
      setState(() {
        _data = _data.copyWith(
          transactionTime: parsedTime,
          serialNumber: serial,
        );
      });
    } catch (_) {
      // Receipt values already have deterministic transfer-time fallbacks.
    }
  }

  void _openReceipt() {
    Get.to<void>(() => AccountTransferReceiptPage(data: _data));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF8F8F8),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('account-transfer-success-page'),
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: SingleChildScrollView(
            child: _ReferenceTemplate(
              asset: _successTemplate,
              referenceHeight: _successTemplateHeight,
              childrenBuilder: (scale) => [
                _successText(
                  key: const Key('transfer-success-amount'),
                  scale: scale,
                  top: 570,
                  left: 350,
                  width: 620,
                  height: 145,
                  text: '¥${_data.amountText}',
                  fontSize: 72,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                _successText(
                  key: const Key('transfer-success-arrival'),
                  scale: scale,
                  top: 720,
                  left: 130,
                  width: 1060,
                  height: 115,
                  text: _successArrivalDescription(_data.arrivalText),
                  fontSize: 41,
                  textAlign: TextAlign.center,
                ),
                _successText(
                  key: const Key('transfer-success-recipient'),
                  scale: scale,
                  top: 825,
                  left: 710,
                  width: 500,
                  height: 85,
                  text: _data.recipientName,
                  fontSize: 43,
                  textAlign: TextAlign.right,
                ),
                _successText(
                  key: const Key('transfer-success-account'),
                  scale: scale,
                  top: 918,
                  left: 500,
                  width: 710,
                  height: 90,
                  text: _data.recipientSummary,
                  fontSize: 41,
                  textAlign: TextAlign.right,
                ),
                _successText(
                  key: const Key('transfer-success-default-card'),
                  scale: scale,
                  top: 1457,
                  left: 155,
                  width: 850,
                  height: 100,
                  text: '设置卡(**${_lastFour(_data.payerAccount)})为转账默认付款卡',
                  fontSize: 39,
                ),
                _hotspot(
                  scale: scale,
                  left: 1120,
                  top: 0,
                  width: 200,
                  height: 150,
                  semanticLabel: '完成',
                  onTap: () => Get.back(result: _data.billId),
                ),
                _hotspot(
                  scale: scale,
                  left: 90,
                  top: 1020,
                  width: 1140,
                  height: 135,
                  semanticLabel: '继续转账',
                  onTap: widget.onContinueTransfer ?? Get.back,
                ),
                _hotspot(
                  scale: scale,
                  left: 820,
                  top: 1160,
                  width: 380,
                  height: 145,
                  semanticLabel: '通知收款人',
                  onTap: _openReceipt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountTransferReceiptPage extends StatefulWidget {
  const AccountTransferReceiptPage({
    super.key,
    required this.data,
    this.receiptSaver,
  });

  final AccountTransferResultData data;
  final TransferReceiptSaver? receiptSaver;

  @override
  State<AccountTransferReceiptPage> createState() =>
      _AccountTransferReceiptPageState();
}

class _AccountTransferReceiptPageState
    extends State<AccountTransferReceiptPage> {
  final _savedReceiptKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveReceipt() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final boundary = _savedReceiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Receipt render is unavailable');
      final ratio = _referenceWidth / boundary.size.width;
      final image = await boundary.toImage(pixelRatio: ratio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) throw StateError('Receipt encoding failed');
      final bytes = data.buffer.asUint8List();
      final saved = await (widget.receiptSaver?.call(bytes) ??
          _saveReceiptToGallery(bytes, widget.data.billId));
      if (!mounted) return;
      (saved ? '保存成功' : '保存失败').showToast;
    } catch (error, stackTrace) {
      debugPrint('Unable to save transfer receipt: $error\n$stackTrace');
      if (mounted) {
        '保存失败'.showToast;
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF8F8F8),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('account-transfer-receipt-page'),
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: RepaintBoundary(
                    key: _savedReceiptKey,
                    child: _SavedReceipt(data: widget.data),
                  ),
                ),
              ),
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFFF8F8F8),
                  child: SingleChildScrollView(
                    child: _ReferenceTemplate(
                      asset: _receiptTemplate,
                      referenceHeight: _successTemplateHeight,
                      childrenBuilder: (scale) => [
                        ..._receiptFields(
                          data: widget.data,
                          scale: scale,
                          topOffset: -15,
                        ),
                        _hotspot(
                          scale: scale,
                          left: 0,
                          top: 0,
                          width: 155,
                          height: 180,
                          semanticLabel: '返回',
                          onTap: Get.back,
                        ),
                        _hotspot(
                          scale: scale,
                          left: 45,
                          top: 2475,
                          width: 590,
                          height: 190,
                          semanticLabel: _isSaving ? '正在保存图片' : '保存图片',
                          onTap: _saveReceipt,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedReceipt extends StatelessWidget {
  const _SavedReceipt({required this.data});

  final AccountTransferResultData data;

  @override
  Widget build(BuildContext context) {
    return _ReferenceTemplate(
      asset: _savedReceiptTemplate,
      referenceHeight: _savedReceiptHeight,
      childrenBuilder: (scale) => _receiptFields(
        data: data,
        scale: scale,
        topOffset: -150,
      ),
    );
  }
}

class _ReferenceTemplate extends StatelessWidget {
  const _ReferenceTemplate({
    required this.asset,
    required this.referenceHeight,
    required this.childrenBuilder,
  });

  final String asset;
  final double referenceHeight;
  final List<Widget> Function(double scale) childrenBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final scale = width / _referenceWidth;
        return SizedBox(
          width: width,
          height: referenceHeight * scale,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Image.asset(asset, fit: BoxFit.fill),
              ),
              ...childrenBuilder(scale),
            ],
          ),
        );
      },
    );
  }
}

List<Widget> _receiptFields({
  required AccountTransferResultData data,
  required double scale,
  required double topOffset,
}) {
  Widget field({
    required Key key,
    required double top,
    required String text,
    Color color = _receiptInk,
    double fontSize = 45,
  }) {
    return Positioned(
      key: key,
      top: (top + topOffset) * scale,
      right: 105 * scale,
      width: 850 * scale,
      height: 78 * scale,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: fontSize * scale,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  return [
    field(
      key: const Key('receipt-recipient-name'),
      top: 425,
      text: data.recipientName,
    ),
    field(
      key: const Key('receipt-recipient-account'),
      top: 523,
      text: data.recipientAccountMasked,
    ),
    field(
      key: const Key('receipt-recipient-bank'),
      top: 620,
      text: data.recipientBank,
    ),
    field(
      key: const Key('receipt-transfer-amount'),
      top: 716,
      text: '${data.amountText}元',
    ),
    field(
      key: const Key('receipt-uppercase-amount'),
      top: 812,
      text: data.uppercaseAmount,
      color: const Color(0xFFBD8459),
      fontSize: 43,
    ),
    field(
      key: const Key('receipt-payer-name'),
      top: 1073,
      text: data.payerName,
    ),
    field(
      key: const Key('receipt-payer-account'),
      top: 1169,
      text: data.payerAccountMasked,
    ),
    field(
      key: const Key('receipt-payer-bank'),
      top: 1265,
      text: data.payerBank,
    ),
    field(
      key: const Key('receipt-serial-number'),
      top: 1402,
      text: data.displaySerialNumber,
      fontSize: 42,
    ),
    field(
      key: const Key('receipt-transaction-time'),
      top: 1500,
      text: data.transactionTimeText,
      fontSize: 43,
    ),
    field(
      key: const Key('receipt-arrival-time'),
      top: 1597,
      text: data.arrivalText,
      fontSize: 43,
    ),
    if (data.purpose.trim().isNotEmpty)
      field(
        key: const Key('receipt-purpose'),
        top: 1693,
        text: data.purpose.trim(),
        fontSize: 42,
      ),
  ];
}

Widget _successText({
  required Key key,
  required double scale,
  required double top,
  required double left,
  required double width,
  required double height,
  required String text,
  required double fontSize,
  FontWeight fontWeight = FontWeight.w400,
  TextAlign textAlign = TextAlign.left,
}) {
  return Positioned(
    key: key,
    left: left * scale,
    top: top * scale,
    width: width * scale,
    height: height * scale,
    child: Align(
      alignment: textAlign == TextAlign.right
          ? Alignment.centerRight
          : textAlign == TextAlign.center
              ? Alignment.center
              : Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          textAlign: textAlign,
          style: TextStyle(
            color: const Color(0xFF161616),
            fontSize: fontSize * scale,
            fontWeight: fontWeight,
            height: 1,
          ),
        ),
      ),
    ),
  );
}

Widget _hotspot({
  required double scale,
  required double left,
  required double top,
  required double width,
  required double height,
  required String semanticLabel,
  required VoidCallback onTap,
}) {
  return Positioned(
    left: left * scale,
    top: top * scale,
    width: width * scale,
    height: height * scale,
    child: Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    ),
  );
}

Future<bool> _saveReceiptToGallery(Uint8List bytes, int billId) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/transfer_receipt_$billId.png');
  await file.writeAsBytes(bytes, flush: true);
  return await GallerySaver.saveImage(
        file.path,
        albumName: '交通银行',
        toDcim: true,
      ) ??
      false;
}

String _successArrivalDescription(String arrivalText) {
  if (arrivalText.contains('实时')) {
    return '预计实时到账，实际到账时间取决于收款银行';
  }
  return '$arrivalText，实际到账时间取决于收款银行';
}

String _maskReceiptCard(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 8) return digits;
  return '${digits.substring(0, 6)}****${digits.substring(digits.length - 4)}';
}

String _lastFour(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 4) return digits;
  return digits.substring(digits.length - 4);
}

String _fallbackSerialNumber(int billId, DateTime time) {
  final prefix = DateFormat('yyyyMMddHHmmss').format(time);
  return '$prefix${billId.toString().padLeft(8, '0')}';
}

String _firstNonEmpty(List<dynamic> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _rmbUppercase(double amount) {
  final totalFen = (amount * 100).round();
  final yuan = totalFen ~/ 100;
  final jiao = totalFen ~/ 10 % 10;
  final fen = totalFen % 10;
  final buffer = StringBuffer('人民币');
  if (yuan > 0) {
    buffer.write('${_uppercaseInteger(yuan)}元');
  }
  if (jiao > 0) {
    buffer.write('${_financialDigits[jiao]}角');
  } else if (yuan > 0 && fen > 0) {
    buffer.write('零');
  }
  if (fen > 0) buffer.write('${_financialDigits[fen]}分');
  if (jiao == 0 && fen == 0) buffer.write(yuan == 0 ? '零元整' : '整');
  return buffer.toString();
}

const _financialDigits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];

String _uppercaseInteger(int value) {
  if (value == 0) return _financialDigits.first;
  const groups = ['', '万', '亿', '兆'];
  final parts = <String>[];
  var remaining = value;
  var groupIndex = 0;
  var needsZero = false;
  while (remaining > 0) {
    final group = remaining % 10000;
    if (group == 0) {
      needsZero = parts.isNotEmpty;
    } else {
      var text = _uppercaseFourDigits(group);
      if (needsZero || (parts.isNotEmpty && group < 1000)) {
        text = '零$text';
      }
      parts.insert(0, '$text${groups[groupIndex]}');
      needsZero = false;
    }
    remaining ~/= 10000;
    groupIndex++;
  }
  return parts.join().replaceAll(RegExp(r'零+'), '零');
}

String _uppercaseFourDigits(int value) {
  const units = ['仟', '佰', '拾', ''];
  final divisors = [1000, 100, 10, 1];
  final buffer = StringBuffer();
  var zeroPending = false;
  for (var index = 0; index < divisors.length; index++) {
    final digit = value ~/ divisors[index] % 10;
    if (digit == 0) {
      if (buffer.isNotEmpty) zeroPending = true;
      continue;
    }
    if (zeroPending) {
      buffer.write('零');
      zeroPending = false;
    }
    buffer.write('${_financialDigits[digit]}${units[index]}');
  }
  return buffer.toString();
}
