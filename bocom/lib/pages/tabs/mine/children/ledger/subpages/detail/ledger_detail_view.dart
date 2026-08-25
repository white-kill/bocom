import 'package:bocom/config/model/bill_item_model.dart';
import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerDetailPage extends StatefulWidget {
  const LedgerDetailPage({
    super.key,
    required this.item,
    this.onUpdated,
  });

  final BillItemList item;
  final VoidCallback? onUpdated;

  @override
  State<LedgerDetailPage> createState() => _LedgerDetailPageState();
}

class _LedgerDetailPageState extends State<LedgerDetailPage> {
  BillItemListBillDetail? get _detail => widget.item.billDetail;
  late List<int> _bookTypes;
  late bool _includeInTotal;
  late String _remark;
  late String _transactionCategory;

  @override
  void initState() {
    super.initState();
    _bookTypes = List<int>.from(_detail?.bookTypes ?? const <int>[]);
    _includeInTotal = _detail?.includeInTotal ?? true;
    _remark = _detail?.remark ?? '';
    _transactionCategory = _detail?.transactionCategory ?? '';
  }

  bool get _isIncome =>
      widget.item.type == '1' ||
      widget.item.type == '收入' ||
      widget.item.type.toLowerCase() == 'income' ||
      widget.item.amount.startsWith('+') ||
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
            initialText: _remark,
            onChanged: (value) => _remark = value,
            onFocusLost: (value) {
              _remark = value;
              _updateDetail();
            },
          ),
        ),
      ],
    );
  }

  Widget _transactionCard() {
    final rawAmount = widget.item.amount.replaceFirst(RegExp(r'^[+-]'), '').trim();
    final amount = double.tryParse(rawAmount.replaceAll(',', ''))
        ?.toStringAsFixed(2) ??
        '0.00';
    // final amount = widget.item.amount.replaceFirst(RegExp(r'^[+-]'), '').trim();
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
            text: _value(_detail?.excerpt, fallback: widget.item.excerpt),
            fontSize: 17,
            color: const Color(0xFF738094),
            maxLines: 2,
          ),
          SizedBox(height: 35.w),
          _detailRow(
            '交易时间',
            _value(
              _detail?.transactionTime,
              fallback: widget.item.transactionTime,
            ),
          ),
          _detailRow('交易账户', _accountText()),
          _detailRow('对方户名',
              _value(_detail?.oppositeName, fallback: widget.item.oppositeName)),
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
    final category = _value(_transactionCategory,
        fallback: _detail?.transactionType ?? '');
    final ledgerType = _displayLedgerType(_bookTypes);
    final ledger = _bookTypes.isEmpty
        ? '总账本'
        : '${_ledgerName(ledgerType)}等(${_bookTypes.length + 1})';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _selectTransactionCategory,
            child: _settingRow('${_isIncome ? '收入' : '支出'}类别', category),
          ),
          const Divider(height: 1, color: Color(0xFFE4E6E9)),
          SizedBox(
            height: 62.w,
            child: Row(
              children: [
                BaseText(text: '计入总账${_isIncome ? '收入' : '支出'}', fontSize: 17),
                const Spacer(),
                BaseText(
                  text: _includeInTotal ? '计入' : '不计入',
                  fontSize: 15,
                  color: const Color(0xFF9AA1AB),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleIncludeInTotal,
                  child: _ledgerSwitch(_includeInTotal),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4E6E9)),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _selectBookTypes,
            child: _settingRow(
              '所属账本',
              ledger,
              leadingAsset: _ledgerIcon(ledgerType),
            ),
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

  Future<void> _toggleIncludeInTotal() async {
    setState(() => _includeInTotal = !_includeInTotal);
    await _updateDetail(refreshList: true);
  }

  Future<void> _selectTransactionCategory() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LedgerCategorySheet(
        isIncome: _isIncome,
        initialCategory: _transactionCategory,
      ),
    );
    if (selected == null || selected == _transactionCategory || !mounted) {
      return;
    }
    setState(() => _transactionCategory = selected);
    await _updateDetail(refreshList: true);
  }

  Future<void> _selectBookTypes() async {
    final selected = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LedgerBookSheet(initialTypes: _bookTypes.toSet()),
    );
    if (selected == null || !mounted) return;
    setState(() => _bookTypes = selected.toList()..sort());
    await _updateDetail(refreshList: true);
  }

  Future<void> _updateDetail({bool refreshList = false}) async {
    final detail = _detail;
    if (detail == null || detail.id <= 0) return;
    await Http.post(
      Apis.bookDetailUpdate,
      data: {
        'billId': detail.id,
        'transactionCategory': _transactionCategory,
        'bookTypes': _bookTypes,
        'includeInTotal': _includeInTotal,
        'bookkeepingTag': '',
        'remark': _remark,
      },
      isLoading: false,
    );
    detail
      ..transactionCategory = _transactionCategory
      ..bookTypes = List<int>.from(_bookTypes)
      ..includeInTotal = _includeInTotal
      ..bookkeepingTag = ''
      ..remark = _remark;
    if (refreshList) widget.onUpdated?.call();
  }

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
    required this.onChanged,
    required this.onFocusLost,
  });

  final double height;
  final double counterHeight;
  final String initialText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onFocusLost;

  @override
  State<_DetailRemarkField> createState() => _DetailRemarkFieldState();
}

