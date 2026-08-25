import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wb_base_widget/extension/double_extension.dart';

import '../../../../component/auth_sm.dart';
import '../../../../component/indicator_loading.dart';
import '../../../../component/password_keyboard_sheet.dart';
import '../../../../../routes/app_pages.dart';
import 'account_transfer_support_pages.dart';
import 'account_transfer_result_pages.dart';

const _accountTransferReferenceWidth = 588.0;
const _accountTransferSupplementalReferenceWidth = 1206.0;
const _contactIconAsset =
    'assets/images/account_transfer/icons/recipient_contact.png';
const _cardScanIconAsset = 'assets/images/account_transfer/icons/card_scan.png';
const _rowChevronAsset = 'assets/images/account_transfer/icons/row_chevron.png';
const _bankOfCommunicationsAsset =
    'assets/images/account_transfer/icons/bank_of_communications.png';
const _bankOfChinaAsset =
    'assets/images/account_transfer/icons/bank_of_china.png';

typedef AccountTransferSubmitter = Future<dynamic> Function(
  Map<String, dynamic> data,
);

enum AccountTransferEntryMode {
  editable,
  quickRecipient,
}

enum TransferPageKind {
  account,
  phone,
}

class AccountTransferRouteArguments {
  const AccountTransferRouteArguments({
    this.mode = AccountTransferEntryMode.editable,
    this.recipient,
  });

  const AccountTransferRouteArguments.quickRecipient(
    ContactsModel this.recipient,
  ) : mode = AccountTransferEntryMode.quickRecipient;

  const AccountTransferRouteArguments.prefilledRecipient(
    ContactsModel this.recipient,
  ) : mode = AccountTransferEntryMode.editable;

  final AccountTransferEntryMode mode;
  final ContactsModel? recipient;
}

double _referencePixels(BuildContext context, double pixels) {
  return MediaQuery.sizeOf(context).width /
      _accountTransferReferenceWidth *
      pixels;
}

double _supplementalReferencePixels(BuildContext context, double pixels) {
  return MediaQuery.sizeOf(context).width /
      _accountTransferSupplementalReferenceWidth *
      pixels;
}

// 账号转账页
// 说明：当前页面是活页面，表单、账户信息和交互状态均由 Flutter 原生绘制。
class HomeAccountTransferPage extends StatefulWidget {
  const HomeAccountTransferPage({
    super.key,
    this.initialRecipient,
    this.entryMode = AccountTransferEntryMode.editable,
    this.pageKind = TransferPageKind.account,
    this.initialAmount,
    this.contactsLoader,
    this.bankLoader,
    this.passwordVerificationLauncher,
    this.smsVerificationLauncher,
    this.transferSubmitter,
    this.billDetailLoader,
    this.now,
    this.onPhoneNext,
  });

  final ContactsModel? initialRecipient;
  final AccountTransferEntryMode entryMode;
  final TransferPageKind pageKind;
  final double? initialAmount;
  final Future<List<ContactsModel>> Function()? contactsLoader;
  final Future<List<RecipientBank>> Function()? bankLoader;
  final PasswordVerificationLauncher? passwordVerificationLauncher;
  final SmsVerificationLauncher? smsVerificationLauncher;
  final AccountTransferSubmitter? transferSubmitter;
  final TransferBillDetailLoader? billDetailLoader;
  final DateTime Function()? now;
  final VoidCallback? onPhoneNext;

  @override
  State<HomeAccountTransferPage> createState() =>
      _HomeAccountTransferPageState();
}

class _HomeAccountTransferPageState extends State<HomeAccountTransferPage> {
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _bankController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  String _arrivalTime = '预计实时到账';
  bool _isSubmitting = false;

  double get _amountValue =>
      double.tryParse(
        _amountController.text.replaceAll(',', '').trim(),
      ) ??
      0;

  double? get _availableBalance {
    if (!Get.isRegistered<BocLogic>()) return null;
    final banks = Get.find<BocLogic>().memberInfo.bankList;
    if (banks.isEmpty) return null;
    return banks.first.accountBalance;
  }

  bool get _hasInsufficientBalance {
    final balance = _availableBalance;
    return balance != null && _amountValue > balance;
  }

  bool get _usesDeferredArrival => _amountValue >= 10000000;

  bool get _isPhoneTransfer => widget.pageKind == TransferPageKind.phone;

  List<TextEditingController> get _requiredControllers => _isPhoneTransfer
      ? [_nameController, _accountController, _amountController]
      : [
          _nameController,
          _accountController,
          _bankController,
          _amountController,
        ];

