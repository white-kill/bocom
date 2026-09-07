import 'dart:io';
import 'dart:ui' as ui;

import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:bocom/pages/tabs/mine/children/account_asset/account_asset_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import '../../../../../routes/app_pages.dart';

const _successTemplate =
    'assets/images/account_transfer/result/transfer_success_template.png';
const _receiptBodyTemplate =
    'assets/images/account_transfer/result/transfer_receipt_body.png';
const _receiptNavigationTemplate =
    'assets/images/account_transfer/result/transfer_receipt_navigation.png';
const _receiptFooterChecked =
    'assets/images/account_transfer/result/transfer_receipt_footer_checked.png';
const _receiptFooterUnchecked =
    'assets/images/account_transfer/result/transfer_receipt_footer_unchecked.png';
const _referenceWidth = 1320.0;
const _successTemplateHeight = 2610.0;
const _receiptScreenReferenceWidth = 1206.0;
const _receiptBodyHeight = 2025.0;
const _receiptNavigationHeight = 180.0;
const _receiptFooterHeight = 660.0;
const _receiptInk = Color(0xFF333333);

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
  String get recipientAccountFull => _formatReceiptCard(recipientAccount);
  String get payerAccountFull => _formatReceiptCard(payerAccount);
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
              referenceWidth: _referenceWidth,
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
                  left: 90,
                  top: 1160,
                  width: 380,
                  height: 145,
                  semanticLabel: '转账记录',
                  onTap: () => Get.toNamed<void>(Routes.homeTransferRecord),
                ),
                _hotspot(
                  scale: scale,
                  left: 470,
                  top: 1160,
                  width: 350,
                  height: 145,
                  semanticLabel: '查询余额',
                  onTap: () =>
                      Get.to<void>(() => AccountAssetPage(initialTabIndex: 0)),
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

// 转账回执页
// 说明：导航使用不含系统状态栏的固定切图，中间使用完整回执长图滚动，底部使用选中/未选中状态切图固定展示。
class AccountTransferReceiptPage extends StatefulWidget {
  const AccountTransferReceiptPage({
    super.key,
    required this.data,
    this.receiptSaver,
    this.onNotifyWechatFriend,
  });

  final AccountTransferResultData data;
  final TransferReceiptSaver? receiptSaver;
  final VoidCallback? onNotifyWechatFriend;

  @override
  State<AccountTransferReceiptPage> createState() =>
      _AccountTransferReceiptPageState();
}

class _AccountTransferReceiptPageState
    extends State<AccountTransferReceiptPage> {
  final _savedReceiptKey = GlobalKey();
  bool _isSaving = false;
  bool _hideCardNumbers = true;

  Future<void> _saveReceipt() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final boundary = _savedReceiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Receipt render is unavailable');
      final ratio = _receiptScreenReferenceWidth / boundary.size.width;
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
        statusBarColor: Color(0xFFF7F7F7),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('account-transfer-receipt-page'),
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = constraints.maxWidth / _receiptScreenReferenceWidth;
              return Column(
                children: [
                  _ReceiptNavigation(
                    height: _receiptNavigationHeight * scale,
                    scale: scale,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const Key('receipt-content-scroll-view'),
                      child: RepaintBoundary(
                        key: _savedReceiptKey,
                        child: _SavedReceipt(
                          data: widget.data,
                          hideCardNumbers: _hideCardNumbers,
                        ),
                      ),
                    ),
                  ),
                  _ReceiptFooter(
                    hideCardNumbers: _hideCardNumbers,
                    isSaving: _isSaving,
                    onToggleCardNumbers: () {
                      setState(() => _hideCardNumbers = !_hideCardNumbers);
                    },
                    onSave: _saveReceipt,
                    onNotifyWechatFriend: widget.onNotifyWechatFriend ?? () {},
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReceiptNavigation extends StatelessWidget {
  const _ReceiptNavigation({
    required this.height,
    required this.scale,
  });

  final double height;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('receipt-fixed-navigation'),
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _receiptNavigationTemplate,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: 180 * scale,
            height: height,
            child: Semantics(
              button: true,
              label: '返回',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: Get.back,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptFooter extends StatelessWidget {
  const _ReceiptFooter({
    required this.hideCardNumbers,
    required this.isSaving,
    required this.onToggleCardNumbers,
    required this.onSave,
    required this.onNotifyWechatFriend,
  });

  final bool hideCardNumbers;
  final bool isSaving;
  final VoidCallback onToggleCardNumbers;
  final VoidCallback onSave;
  final VoidCallback onNotifyWechatFriend;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = width / _receiptScreenReferenceWidth;
        return SizedBox(
          key: const Key('receipt-fixed-footer'),
          width: width,
          height: _receiptFooterHeight * scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  hideCardNumbers
                      ? _receiptFooterChecked
                      : _receiptFooterUnchecked,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 100 * scale,
                child: Semantics(
                  button: true,
                  checked: hideCardNumbers,
                  label: '隐藏收付款卡号',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggleCardNumbers,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              _footerHotspot(
                scale: scale,
                left: 44,
                top: 397,
                width: 538,
                height: 150,
                semanticLabel: isSaving ? '正在保存图片' : '保存图片',
                onTap: onSave,
              ),
              _footerHotspot(
                scale: scale,
                left: 625,
                top: 397,
                width: 537,
                height: 150,
                semanticLabel: '通知微信好友',
                onTap: onNotifyWechatFriend,
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _footerHotspot({
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

class _SavedReceipt extends StatelessWidget {
  const _SavedReceipt({
    required this.data,
    required this.hideCardNumbers,
  });

  final AccountTransferResultData data;
  final bool hideCardNumbers;

  @override
  Widget build(BuildContext context) {
    return _ReferenceTemplate(
      asset: _receiptBodyTemplate,
      referenceWidth: _receiptScreenReferenceWidth,
      referenceHeight: _receiptBodyHeight,
      childrenBuilder: (scale) => _receiptFields(
        data: data,
        scale: scale,
        hideCardNumbers: hideCardNumbers,
      ),
    );
  }
}

class _ReferenceTemplate extends StatelessWidget {
  const _ReferenceTemplate({
    required this.asset,
    required this.referenceWidth,
    required this.referenceHeight,
    required this.childrenBuilder,
  });

  final String asset;
  final double referenceWidth;
  final double referenceHeight;
  final List<Widget> Function(double scale) childrenBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final scale = width / referenceWidth;
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
  required bool hideCardNumbers,
}) {
  Widget field({
    required Key key,
    required double top,
    required String text,
    Color color = _receiptInk,
    double fontSize = 48,
  }) {
    return Positioned(
      key: key,
      top: top * scale,
      right: 102 * scale,
      width: 850 * scale,
      height: 64 * scale,
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
      top: 238,
      text: data.recipientName,
    ),
    field(
      key: const Key('receipt-recipient-account'),
      top: 334,
      text: hideCardNumbers
          ? data.recipientAccountMasked
          : data.recipientAccountFull,
      fontSize: hideCardNumbers ? 49 : 48,
    ),
    field(
      key: const Key('receipt-recipient-bank'),
      top: 430,
      text: data.recipientBank,
    ),
    field(
      key: const Key('receipt-transfer-amount'),
      top: 524,
      text: '${data.amountText}元',
    ),
    field(
      key: const Key('receipt-uppercase-amount'),
      top: 620,
      text: data.uppercaseAmount,
      color: const Color(0xFFBD8459),
      fontSize: 48,
    ),
    field(
      key: const Key('receipt-payer-name'),
      top: 883,
      text: data.payerName,
    ),
    field(
      key: const Key('receipt-payer-account'),
      top: 979,
      text: hideCardNumbers ? data.payerAccountMasked : data.payerAccountFull,
      fontSize: hideCardNumbers ? 49 : 48,
    ),
    field(
      key: const Key('receipt-payer-bank'),
      top: 1075,
      text: data.payerBank,
    ),
    field(
      key: const Key('receipt-serial-number'),
      top: 1228,
      text: data.displaySerialNumber,
      fontSize: 48,
    ),
    field(
      key: const Key('receipt-transaction-time'),
      top: 1324,
      text: data.transactionTimeText,
      fontSize: 48,
    ),
    field(
      key: const Key('receipt-arrival-time'),
      top: 1420,
      text: data.arrivalText,
      fontSize: 48,
    ),
    if (data.purpose.trim().isNotEmpty)
      field(
        key: const Key('receipt-purpose'),
        top: 1516,
        text: data.purpose.trim(),
        fontSize: 48,
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

String _formatReceiptCard(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  return RegExp(r'.{1,4}')
      .allMatches(digits)
      .map((match) => match.group(0)!)
      .join(' ');
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
