import 'dart:async';

import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/model/member_info_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_pages.dart';
import 'transfer_record_detail_view.dart';
import 'transfer_record_repository.dart';

enum TransferRecordRange {
  recentWeek('近7天'),
  recentMonth('近一个月'),
  recentThreeMonths('近三个月'),
  recentHalfYear('近半年'),
  custom('自定义');

  const TransferRecordRange(this.label);

  final String label;
}

class TransferRecordItem {
  const TransferRecordItem({
    required this.name,
    required this.cardSuffix,
    required this.occurredAt,
    required this.amount,
    this.recipientAccount = '6217 0016 3007 6962 353',
    this.recipientBank = '中国建设银行',
    this.iconUrl = '',
    this.bankAsset =
        'assets/images/account_transfer/banks/bank_construction.jpg',
    this.sourceAccount = '交通银行 借记卡(**2910)',
    this.transferRoute = '超级网银快速汇款',
    this.fee = 0,
    this.channel = '手机银行',
    this.arrivalTime = '预计实时到账',
    this.serialNumber = '2005000420260812436002416952',
    this.postscript = '',
    this.billId = 0,
    this.payerName = '沈田田',
    this.payerAccount = '6222620000002910',
    this.payerBank = '交通银行',
  });

  final String name;
  final String cardSuffix;
  final DateTime occurredAt;
  final double amount;
  final String recipientAccount;
  final String recipientBank;
  final String iconUrl;
  final String bankAsset;
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

  TransferRecordDetailData toDetailData() => TransferRecordDetailData(
        amount: amount,
        recipientName: name,
        recipientAccount: recipientAccount,
        recipientBank: recipientBank,
        transferredAt: occurredAt,
        sourceAccount: sourceAccount,
        transferRoute: transferRoute,
        fee: fee,
        channel: channel,
        arrivalTime: arrivalTime,
        serialNumber: serialNumber,
        postscript: postscript,
        billId: billId,
        payerName: payerName,
        payerAccount: payerAccount,
        payerBank: payerBank,
      );
}

const _blue = Color(0xFF0878E8);
const _muted = Color(0xFF929DAD);
const _pageGray = Color(0xFFF7F7F7);

// 转账记录页
// 说明：当前页面参照用户提供的完整截图由 Flutter 原生绘制，系统状态栏、导航、筛选面板、日期滚轮和记录列表均为活组件。
class TransferRecordPage extends StatefulWidget {
  const TransferRecordPage({
    super.key,
    this.today,
    this.records,
    this.pageLoader,
    this.detailLoader,
  });

  final DateTime? today;
  final List<TransferRecordItem>? records;
  final TransferRecordPageLoader? pageLoader;
  final TransferRecordDetailLoader? detailLoader;

  DateTime get effectiveToday => today ?? DateTime.now();

  List<TransferRecordItem> get effectiveRecords => records ?? const [];

  static final List<TransferRecordItem> previewRecords = [
    TransferRecordItem(
      billId: 10020,
      name: '沈光德',
      cardSuffix: '2353',
      occurredAt: DateTime(2026, 8, 12, 11, 43, 23),
      amount: -1,
    ),
    TransferRecordItem(
      billId: 10019,
      name: '沈光德',
      cardSuffix: '2353',
      occurredAt: DateTime(2026, 8, 12, 11, 37),
      amount: -0.77,
    ),
    TransferRecordItem(
      billId: 10018,
      name: '沈光德',
      cardSuffix: '2353',
      occurredAt: DateTime(2026, 8, 12, 11, 29),
      amount: -1,
    ),
    TransferRecordItem(
      billId: 10017,
      name: '沈光德',
      cardSuffix: '2353',
      occurredAt: DateTime(2026, 8, 12, 11, 29),
      amount: -1,
    ),
    TransferRecordItem(
      billId: 10016,
      name: '沈光德',
      cardSuffix: '2353',
      occurredAt: DateTime(2026, 8, 12, 11, 21),
      amount: -1,
    ),
    TransferRecordItem(
      billId: 10015,
      name: '沈光德',
      cardSuffix: '2353',
      occurredAt: DateTime(2026, 7, 14, 18, 5),
      amount: -1,
    ),
    TransferRecordItem(
      billId: 10014,
      name: '沈光德',
      cardSuffix: '2353',
      occurredAt: DateTime(2026, 7, 14, 18, 4),
      amount: -20,
    ),
  ];

  @override
  State<TransferRecordPage> createState() => _TransferRecordPageState();
}

