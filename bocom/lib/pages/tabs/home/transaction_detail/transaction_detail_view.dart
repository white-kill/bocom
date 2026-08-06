import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'filter/transaction_advanced_filter_model.dart';
import 'filter/transaction_advanced_filter_panel.dart';
import 'filter/transaction_filter_model.dart';
import 'filter/transaction_filter_sheet.dart';
import 'filter/transaction_future_date_dialog.dart';
import 'filter/transaction_quick_filter_panel.dart';
import 'transaction_detail_mock_data.dart';
import 'transaction_detail_model.dart';

// 交易明细页
// 说明：当前页面参照完整截图使用 Flutter 原生绘制，系统状态栏、固定导航、跨月滚动和动态金额均未保留在截图中。
class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({
    super.key,
    this.onMonthTap,
    this.onFilterTap,
    this.onExportTap,
  });

  final ValueChanged<String>? onMonthTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onExportTap;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  static final DateTime _today = DateTime(2026, 8, 5);

  late final ScrollController _scrollController;
  late final ListObserverController _observerController;

  int _visibleMonthIndex = 0;
  bool _showScrollToTop = false;
  bool _showQuickFilter = false;
  bool _showAdvancedFilter = false;
  TransactionFilterResult? _filterResult;
  TransactionFilterSelection? _lastDateSelection;
  TransactionAdvancedFilterValue _advancedFilter =
      const TransactionAdvancedFilterValue();

  TransactionMonthSection get _visibleSection =>
      transactionDetailMockSections[_visibleMonthIndex];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _observerController = ListObserverController(
      controller: _scrollController,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _observerController.dispatchOnceObserve();
      }
    });
  }

  void _handleScroll() {
    final show =
        _scrollController.hasClients && _scrollController.offset > 420.w;
    if (show != _showScrollToTop && mounted) {
      setState(() => _showScrollToTop = show);
    }
  }

  void _handleObserve(ListViewObserveModel result) {
    final index = result.firstChild?.index;
    if (index == null ||
        index < 0 ||
        index >= transactionDetailMockSections.length ||
        index == _visibleMonthIndex ||
        !mounted) {
      return;
    }
    setState(() => _visibleMonthIndex = index);
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleQuickFilter() {
    widget.onMonthTap?.call(_visibleSection.monthKey);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showAdvancedFilter = false;
      _showQuickFilter = !_showQuickFilter;
    });
  }

  void _toggleAdvancedFilter() {
    widget.onFilterTap?.call();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showQuickFilter = false;
      _showAdvancedFilter = !_showAdvancedFilter;
    });
  }

  Future<void> _handleQuickRange(TransactionQuickRange range) async {
    setState(() => _showQuickFilter = false);
    if (range == TransactionQuickRange.custom) {
      await _openDateFilter();
      return;
    }
    setState(() => _filterResult = _quickResult(range));
  }

  Future<void> _openDateFilter() async {
    final selection = await TransactionDateFilterSheet.show(
      context,
      initialMode: TransactionDateFilterMode.custom,
      initialSelection:
          _lastDateSelection?.mode == TransactionDateFilterMode.custom
              ? _lastDateSelection
              : null,
      today: _today,
    );
    if (selection == null || !mounted) return;

    _lastDateSelection = selection;
    final result = _resultForSelection(selection);
    setState(() => _filterResult = result);

    if (selection.mode == TransactionDateFilterMode.custom &&
        TransactionDateRules.containsFutureDate(
          selection.startDate!,
          selection.endDate!,
          _today,
        )) {
      await TransactionFutureDateDialog.show(context);
    }
  }

  List<TransactionRecord> get _allRecords => transactionDetailMockSections
      .expand((section) => section.records)
      .toList(growable: false);

  TransactionFilterResult _quickResult(TransactionQuickRange range) {
    final august = transactionDetailMockSections.first;
    return switch (range) {
      TransactionQuickRange.currentMonth => TransactionFilterResult(
          toolbarLabel: '本月',
          count: 10,
          income: 0,
          expense: 342.15,
          records: august.records,
          quickRange: range,
        ),
      TransactionQuickRange.recentWeek => TransactionFilterResult(
          toolbarLabel: '近一周',
          count: 10,
          income: 0,
          expense: 342.15,
          records: august.records,
          quickRange: range,
        ),
      TransactionQuickRange.recentMonth => TransactionFilterResult(
          toolbarLabel: '近一个月',
          count: 19,
          income: 2419.21,
          expense: 3220.32,
          records: _allRecords.take(18).toList(growable: false),
          quickRange: range,
        ),
      TransactionQuickRange.recentThreeMonths => TransactionFilterResult(
          toolbarLabel: '近三个月',
          count: 23,
          income: 7419.21,
          expense: 3402.82,
          records: _allRecords,
          quickRange: range,
        ),
      TransactionQuickRange.recentYear => TransactionFilterResult(
          toolbarLabel: '近一年',
          count: 70,
          income: 12664.21,
          expense: 10469.29,
          records: _allRecords,
          quickRange: range,
        ),
      TransactionQuickRange.custom => throw StateError('自定义范围由日期面板处理'),
    };
  }

  TransactionFilterResult _resultForSelection(
    TransactionFilterSelection selection,
  ) {
    switch (selection.mode) {
      case TransactionDateFilterMode.month:
        final selected = selection.month!;
        final matching = transactionDetailMockSections.where(
          (section) =>
              section.year == selected.year && section.month == selected.month,
        );
        final records = matching.isEmpty
            ? const <TransactionRecord>[]
            : matching.first.records;
        return _resultFromRecords(selection.toolbarLabel, records, selection);
      case TransactionDateFilterMode.year:
        final records = transactionDetailMockSections
            .where((section) => section.year == selection.year)
            .expand((section) => section.records)
            .toList(growable: false);
        return _resultFromRecords(selection.toolbarLabel, records, selection);
      case TransactionDateFilterMode.custom:
        final start = selection.startDate!;
        final end = selection.endDate!;
        final future =
            TransactionDateRules.containsFutureDate(start, end, _today);
        if (future) {
          return TransactionFilterResult(
            toolbarLabel: selection.toolbarLabel,
            count: 0,
            income: 0,
            expense: 0,
            records: const [],
            selection: selection,
            showSummary: false,
          );
        }
        final records = _allRecords.where((record) {
          final date = DateTime(
            record.occurredAt.year,
            record.occurredAt.month,
            record.occurredAt.day,
          );
          return !date.isBefore(start) && !date.isAfter(end);
        }).toList(growable: false);
        if (start.isBefore(DateTime(2025, 8, 6)) && !end.isBefore(_today)) {
          return TransactionFilterResult(
            toolbarLabel: selection.toolbarLabel,
            count: 70,
            income: 12664.21,
            expense: 10469.29,
            records: _allRecords,
            selection: selection,
          );
        }
        return _resultFromRecords(selection.toolbarLabel, records, selection);
    }
  }

  TransactionFilterResult _resultFromRecords(
    String toolbarLabel,
    List<TransactionRecord> records,
    TransactionFilterSelection selection,
  ) {
    final income = records
        .where((record) => record.isIncome)
        .fold<double>(0, (sum, record) => sum + record.amount);
    final expense = records
        .where((record) => !record.isIncome)
        .fold<double>(0, (sum, record) => sum + record.amount.abs());
    return TransactionFilterResult(
      toolbarLabel: toolbarLabel,
      count: records.length,
      income: income,
      expense: expense,
      records: records,
      selection: selection,
    );
  }

  void _completeAdvancedFilter(TransactionAdvancedFilterValue value) {
    final records = _recordsForAdvancedFilter(value);
    final income = records
        .where((record) => record.isIncome)
        .fold<double>(0, (sum, record) => sum + record.amount);
    final expense = records
        .where((record) => !record.isIncome)
        .fold<double>(0, (sum, record) => sum + record.amount.abs());

    setState(() {
      _advancedFilter = value;
      _showAdvancedFilter = false;
      if (value.isEmpty) {
        _filterResult = null;
      } else {
        _filterResult = TransactionFilterResult(
          toolbarLabel:
              _visibleMonthIndex == 0 ? '本月' : _visibleSection.monthKey,
          count: records.length,
          income: income,
          expense: expense,
          records: records,
          showSummary: records.isNotEmpty,
        );
      }
    });
  }

  List<TransactionRecord> _recordsForAdvancedFilter(
    TransactionAdvancedFilterValue value,
  ) {
    return _allRecords.where((record) {
      if (value.direction == '全部收入' && !record.isIncome) return false;
      if (value.direction == '全部支出' && record.isIncome) return false;

      final amount = record.amount.abs();
      final matchesAmount = switch (value.amountRange) {
        '1百以下' => amount < 100,
        '1百-1千' => amount >= 100 && amount < 1000,
        '1千-5千' => amount >= 1000 && amount < 5000,
        '5千-1万' => amount >= 5000 && amount < 10000,
        '1万-5万' => amount >= 10000 && amount < 50000,
        '5万以上' => amount >= 50000,
        _ => true,
      };
      if (!matchesAmount) return false;

      final accountName = value.accountName.trim();
      if (accountName.isNotEmpty && !record.title.contains(accountName)) {
        return false;
      }
      final summary = value.summary.trim();
      if (summary.isNotEmpty &&
          !record.title.contains(summary) &&
          !record.channel.contains(summary)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthText = _filterResult?.toolbarLabel ??
        (_visibleMonthIndex == 0 ? '本月' : _visibleSection.monthKey);
    final mediaQuery = MediaQuery.of(context);
    final filterOverlayTop = mediaQuery.padding.top + 134.w;
    final advancedAvailableHeight = mediaQuery.size.height -
        filterOverlayTop -
        mediaQuery.viewInsets.bottom -
        mediaQuery.padding.bottom;
    final advancedFilterHeight = advancedAvailableHeight < 527.w
        ? advancedAvailableHeight.clamp(80.w, 527.w).toDouble()
        : 527.w;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ScreenUtil dimensions must be rebuilt after device metrics settle.
                  // ignore: prefer_const_constructors
                  _TransactionNavigationBar(),
                  // ignore: prefer_const_constructors
                  _AccountHeader(),
                  _FilterBar(
                    monthText: monthText,
                    expanded: _showQuickFilter,
                    highlighted: _filterResult?.selection != null ||
                        _filterResult?.quickRange != null,
                    filterActive:
                        _showAdvancedFilter || !_advancedFilter.isEmpty,
                    onMonthTap: _toggleQuickFilter,
                    onFilterTap: _toggleAdvancedFilter,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        if (_filterResult == null)
                          ListViewObserver(
                            controller: _observerController,
                            onObserve: _handleObserve,
                            child: ListView.builder(
                              key: const ValueKey('transaction_detail_list'),
                              controller: _scrollController,
                              padding: EdgeInsets.zero,
                              physics: const ClampingScrollPhysics(),
                              itemCount: transactionDetailMockSections.length,
                              itemBuilder: (_, index) => _MonthSection(
                                section: transactionDetailMockSections[index],
                              ),
                            ),
                          )
                        else
                          _FilteredResultList(result: _filterResult!),
                        if (_filterResult == null)
                          Positioned(
                            right: 20.w,
                            bottom: 18.w,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 150),
                              scale: _showScrollToTop ? 1 : 0,
                              child: _ScrollToTopButton(onTap: _scrollToTop),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _filterResult?.records.isEmpty == true
                ? null
                : _ExportBar(onTap: widget.onExportTap),
          ),
          if (_showQuickFilter) ...[
            Positioned(
              left: 0,
              right: 0,
              top: filterOverlayTop,
              bottom: 0,
              child: GestureDetector(
                key: const ValueKey('transaction_quick_filter_scrim'),
                behavior: HitTestBehavior.opaque,
                onTap: _toggleQuickFilter,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.36),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: filterOverlayTop,
              height: 139.w,
              child: TransactionQuickFilterPanel(
                onSelected: _handleQuickRange,
              ),
            ),
          ],
          if (_showAdvancedFilter) ...[
            Positioned(
              left: 0,
              right: 0,
              top: filterOverlayTop,
              bottom: mediaQuery.viewInsets.bottom,
              child: GestureDetector(
                key: const ValueKey('transaction_advanced_filter_scrim'),
                behavior: HitTestBehavior.opaque,
                onTap: _toggleAdvancedFilter,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.36),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: filterOverlayTop,
              height: advancedFilterHeight,
              child: TransactionAdvancedFilterPanel(
                initialValue: _advancedFilter,
                onComplete: _completeAdvancedFilter,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionNavigationBar extends StatelessWidget {
  const _TransactionNavigationBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '交易明细',
            style: TextStyle(
              color: const Color(0xFF111111),
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Positioned(
            left: 4.w,
            width: 44.w,
            top: 0,
            bottom: 0,
            child: Semantics(
              button: true,
              label: '返回',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: Get.back,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22.w,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            width: 77.w,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: '小交通',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: SizedBox(
                      width: 38.w,
                      height: 44.w,
                      child: Center(
                        child: Image.asset(
                          'assets/images/transaction_detail/mascot.png',
                          width: 34.w,
                          height: 34.w,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 9.w),
                Semantics(
                  button: true,
                  label: '在线客服',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: SizedBox(
                      width: 30.w,
                      height: 44.w,
                      child: Center(
                        child: Image.asset(
                          'assets/images/nav_right_kf.png',
                          width: 23.w,
                          height: 23.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47.w,
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Image.asset(
            'assets/images/transaction_detail/bank_logo.png',
            width: 33.w,
            height: 33.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              '交通银行 II类账户 (**2910)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF252525),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 14.w),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.monthText,
    required this.expanded,
    required this.highlighted,
    required this.filterActive,
    this.onMonthTap,
    this.onFilterTap,
  });

  final String monthText;
  final bool expanded;
  final bool highlighted;
  final bool filterActive;
  final VoidCallback? onMonthTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43.w,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: '按月份筛选，当前$monthText',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onMonthTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthText,
                      key: const ValueKey(
                        'transaction_detail_selected_month',
                      ),
                      style: TextStyle(
                        color: expanded || highlighted
                            ? const Color(0xFF0077DF)
                            : const Color(0xFF303030),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Icon(
                      expanded
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      color: expanded || highlighted
                          ? const Color(0xFF0077DF)
                          : const Color(0xFF303030),
                      size: 15.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 0.5.w,
            height: 20.w,
            color: const Color(0xFFE7E7E7),
          ),
          Semantics(
            button: true,
            label: '筛选交易明细',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onFilterTap,
              child: SizedBox(
                width: 75.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '筛选',
                      style: TextStyle(
                        color: filterActive
                            ? const Color(0xFF0077DF)
                            : const Color(0xFF303030),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Transform.translate(
                      offset: Offset(0, 1.w),
                      child: Image.asset(
                        filterActive
                            ? 'assets/images/transaction_detail/filter_icon_active.png'
                            : 'assets/images/transaction_detail/filter_icon.png',
                        key: const ValueKey('transaction_filter_icon'),
                        width: 9.w,
                        height: 10.5.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilteredResultList extends StatelessWidget {
  const _FilteredResultList({required this.result});

  final TransactionFilterResult result;

  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7F7),
      child: Column(
        children: [
          if (result.showSummary)
            SizedBox(
              height: 40.w,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  children: [
                    Text(
                      '共${result.count}笔',
                      key: const ValueKey('transaction_filter_count'),
                      style: TextStyle(
                        color: const Color(0xFF373737),
                        fontSize: 14.sp,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: _SummaryText(
                        label: '收入',
                        amount: result.income,
                        formatter: _amountFormat,
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Flexible(
                      child: _SummaryText(
                        label: '支出',
                        amount: result.expense,
                        formatter: _amountFormat,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: result.records.isEmpty
                ? const _EmptyFilterResult()
                : ListView(
                    key: const ValueKey('transaction_filtered_list'),
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.w),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var index = 0;
                                index < result.records.length;
                                index++)
                              _TransactionRow(
                                record: result.records[index],
                                showDivider: index != result.records.length - 1,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterResult extends StatelessWidget {
  const _EmptyFilterResult();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.18),
      child: Column(
        key: const ValueKey('transaction_empty_result'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/transaction_detail/empty_records.png',
            key: const ValueKey('transaction_empty_result_image'),
            width: 111.w,
            height: 87.w,
            fit: BoxFit.fill,
          ),
          SizedBox(height: 14.w),
          Text(
            '无交易明细记录',
            style: TextStyle(
              color: const Color(0xFF303030),
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({required this.section});

  final TransactionMonthSection section;

  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7F7),
      child: Column(
        children: [
          SizedBox(
            height: 40.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                children: [
                  Text(
                    section.monthKey,
                    style: TextStyle(
                      color: const Color(0xFF373737),
                      fontSize: 14.sp,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: _SummaryText(
                      label: '收入',
                      amount: section.income,
                      formatter: _amountFormat,
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Flexible(
                    child: _SummaryText(
                      label: '支出',
                      amount: section.expense,
                      formatter: _amountFormat,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11.w),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < section.records.length; index++)
                  _TransactionRow(
                    record: section.records[index],
                    showDivider: index != section.records.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryText extends StatelessWidget {
  const _SummaryText({
    required this.label,
    required this.amount,
    required this.formatter,
  });

  final String label;
  final double amount;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(color: Color(0xFF8793A5)),
            ),
            TextSpan(
              text: '${label == '收入' ? '+' : '-'}${formatter.format(amount)}',
              style: const TextStyle(color: Color(0xFF3B3B3B)),
            ),
          ],
        ),
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.record,
    required this.showDivider,
  });

  final TransactionRecord record;
  final bool showDivider;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');

  String get _amountText {
    final value = _amountFormat.format(record.amount.abs());
    return record.isIncome ? '+$value' : '-$value';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${record.title}，${record.channel}，$_amountText，${_dateFormat.format(record.occurredAt)}',
      child: SizedBox(
        key: ValueKey('transaction_row_${record.title}'),
        // 参考图 1080px 宽：相邻分隔线间距约 270px，即 94w。
        height: 94.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 105.w,
                top: 10.w,
                child: Text(
                  record.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1D1D1D),
                    fontSize: 16.sp,
                    height: 1.05,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 35.w,
                child: Text(
                  record.channel,
                  style: TextStyle(
                    color: const Color(0xFF969696),
                    fontSize: 14.sp,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 57.w,
                child: Text(
                  _dateFormat.format(record.occurredAt),
                  style: TextStyle(
                    color: const Color(0xFF969696),
                    fontSize: 14.sp,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 9.w,
                child: Text(
                  _amountText,
                  style: TextStyle(
                    color: record.isIncome
                        ? const Color(0xFFFF5C5C)
                        : const Color(0xFF333333),
                    fontSize: 16.sp,
                    height: 1.05,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 35.w,
                child: Text(
                  '余额${_amountFormat.format(record.balance)}',
                  style: TextStyle(
                    color: const Color(0xFF616161),
                    fontSize: 14.sp,
                    height: 1,
                  ),
                ),
              ),
              if (showDivider)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 0.5.w,
                    color: const Color(0xFFE9E9E9),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollToTopButton extends StatelessWidget {
  const _ScrollToTopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '返回顶部',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF536273).withValues(alpha: 0.12),
                blurRadius: 18.w,
                offset: Offset(0, 5.w),
              ),
            ],
          ),
          child: Icon(
            Icons.keyboard_double_arrow_up_rounded,
            color: const Color(0xFF435365),
            size: 28.w,
          ),
        ),
      ),
    );
  }
}

class _ExportBar extends StatelessWidget {
  const _ExportBar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Semantics(
        button: true,
        label: '导出交易明细',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 55.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/transaction_detail/export_icon.png',
                  key: const ValueKey('transaction_export_icon'),
                  width: 20.w,
                  height: 22.w,
                  fit: BoxFit.fill,
                ),
                Text(
                  '导出交易明细',
                  style: TextStyle(
                    color: const Color(0xFF303030),
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
