import 'package:bocom/config/model/bill_item_model.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerDetailPage extends StatelessWidget {
  const LedgerDetailPage({super.key, required this.item});

  final BillItemList item;
  BillItemListBillDetail? get _detail => item.billDetail;
  bool get _isIncome =>
      item.type == '1' ||
      item.type == '收入' ||
      item.type.toLowerCase() == 'income' ||
      item.amount.startsWith('+') ||
      _detail?.type == '1';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 22, color: Color(0xFF222222)),
          ),
          title: const BaseText(
            text: '流水详情',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(15.w, 12.w, 15.w, 30.w),
          children: [
            _transactionCard(),
            SizedBox(height: 12.w),
            _settingCard(),
            SizedBox(height: 12.w),
            _noteCard(),
          ],
        ),
      );

  Widget _noteCard() {
    final width = 1.sw - 30.w;
    final position = StackPosition(
      designWidth: 1089,
      designHeight: 698,
      deviceWidth: width,
    );
    return Stack(
      children: [
        Image.asset(
          'assets/images/ledger_detail_note.png',
          width: width,
          fit: BoxFit.fitWidth,
        ),
        Positioned(
          left: position.getX(130),
          right: position.getX(70),
          top: position.getY(180),
          child: _DetailRemarkField(
            height: position.getHeight(300),
            counterHeight: position.getHeight(45),
            initialText: _detail?.postscriptno ?? '',
          ),
        ),
      ],
    );
  }

  Widget _transactionCard() {
    final amount = item.amount.replaceFirst(RegExp(r'^[+-]'), '').trim();
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 24.w, 15.w, 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        children: [
          BaseText(text: '${_isIncome ? '收入' : '支出'}金额', fontSize: 17),
          SizedBox(height: 10.w),
          BaseText(
            text: '${_isIncome ? '+' : '-'}${amount.isEmpty ? '0.00' : amount}',
            fontSize: 34,
            fontWeight: FontWeight.w500,
            color:
                _isIncome ? const Color(0xFFFF565B) : const Color(0xFF222222),
          ),
          SizedBox(height: 9.w),
          BaseText(
            text: _value(_detail?.excerpt, fallback: item.excerpt),
            fontSize: 17,
            color: const Color(0xFF738094),
            maxLines: 2,
          ),
          SizedBox(height: 35.w),
          _detailRow('交易时间',
              _value(_detail?.transactionTime, fallback: item.transactionTime)),
          _detailRow('交易账户', _accountText()),
          _detailRow('对方户名',
              _value(_detail?.oppositeName, fallback: item.oppositeName)),
          _detailRow('对方账户', _maskedOppositeAccount()),
          _detailRow(
              '对方开户行',
              _value(_detail?.oppositeBankName,
                  fallback: _detail?.merchantBranch ?? '')),
          _detailRow('交易渠道', _value(_detail?.transactionChannel,
              fallback: _detail?.merchantBranch ?? '')),
        ],
      ),
    );
  }

  Widget _settingCard() {
    final category = _value(_detail?.transactionCategory,
        fallback: _detail?.transactionType ?? '');
    final counted = _detail?.billType != '不计入';
    final bookTypes = _detail?.bookTypes ?? const <int>[];
    final ledgerType = _displayLedgerType(bookTypes);
    final ledger = bookTypes.isEmpty
        ? '总账本'
        : '${_ledgerName(ledgerType)}等(${bookTypes.length + 1})';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        children: [
          _settingRow('${_isIncome ? '收入' : '支出'}类别', category),
          const Divider(height: 1, color: Color(0xFFE4E6E9)),
          SizedBox(
            height: 62.w,
            child: Row(
              children: [
                BaseText(text: '计入总账${_isIncome ? '收入' : '支出'}', fontSize: 17),
                const Spacer(),
                const BaseText(
                    text: '计入', fontSize: 15, color: Color(0xFF9AA1AB)),
                SizedBox(width: 10.w),
                _ledgerSwitch(counted),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4E6E9)),
          _settingRow(
            '所属账本',
            ledger,
            leadingAsset: _ledgerIcon(ledgerType),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 105.w,
              child: BaseText(
                  text: label, fontSize: 16, color: const Color(0xFF909BAB)),
            ),
            Expanded(
              child: BaseText(
                text: value,
                textAlign: TextAlign.right,
                fontSize: 16,
                maxLines: 3,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      );

  Widget _settingRow(
    String label,
    String value, {
    String? leadingAsset,
  }) =>
      SizedBox(
        height: 62.w,
        child: Row(
          children: [
            BaseText(text: label, fontSize: 16),
            SizedBox(width: 12.w),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingAsset != null) ...[
                      Image.asset(
                        leadingAsset,
                        width: 16.w,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(width: 7.w),
                    ],
                    Flexible(
                      child: BaseText(
                        text: value,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 7.w),
            Image(
              image: 'ic_mine_amount_right'.png,
              width: 8.w,
              fit: BoxFit.fitWidth,
              color: const Color(0xFF333333),
            ),
          ],
        ),
      );

  int _displayLedgerType(List<int> bookTypes) {
    if (bookTypes.isEmpty) return 0;
    return bookTypes.reduce((current, next) => next > current ? next : current);
  }

  String _ledgerName(int type) {
    switch (type) {
      case 1:
        return '投资账本';
      case 2:
        return '消费账本';
      case 3:
      case 4:
        return '薪资账本';
      default:
        return '总账本';
    }
  }

  String _ledgerIcon(int type) {
    final assetIndex = type <= 0 ? 1 : (type >= 3 ? 4 : type + 1);
    return 'assets/images/ledger_type_${assetIndex}_small.png';
  }

  Widget _ledgerSwitch(bool value) => Container(
        width: 46.w,
        height: 28.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF087DFF) : const Color(0xFFD5D8DE),
          borderRadius: BorderRadius.circular(14.w),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      );

  String _accountText() {
    final bank = _value(_detail?.bankName);
    final card = _detail?.bankCard ?? '';
    if (card.isEmpty) return bank;
    final compact = card.replaceAll(RegExp(r'\s+'), '');
    final suffix =
        compact.length > 4 ? compact.substring(compact.length - 4) : compact;
    return '$bank 借记卡(**$suffix)'.trim();
  }

  String _maskedOppositeAccount() {
    final account = _detail?.oppositeAccount.trim() ?? '';
    if (account.isEmpty) return '--';
    if (account.length < 10) return account;
    return '${account.substring(0, 6)}****${account.substring(account.length - 4)}';
  }

  String _value(String? value, {String fallback = ''}) {
    final result = value?.trim() ?? '';
    if (result.isNotEmpty) return result;
    final backup = fallback.trim();
    return backup.isEmpty ? '--' : backup;
  }
}

class _DetailRemarkField extends StatefulWidget {
  const _DetailRemarkField({
    required this.height,
    required this.counterHeight,
    required this.initialText,
  });

  final double height;
  final double counterHeight;
  final String initialText;

  @override
  State<_DetailRemarkField> createState() => _DetailRemarkFieldState();
}

class _DetailRemarkFieldState extends State<_DetailRemarkField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_refreshCounter);
  }

  void _refreshCounter() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refreshCounter)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            Positioned.fill(
              bottom: widget.counterHeight,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                maxLength: 24,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: const Color(0xFF333333),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.w),
                  hintText: '备注更多信息（24个字）',
                  hintStyle: TextStyle(
                    fontSize: 17.sp,
                    color: const Color(0xFFB8BDC6),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: BaseText(
                text: '${_controller.text.characters.length}/24',
                fontSize: 14,
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
      );
}
