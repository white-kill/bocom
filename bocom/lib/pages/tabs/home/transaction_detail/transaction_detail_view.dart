import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../../config/abc_config/boc_logic.dart';
import '../../../../pages/component/indicator_loading.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/sp_util.dart';
import 'filter/transaction_advanced_filter_model.dart';
import 'filter/transaction_advanced_filter_panel.dart';
import 'filter/transaction_filter_model.dart';
import 'filter/transaction_filter_sheet.dart';
import 'filter/transaction_future_date_dialog.dart';
import 'filter/transaction_quick_filter_panel.dart';
import 'transaction_bill_detail_view.dart';
import 'transaction_detail_mock_data.dart';
import 'transaction_detail_model.dart';
import 'transaction_detail_repository.dart';

// 交易明细页
// 说明：当前页面参照完整截图使用 Flutter 原生绘制，系统状态栏、固定导航、跨月滚动和动态金额均未保留在截图中。
class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({
    super.key,
    this.onMonthTap,
    this.onFilterTap,
    this.onExportTap,
    this.billLoader,
    this.billDetailLoader,
    this.today,
  });

  final ValueChanged<String>? onMonthTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onExportTap;
  final TransactionBillPageLoader? billLoader;
  final TransactionBillDetailLoader? billDetailLoader;
  final DateTime? today;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late final ScrollController _scrollController;
  late final RefreshController _listRefreshController;
  late final RefreshController _filteredRefreshController;

  List<TransactionBillEntry> _entries = const [];
  List<TransactionMonthSection> _sections = const [];
  int _visibleMonthIndex = 0;
  int _pageNum = 0;
  int _pages = 0;
  int _requestVersion = 0;
  bool _initialLoading = true;
  bool _loadFailed = false;
  bool _loadingMore = false;
  bool _loadMoreFailed = false;
  bool _showScrollToTop = false;
  bool _showQuickFilter = false;
  bool _showAdvancedFilter = false;
  TransactionFilterResult? _filterResult;
  TransactionFilterSelection? _lastDateSelection;
  TransactionQuickRange? _quickRange;
  TransactionAdvancedFilterValue _advancedFilter =
      const TransactionAdvancedFilterValue();

  DateTime get _today => widget.today ?? DateTime.now();

  bool get _usesPreviewData => widget.billLoader == null && token.isEmpty;

  bool get _hasActiveFilter =>
      _quickRange != null ||
      _lastDateSelection != null ||
      !_advancedFilter.isEmpty;

  bool get _hasActiveDateFilter =>
      _quickRange != null ||
      _lastDateSelection != null ||
      _filterResult?.quickRange != null ||
      _filterResult?.selection != null;

  TransactionMonthSection? get _visibleSection => _sections.isEmpty
      ? null
      : _sections[_visibleMonthIndex.clamp(0, _sections.length - 1)];

  String get _visibleMonthLabel {
    final section = _visibleSection;
    if (section == null) return '本月';
    return section.year == _today.year && section.month == _today.month
        ? '本月'
        : section.monthKey;
  }

  String get _monthToolbarLabel {
    if (_hasActiveDateFilter) {
      return _filterResult?.toolbarLabel ?? _activeToolbarLabel;
    }
    return _visibleMonthLabel;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _listRefreshController = RefreshController();
    _filteredRefreshController = RefreshController();
    if (_usesPreviewData) {
      _sections = transactionDetailMockSections;
      _initialLoading = false;
    } else {
      _loadTransactions();
    }
  }

  void _handleScroll() {
    final show =
        _scrollController.hasClients && _scrollController.offset > 420.w;
    var visibleMonthIndex = _visibleMonthIndex;
    if (_filterResult == null && _sections.isNotEmpty) {
      final offset = math.max(0.0, _scrollController.offset);
      var sectionEnd = 0.0;
      for (var index = 0; index < _sections.length; index++) {
        sectionEnd += 52.w + _sections[index].records.length * 94.w;
        if (offset < sectionEnd || index == _sections.length - 1) {
          visibleMonthIndex = index;
          break;
        }
      }
    }
    if (mounted &&
        (show != _showScrollToTop || visibleMonthIndex != _visibleMonthIndex)) {
      setState(() {
        _showScrollToTop = show;
        _visibleMonthIndex = visibleMonthIndex;
      });
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _openBillDetail(TransactionRecord record) {
    TransactionBillEntry? entry;
    for (final candidate in _entries) {
      if (identical(candidate.record, record)) {
        entry = candidate;
        break;
      }
    }
    final initialDetail = entry?.detail ??
        (_usesPreviewData ? TransactionBillDetail.fromRecord(record) : null);
    Get.to<void>(
      () => TransactionBillDetailPage(
        billId: entry?.id ?? 0,
        initialDetail: initialDetail,
        detailLoader: widget.billDetailLoader,
      ),
    );
  }

  void _toggleQuickFilter() {
    widget.onMonthTap?.call(_visibleSection?.monthKey ?? '本月');
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
    if (_usesPreviewData) {
      setState(() => _filterResult = _quickResult(range));
      return;
    }
    setState(() {
      _quickRange = range;
      _lastDateSelection = null;
    });
    await _loadTransactions();
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
    if (selection.mode == TransactionDateFilterMode.custom &&
        TransactionDateRules.containsFutureDate(
          selection.startDate!,
          selection.endDate!,
          _today,
        )) {
      setState(() {
        _quickRange = null;
        _filterResult = TransactionFilterResult(
          toolbarLabel: selection.toolbarLabel,
          count: 0,
          income: 0,
          expense: 0,
          records: const [],
          selection: selection,
          showSummary: false,
        );
      });
      await TransactionFutureDateDialog.show(context);
      return;
    }

    if (_usesPreviewData) {
      setState(() => _filterResult = _resultForSelection(selection));
      return;
    }
    setState(() => _quickRange = null);
    await _loadTransactions();
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

  Future<void> _completeAdvancedFilter(
    TransactionAdvancedFilterValue value,
  ) async {
    if (!_usesPreviewData) {
      setState(() {
        _advancedFilter = value;
        _showAdvancedFilter = false;
      });
      await _loadTransactions();
      return;
    }

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
          toolbarLabel: _visibleMonthLabel,
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
      final customMinAmount = _amountOrNull(value.minAmount);
      final customMaxAmount = _amountOrNull(value.maxAmount);
      final matchesAmount = switch (value.amountRange) {
        '1百以下' => amount < 100,
        '1百-1千' => amount >= 100 && amount < 1000,
        '1千-5千' => amount >= 1000 && amount < 5000,
        '5千-1万' => amount >= 5000 && amount < 10000,
        '1万-5万' => amount >= 10000 && amount < 50000,
        '5万以上' => amount >= 50000,
        '自定义' => (customMinAmount == null || amount >= customMinAmount) &&
            (customMaxAmount == null || amount <= customMaxAmount),
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

  double? _amountOrNull(String value) => double.tryParse(value.trim());

  Future<bool> _loadTransactions({
    bool loadMore = false,
    bool preserveContent = false,
  }) async {
    if (_usesPreviewData ||
        (loadMore && (_loadingMore || _pageNum >= _pages))) {
      return false;
    }

    final version = loadMore ? _requestVersion : ++_requestVersion;
    final pageNum = loadMore ? _pageNum + 1 : 1;
    if (mounted) {
      setState(() {
        if (loadMore) {
          _loadingMore = true;
          _loadMoreFailed = false;
        } else if (!preserveContent) {
          _initialLoading = true;
          _loadFailed = false;
          _loadMoreFailed = false;
          _visibleMonthIndex = 0;
          _pageNum = 0;
          _pages = 0;
        } else {
          _loadFailed = false;
          _loadMoreFailed = false;
        }
      });
    }

    final range = _requestDateRange();
    final params = TransactionBillQuery.build(
      pageNum: pageNum,
      filter: _advancedFilter,
      beginTime: range.beginTime,
      endTime: range.endTime,
    );

    try {
      final page = await (widget.billLoader ?? loadTransactionBillPage)(params);
      if (!mounted || version != _requestVersion) return false;
      final entries = loadMore ? [..._entries, ...page.entries] : page.entries;
      final sections = _sectionsFrom(entries);
      setState(() {
        _entries = entries;
        _sections = sections;
        _pageNum = pageNum;
        _pages = entries.length >= page.total ? pageNum : page.pages;
        _initialLoading = false;
        _loadingMore = false;
        _loadFailed = false;
        _loadMoreFailed = false;
        _filterResult = _hasActiveFilter
            ? TransactionFilterResult(
                toolbarLabel: _activeToolbarLabel,
                count: page.total,
                income: page.incomeTotal,
                expense: page.expensesTotal,
                records: entries.map((entry) => entry.record).toList(
                      growable: false,
                    ),
                selection: _lastDateSelection,
                quickRange: _quickRange,
                showSummary: entries.isNotEmpty,
              )
            : null;
      });
      if (!loadMore) _jumpToStartAfterLoad();
      return true;
    } catch (_) {
      if (!mounted || version != _requestVersion) return false;
      setState(() {
        _initialLoading = false;
        _loadingMore = false;
        if (loadMore) {
          _loadMoreFailed = true;
        } else if (!preserveContent) {
          _loadFailed = true;
        }
      });
      return false;
    }
  }

  Future<void> _refreshTransactions(RefreshController controller) async {
    final succeeded = _usesPreviewData
        ? await _refreshPreviewData()
        : await _loadTransactions(preserveContent: true);
    if (!mounted) return;
    if (succeeded) {
      controller.refreshCompleted(resetFooterState: true);
    } else {
      controller.refreshFailed();
    }
  }

  Future<bool> _refreshPreviewData() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return false;
    setState(() {
      _sections = transactionDetailMockSections;
      _visibleMonthIndex = 0;
    });
    _jumpToStartAfterLoad();
    return true;
  }

  Future<void> _loadMoreTransactions(RefreshController controller) async {
    if (_usesPreviewData || _pageNum >= _pages) {
      controller.loadNoData();
      return;
    }
    final succeeded = await _loadTransactions(loadMore: true);
    if (!mounted) return;
    if (!succeeded) {
      controller.loadFailed();
    } else if (_pageNum >= _pages) {
      controller.loadNoData();
    } else {
      controller.loadComplete();
    }
  }

  Widget _withRefresh({
    required Widget child,
    required RefreshController controller,
  }) {
    return RefreshConfiguration(
      headerTriggerDistance: 62.w,
      maxOverScrollExtent: 86.w,
      child: SmartRefresher(
        controller: controller,
        enablePullDown: true,
        enablePullUp: _loadingMore || _loadMoreFailed || _pageNum < _pages,
        header: CustomHeader(
          height: 74.w,
          completeDuration: const Duration(milliseconds: 120),
          builder: (_, mode) => _TransactionPullRefreshHeader(mode: mode),
        ),
        footer: CustomFooter(
          height: 70.w,
          loadStyle: LoadStyle.ShowWhenLoading,
          builder: (_, mode) => mode == LoadStatus.loading
              ? const _TransactionLoadMoreWave()
              : const SizedBox.shrink(),
        ),
        onRefresh: () => _refreshTransactions(controller),
        onLoading: () => _loadMoreTransactions(controller),
        child: child,
      ),
    );
  }

  String get _activeToolbarLabel =>
      _lastDateSelection?.toolbarLabel ?? _quickRange?.label ?? '本月';

  ({DateTime? beginTime, DateTime? endTime}) _requestDateRange() {
    final today = DateTime(_today.year, _today.month, _today.day);
    final selection = _lastDateSelection;
    if (selection != null) {
      return switch (selection.mode) {
        TransactionDateFilterMode.month => (
            beginTime: DateTime(
              selection.month!.year,
              selection.month!.month,
              1,
            ),
            endTime: _notAfterToday(
              DateTime(
                selection.month!.year,
                selection.month!.month + 1,
                0,
              ),
              today,
            ),
          ),
        TransactionDateFilterMode.year => (
            beginTime: DateTime(selection.year!, 1, 1),
            endTime: _notAfterToday(DateTime(selection.year!, 12, 31), today),
          ),
        TransactionDateFilterMode.custom => (
            beginTime: selection.startDate,
            endTime: selection.endDate,
          ),
      };
    }

    return switch (_quickRange) {
      TransactionQuickRange.currentMonth => (
          beginTime: DateTime(today.year, today.month, 1),
          endTime: today,
        ),
      TransactionQuickRange.recentWeek => (
          beginTime: today.subtract(const Duration(days: 6)),
          endTime: today,
        ),
      TransactionQuickRange.recentMonth => (
          beginTime: today.subtract(const Duration(days: 29)),
          endTime: today,
        ),
      TransactionQuickRange.recentThreeMonths => (
          beginTime: today.subtract(const Duration(days: 89)),
          endTime: today,
        ),
      TransactionQuickRange.recentYear => (
          beginTime: today.subtract(const Duration(days: 364)),
          endTime: today,
        ),
      _ => (beginTime: null, endTime: null),
    };
  }

  DateTime _notAfterToday(DateTime value, DateTime today) =>
      value.isAfter(today) ? today : value;

  List<TransactionMonthSection> _sectionsFrom(
    List<TransactionBillEntry> entries,
  ) {
    final sections = <TransactionMonthSection>[];
    for (final entry in entries) {
      final record = entry.record;
      if (sections.isNotEmpty &&
          sections.last.year == record.occurredAt.year &&
          sections.last.month == record.occurredAt.month) {
        final current = sections.last;
        sections[sections.length - 1] = TransactionMonthSection(
          year: current.year,
          month: current.month,
          records: [...current.records, record],
          serverIncome: current.serverIncome ?? entry.monthIncomeTotal,
          serverExpense: current.serverExpense ?? entry.monthExpensesTotal,
        );
      } else {
        sections.add(
          TransactionMonthSection(
            year: record.occurredAt.year,
            month: record.occurredAt.month,
            records: [record],
            serverIncome: entry.monthIncomeTotal,
            serverExpense: entry.monthExpensesTotal,
          ),
        );
      }
    }
    return sections;
  }

  void _jumpToStartAfterLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _listRefreshController.dispose();
    _filteredRefreshController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthText = _monthToolbarLabel;
    final hasRecords =
        _filterResult?.records.isNotEmpty ?? _sections.isNotEmpty;
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
                    highlighted: _hasActiveDateFilter,
                    filterActive:
                        _showAdvancedFilter || !_advancedFilter.isEmpty,
                    onMonthTap: _toggleQuickFilter,
                    onFilterTap: _toggleAdvancedFilter,
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: const Color(0xFFF7F7F7),
                      child: Stack(
                        children: [
                          if (_initialLoading)
                            const _TransactionLoadingState()
                          else if (_loadFailed)
                            _TransactionLoadError(
                              onRetry: () => _loadTransactions(),
                            )
                          else if (_filterResult == null && _sections.isEmpty)
                            const _EmptyFilterResult()
                          else if (_filterResult == null)
                            _withRefresh(
                              controller: _listRefreshController,
                              child: ListView.builder(
                                key: const ValueKey('transaction_detail_list'),
                                controller: _scrollController,
                                padding: EdgeInsets.zero,
                                physics: const ClampingScrollPhysics(),
                                itemCount: _sections.length +
                                    (_loadMoreFailed ? 1 : 0),
                                itemBuilder: (_, index) {
                                  if (index == _sections.length) {
                                    return _LoadMoreFooter(
                                      failed: true,
                                      onRetry: () => _loadMoreTransactions(
                                        _listRefreshController,
                                      ),
                                    );
                                  }
                                  return _MonthSection(
                                    section: _sections[index],
                                    onRecordTap: _openBillDetail,
                                  );
                                },
                              ),
                            )
                          else
                            _FilteredResultList(
                              result: _filterResult!,
                              controller: _scrollController,
                              loadMoreFailed: _loadMoreFailed,
                              onRetryLoadMore: () => _loadMoreTransactions(
                                _filteredRefreshController,
                              ),
                              onRecordTap: _openBillDetail,
                              wrapList: ({required child}) => _withRefresh(
                                child: child,
                                controller: _filteredRefreshController,
                              ),
                            ),
                          if (!_initialLoading &&
                              !_loadFailed &&
                              _filterResult == null &&
                              _sections.isNotEmpty)
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
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _initialLoading || _loadFailed || !hasRecords
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
                    onTap: () => Get.toNamed(Routes.customerService),
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

  String _accountTitle(BocLogic? logic) {
    if (logic == null || logic.memberInfo.bankList.isEmpty) {
      return '交通银行 借记卡';
    }

    final cardNumber = logic.memberInfo.bankList.first.bankCard.trim();
    if (cardNumber.isEmpty) {
      return '交通银行 借记卡';
    }
    final lastFour = cardNumber.length <= 4
        ? cardNumber
        : cardNumber.substring(cardNumber.length - 4);
    return '交通银行 借记卡 (**$lastFour)';
  }

  Widget _titleText(String title) {
    return Text(
      title,
      key: const ValueKey('transaction-account-title'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: const Color(0xFF252525),
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

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
            child: Get.isRegistered<BocLogic>()
                ? GetBuilder<BocLogic>(
                    id: 'updateCard',
                    builder: (logic) => _titleText(_accountTitle(logic)),
                  )
                : _titleText(_accountTitle(null)),
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
  const _FilteredResultList({
    required this.result,
    required this.controller,
    required this.loadMoreFailed,
    required this.onRetryLoadMore,
    required this.onRecordTap,
    required this.wrapList,
  });

  final TransactionFilterResult result;
  final ScrollController controller;
  final bool loadMoreFailed;
  final VoidCallback onRetryLoadMore;
  final ValueChanged<TransactionRecord> onRecordTap;
  final Widget Function({required Widget child}) wrapList;

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
                : wrapList(
                    child: ListView(
                      key: const ValueKey('transaction_filtered_list'),
                      controller: controller,
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
                                  showDivider:
                                      index != result.records.length - 1,
                                  onTap: () =>
                                      onRecordTap(result.records[index]),
                                ),
                            ],
                          ),
                        ),
                        if (loadMoreFailed)
                          _LoadMoreFooter(
                            failed: true,
                            onRetry: onRetryLoadMore,
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TransactionLoadingState extends StatelessWidget {
  const _TransactionLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        child: const CircularProgressIndicator(strokeWidth: 2.2),
      ),
    );
  }
}

class _TransactionLoadError extends StatelessWidget {
  const _TransactionLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        key: const ValueKey('transaction_load_retry'),
        onPressed: onRetry,
        child: Text(
          '加载失败，点击重试',
          style: TextStyle(
            color: const Color(0xFF777777),
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.failed,
    required this.onRetry,
  });

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.w,
      child: Center(
        child: failed
            ? TextButton(
                key: const ValueKey('transaction_load_more_retry'),
                onPressed: onRetry,
                child: Text(
                  '加载失败，点击重试',
                  style: TextStyle(
                    color: const Color(0xFF777777),
                    fontSize: 13.sp,
                  ),
                ),
              )
            : SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
      ),
    );
  }
}

class _TransactionPullRefreshHeader extends StatelessWidget {
  const _TransactionPullRefreshHeader({required this.mode});

  final RefreshStatus? mode;

  @override
  Widget build(BuildContext context) {
    final refreshing = mode == RefreshStatus.refreshing;
    return Center(
      child: SizedBox.square(
        key: const ValueKey('transaction_pull_refresh_indicator'),
        dimension: 22.w,
        child: refreshing
            ? BocomArcLoadingIndicator(
                dimension: 22.w,
                color: const Color(0xFF555555),
                strokeWidth: 2.7.w,
              )
            : CircularProgressIndicator(
                value: 0.72,
                color: const Color(0xFF555555),
                strokeWidth: 2.7.w,
                strokeCap: StrokeCap.round,
              ),
      ),
    );
  }
}

class _TransactionLoadMoreWave extends StatefulWidget {
  const _TransactionLoadMoreWave();

  @override
  State<_TransactionLoadMoreWave> createState() =>
      _TransactionLoadMoreWaveState();
}

class _TransactionLoadMoreWaveState extends State<_TransactionLoadMoreWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '正在加载更多交易明细',
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Row(
            key: const ValueKey('transaction_load_more_wave'),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < 3; index++) ...[
                if (index > 0) SizedBox(width: 9.w),
                _buildDot(index),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final phase = _controller.value * math.pi * 2 - index * 0.9;
    final wave = (math.sin(phase) + 1) / 2;
    final scale = 0.62 + wave * 0.48;
    return Transform.scale(
      key: ValueKey('transaction_load_more_dot_$index'),
      scale: scale,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF9DCEF4),
            const Color(0xFF258FE8),
            wave,
          ),
          shape: BoxShape.circle,
        ),
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
  const _MonthSection({
    required this.section,
    required this.onRecordTap,
  });

  final TransactionMonthSection section;
  final ValueChanged<TransactionRecord> onRecordTap;

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
                    onTap: () => onRecordTap(section.records[index]),
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
    this.onTap,
  });

  final TransactionRecord record;
  final bool showDivider;
  final VoidCallback? onTap;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');

  String get _amountText {
    final value = _amountFormat.format(record.amount.abs());
    return record.isIncome ? '+$value' : '-$value';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      onTap: onTap,
      label:
          '${record.title}，${record.channel}，$_amountText，${_dateFormat.format(record.occurredAt)}',
      child: _NonBlockingTap(
        onTap: onTap,
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
      ),
    );
  }
}

class _NonBlockingTap extends StatefulWidget {
  const _NonBlockingTap({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_NonBlockingTap> createState() => _NonBlockingTapState();
}

class _NonBlockingTapState extends State<_NonBlockingTap> {
  Offset? _pointerDownPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _pointerDownPosition = event.position,
      onPointerMove: (event) {
        final origin = _pointerDownPosition;
        if (origin != null && (event.position - origin).distance > 12.w) {
          _pointerDownPosition = null;
        }
      },
      onPointerCancel: (_) => _pointerDownPosition = null,
      onPointerUp: (_) {
        if (_pointerDownPosition != null) widget.onTap?.call();
        _pointerDownPosition = null;
      },
      child: widget.child,
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