class _TransferRecordPageState extends State<TransferRecordPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  List<TransferRecordItem> _liveRecords = const [];
  int _pageNum = 1;
  int _pages = 0;
  int _total = 0;
  double _expensesTotal = 0;
  bool _initialLoading = false;
  bool _loadingMore = false;
  bool _loadFailed = false;
  int _requestVersion = 0;

  bool _showAccountPanel = false;
  bool _showRangePanel = false;
  bool _accountApplied = false;
  TransferRecordRange _range = TransferRecordRange.recentMonth;
  TransferRecordRange _appliedRange = TransferRecordRange.recentMonth;
  bool _rangeApplied = false;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _appliedStartDate;
  DateTime? _appliedEndDate;

  bool get _custom => _range == TransferRecordRange.custom;
  bool get _usesInjectedRecords => widget.records != null;

  MemberInfoBankList? get _selectedBank {
    if (!Get.isRegistered<BocLogic>()) return null;
    final banks = Get.find<BocLogic>().memberInfo.bankList;
    if (banks.isEmpty) return null;
    return banks.first;
  }

  String get _selectedBankCard {
    final memberCard = _selectedBank?.bankCard.trim() ?? '';
    if (memberCard.isNotEmpty) return memberCard;
    final records = widget.records ?? _liveRecords;
    return records.isEmpty ? '' : records.first.payerAccount;
  }

  String get _selectedBankName {
    final name = _selectedBank?.bankName.trim() ?? '';
    if (name.isNotEmpty) return name;
    final records = widget.records ?? _liveRecords;
    return records.isEmpty ? '交通银行' : records.first.payerBank;
  }

  String get _selectedCardSuffix {
    final suffix = _lastFourDigits(_selectedBankCard);
    return suffix.isEmpty ? '----' : suffix;
  }

  String get _rangeLabel {
    if (_appliedRange == TransferRecordRange.custom &&
        _rangeApplied &&
        _appliedStartDate != null &&
        _appliedEndDate != null) {
      return '${_slashDate(_appliedStartDate!)}-${_slashDate(_appliedEndDate!)}';
    }
    return _appliedRange.label;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    if (_usesInjectedRecords) {
      final records = widget.records!;
      _total = records.length;
      _expensesTotal = records.fold<double>(
        0,
        (sum, item) => sum + (item.amount < 0 ? item.amount.abs() : 0),
      );
    } else {
      _loadFirstPage();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_handleScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_usesInjectedRecords ||
        _loadingMore ||
        _initialLoading ||
        _pageNum >= _pages ||
        !_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter < 260) {
      _loadPage(reset: false);
    }
  }

  Future<void> _loadFirstPage() => _loadPage(reset: true);

  Future<void> _loadPage({required bool reset}) async {
    if (_usesInjectedRecords) {
      if (mounted) setState(() {});
      return;
    }
    if (!reset && (_loadingMore || _pageNum >= _pages)) return;
    final targetPage = reset ? 1 : _pageNum + 1;
    final version = reset ? ++_requestVersion : _requestVersion;
    setState(() {
      if (reset) {
        _initialLoading = _liveRecords.isEmpty;
        _loadFailed = false;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final response = await (widget.pageLoader?.call(
            _buildQuery(targetPage),
          ) ??
          loadTransferRecordPage(_buildQuery(targetPage)));
      if (!mounted || version != _requestVersion) return;
      final items =
          response.records.map(_itemFromEntry).toList(growable: false);
      setState(() {
        _liveRecords = reset ? items : [..._liveRecords, ...items];
        _pageNum = targetPage;
        _pages = response.pages;
        _total = response.total;
        _expensesTotal = response.expensesTotal;
        _initialLoading = false;
        _loadingMore = false;
        _loadFailed = false;
      });
      if (reset) _jumpToTop();
    } catch (error, stackTrace) {
      debugPrint('加载转账记录失败: $error\n$stackTrace');
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _initialLoading = false;
        _loadingMore = false;
        _loadFailed = reset && _liveRecords.isEmpty;
      });
    }
  }

  Map<String, dynamic> _buildQuery(int pageNum) {
    final (begin, end) = _queryDateRange;
    final params = <String, dynamic>{
      'pageNum': pageNum,
      'pageSize': 10,
      'beginTime': _dashDate(begin),
      'endTime': _dashDate(end),
    };
    final bankCard = _selectedBankCard.trim();
    final keyword = _searchController.text.trim();
    if (bankCard.isNotEmpty) params['bankCard'] = bankCard;
    if (keyword.isNotEmpty) params['keyword'] = keyword;
    return params;
  }

  (DateTime, DateTime) get _queryDateRange {
    final end = DateTime(
      widget.effectiveToday.year,
      widget.effectiveToday.month,
      widget.effectiveToday.day,
    );
    if (_appliedRange == TransferRecordRange.custom &&
        _appliedStartDate != null &&
        _appliedEndDate != null) {
      return (_appliedStartDate!, _appliedEndDate!);
    }
    final days = switch (_appliedRange) {
      TransferRecordRange.recentWeek => 6,
      TransferRecordRange.recentMonth => 30,
      TransferRecordRange.recentThreeMonths => 92,
      TransferRecordRange.recentHalfYear => 183,
      TransferRecordRange.custom => 30,
    };
    return (end.subtract(Duration(days: days)), end);
  }

  TransferRecordItem _itemFromEntry(TransferRecordEntry entry) {
    final memberBank = _memberBankFor(entry.bankCard);
    final payerAccount = entry.bankCard.isNotEmpty
        ? entry.bankCard
        : (memberBank?.bankCard ?? _selectedBankCard);
    final payerBank = memberBank?.bankName.trim().isNotEmpty == true
        ? memberBank!.bankName.trim()
        : _selectedBankName;
    final member =
        Get.isRegistered<BocLogic>() ? Get.find<BocLogic>().memberInfo : null;
    final payerName = memberBank?.realName.trim().isNotEmpty == true
        ? memberBank!.realName.trim()
        : (member?.realName.trim() ?? '');
    final recipientSuffix = _lastFourDigits(entry.oppositeAccount);
    return TransferRecordItem(
      billId: entry.id,
      name: entry.oppositeName,
      cardSuffix: recipientSuffix,
      occurredAt: entry.transactionTime,
      amount: entry.amount,
      recipientAccount: _formatAccount(entry.oppositeAccount),
      recipientBank: entry.oppositeBankName,
      iconUrl: entry.icon,
      bankAsset: _bankAssetFor(entry.oppositeBankName),
      sourceAccount: '$payerBank 借记卡(**${_lastFourDigits(payerAccount)})',
      transferRoute: '超级网银快速汇款',
      fee: 0,
      channel: '手机银行',
      arrivalTime: '预计实时到账',
      serialNumber: '',
      postscript: '',
      payerName: payerName,
      payerAccount: payerAccount,
      payerBank: payerBank,
    );
  }

  MemberInfoBankList? _memberBankFor(String bankCard) {
    if (!Get.isRegistered<BocLogic>()) return null;
    final banks = Get.find<BocLogic>().memberInfo.bankList;
    if (banks.isEmpty) return null;
    final digits = _digitsOnly(bankCard);
    for (final bank in banks) {
      if (_digitsOnly(bank.bankCard) == digits && digits.isNotEmpty) {
        return bank;
      }
    }
    return banks.first;
  }

  void _onSearchChanged(String _) {
    if (_usesInjectedRecords) {
      setState(() {});
      return;
    }
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _loadFirstPage);
  }

  void _toggleAccountPanel() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showRangePanel = false;
      _showAccountPanel = !_showAccountPanel;
    });
  }

  void _selectAccount() {
    setState(() {
      _accountApplied = true;
      _showAccountPanel = false;
    });
    _loadFirstPage();
  }

  void _toggleRangePanel() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showAccountPanel = false;
      _showRangePanel = !_showRangePanel;
    });
  }

  void _selectRange(TransferRecordRange range) {
    if (range == TransferRecordRange.custom) {
      setState(() {
        _range = range;
        _startDate = _appliedRange == TransferRecordRange.custom
            ? _appliedStartDate
            : null;
        _endDate = _appliedRange == TransferRecordRange.custom
            ? _appliedEndDate
            : null;
      });
      return;
    }
    setState(() {
      _range = range;
      _appliedRange = range;
      _rangeApplied = true;
      _startDate = null;
      _endDate = null;
      _appliedStartDate = null;
      _appliedEndDate = null;
      _showRangePanel = false;
    });
    _loadFirstPage();
  }

  Future<void> _pickCustomDate(bool editingStart) async {
    final initial = editingStart
        ? (_startDate ?? widget.effectiveToday)
        : (_endDate ?? _startDate ?? widget.effectiveToday);
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => _TransferDatePickerSheet(
        initialDate: initial,
        maximumDate: widget.effectiveToday,
      ),
    );
    if (result == null || !mounted) return;

    if (editingStart) {
      setState(() => _startDate = result);
      return;
    }

    setState(() => _endDate = result);
    if (_startDate != null && result.isBefore(_startDate!)) {
      await _showInvalidRangeDialog();
      return;
    }
    if (!mounted || _startDate == null) return;
    setState(() {
      _rangeApplied = true;
      _appliedRange = TransferRecordRange.custom;
      _appliedStartDate = _startDate;
      _appliedEndDate = _endDate;
      _showRangePanel = false;
    });
    _loadFirstPage();
  }

  Future<void> _showInvalidRangeDialog() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.67),
      builder: (context) => _InvalidRangeSheet(
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _jumpToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  void _openRecord(TransferRecordItem record) {
    Get.to<void>(
      () => TransferRecordDetailPage(
        data: record.toDetailData(),
        detailLoader: widget.detailLoader,
      ),
    );
  }

  List<TransferRecordItem> get _filteredRecords {
    final source = widget.records ?? _liveRecords;
    if (!_usesInjectedRecords) return source;
    final query = _searchController.text.trim();
    return source.where((record) {
      if (query.isNotEmpty &&
          !record.name.contains(query) &&
          !record.cardSuffix.contains(query)) {
        return false;
      }
      if (_appliedRange == TransferRecordRange.custom &&
          _rangeApplied &&
          _appliedStartDate != null &&
          _appliedEndDate != null) {
        final date = DateTime(
          record.occurredAt.year,
          record.occurredAt.month,
          record.occurredAt.day,
        );
        return !date.isBefore(_appliedStartDate!) &&
            !date.isAfter(_appliedEndDate!);
      }
      if (!_rangeApplied) {
        return record.occurredAt.year == 2026 && record.occurredAt.month == 8;
      }
      final earliest = switch (_appliedRange) {
        TransferRecordRange.recentWeek =>
          widget.effectiveToday.subtract(const Duration(days: 6)),
        TransferRecordRange.recentMonth =>
          widget.effectiveToday.subtract(const Duration(days: 30)),
        TransferRecordRange.recentThreeMonths =>
          widget.effectiveToday.subtract(const Duration(days: 92)),
        TransferRecordRange.recentHalfYear =>
          widget.effectiveToday.subtract(const Duration(days: 183)),
        TransferRecordRange.custom => DateTime(2000),
      };
      return !record.occurredAt.isBefore(earliest);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    final summaryCount = _usesInjectedRecords ? records.length : _total;
    final summaryAmount = _usesInjectedRecords
        ? records.fold<double>(
            0,
            (sum, item) => sum + (item.amount < 0 ? item.amount.abs() : 0),
          )
        : _expensesTotal;
    final customPanel = _showRangePanel && _custom;
    final media = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _pageGray,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final unit = constraints.maxWidth / 402;
          final fixedHeaderHeight = 147.5 * unit;
          final overlayTop = media.padding.top + fixedHeaderHeight;
          final panelHeight = customPanel ? 149 * unit : 104 * unit;
          return Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.white,
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _TransferRecordHeader(
                        unit: unit,
                        searchController: _searchController,
                        accountHighlighted:
                            _showAccountPanel || _accountApplied,
                        rangeHighlighted: _showRangePanel || _rangeApplied,
                        rangeExpanded: _showRangePanel,
                        accountExpanded: _showAccountPanel,
                        accountLabel: '借记卡(**$_selectedCardSuffix)',
                        rangeLabel: _rangeLabel,
                        onAccountTap: _toggleAccountPanel,
                        onRangeTap: _toggleRangePanel,
                        onSearchChanged: _onSearchChanged,
                      ),
                      Expanded(
                        child: _initialLoading
                            ? _TransferLoadingState(unit: unit)
                            : _loadFailed
                                ? _TransferLoadFailedState(
                                    unit: unit,
                                    onRetry: _loadFirstPage,
                                  )
                                : records.isEmpty
                                    ? _TransferEmptyState(unit: unit)
                                    : _TransferRecordList(
                                        unit: unit,
                                        records: records,
                                        controller: _scrollController,
                                        showSummary: true,
                                        summaryCount: summaryCount,
                                        summaryAmount: summaryAmount,
                                        loadingMore: _loadingMore,
                                        onRecordTap: _openRecord,
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showAccountPanel || _showRangePanel)
                Positioned(
                  left: 0,
                  right: 0,
                  top: overlayTop,
                  bottom: 0,
                  child: GestureDetector(
                    key: const ValueKey('transfer_record_filter_scrim'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _showAccountPanel = false;
                      _showRangePanel = false;
                    }),
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.36),
                    ),
                  ),
                ),
              if (_showAccountPanel)
                Positioned(
                  left: 0,
                  right: 0,
                  top: overlayTop,
                  height: 61 * unit,
                  child: _AccountPanel(
                    unit: unit,
                    bankName: _selectedBankName,
                    cardSuffix: _selectedCardSuffix,
                    onSelected: _selectAccount,
                  ),
                ),
              if (_showRangePanel)
                Positioned(
                  left: 0,
                  right: 0,
                  top: overlayTop,
                  height: panelHeight,
                  child: _RangePanel(
                    unit: unit,
                    range: _range,
                    startDate: _startDate,
                    endDate: _endDate,
                    onRangeSelected: _selectRange,
                    onStartTap: () => _pickCustomDate(true),
                    onEndTap: () => _pickCustomDate(false),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TransferRecordHeader extends StatelessWidget {
  const _TransferRecordHeader({
    required this.unit,
    required this.searchController,
    required this.accountHighlighted,
    required this.rangeHighlighted,
    required this.rangeExpanded,
    required this.accountExpanded,
    required this.accountLabel,
    required this.rangeLabel,
    required this.onAccountTap,
    required this.onRangeTap,
    required this.onSearchChanged,
  });

  final double unit;
  final TextEditingController searchController;
  final bool accountHighlighted;
  final bool rangeHighlighted;
  final bool rangeExpanded;
  final bool accountExpanded;
  final String accountLabel;
  final String rangeLabel;
  final VoidCallback onAccountTap;
  final VoidCallback onRangeTap;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final scale = unit;
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        height: 147.5 * scale,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56 * scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, 6.5 * scale),
                    child: Text(
                      '转账记录',
                      style: TextStyle(
                        color: const Color(0xFF111111),
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8 * scale,
                    top: 0,
                    bottom: 0,
                    width: 42 * scale,
                    child: Semantics(
                      button: true,
                      label: '返回',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: Get.back,
                        child: Transform.translate(
                          offset: Offset(0, 9 * scale),
                          child: Center(
                            child: Image.asset(
                              'assets/images/home_credit_card_back.png',
                              width: 32 * scale,
                              height: 32 * scale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 13 * scale,
                    top: 0,
                    bottom: 0,
                    width: 35 * scale,
                    child: Semantics(
                      button: true,
                      label: '在线客服',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.toNamed(Routes.customerService),
                        child: Transform.translate(
                          offset: Offset(0, 9 * scale),
                          child: Center(
                            child: Image.asset(
                              'assets/images/nav_right_kf.png',
                              width: 18 * scale,
                              height: 18 * scale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15 * scale),
              child: SizedBox(
                height: 30 * scale,
                child: TextField(
                  key: const ValueKey('transfer_record_search'),
                  controller: searchController,
                  onChanged: onSearchChanged,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14 * scale,
                    height: 1.1,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(
                      left: 7 * scale,
                      right: 11 * scale,
                      top: 4 * scale,
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 24 * scale,
                      minHeight: 30 * scale,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8 * scale),
                      child: Icon(
                        CupertinoIcons.search,
                        color: _muted,
                        size: 17 * scale,
                      ),
                    ),
                    hintText: '输入收款人姓名/卡号/手机号搜索',
                    hintStyle: TextStyle(
                      color: _muted,
                      fontSize: 14 * scale,
                      height: 1.1,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17 * scale),
                      borderSide: BorderSide(
                        color: const Color(0xFFD0D4DA),
                        width: 1 * scale,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17 * scale),
                      borderSide: BorderSide(
                        color: const Color(0xFFD0D4DA),
                        width: 1 * scale,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2 * scale),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    left: 39 * scale,
                    top: 0,
                    bottom: 0,
                    width: 174 * scale,
                    child: _HeaderFilterButton(
                      semanticLabel: '选择付款账户',
                      text: accountLabel,
                      highlighted: accountHighlighted,
                      expanded: accountExpanded,
                      onTap: onAccountTap,
                      unit: scale,
                      alignment: MainAxisAlignment.start,
                    ),
                  ),
                  Positioned(
                    right: (rangeLabel.length > 10 ? 26 : 75) * scale,
                    top: 0,
                    bottom: 0,
                    width: (rangeLabel.length > 10 ? 192 : 125) * scale,
                    child: _HeaderFilterButton(
                      key: const ValueKey('transfer_record_range_button'),
                      semanticLabel: '选择查询时间',
                      text: rangeLabel,
                      highlighted: rangeHighlighted,
                      expanded: rangeExpanded,
                      onTap: onRangeTap,
                      unit: scale,
                      alignment: MainAxisAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderFilterButton extends StatelessWidget {
  const _HeaderFilterButton({
    required this.semanticLabel,
    required this.text,
    required this.highlighted,
    required this.expanded,
    required this.onTap,
    required this.unit,
    required this.alignment,
    super.key,
  });

  final String semanticLabel;
  final String text;
  final bool highlighted;
  final bool expanded;
  final VoidCallback onTap;
  final double unit;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(0, 1 * unit),
          child: Row(
            mainAxisAlignment: alignment,
            children: [
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: highlighted ? _blue : const Color(0xFF2D2D2D),
                    fontSize: 13.5 * unit,
                    height: 1.1,
                  ),
                ),
              ),
              SizedBox(width: 8 * unit),
              Icon(
                expanded
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                color: highlighted ? _blue : const Color(0xFF2D2D2D),
                size: 13.5 * unit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({
    required this.unit,
    required this.bankName,
    required this.cardSuffix,
    required this.onSelected,
  });

  final double unit;
  final String bankName;
  final String cardSuffix;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Semantics(
        button: true,
        label: '$bankName借记卡$cardSuffix，已选中',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSelected,
          child: Row(
            children: [
              SizedBox(width: 12 * unit),
              Transform.translate(
                offset: Offset(0, -7.5 * unit),
                child: Image.asset(
                  'assets/images/transaction_detail/bank_logo.png',
                  width: 35 * unit,
                  height: 35 * unit,
                ),
              ),
              SizedBox(width: 2 * unit),
              Transform.translate(
                offset: Offset(0, -7.5 * unit),
                child: Text(
                  '$bankName 借记卡(**$cardSuffix)',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 15 * unit,
                    letterSpacing: 0.45 * unit,
                  ),
                ),
              ),
              const Spacer(),
              Transform.translate(
                offset: Offset(0, -7.5 * unit),
                child: Icon(
                  CupertinoIcons.check_mark,
                  key: const ValueKey('transfer_record_account_check'),
                  color: _blue,
                  size: 15 * unit,
                ),
              ),
              SizedBox(width: 21 * unit),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangePanel extends StatelessWidget {
  const _RangePanel({
    required this.unit,
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.onRangeSelected,
    required this.onStartTap,
    required this.onEndTap,
  });

  final double unit;
  final TransferRecordRange range;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<TransferRecordRange> onRangeSelected;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  @override
  Widget build(BuildContext context) {
    final custom = range == TransferRecordRange.custom;
    const options = TransferRecordRange.values;
    return Material(
      color: Colors.white,
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(16 * unit, 12 * unit, 16 * unit, 10 * unit),
        child: Column(
          children: [
            Row(
              children: [
                for (var index = 0; index < 3; index++) ...[
                  if (index > 0) SizedBox(width: 13 * unit),
                  Expanded(
                    child: _RangeOption(
                      range: options[index],
                      selected: range == options[index],
                      unit: unit,
                      onTap: () => onRangeSelected(options[index]),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12 * unit),
            Row(
              children: [
                Expanded(
                  child: _RangeOption(
                    range: TransferRecordRange.recentHalfYear,
                    selected: range == TransferRecordRange.recentHalfYear,
                    unit: unit,
                    onTap: () =>
                        onRangeSelected(TransferRecordRange.recentHalfYear),
                  ),
                ),
                SizedBox(width: 13 * unit),
                Expanded(
                  child: _RangeOption(
                    range: TransferRecordRange.custom,
                    selected: custom,
                    unit: unit,
                    onTap: () => onRangeSelected(TransferRecordRange.custom),
                  ),
                ),
                SizedBox(width: 13 * unit),
                const Expanded(child: SizedBox()),
              ],
            ),
            if (custom) ...[
              SizedBox(height: 12 * unit),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: startDate != null
                      ? const Color(0xFFE5F1FF)
                      : const Color(0xFFFBFBFB),
                  borderRadius: BorderRadius.circular(6 * unit),
                ),
                child: SizedBox(
                  height: 34 * unit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DateEndpoint(
                        key: const ValueKey('transfer_record_start_date'),
                        value: startDate,
                        placeholder: '开始时间',
                        unit: unit,
                        onTap: onStartTap,
                      ),
                      Text(
                        '至',
                        style: TextStyle(
                          color: const Color(0xFF87919E),
                          fontSize: 14 * unit,
                        ),
                      ),
                      _DateEndpoint(
                        key: const ValueKey('transfer_record_end_date'),
                        value: endDate,
                        placeholder: '结束时间',
                        unit: unit,
                        onTap: onEndTap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RangeOption extends StatelessWidget {
  const _RangeOption({
    required this.range,
    required this.selected,
    required this.unit,
    required this.onTap,
  });

  final TransferRecordRange range;
  final bool selected;
  final double unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: range.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE4F0FD) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(6 * unit),
          ),
          child: SizedBox(
            height: 34 * unit,
            child: Center(
              child: Text(
                range.label,
                style: TextStyle(
                  color: selected ? _blue : const Color(0xFF333333),
                  fontSize: 14 * unit,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateEndpoint extends StatelessWidget {
  const _DateEndpoint({
    required this.value,
    required this.placeholder,
    required this.unit,
    required this.onTap,
    super.key,
  });

  final DateTime? value;
  final String placeholder;
  final double unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: value == null ? '选择$placeholder' : _dashDate(value!),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 162 * unit,
          child: Center(
            child: Text(
              value == null ? placeholder : _dashDate(value!),
              style: TextStyle(
                color: value == null ? const Color(0xFFD6DAE0) : _blue,
                fontSize: 14 * unit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransferRecordList extends StatelessWidget {
  const _TransferRecordList({
    required this.unit,
    required this.records,
    required this.controller,
    required this.showSummary,
    required this.summaryCount,
    required this.summaryAmount,
    required this.loadingMore,
    required this.onRecordTap,
  });

  final double unit;
  final List<TransferRecordItem> records;
  final ScrollController controller;
  final bool showSummary;
  final int summaryCount;
  final double summaryAmount;
  final bool loadingMore;
  final ValueChanged<TransferRecordItem> onRecordTap;

  @override
  Widget build(BuildContext context) {
    final sections = <String, List<TransferRecordItem>>{};
    for (final record in records) {
      final key =
          '${record.occurredAt.year}-${record.occurredAt.month.toString().padLeft(2, '0')}';
      sections.putIfAbsent(key, () => []).add(record);
    }
    return ColoredBox(
      color: _pageGray,
      child: ListView(
        key: const ValueKey('transfer_record_list'),
        controller: controller,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          if (showSummary)
            Container(
              height: 47.6 * unit,
              color: _pageGray,
              padding: EdgeInsets.symmetric(horizontal: 15 * unit),
              child: Row(
                children: [
                  Text(
                    '成功  $summaryCount 笔',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 15.5 * unit,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '共  ${summaryAmount.toStringAsFixed(2)} 元',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 15.5 * unit,
                    ),
                  ),
                ],
              ),
            ),
          for (final entry in sections.entries) ...[
            if (entry.key != sections.keys.first)
              Container(
                key: ValueKey('transfer_record_month_divider_${entry.key}'),
                height: 15 * unit,
                color: _pageGray,
              ),
            Container(
              height: 39.3 * unit,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 15 * unit),
              child: Transform.translate(
                offset: Offset(0, -2 * unit),
                child: Transform.scale(
                  scaleX: 1.13,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 16.5 * unit,
                    ),
                  ),
                ),
              ),
            ),
            ColoredBox(
              color: Colors.white,
              child: Column(
                children: [
                  for (var index = 0; index < entry.value.length; index++)
                    _TransferRecordRow(
                      unit: unit,
                      record: entry.value[index],
                      showDivider: index != entry.value.length - 1,
                      onTap: () => onRecordTap(entry.value[index]),
                    ),
                ],
              ),
            ),
          ],
          if (loadingMore)
            SizedBox(
              height: 42 * unit,
              child: Center(
                child: SizedBox(
                  width: 18 * unit,
                  height: 18 * unit,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          _WarmTips(unit: unit),
        ],
      ),
    );
  }
}

class _TransferRecordRow extends StatelessWidget {
  const _TransferRecordRow({
    required this.unit,
    required this.record,
    required this.showDivider,
    required this.onTap,
  });

  final double unit;
  final TransferRecordItem record;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${record.name}，尾号${record.cardSuffix}，${record.amount.toStringAsFixed(2)}元',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 66.85 * unit,
          child: Row(
            children: [
              SizedBox(width: 15 * unit),
              _TransferBankIcon(
                key: ValueKey('transfer_record_bank_icon_${record.billId}'),
                iconUrl: record.iconUrl,
                fallbackAsset: record.bankAsset,
                size: 23 * unit,
              ),
              SizedBox(width: 9 * unit),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: showDivider
                        ? Border(
                            bottom: BorderSide(
                              color: const Color(0xFFE8E8E8),
                              width: 0.5 * unit,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Transform.translate(
                          offset: Offset(0, -1.5 * unit),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${record.name}(**${record.cardSuffix})',
                                style: TextStyle(
                                  color: const Color(0xFF292929),
                                  fontSize: 16 * unit,
                                  height: 1.05,
                                ),
                              ),
                              SizedBox(height: 7 * unit),
                              Text(
                                '${record.occurredAt.month.toString().padLeft(2, '0')}-${record.occurredAt.day.toString().padLeft(2, '0')} ${record.occurredAt.hour.toString().padLeft(2, '0')}:${record.occurredAt.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 14 * unit,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -11.5 * unit),
                        child: Text(
                          record.amount.toStringAsFixed(2),
                          style: TextStyle(
                            color: const Color(0xFF292929),
                            fontSize: 17 * unit,
                          ),
                        ),
                      ),
                      SizedBox(width: 15 * unit),
                    ],
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

class _TransferBankIcon extends StatelessWidget {
  const _TransferBankIcon({
    required this.iconUrl,
    required this.fallbackAsset,
    required this.size,
    super.key,
  });

  final String iconUrl;
  final String fallbackAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Image.asset(
          fallbackAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
    if (iconUrl.isEmpty) return fallback();
    return Image.network(
      iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
}

class _WarmTips extends StatelessWidget {
  const _WarmTips({required this.unit});

  final double unit;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      color: const Color(0xFF999999),
      fontSize: 12 * unit,
      height: 1.42,
    );
    return Container(
      color: _pageGray,
      padding: EdgeInsets.fromLTRB(
        15 * unit,
        29.5 * unit,
        15 * unit,
        44 * unit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '温馨提示',
            style: TextStyle(
              color: const Color(0xFF8D8D8D),
              fontSize: 14 * unit,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6 * unit),
          Text(
            '1.您可查询手机银行及个人网银的自助转账记录(不含柜台、ATM、智易通转账记录)。',
            style: bodyStyle,
          ),
          SizedBox(height: 4 * unit),
          Text('2.支持查询所有历史转账记录，每次查询时间跨度最长5年。', style: bodyStyle),
          SizedBox(height: 4 * unit),
          Text('3.转账记录仅供参考，请以收款方账户实际入账为准。', style: bodyStyle),
        ],
      ),
    );
  }
}

class _TransferEmptyState extends StatelessWidget {
  const _TransferEmptyState({required this.unit});

  final double unit;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _pageGray,
      child: ListView(
        key: const ValueKey('transfer_record_empty'),
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          SizedBox(height: 107 * unit),
          Center(
            child: Image.asset(
              'assets/images/transaction_detail/empty_records.png',
              width: 111 * unit,
              height: 87 * unit,
            ),
          ),
          SizedBox(height: 17 * unit),
          Center(
            child: Text(
              '没有转账记录，换个条件试试',
              style: TextStyle(
                color: const Color(0xFF333333),
                fontSize: 16 * unit,
              ),
            ),
          ),
          SizedBox(height: 32 * unit),
          _WarmTips(unit: unit),
        ],
      ),
    );
  }
}

class _TransferLoadingState extends StatelessWidget {
  const _TransferLoadingState({required this.unit});

  final double unit;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('transfer_record_loading'),
      color: _pageGray,
      child: Center(
        child: SizedBox(
          width: 24 * unit,
          height: 24 * unit,
          child: const CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _TransferLoadFailedState extends StatelessWidget {
  const _TransferLoadFailedState({
    required this.unit,
    required this.onRetry,
  });

  final double unit;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('transfer_record_load_failed'),
      color: _pageGray,
      child: Center(
        child: Semantics(
          button: true,
          label: '重新加载转账记录',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRetry,
            child: Padding(
              padding: EdgeInsets.all(24 * unit),
              child: Text(
                '加载失败，点击重试',
                style: TextStyle(
                  color: _muted,
                  fontSize: 14 * unit,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransferDatePickerSheet extends StatefulWidget {
  const _TransferDatePickerSheet({
    required this.initialDate,
    required this.maximumDate,
  });

  final DateTime initialDate;
  final DateTime maximumDate;

  @override
  State<_TransferDatePickerSheet> createState() =>
      _TransferDatePickerSheetState();
}

class _TransferDatePickerSheetState extends State<_TransferDatePickerSheet> {
  late int _year;
  late int _month;
  late int _day;
  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;

  List<int> get _years => [
        for (var year = widget.maximumDate.year - 5;
            year <= widget.maximumDate.year;
            year++)
          year,
      ];

  List<int> get _months => [
        for (var month = 1;
            month <=
                (_year == widget.maximumDate.year
                    ? widget.maximumDate.month
                    : 12);
            month++)
          month,
      ];

  List<int> get _days => [
        for (var day = 1;
            day <=
                (_year == widget.maximumDate.year &&
                        _month == widget.maximumDate.month
                    ? widget.maximumDate.day
                    : DateTime(_year, _month + 1, 0).day);
            day++)
          day,
      ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
    _month = widget.initialDate.month;
    _day = widget.initialDate.day;
    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_year),
    );
    _monthController = FixedExtentScrollController(initialItem: _month - 1);
    _dayController = FixedExtentScrollController(initialItem: _day - 1);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _update({int? year, int? month, int? day}) {
    final nextYear = year ?? _year;
    final maximumMonth =
        nextYear == widget.maximumDate.year ? widget.maximumDate.month : 12;
    final nextMonth = (month ?? _month).clamp(1, maximumMonth).toInt();
    final maximumDay = nextYear == widget.maximumDate.year &&
            nextMonth == widget.maximumDate.month
        ? widget.maximumDate.day
        : DateTime(nextYear, nextMonth + 1, 0).day;
    setState(() {
      _year = nextYear;
      _month = nextMonth;
      _day = (day ?? _day).clamp(1, maximumDay).toInt();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monthController.hasClients &&
          _monthController.selectedItem != _month - 1) {
        _monthController.jumpToItem(_month - 1);
      }
      if (_dayController.hasClients &&
          _dayController.selectedItem != _day - 1) {
        _dayController.jumpToItem(_day - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = MediaQuery.sizeOf(context).width / 402;
    return SizedBox(
      height: 271 * unit + MediaQuery.paddingOf(context).bottom,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.vertical(top: Radius.circular(11 * unit)),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: 53 * unit,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 17 * unit,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(
                        DateTime(_year, _month, _day),
                      ),
                      child: Text(
                        '确定',
                        style: TextStyle(color: _blue, fontSize: 17 * unit),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 0.5 * unit, thickness: 0.5 * unit),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _DateWheel(
                        controller: _yearController,
                        values: _years,
                        selected: _year,
                        suffix: '年',
                        unit: unit,
                        onChanged: (value) => _update(year: value),
                      ),
                    ),
                    Expanded(
                      child: _DateWheel(
                        controller: _monthController,
                        values: _months,
                        selected: _month,
                        suffix: '月',
                        unit: unit,
                        pad: true,
                        onChanged: (value) => _update(month: value),
                      ),
                    ),
                    Expanded(
                      child: _DateWheel(
                        controller: _dayController,
                        values: _days,
                        selected: _day,
                        suffix: '日',
                        unit: unit,
                        pad: true,
                        onChanged: (value) => _update(day: value),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateWheel extends StatelessWidget {
  const _DateWheel({
    required this.controller,
    required this.values,
    required this.selected,
    required this.suffix,
    required this.unit,
    required this.onChanged,
    this.pad = false,
  });

  final FixedExtentScrollController controller;
  final List<int> values;
  final int selected;
  final String suffix;
  final double unit;
  final ValueChanged<int> onChanged;
  final bool pad;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 45 * unit,
          physics: const FixedExtentScrollPhysics(),
          diameterRatio: 100,
          perspective: 0.0001,
          overAndUnderCenterOpacity: 1,
          onSelectedItemChanged: (index) => onChanged(values[index]),
          childDelegate: ListWheelChildListDelegate(
            children: [
              for (final value in values)
                Center(
                  child: Text(
                    '${pad ? value.toString().padLeft(2, '0') : value}$suffix',
                    style: TextStyle(
                      color: value == selected ? _blue : _muted,
                      fontSize: 18 * unit,
                      fontWeight:
                          value == selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ),
        IgnorePointer(
          child: SizedBox(
            height: 45 * unit,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: const Color(0xFFE6E6E6),
                    width: 0.5 * unit,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InvalidRangeSheet extends StatelessWidget {
  const _InvalidRangeSheet({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final unit = MediaQuery.sizeOf(context).width / 402;
    return SizedBox(
      height: 183 * unit,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(11 * unit)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15 * unit),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  '您的起始时间晚于终止时间，请重新选择时间',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 16 * unit,
                  ),
                ),
                SizedBox(height: 45 * unit),
                SizedBox(
                  width: double.infinity,
                  height: 48 * unit,
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0874E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11 * unit),
                      ),
                    ),
                    child: Text(
                      '我知道了',
                      style: TextStyle(fontSize: 18 * unit),
                    ),
                  ),
                ),
                SizedBox(height: 9 * unit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _dashDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _slashDate(DateTime date) =>
    '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String _lastFourDigits(String value) {
  final digits = _digitsOnly(value);
  if (digits.length <= 4) return digits;
  return digits.substring(digits.length - 4);
}

String _formatAccount(String value) {
  final digits = _digitsOnly(value);
  if (digits.length <= 11 ||
      digits.length != value.replaceAll(' ', '').length) {
    return value;
  }
  final groups = <String>[];
  for (var index = 0; index < digits.length; index += 4) {
    final end = index + 4 < digits.length ? index + 4 : digits.length;
    groups.add(digits.substring(index, end));
  }
  return groups.join(' ');
}

String _bankAssetFor(String bankName) {
  const root = 'assets/images/account_transfer/banks';
  if (bankName.contains('工商')) return '$root/bank_icbc.jpg';
  if (bankName.contains('农业')) return '$root/bank_agricultural.jpg';
  if (bankName.contains('建设')) return '$root/bank_construction.jpg';
  if (bankName.contains('交通')) return '$root/bank_communications.jpg';
  if (bankName.contains('招商')) return '$root/bank_merchants.jpg';
  if (bankName.contains('中信')) return '$root/bank_citic.jpg';
  if (bankName.contains('邮政') || bankName.contains('邮储')) {
    return '$root/bank_postal.jpg';
  }
  if (bankName.contains('浦发')) return '$root/bank_spdb.jpg';
  if (bankName.contains('华夏')) return '$root/bank_huaxia.jpg';
  if (bankName.contains('民生')) return '$root/bank_minsheng.jpg';
  if (bankName.contains('平安')) return '$root/bank_pingan.jpg';
  if (bankName.contains('兴业')) return '$root/bank_industrial.jpg';
  if (bankName.contains('光大')) return '$root/bank_everbright.jpg';
  if (bankName == '中国银行' || bankName.contains('中国银行')) {
    return '$root/bank_china.jpg';
  }
  return '$root/bank_construction.jpg';
}