  bool get _canContinue =>
      _requiredControllers.every(
        (controller) => controller.text.trim().isNotEmpty,
      ) &&
      (!_isPhoneTransfer ||
          _accountController.text.replaceAll(RegExp(r'\D'), '').length == 11) &&
      _amountValue >= 0.01 &&
      !_hasInsufficientBalance;

  @override
  void initState() {
    super.initState();
    _fillRecipient(widget.initialRecipient);
    final initialAmount = widget.initialAmount;
    if (initialAmount != null && initialAmount.abs() >= 0.01) {
      _amountController.text = _displayAmount(
        initialAmount.abs().toStringAsFixed(2),
      );
    }
    for (final controller in _requiredControllers) {
      controller.addListener(_refresh);
    }
    _amountFocusNode.addListener(_handleAmountFocusChanged);
    _descriptionFocusNode.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _handleAmountFocusChanged() {
    final original = _amountController.text;
    if (original.isEmpty) {
      _refresh();
      return;
    }
    final updated = _amountFocusNode.hasFocus
        ? _editableAmount(original)
        : _displayAmount(original);
    if (updated != original) {
      _amountController.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: updated.length),
      );
    }
    _refresh();
  }

  String _editableAmount(String value) {
    var result = value.replaceAll(',', '');
    if (result.endsWith('.00')) result = result.substring(0, result.length - 3);
    if (result.contains('.')) {
      result = result.replaceFirst(RegExp(r'0+$'), '');
      result = result.replaceFirst(RegExp(r'\.$'), '');
    }
    return result;
  }

  String _displayAmount(String value) {
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null) return value;
    return NumberFormat('#,##0.00').format(parsed);
  }

  void _fillRecipient(ContactsModel? recipient) {
    if (recipient == null) return;
    _nameController.text = recipient.name;
    _accountController.text = recipient.bankCard;
    _bankController.text = recipient.bankName;
  }

  Future<void> _chooseRecipient() async {
    FocusScope.of(context).unfocus();
    final recipient = await Get.to<ContactsModel>(
      () => AccountTransferRecipientsPage(
        contactsLoader: widget.contactsLoader,
      ),
    );
    if (recipient != null) _fillRecipient(recipient);
  }

  Future<void> _scanBankCard() async {
    FocusScope.of(context).unfocus();
    final cardNumber = await Get.to<String>(() => const BankCardScannerPage());
    if (cardNumber != null) _accountController.text = cardNumber;
  }

  Future<void> _chooseBank() async {
    FocusScope.of(context).unfocus();
    final bank = await Get.to<String>(
      () => RecipientBankPage(bankLoader: widget.bankLoader),
    );
    if (bank != null) _bankController.text = bank;
  }

  Future<void> _chooseArrivalTime() async {
    FocusScope.of(context).unfocus();
    final result = await showArrivalTimeSheet(context, _arrivalTime);
    if (result != null && mounted) setState(() => _arrivalTime = result);
  }

  Future<void> _showArrivalExplanation() async {
    FocusScope.of(context).unfocus();
    await showArrivalExplanationSheet(context);
  }

  Future<void> _continue() async {
    if (!_canContinue || _isSubmitting) return;
    _amountFocusNode.unfocus();
    if (_isPhoneTransfer) {
      widget.onPhoneNext?.call();
      return;
    }
    final recipient = ContactsModel()
      ..name = _nameController.text.trim()
      ..bankCard = _accountController.text.trim()
      ..bankName = _bankController.text.trim();
    final amount = _displayAmount(_amountController.text.trim());
    setState(() => _isSubmitting = true);
    try {
      final transferContext = AuthSmTransferContext(
        payeeName: recipient.name,
        cardLast4: _cardLastFour(recipient.bankCard),
        amountDisplay: amount.replaceAll(',', ''),
      );
      final phone = _memberPhone;
      final smsVerified = await (widget.smsVerificationLauncher?.call(
            context,
            phone,
            transferContext,
          ) ??
          showSmsVerificationCode(
            context,
            phone: phone,
            transferContext: transferContext,
          ));
      if (!mounted || smsVerified != true) return;
      final transaction = TransactionPasswordContext(
        payeeName: recipient.name,
        amountDisplay: amount,
        bankName: recipient.bankName,
        accountNumber: recipient.bankCard,
      );
      final passwordVerified = await (widget.passwordVerificationLauncher
              ?.call(context, transaction) ??
          PasswordKeyboardSheet.showForVerification(
            context,
            transaction: transaction,
          ));
      if (!mounted || passwordVerified != true) return;
      final transactionTime = widget.now?.call() ?? DateTime.now();
      final amountValue = num.parse(amount.replaceAll(',', '')).toDouble();
      final purpose = _descriptionController.text.trim();
      final accountsTime = _accountsTimeFor(transactionTime);
      final payload = <String, dynamic>{
        'type': '0',
        'realName': recipient.name,
        'cardNo': recipient.bankCard,
        'bankName': recipient.bankName,
        'amount': amountValue,
        if (purpose.isNotEmpty) 'purpose': purpose,
        if (accountsTime != null)
          'accountsTime':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(accountsTime),
      };
      final response = await BocomLoading.run<dynamic>(
        context,
        () =>
            widget.transferSubmitter?.call(payload) ??
            Http.post(
              Apis.transfer,
              data: payload,
              isLoading: false,
            ),
        alignment: const Alignment(0, -0.22),
      );
      if (!mounted) return;
      final billId = _transferBillId(response);
      if (billId == null) throw StateError('转账接口未返回账单ID');
      if (Get.isRegistered<BocLogic>()) {
        Get.find<BocLogic>().memberInfoData();
      }
      if (mounted) {
        final arrivalText =
            _usesDeferredArrival ? '实时提交，预计1小时内到账' : _arrivalTime;
        final result = AccountTransferResultData.fromTransfer(
          billId: billId,
          recipientName: recipient.name,
          recipientAccount: recipient.bankCard,
          recipientBank: recipient.bankName,
          amount: amountValue,
          transactionTime: transactionTime,
          arrivalText: arrivalText,
          purpose: purpose,
        );
        Get.off<int>(
          () => AccountTransferSuccessPage(
            data: result,
            billDetailLoader: widget.billDetailLoader,
            onContinueTransfer: () =>
                Get.off<void>(() => const HomeAccountTransferPage()),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('转账提交失败，请稍后重试')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  DateTime? _accountsTimeFor(DateTime now) {
    if (_usesDeferredArrival) return now.add(const Duration(hours: 1));
    return switch (_arrivalTime) {
      '预计2小时后到账' => now.add(const Duration(hours: 2)),
      '预计次日到账' => now.add(const Duration(days: 1)),
      _ => null,
    };
  }

  int? _transferBillId(dynamic response) {
    final value = response is Map ? response['data'] : response;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String get _memberPhone {
    try {
      return AppConfig.config.abcLogic.memberInfo.phone;
    } catch (_) {
      return '';
    }
  }

  String _cardLastFour(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;
    return digits.substring(digits.length - 4);
  }

  @override
  void dispose() {
    for (final controller in _requiredControllers) {
      controller.removeListener(_refresh);
    }
    _nameController.dispose();
    _accountController.dispose();
    _bankController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode
      ..removeListener(_handleAmountFocusChanged)
      ..dispose();
    _descriptionFocusNode
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7F8FA),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 48,
          centerTitle: true,
          leading: Semantics(
            button: true,
            label: '返回',
            child: IconButton(
              onPressed: Get.back,
              icon: Image.asset(
                'assets/images/home_credit_card_back.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
          title: Text(
            _isPhoneTransfer ? '手机号转账' : '账号转账',
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Semantics(
              button: true,
              label: '客服',
              child: IconButton(
                onPressed: () => Get.toNamed(Routes.customerService),
                icon: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/nav_right_kf.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _buildPayerCard(),
            const SizedBox(height: 12),
            _buildRecipientCard(),
            const SizedBox(height: 12),
            _buildAmountCard(),
            if (!_isPhoneTransfer) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildArrivalSummary()),
                  TextButton(
                    onPressed: _chooseArrivalTime,
                    child: const Text(
                      '更换到账时间',
                      style: TextStyle(color: Color(0xFF0875E8), fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 30),
            _buildNextButton(),
            const SizedBox(height: 28),
            if (_isPhoneTransfer)
              const _PhoneTransferTips()
            else
              const _TransferTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayerCard() {
    if (!Get.isRegistered<BocLogic>()) {
      return _PayerCardEmpty(label: _isPhoneTransfer ? '付款卡' : '付款账户');
    }
    return GetBuilder<BocLogic>(
      id: 'updateCard',
      builder: (logic) {
        if (logic.memberInfo.bankList.isEmpty) {
          return _PayerCardEmpty(label: _isPhoneTransfer ? '付款卡' : '付款账户');
        }
        final bank = logic.memberInfo.bankList.first;
        final digits = bank.bankCard.replaceAll(RegExp(r'\D'), '');
        final suffix =
            digits.length > 4 ? digits.substring(digits.length - 4) : digits;
        return _PayerCard(
          label: _isPhoneTransfer ? '付款卡' : '付款账户',
          bankName: bank.bankName,
          title: '${bank.bankName} 借记卡(**$suffix)',
          balance: _isPhoneTransfer
              ? '可用余额： ${bank.accountBalance.bankBalance}元'
              : '可用余额 ${bank.accountBalance.bankBalance}元',
          onTap: () => _showPayerAccountSheet(
            bankName: bank.bankName,
            title: '${bank.bankName} 借记卡 (**$suffix)',
            balance: '可用余额${bank.accountBalance.bankBalance}元',
          ),
        );
      },
    );
  }

  Widget _buildArrivalSummary() {
    if (_usesDeferredArrival) {
      return _ArrivalSummaryButton(
        onPressed: _showArrivalExplanation,
        children: const [
          TextSpan(
            text: '实时提交，预计1小时内到账',
            style: TextStyle(color: Color(0xFFFF575A)),
          ),
        ],
      );
    }
    if (_arrivalTime != '预计实时到账') {
      return _ArrivalSummaryButton(
        onPressed: _showArrivalExplanation,
        children: [TextSpan(text: _arrivalTime)],
      );
    }
    return _ArrivalSummaryButton(
      onPressed: _showArrivalExplanation,
      children: const [
        TextSpan(text: '预计'),
        TextSpan(
          text: '实时',
          style: TextStyle(color: Color(0xFFFF575A)),
        ),
        TextSpan(text: '到账'),
      ],
    );
  }

  Future<void> _showPayerAccountSheet({
    required String bankName,
    required String title,
    required String balance,
  }) async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (sheetContext) => SizedBox(
        height: _supplementalReferencePixels(sheetContext, 1644),
        child: _PayerAccountSheet(
          bankName: bankName,
          title: title,
          balance: balance,
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  Widget _buildRecipientCard() {
    if (_isPhoneTransfer) return _buildPhoneRecipientCard();
    if (widget.entryMode == AccountTransferEntryMode.quickRecipient &&
        widget.initialRecipient != null) {
      return _QuickRecipientCard(recipient: widget.initialRecipient!);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '收款人',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _TransferInputRow(
              label: '户名',
              hint: '收款人户名/企业账户名',
              controller: _nameController,
              suffix: _TransferSuffixButton(
                label: '选择收款人',
                onPressed: _chooseRecipient,
                asset: _contactIconAsset,
                sourceWidth: 20,
                sourceHeight: 20,
              ),
            ),
            _TransferInputRow(
              label: '账号',
              hint: '借记卡号/信用卡号/企业账号',
              controller: _accountController,
              keyboardType: TextInputType.number,
              suffix: _TransferSuffixButton(
                label: '扫描银行卡',
                onPressed: _scanBankCard,
                asset: _cardScanIconAsset,
                sourceWidth: 21,
                sourceHeight: 20,
              ),
            ),
            _TransferInputRow(
              key: const Key('transfer-recipient-bank-row'),
              label: '银行',
              semanticsLabel: '收款银行',
              hint: '请选择收款账户开户银行',
              controller: _bankController,
              readOnly: true,
              onTap: _chooseBank,
              suffix: const _TransferSuffixIcon(
                asset: _rowChevronAsset,
                sourceWidth: 10,
                sourceHeight: 19,
              ),
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneRecipientCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '收款人',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _TransferInputRow(
              rowHeight: 48,
              fieldKey: const Key('phone-transfer-name-field'),
              label: '姓名',
              hint: '请输入收款人的真实姓名',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              suffix: const SizedBox(
                width: 40,
                height: 43,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.person_outline,
                    size: 23,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
            _TransferInputRow(
              rowHeight: 48,
              fieldKey: const Key('phone-transfer-phone-field'),
              label: '手机号',
              hint: '请输入收款人手机号',
              controller: _accountController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final unit = _amountUnit(_amountValue);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '转账金额',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: _isPhoneTransfer
                      ? null
                      : () => showTransferLimitSheet(context),
                  child: _isPhoneTransfer
                      ? const SizedBox.shrink()
                      : const Text(
                          '限额说明',
                          style: TextStyle(
                            color: Color(0xFF0875E8),
                            fontSize: 14,
                          ),
                        ),
                ),
              ],
            ),
            Container(
              height: _hasInsufficientBalance ? 62 : 56,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.translate(
                          key: const Key('transfer-currency-symbol'),
                          offset: const Offset(0, 4),
                          child: const Text(
                            '¥',
                            style: TextStyle(
                              fontSize: 31,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF292929),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            key: const Key('transfer-amount-field'),
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: const [_TransferAmountFormatter()],
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                              fontSize: 30,
                              height: 1,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF292929),
                            ),
                            decoration: InputDecoration(
                              hintText: '0手续费',
                              hintStyle: const TextStyle(
                                color: Color(0xFFD5D9E1),
                                fontSize: 20,
                                height: 1,
                                fontWeight: FontWeight.w400,
                              ),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                              suffixIcon: _amountFocusNode.hasFocus &&
                                      _amountController.text.isNotEmpty
                                  ? IconButton(
                                      key: const Key('clear-transfer-amount'),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: _amountController.clear,
                                      icon: const Icon(
                                        Icons.cancel,
                                        size: 17,
                                        color: Color(0xFFC7CCD5),
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.only(top: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unit != null)
                    Positioned(
                      key: const Key('amount-unit-tooltip'),
                      left: 21,
                      top: -2,
                      child: _AmountUnitBubble(label: unit),
                    ),
                  if (_hasInsufficientBalance)
                    const Positioned(
                      key: Key('amount-insufficient-message'),
                      left: 23,
                      bottom: -7,
                      child: _InsufficientBalanceBubble(),
                    ),
                ],
              ),
            ),
            TextField(
              key: const Key('transfer-description-field'),
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              maxLength: 60,
              decoration: InputDecoration(
                counterText: '',
                hintText:
                    _descriptionFocusNode.hasFocus ? '选填，对方可见，60字内' : '添加转账说明',
                hintStyle: const TextStyle(
                  color: Color(0xFFD5D9E1),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 13, bottom: 10),
              ),
            ),
            if (_descriptionFocusNode.hasFocus) ...[
              const SizedBox(height: 2),
              _DescriptionSuggestions(
                onSelected: (value) {
                  _descriptionController.text = value;
                  _descriptionController.selection = TextSelection.collapsed(
                    offset: value.length,
                  );
                },
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }

  String? _amountUnit(double amount) {
    if (amount >= 100000000) return '亿';
    if (amount >= 10000000) return '千万';
    if (amount >= 1000000) return '百万';
    if (amount >= 100000) return '十万';
    if (amount >= 10000) return '万';
    if (amount >= 1000) return '千';
    return null;
  }

  Widget _buildNextButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _canContinue && !_isSubmitting ? _continue : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF72A7E9),
          disabledBackgroundColor: const Color(0xFFD2D6DE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: const Text(
          '下一步',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class _TransferAmountFormatter extends TextInputFormatter {
  const _TransferAmountFormatter();

  static final _validAmount = RegExp(r'^\d{0,12}(?:\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final candidate = newValue.text.replaceAll(',', '');
    if (!_validAmount.hasMatch(candidate)) return oldValue;
    final selectionEnd = newValue.selection.end;
    final safeEnd = selectionEnd.clamp(0, newValue.text.length);
    final removedCommas =
        ','.allMatches(newValue.text.substring(0, safeEnd)).length;
    final cursor = (safeEnd - removedCommas).clamp(0, candidate.length);
    return newValue.copyWith(
      text: candidate,
      selection: TextSelection.collapsed(offset: cursor),
      composing: TextRange.empty,
    );
  }
}

class _ArrivalSummaryButton extends StatelessWidget {
  const _ArrivalSummaryButton({
    required this.onPressed,
    required this.children,
  });

  final VoidCallback onPressed;
  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          key: const Key('arrival-summary-text'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFF8B99AA),
                fontSize: 14,
              ),
              children: children,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Semantics(
          button: true,
          label: '查看到账说明',
          child: InkResponse(
            key: const Key('arrival-explanation-button'),
            onTap: onPressed,
            radius: 18,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF8B99AA),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountUnitBubble extends StatelessWidget {
  const _AmountUnitBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _AmountUnitBubblePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 2, 7, 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0875E8),
            fontSize: 11,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _AmountUnitBubblePainter extends CustomPainter {
  const _AmountUnitBubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(.5, .5)
      ..lineTo(size.width - .5, .5)
      ..lineTo(size.width - .5, size.height - 5.5)
      ..lineTo(size.width / 2 + 4, size.height - 5.5)
      ..lineTo(size.width / 2, size.height - .5)
      ..lineTo(size.width / 2 - 4, size.height - 5.5)
      ..lineTo(.5, size.height - 5.5)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF0875E8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InsufficientBalanceBubble extends StatelessWidget {
  const _InsufficientBalanceBubble();

  @override
  Widget build(BuildContext context) {
    // The supplied 1206 px screenshot was captured at 3x. The unscaled
    // Flutter bubble is 192 logical px wide (= 576 source px at 3x), so this
    // factor preserves its 576/1206 viewport ratio on the current device.
    final referenceScale = _supplementalReferencePixels(context, 576) / 192;
    return Transform.scale(
      key: const Key('amount-insufficient-reference-scale'),
      scale: referenceScale,
      alignment: Alignment.topLeft,
      child: const CustomPaint(
        key: Key('amount-insufficient-tip-shape'),
        painter: _InsufficientBalanceBubblePainter(),
        child: Padding(
          // The supplemental reference has a 9 px upward tip above an 18 dp
          // message body. Keep that space inside the painted bounds so the
          // bubble remains anchored to the amount underline by its bottom edge.
          padding: EdgeInsets.fromLTRB(6, 5, 6, 2),
          child: Text(
            '余额不足，更换付款卡或补充资金',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _InsufficientBalanceBubblePainter extends CustomPainter {
  const _InsufficientBalanceBubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const tipHeight = 3.0;
    const tipCenter = 12.5;
    const tipHalfWidth = 3.5;
    const radius = Radius.circular(1.5);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, tipHeight, size.width, size.height - tipHeight),
      radius,
    );
    final path = Path()
      ..addRRect(body)
      ..moveTo(tipCenter - tipHalfWidth, tipHeight)
      ..lineTo(tipCenter, 0)
      ..lineTo(tipCenter + tipHalfWidth, tipHeight)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFFFF575A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DescriptionSuggestions extends StatelessWidget {
  const _DescriptionSuggestions({required this.onSelected});

  static const values = [
    '生活费',
    '工资福利',
    '投资理财',
    '还信用卡',
    '商业贷款',
    '还房租',
    '还贷款',
    '归还欠款',
  ];

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 50;
    final tileWidth = (availableWidth - 18) / 4;
    final gridHeight = tileWidth / 2.55 * 2 + 6;
    return SizedBox(
      height: gridHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 2.55,
        ),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          return Material(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(7),
            child: InkWell(
              onTap: () => onSelected(value),
              borderRadius: BorderRadius.circular(7),
              child: Center(
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PayerAccountSheet extends StatelessWidget {
  const _PayerAccountSheet({
    required this.bankName,
    required this.title,
    required this.balance,
    required this.onClose,
  });

  final String bankName;
  final String title;
  final String balance;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('payer-account-sheet'),
      color: const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(_supplementalReferencePixels(context, 32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: _supplementalReferencePixels(context, 164),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    '选择付款账户',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: _supplementalReferencePixels(context, 4),
                    child: IconButton(
                      tooltip: '关闭',
                      onPressed: onClose,
                      icon: Icon(
                        Icons.close,
                        size: _supplementalReferencePixels(context, 57),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                _supplementalReferencePixels(context, 45),
                _supplementalReferencePixels(context, 59),
                _supplementalReferencePixels(context, 45),
                0,
              ),
              child: Container(
                key: const Key('payer-account-option'),
                height: _supplementalReferencePixels(context, 222),
                padding: EdgeInsets.symmetric(
                  horizontal: _supplementalReferencePixels(context, 28),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    _supplementalReferencePixels(context, 22),
                  ),
                  border: Border.all(color: const Color(0xFF0875E8)),
                ),
                child: Row(
                  children: [
                    _PayerBankLogo(bankName: bankName),
                    SizedBox(
                      width: _supplementalReferencePixels(context, 21),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, height: 1),
                          ),
                          SizedBox(
                            height: _supplementalReferencePixels(context, 33),
                          ),
                          Text(
                            balance,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 13,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: _supplementalReferencePixels(context, 59),
                      height: _supplementalReferencePixels(context, 59),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0875E8),
                        borderRadius: BorderRadius.circular(
                          _supplementalReferencePixels(context, 17),
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: _supplementalReferencePixels(context, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                _supplementalReferencePixels(context, 45),
                0,
                _supplementalReferencePixels(context, 45),
                _supplementalReferencePixels(context, 129),
              ),
              child: SizedBox(
                width: double.infinity,
                height: _supplementalReferencePixels(context, 138),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0875E8),
                    side: const BorderSide(color: Color(0xFF0875E8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        _supplementalReferencePixels(context, 22),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 23),
                  label: const Text('添加付款账户', style: TextStyle(fontSize: 17)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showArrivalExplanationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black45,
    builder: (sheetContext) => SizedBox(
      height: _supplementalReferencePixels(sheetContext, 1644),
      child: Material(
        key: const Key('arrival-explanation-sheet'),
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            _supplementalReferencePixels(sheetContext, 32),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: _supplementalReferencePixels(sheetContext, 164),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      '到账说明',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Positioned(
                      left: _supplementalReferencePixels(sheetContext, 4),
                      child: IconButton(
                        tooltip: '关闭',
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(
                          Icons.close,
                          size: _supplementalReferencePixels(sheetContext, 57),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _supplementalReferencePixels(sheetContext, 45),
                  _supplementalReferencePixels(sheetContext, 66),
                  _supplementalReferencePixels(sheetContext, 45),
                  0,
                ),
                child: const Text(
                  '1.我行将根据您选择的到账时间自动确定转账交易实际处理的时间。\n'
                  '2.请您注意转账交易在我行的实际处理时间。交行行内转账，一般实时到账，跨行转账具体到账时间，以收款银行入账时间为准。\n'
                  '3.对于非实时到账的转账交易，您可随时在交易实际处理时间前，通过个人手机银行-转账-转账记录、个人网银-转账-转账记录查询-可撤销交易查询等任一渠道办理撤销。',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PayerCard extends StatelessWidget {
  const _PayerCard({
    this.label = '付款账户',
    required this.bankName,
    required this.title,
    required this.balance,
    required this.onTap,
  });

  final String label;
  final String bankName;
  final String title;
  final String balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('payer-account-card'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _PayerBankLogo(bankName: bankName),
                  SizedBox(
                    width: _referencePixels(context, 12),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balance,
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _TransferSuffixIcon(
                    asset: _rowChevronAsset,
                    sourceWidth: 10,
                    sourceHeight: 19,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayerBankLogo extends StatelessWidget {
  const _PayerBankLogo({required this.bankName});

  final String bankName;

  @override
  Widget build(BuildContext context) {
    final isBankOfChina = bankName.contains('中国银行');
    return Semantics(
      image: true,
      label: '$bankName图标',
      child: _ReferenceIcon(
        asset: isBankOfChina ? _bankOfChinaAsset : _bankOfCommunicationsAsset,
        sourceWidth: isBankOfChina ? 38 : 48,
        sourceHeight: isBankOfChina ? 38 : 48,
      ),
    );
  }
}

class _QuickRecipientCard extends StatelessWidget {
  const _QuickRecipientCard({required this.recipient});

  final ContactsModel recipient;

  String get _formattedCardNumber {
    final compact = recipient.bankCard.replaceAll(RegExp(r'\s+'), '');
    if (compact.isEmpty) return '';
    final groups = <String>[];
    for (var index = 0; index < compact.length; index += 4) {
      final end = (index + 4).clamp(0, compact.length);
      groups.add(compact.substring(index, end));
    }
    return groups.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('quick-recipient-card'),
      height: 108,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '收款人',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              _QuickRecipientBankLogo(recipient: recipient),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipient.bankName} ($_formattedCardNumber)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8C98A8),
                        fontSize: 13,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickRecipientBankLogo extends StatelessWidget {
  const _QuickRecipientBankLogo({required this.recipient});

  final ContactsModel recipient;

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    if (recipient.icon.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipient.icon,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => _fallback(size),
      );
    }
    return _fallback(size);
  }

  Widget _fallback(double size) {
    final bankName = recipient.bankName;
    final String asset;
    if (bankName.contains('建设银行')) {
      asset = 'assets/images/account_transfer/banks/bank_construction.jpg';
    } else if (bankName.contains('中国银行')) {
      asset = _bankOfChinaAsset;
    } else if (bankName.contains('交通银行')) {
      asset = _bankOfCommunicationsAsset;
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.account_balance,
          color: const Color(0xFF0B6DB9),
          size: size * .85,
        ),
      );
    }
    return Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
  }
}

class _ReferenceIcon extends StatelessWidget {
  const _ReferenceIcon({
    required this.asset,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final String asset;
  final double sourceWidth;
  final double sourceHeight;

  @override
  Widget build(BuildContext context) {
    // Input crops come from the 588x1280 account-transfer reference:
    // contact (523,236,20,20), scan (522,303,21,20), chevron (533,371,10,19).
    return Image.asset(
      asset,
      width: _referencePixels(context, sourceWidth),
      height: _referencePixels(context, sourceHeight),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _TransferSuffixIcon extends StatelessWidget {
  const _TransferSuffixIcon({
    required this.asset,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final String asset;
  final double sourceWidth;
  final double sourceHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 43,
      child: Align(
        alignment: Alignment.centerRight,
        child: _ReferenceIcon(
          asset: asset,
          sourceWidth: sourceWidth,
          sourceHeight: sourceHeight,
        ),
      ),
    );
  }
}

class _TransferSuffixButton extends StatelessWidget {
  const _TransferSuffixButton({
    required this.label,
    required this.onPressed,
    required this.asset,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final String label;
  final VoidCallback onPressed;
  final String asset;
  final double sourceWidth;
  final double sourceHeight;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onPressed,
          child: _TransferSuffixIcon(
            asset: asset,
            sourceWidth: sourceWidth,
            sourceHeight: sourceHeight,
          ),
        ),
      ),
    );
  }
}

class _PayerCardEmpty extends StatelessWidget {
  const _PayerCardEmpty({this.label = '付款账户'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '暂无可用付款账户',
              style: TextStyle(color: Color(0xFF999999), fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferInputRow extends StatelessWidget {
  const _TransferInputRow({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.showDivider = true,
    this.semanticsLabel,
    this.fieldKey,
    this.inputFormatters,
    this.textInputAction,
    this.rowHeight = 43,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final bool showDivider;
  final String? semanticsLabel;
  final Key? fieldKey;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: rowHeight,
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          Expanded(
            child: Semantics(
              textField: true,
              label: semanticsLabel ?? label,
              child: TextField(
                key: fieldKey,
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                textInputAction: textInputAction,
                readOnly: readOnly,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: AbsorbPointer(child: content),
        ),
      ),
    );
  }
}

class _PhoneTransferTips extends StatelessWidget {
  const _PhoneTransferTips();

  @override
  Widget build(BuildContext context) {
    const normal =
        TextStyle(color: Color(0xFF888888), fontSize: 13, height: 1.55);
    const link =
        TextStyle(color: Color(0xFF0875E8), fontSize: 13, height: 1.55);
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '温馨提示：',
          style: TextStyle(color: Color(0xFF777777), fontSize: 15),
        ),
        SizedBox(height: 10),
        Text(
          '1.通过手机银行进行手机号转账，单日/单笔限额为5000元。',
          style: normal,
        ),
        SizedBox(height: 5),
        Text(
          '2.如收款人手机号已绑定收款账户（绑定账户需收款人另行开通），转账资金将实时入账至绑定的默认收款账户中，否则资金将在付款人账户中冻结直至收款人收款，次日22:00前未收款将自动解除交易。',
          style: normal,
        ),
        SizedBox(height: 5),
        Text.rich(
          TextSpan(
            style: normal,
            children: [
              TextSpan(
                text: '3.收款人手机号可绑定银行卡收款，未绑定也可以通过短信回复卡号收款。点击设置您的 ',
              ),
              TextSpan(text: '手机号收款卡', style: link),
              TextSpan(text: '。'),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(
          '4.使用交通银行借记卡向未绑定账户的手机号转账时，同时受借记卡本身支出限额（日累计1万元，年累计20万元）限制。',
          style: normal,
        ),
        SizedBox(height: 5),
        Text(
          '5.为保障您的资金安全，切勿轻信以网购刷单、冒充公检法、领导或亲人朋友、代办大额信用卡和高额贷款、网购客服或快递进行退款、鼓吹大额投资理财等非正规渠道要求进行的转账汇款，谨防被骗。涉及不明资金的转账事宜，务必当面或电话确认核实。资金一旦转出将无法追回。',
          style: normal,
        ),
        SizedBox(height: 5),
        Text(
          '6.不扫描可疑二维码，不安装不明APP，妥善保管卡号、密码、短信验证码、令牌动态口令等个人重要信息。',
          style: normal,
        ),
        SizedBox(height: 5),
        Text(
          '7.防范非法集资，警惕高息诱惑。远离以“保本高收益”为诱饵，以虚拟项目、消费返利、养老投资等伪装的非法金融活动。请选择合法正规金融机构办理投资理财业务。',
          style: normal,
        ),
      ],
    );
  }
}

class _TransferTips extends StatelessWidget {
  const _TransferTips();

  @override
  Widget build(BuildContext context) {
    const normal =
        TextStyle(color: Color(0xFF888888), fontSize: 11.5, height: 1.55);
    const warning =
        TextStyle(color: Color(0xFFF39A2D), fontSize: 11.5, height: 1.55);
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('温馨提示：', style: TextStyle(color: Color(0xFF777777), fontSize: 15)),
        SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: normal,
            children: [
              TextSpan(
                  text:
                      '1.为保障您的资金安全，切勿轻信以网购刷单、冒充公检法、领导或亲人朋友、代办大额信用卡和高额贷款、网购客服或快递进行退款、鼓吹大额投资理财等非正规渠道要求进行的转账汇款，谨防被骗。'),
              TextSpan(
                  text: '涉及不明资金的转账事宜，务必当面或电话确认核实。资金一旦转出将无法追回。', style: warning),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text('2.不扫描可疑二维码，不安装不明App，妥善保管卡号、密码、短信验证码、令牌动态口令等个人重要信息。',
            style: normal),
        SizedBox(height: 8),
        Text(
            '3.防范非法集资，警惕高息诱惑。远离以“保本高收益”为诱饵、以虚拟项目、消费返利、养老投资等伪装的非法金融活动。请选择合法正规金融机构办理投资理财业务。',
            style: normal),
      ],
    );
  }
}
