import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'transaction_advanced_filter_model.dart';

class TransactionAdvancedFilterPanel extends StatefulWidget {
  const TransactionAdvancedFilterPanel({
    super.key,
    required this.initialValue,
    required this.onComplete,
    this.actionsRequireChange = false,
  });

  final TransactionAdvancedFilterValue initialValue;
  final ValueChanged<TransactionAdvancedFilterValue> onComplete;
  final bool actionsRequireChange;

  @override
  State<TransactionAdvancedFilterPanel> createState() =>
      _TransactionAdvancedFilterPanelState();
}

class _TransactionAdvancedFilterPanelState
    extends State<TransactionAdvancedFilterPanel> {
  static const _directions = ['全部收入', '全部支出'];
  static const _commonTypes = [
    '转账',
    '代发工资',
    '现金',
    '投资理财',
    '生活缴费',
    '消费支付',
    'ETC',
    '其他',
  ];
  static const _amountRanges = [
    '1百以下',
    '1百-1千',
    '1千-5千',
    '5千-1万',
    '1万-5万',
    '5万以上',
    '自定义',
  ];
  static const _channels = [
    '手机银行',
    '网银',
    '柜面',
    'POS',
    '自助设备',
    '电话银行',
    '其他',
  ];
  static const _banks = [
    '交通银行',
    '建设银行',
    '中国银行',
    '工商银行',
    '农业银行',
    '招商银行',
    '浦发银行',
    '民生银行',
    '中信银行',
    '广发银行',
    '兴业银行',
    '邮储银行',
    '光大银行',
    '平安银行',
    '华夏银行',
    '自定义',
  ];

  final _scrollController = ScrollController();
  final _minAmountKey = GlobalKey();
  final _maxAmountKey = GlobalKey();
  final _customBankKey = GlobalKey();
  final _accountNameKey = GlobalKey();
  final _accountNumberKey = GlobalKey();
  final _summaryKey = GlobalKey();

  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;
  late final TextEditingController _customBankController;
  late final TextEditingController _accountNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _summaryController;
  late final FocusNode _minAmountFocus;
  late final FocusNode _maxAmountFocus;
  late final FocusNode _customBankFocus;
  late final FocusNode _accountNameFocus;
  late final FocusNode _accountNumberFocus;
  late final FocusNode _summaryFocus;

  String? _direction;
  String? _commonType;
  String? _amountRange;
  String? _channel;
  String? _bank;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _direction = initial.direction;
    _commonType = initial.commonType;
    _amountRange = initial.amountRange;
    _channel = initial.channel;
    _bank = initial.bank;
    _minAmountController = TextEditingController(text: initial.minAmount);
    _maxAmountController = TextEditingController(text: initial.maxAmount);
    _customBankController = TextEditingController(
      text: initial.customBankName,
    );
    _accountNameController = TextEditingController(text: initial.accountName);
    _accountNumberController = TextEditingController(
      text: initial.accountNumber,
    );
    _summaryController = TextEditingController(text: initial.summary);
    _minAmountFocus = _focusNodeFor(_minAmountKey, alignment: 0.68);
    _maxAmountFocus = _focusNodeFor(_maxAmountKey, alignment: 0.68);
    _customBankFocus = _focusNodeFor(_customBankKey, alignment: 0.48);
    _accountNameFocus = _focusNodeFor(_accountNameKey);
    _accountNumberFocus = _focusNodeFor(_accountNumberKey);
    _summaryFocus = _focusNodeFor(_summaryKey);
    _minAmountController.addListener(_markChanged);
    _maxAmountController.addListener(_markChanged);
    _customBankController.addListener(_markChanged);
    _accountNameController.addListener(_markChanged);
    _accountNumberController.addListener(_markChanged);
    _summaryController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!widget.actionsRequireChange || _hasChanges || !mounted) return;
    setState(() => _hasChanges = true);
  }

  FocusNode _focusNodeFor(GlobalKey key, {double alignment = 0.72}) {
    final node = FocusNode();
    node.addListener(() {
      if (!node.hasFocus) return;
      Future<void>.delayed(const Duration(milliseconds: 260), () {
        final fieldContext = key.currentContext;
        if (!mounted || fieldContext == null || !fieldContext.mounted) return;
        Scrollable.ensureVisible(
          fieldContext,
          alignment: alignment,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
    });
    return node;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _customBankController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _summaryController.dispose();
    _minAmountFocus.dispose();
    _maxAmountFocus.dispose();
    _customBankFocus.dispose();
    _accountNameFocus.dispose();
    _accountNumberFocus.dispose();
    _summaryFocus.dispose();
    super.dispose();
  }

  TransactionAdvancedFilterValue get _value => TransactionAdvancedFilterValue(
        direction: _direction,
        commonType: _commonType,
        amountRange: _amountRange,
        minAmount:
            _amountRange == '自定义' ? _minAmountController.text.trim() : '',
        maxAmount:
            _amountRange == '自定义' ? _maxAmountController.text.trim() : '',
        channel: _channel,
        bank: _bank,
        customBankName: _bank == '自定义' ? _customBankController.text.trim() : '',
        accountName: _accountNameController.text,
        accountNumber: _accountNumberController.text,
        summary: _summaryController.text,
      );

  void _reset() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _hasChanges = true;
      _direction = null;
      _commonType = null;
      _amountRange = null;
      _channel = null;
      _bank = null;
      _minAmountController.clear();
      _maxAmountController.clear();
      _customBankController.clear();
      _accountNameController.clear();
      _accountNumberController.clear();
      _summaryController.clear();
    });
  }

  Widget _section({
    required String title,
    required List<String> values,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      key: ValueKey('advanced_filter_section_$title'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF2B2B2B),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 11.w),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 26.w) / 3;
            return Wrap(
              spacing: 13.w,
              runSpacing: 13.w,
              children: [
                for (final value in values)
                  _FilterChoice(
                    key: ValueKey('advanced_filter_choice_$value'),
                    width: itemWidth,
                    label: value,
                    selected: selected == value,
                    onTap: () => onSelected(value),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _customAmountFields() {
    return Padding(
      padding: EdgeInsets.only(top: 18.w),
      child: Row(
        key: const ValueKey('advanced_filter_custom_amount_fields'),
        children: [
          Expanded(
            flex: 49,
            child: _amountField(
              fieldKey: _minAmountKey,
              inputKey: const ValueKey('advanced_filter_min_amount'),
              prefix: '¥ ',
              hint: '最小金额',
              controller: _minAmountController,
              focusNode: _minAmountFocus,
              inputAction: TextInputAction.next,
              onSubmitted: (_) => _maxAmountFocus.requestFocus(),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '至',
            key: const ValueKey('advanced_filter_amount_separator'),
            style: TextStyle(
              color: const Color(0xFF30343B),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 51,
            child: _amountField(
              fieldKey: _maxAmountKey,
              inputKey: const ValueKey('advanced_filter_max_amount'),
              prefix: '¥ ',
              hint: '最大金额',
              controller: _maxAmountController,
              focusNode: _maxAmountFocus,
              inputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountField({
    required GlobalKey fieldKey,
    required Key inputKey,
    required String prefix,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputAction inputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    final textStyle = TextStyle(
      color: const Color(0xFF30343B),
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
    );
    return SizedBox(
      key: fieldKey,
      height: 48.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFE0E3E7),
              width: 0.5.w,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(prefix, style: textStyle),
            Expanded(
              child: TextField(
                key: inputKey,
                controller: controller,
                focusNode: focusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: inputAction,
                inputFormatters: const [_TransactionAmountInputFormatter()],
                onSubmitted: onSubmitted,
                cursorColor: const Color(0xFF0879E8),
                style: textStyle,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: textStyle.copyWith(
                    color: const Color(0xFFD1D4D8),
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customBankField() {
    return Padding(
      padding: EdgeInsets.only(top: 18.w),
      child: SizedBox(
        key: _customBankKey,
        height: 34.w,
        child: TextField(
          key: const ValueKey('advanced_filter_custom_bank'),
          controller: _customBankController,
          focusNode: _customBankFocus,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          cursorColor: const Color(0xFF0879E8),
          style: TextStyle(
            color: const Color(0xFF303030),
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            hintText: '请输入对方开户行',
            hintStyle: TextStyle(
              color: const Color(0xFFD1D4D8),
              fontSize: 14.sp,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.w),
              borderSide: BorderSide(
                color: const Color(0xFFDADDE1),
                width: 0.5.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.w),
              borderSide: BorderSide(
                color: const Color(0xFF0077DF),
                width: 0.8.w,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required GlobalKey fieldKey,
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputAction inputAction = TextInputAction.next,
  }) {
    return Column(
      key: fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF303030),
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 17.w),
        SizedBox(
          height: 34.w,
          child: TextField(
            key: ValueKey('advanced_filter_input_$label'),
            controller: controller,
            focusNode: focusNode,
            textInputAction: inputAction,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: const Color(0xFF303030),
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFFD1D4D8),
                fontSize: 14.sp,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.w),
                borderSide: BorderSide(
                  color: const Color(0xFFDADDE1),
                  width: 0.5.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.w),
                borderSide: BorderSide(
                  color: const Color(0xFF0077DF),
                  width: 0.8.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('transaction_advanced_filter_panel'),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('transaction_advanced_filter_scroll'),
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(15.w, 10.w, 15.w, 24.w),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    title: '交易类型',
                    values: _directions,
                    selected: _direction,
                    onSelected: (value) => setState(() {
                      _hasChanges = true;
                      _direction = _direction == value ? null : value;
                    }),
                  ),
                  SizedBox(height: 23.w),
                  _section(
                    title: '常用',
                    values: _commonTypes,
                    selected: _commonType,
                    onSelected: (value) => setState(() {
                      _hasChanges = true;
                      _commonType = _commonType == value ? null : value;
                    }),
                  ),
                  SizedBox(height: 23.w),
                  _section(
                    title: '金额',
                    values: _amountRanges,
                    selected: _amountRange,
                    onSelected: (value) => setState(() {
                      _hasChanges = true;
                      _amountRange = _amountRange == value ? null : value;
                    }),
                  ),
                  if (_amountRange == '自定义') _customAmountFields(),
                  SizedBox(height: 23.w),
                  _section(
                    title: '渠道/地点',
                    values: _channels,
                    selected: _channel,
                    onSelected: (value) => setState(() {
                      _hasChanges = true;
                      _channel = _channel == value ? null : value;
                    }),
                  ),
                  SizedBox(height: 23.w),
                  _section(
                    title: '对方开户行',
                    values: _banks,
                    selected: _bank,
                    onSelected: (value) => setState(() {
                      _hasChanges = true;
                      _bank = _bank == value ? null : value;
                    }),
                  ),
                  if (_bank == '自定义') _customBankField(),
                  SizedBox(height: 25.w),
                  _textField(
                    fieldKey: _accountNameKey,
                    label: '对方开户名',
                    hint: '请输入对方开户名',
                    controller: _accountNameController,
                    focusNode: _accountNameFocus,
                  ),
                  SizedBox(height: 25.w),
                  _textField(
                    fieldKey: _accountNumberKey,
                    label: '对方账户',
                    hint: '请输入对方账户',
                    controller: _accountNumberController,
                    focusNode: _accountNumberFocus,
                  ),
                  SizedBox(height: 25.w),
                  _textField(
                    fieldKey: _summaryKey,
                    label: '摘要',
                    hint: '请输入摘要',
                    controller: _summaryController,
                    focusNode: _summaryFocus,
                    inputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
          ),
          _AdvancedFilterActions(
            enabled: !widget.actionsRequireChange || _hasChanges,
            onReset: _reset,
            onComplete: () {
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onComplete(_value);
            },
          ),
        ],
      ),
    );
  }
}

class _TransactionAmountInputFormatter extends TextInputFormatter {
  const _TransactionAmountInputFormatter();

  static final RegExp _validAmount = RegExp(r'^\d{0,12}(?:\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _validAmount.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    super.key,
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: width,
          height: 33.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE9F3FD) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(7.w),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF0077DF) : const Color(0xFF303030),
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancedFilterActions extends StatelessWidget {
  const _AdvancedFilterActions({
    required this.enabled,
    required this.onReset,
    required this.onComplete,
  });

  final bool enabled;
  final VoidCallback onReset;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('transaction_advanced_filter_actions'),
      height: 44.w,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE8E8E8), width: 0.5.w),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? onReset : null,
              child: Center(
                child: Text(
                  '重置',
                  style: TextStyle(
                    color: enabled
                        ? const Color(0xFF0077DF)
                        : const Color(0xFFC8CDD5),
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? onComplete : null,
              child: ColoredBox(
                color: enabled
                    ? const Color(0xFF0879E8)
                    : const Color(0xFFD0D5DD),
                child: Center(
                  child: Text(
                    '完成',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
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
