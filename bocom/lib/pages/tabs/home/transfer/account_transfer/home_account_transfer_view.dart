import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/contacts_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/double_extension.dart';

import 'account_transfer_support_pages.dart';

const _accountTransferReferenceWidth = 588.0;
const _contactIconAsset =
    'assets/images/account_transfer/icons/recipient_contact.png';
const _cardScanIconAsset = 'assets/images/account_transfer/icons/card_scan.png';
const _rowChevronAsset = 'assets/images/account_transfer/icons/row_chevron.png';
const _bankOfCommunicationsAsset =
    'assets/images/account_transfer/icons/bank_of_communications.png';
const _bankOfChinaAsset =
    'assets/images/account_transfer/icons/bank_of_china.png';

double _referencePixels(BuildContext context, double pixels) {
  return MediaQuery.sizeOf(context).width /
      _accountTransferReferenceWidth *
      pixels;
}

// 账号转账页
// 说明：当前页面是活页面，表单、账户信息和交互状态均由 Flutter 原生绘制。
class HomeAccountTransferPage extends StatefulWidget {
  const HomeAccountTransferPage({
    super.key,
    this.initialRecipient,
    this.contactsLoader,
    this.bankLoader,
  });

  final ContactsModel? initialRecipient;
  final Future<List<ContactsModel>> Function()? contactsLoader;
  final Future<List<RecipientBank>> Function()? bankLoader;

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
  String _arrivalTime = '预计实时到账';

  List<TextEditingController> get _requiredControllers => [
        _nameController,
        _accountController,
        _bankController,
        _amountController,
      ];

  bool get _canContinue => _requiredControllers.every(
        (controller) => controller.text.trim().isNotEmpty,
      );

  @override
  void initState() {
    super.initState();
    _fillRecipient(widget.initialRecipient);
    for (final controller in _requiredControllers) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
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

  void _continue() {
    if (!_canContinue) return;
    final recipient = ContactsModel()
      ..name = _nameController.text.trim()
      ..bankCard = _accountController.text.trim()
      ..bankName = _bankController.text.trim();
    Get.to(
      () => AccountTransferConfirmationPage(
        recipient: recipient,
        amount: _amountController.text.trim(),
        description: _descriptionController.text.trim(),
        arrivalTime: _arrivalTime,
      ),
    );
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
          title: const Text(
            '账号转账',
            style: TextStyle(
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
                onPressed: () {},
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
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: '预计'),
                        TextSpan(
                          text: _arrivalTime.replaceFirst('预计', ''),
                          style: const TextStyle(color: Color(0xFFFF4F54)),
                        ),
                        const TextSpan(text: ' ⓘ'),
                      ],
                    ),
                  ),
                ),
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
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _canContinue ? _continue : null,
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
            ),
            const SizedBox(height: 28),
            const _TransferTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayerCard() {
    if (!Get.isRegistered<BocLogic>()) {
      return const _PayerCardEmpty();
    }
    return GetBuilder<BocLogic>(
      id: 'updateCard',
      builder: (logic) {
        if (logic.memberInfo.bankList.isEmpty) {
          return const _PayerCardEmpty();
        }
        final bank = logic.memberInfo.bankList.first;
        final digits = bank.bankCard.replaceAll(RegExp(r'\D'), '');
        final suffix =
            digits.length > 4 ? digits.substring(digits.length - 4) : digits;
        final cardType = bank.cardType.isEmpty ? 'II类账户' : bank.cardType;
        return _PayerCard(
          bankName: bank.bankName,
          title: '${bank.bankName} $cardType(**$suffix)',
          balance: '可用余额 ${bank.accountBalance.bankBalance}元',
        );
      },
    );
  }

  Widget _buildRecipientCard() {
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

  Widget _buildAmountCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '转账金额',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => showTransferLimitSheet(context),
                  child: const Text(
                    '限额说明',
                    style: TextStyle(color: Color(0xFF0875E8), fontSize: 14),
                  ),
                ),
              ],
            ),
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  const Text(
                    '¥',
                    style: TextStyle(fontSize: 30, color: Color(0xFF333333)),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 26,
                        color: Color(0xFF222222),
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 26,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const Text(
                    '0手续费',
                    style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 15),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: TextField(
                controller: _descriptionController,
                maxLength: 30,
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '添加转账说明',
                  hintStyle: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayerCard extends StatelessWidget {
  const _PayerCard({
    required this.bankName,
    required this.title,
    required this.balance,
  });

  final String bankName;
  final String title;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '付款账户',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
  const _PayerCardEmpty();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '付款账户',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 18),
            Text(
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
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.showDivider = true,
    this.semanticsLabel,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
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
                controller: controller,
                keyboardType: keyboardType,
                readOnly: readOnly,
                onTap: onTap,
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