class _DetailRemarkFieldState extends State<_DetailRemarkField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hadFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_refreshCounter);
    _focusNode.addListener(_handleFocusChanged);
  }

  void _refreshCounter() {
    widget.onChanged(_controller.text);
    if (mounted) setState(() {});
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _hadFocus = true;
    } else if (_hadFocus) {
      _hadFocus = false;
      widget.onFocusLost(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refreshCounter)
      ..dispose();
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
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

class _LedgerCategorySheet extends StatefulWidget {
  const _LedgerCategorySheet({
    required this.isIncome,
    required this.initialCategory,
  });

  final bool isIncome;
  final String initialCategory;

  @override
  State<_LedgerCategorySheet> createState() => _LedgerCategorySheetState();
}

class _LedgerCategorySheetState extends State<_LedgerCategorySheet> {
  late String _selectedCategory;

  static const _expenseSections = <_CategorySection>[
    _CategorySection(
      title: '日常支出',
      assetDirectory: 'expense/daily',
      items: [
        _CategoryItem('餐饮美食', assetName: 'dining'),
        _CategoryItem('服饰美容', assetName: 'clothing_beauty'),
        _CategoryItem('交通出行', assetName: 'transportation'),
        _CategoryItem('居家生活', assetName: 'home_living'),
        _CategoryItem('话费网费', assetName: 'phone_internet'),
        _CategoryItem('转账', assetName: 'transfer'),
        _CategoryItem('购物', assetName: 'shopping'),
        _CategoryItem('旅游酒店', assetName: 'travel_hotel'),
        _CategoryItem('休闲娱乐', assetName: 'entertainment'),
        _CategoryItem('运动健身', assetName: 'fitness'),
        _CategoryItem('学习培训', assetName: 'education'),
        _CategoryItem('医疗保健', assetName: 'healthcare'),
        _CategoryItem('人情往来', assetName: 'social_gifts'),
        _CategoryItem('还款', assetName: 'repayment'),
        _CategoryItem('现金取出', assetName: 'cash_withdrawal'),
        _CategoryItem('税金服务费', assetName: 'tax_service_fee'),
        _CategoryItem('慈善公益', assetName: 'charity'),
        _CategoryItem('其他支出', assetName: 'other_expense'),
      ],
    ),
    _CategorySection(
      title: '金融理财',
      assetDirectory: 'expense/finance',
      items: [
        _CategoryItem('理财', assetName: 'wealth_management'),
        _CategoryItem('基金', assetName: 'fund'),
        _CategoryItem('存款', assetName: 'deposit'),
        _CategoryItem('债券', assetName: 'bond'),
        _CategoryItem('保险', assetName: 'insurance'),
        _CategoryItem('外汇', assetName: 'foreign_exchange'),
        _CategoryItem('股票期货', assetName: 'stocks_futures'),
        _CategoryItem('其他投资', assetName: 'other_investment'),
      ],
    ),
  ];

  static const _incomeSections = <_CategorySection>[
    _CategorySection(
      title: '日常收入',
      assetDirectory: 'income/daily',
      items: [
        _CategoryItem('薪酬福利', assetName: 'salary_benefits'),
        _CategoryItem('转账', assetName: 'transfer'),
        _CategoryItem('经营所得', assetName: 'business_income'),
        _CategoryItem('贷款发放', assetName: 'loan_disbursement'),
        _CategoryItem('现金存入', assetName: 'cash_deposit'),
        _CategoryItem('退款', assetName: 'refund'),
        _CategoryItem('报销', assetName: 'reimbursement'),
        _CategoryItem(
          '社保公积金',
          assetName: 'social_security_housing_fund',
        ),
        _CategoryItem('刷卡金', assetName: 'card_reward'),
        _CategoryItem('人情往来', assetName: 'social_gifts'),
        _CategoryItem('其他收入', assetName: 'other_income'),
      ],
    ),
    _CategorySection(
      title: '金融理财',
      assetDirectory: 'income/finance',
      items: [
        _CategoryItem('理财', assetName: 'wealth_management'),
        _CategoryItem('基金', assetName: 'fund'),
        _CategoryItem('存款', assetName: 'deposit'),
        _CategoryItem('债券', assetName: 'bond'),
        _CategoryItem('保险', assetName: 'insurance'),
        _CategoryItem('外汇', assetName: 'foreign_exchange'),
        _CategoryItem('股票期货', assetName: 'stocks_futures'),
        _CategoryItem('其他投资', assetName: 'other_investment'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = switch (widget.initialCategory) {
      '其它支出' => '其他支出',
      '其它收入' => '其他收入',
      '其它投资' => '其他投资',
      '债卷' => '债券',
      _ => widget.initialCategory,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.isIncome ? _incomeSections : _expenseSections;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.72,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
      ),
      child: Column(
        children: [
          _header(),
          const Divider(height: 1, color: Color(0xFFE7E9EC)),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 15.w, bottom: 24.w),
              itemCount: sections.length,
              itemBuilder: (_, index) => _section(sections[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => SizedBox(
        height: 58.w,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            BaseText(
              text: '选择${widget.isIncome ? '收入' : '支出'}类别',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            Positioned(
              left: 8.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 27),
              ),
            ),
            Positioned(
              right: 15.w,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _selectedCategory.isEmpty
                    ? null
                    : () => Navigator.pop(context, _selectedCategory),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: BaseText(
                    text: '确定',
                    fontSize: 18,
                    color: _selectedCategory.isEmpty
                        ? const Color(0xFFB8BDC6)
                        : const Color(0xFF087DFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _section(_CategorySection section) => Padding(
        padding: EdgeInsets.only(bottom: 22.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: BaseText(
                text: section.title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 14.w),
            GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 82.w,
              ),
              itemBuilder: (_, index) =>
                  _categoryItem(section, section.items[index]),
            ),
          ],
        ),
      );

  Widget _categoryItem(_CategorySection section, _CategoryItem item) {
    final selected = item.name == _selectedCategory;
    final asset =
        'assets/images/category/${section.assetDirectory}/${item.assetName}.png';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedCategory = item.name),
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF4D94F7) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              color: selected ? Colors.white : null,
            ),
          ),
          SizedBox(height: 5.w),
          BaseText(
            text: item.name,
            fontSize: 15,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategorySection {
  const _CategorySection({
    required this.title,
    required this.assetDirectory,
    required this.items,
  });

  final String title;
  final String assetDirectory;
  final List<_CategoryItem> items;
}

class _CategoryItem {
  const _CategoryItem(this.name, {required this.assetName});

  final String name;
  final String assetName;
}

class _LedgerBookSheet extends StatefulWidget {
  const _LedgerBookSheet({required this.initialTypes});

  final Set<int> initialTypes;

  @override
  State<_LedgerBookSheet> createState() => _LedgerBookSheetState();
}

class _LedgerBookSheetState extends State<_LedgerBookSheet> {
  late final Set<int> _selectedTypes;

  static const _books = <({int? type, String name, int assetIndex})>[
    (type: null, name: '总账本', assetIndex: 1),
    (type: 1, name: '投资账本', assetIndex: 2),
    (type: 2, name: '消费账本', assetIndex: 3),
    (type: 4, name: '薪资账本', assetIndex: 4),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set<int>.from(widget.initialTypes);
  }

  @override
  Widget build(BuildContext context) => Container(
        height: 510.w,
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 58.w,
              width: 1.sw,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const BaseText(
                    text: '所属账本',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  Positioned(
                    left: 8.w,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 27),
                    ),
                  ),
                  Positioned(
                    right: 15.w,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(context, _selectedTypes),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: BaseText(
                          text: '确定',
                          fontSize: 18,
                          color: Color(0xFF087DFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 12.w, 15.w, 16.w),
              child: const BaseText(
                text: '总账本将自动汇总全部流水，无需手动处理。同一笔流水可同时归属多个账本，您可按需勾选。',
                fontSize: 15,
                color: Color(0xFF929292),
                maxLines: 3,
              ),
            ),
            ..._books.map(_bookRow),
          ],
        ),
      );

  Widget _bookRow(({int? type, String name, int assetIndex}) book) {
    final isTotal = book.type == null;
    final selected = isTotal || _selectedTypes.contains(book.type);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isTotal
          ? null
          : () => setState(() {
                if (selected) {
                  _selectedTypes.remove(book.type);
                } else {
                  _selectedTypes.add(book.type!);
                }
              }),
      child: Container(
        height: 65.w,
        margin: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE7E9EC))),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/ledger_type_${book.assetIndex}_small.png',
              width: 23.w,
              height: 23.w,
            ),
            SizedBox(width: 12.w),
            BaseText(text: book.name, fontSize: 16),
            const Spacer(),
            _checkBox(selected, disabled: isTotal),
          ],
        ),
      ),
    );
  }

  Widget _checkBox(bool selected, {required bool disabled}) => Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: selected
              ? (disabled
                  ? const Color(0xFF65A9F6)
                  : const Color(0xFF087DFF))
              : Colors.white,
          borderRadius: BorderRadius.circular(6.w),
          border: selected
              ? null
              : Border.all(color: const Color(0xFFD1D6DD), width: 1.5),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      );
}
