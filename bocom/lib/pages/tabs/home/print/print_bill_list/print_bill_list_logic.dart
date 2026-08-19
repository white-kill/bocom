import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'print_bill_list_state.dart';
import '../../transaction_detail/filter/transaction_advanced_filter_model.dart';
import '../../transaction_detail/transaction_detail_model.dart';
import '../../transaction_detail/transaction_detail_repository.dart';

class PrintBillListLogic extends GetxController {
  final PrintBillListState state = PrintBillListState();

  final periodFilterExpanded = false.obs;
  final currencyFilterExpanded = false.obs;
  final selectedPeriodLabel = '近1个月'.obs;
  final selectedCurrencyLabel = '人民币CNY'.obs;
  final advancedFilterExpanded = false.obs;
  final advancedFilter =
      const TransactionAdvancedFilterValue().obs;
  final Rxn<DateTime> beginTime = Rxn<DateTime>();
  final Rxn<DateTime> endTime = Rxn<DateTime>();
  final entries = <TransactionBillEntry>[].obs;
  final loading = true.obs;
  final loadFailed = false.obs;
  final loadingMore = false.obs;
  final loadMoreFailed = false.obs;
  final pageNum = 0.obs;
  final pages = 0.obs;
  int _requestVersion = 0;

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    selectPeriod('近1个月', closeFilter: false);
  }

  Future<bool> loadTransactions({
    bool loadMore = false,
    bool preserveContent = false,
  }) async {
    if (loadMore &&
        (loadingMore.value || pageNum.value >= pages.value)) {
      return false;
    }
    final version = loadMore ? _requestVersion : ++_requestVersion;
    final nextPage = loadMore ? pageNum.value + 1 : 1;
    if (loadMore) {
      loadingMore.value = true;
      loadMoreFailed.value = false;
    } else if (!preserveContent) {
      loading.value = true;
      loadFailed.value = false;
      loadMoreFailed.value = false;
      pageNum.value = 0;
      pages.value = 0;
    } else {
      loadFailed.value = false;
      loadMoreFailed.value = false;
    }

    final params = TransactionBillQuery.build(
      pageNum: nextPage,
      filter: advancedFilter.value,
      beginTime: beginTime.value,
      endTime: endTime.value,
    );
    try {
      final page = await loadTransactionBillPage(params);
      if (version != _requestVersion) return false;
      entries.assignAll(loadMore
          ? [...entries, ...page.entries]
          : page.entries);
      pageNum.value = nextPage;
      pages.value = page.pages;
      loading.value = false;
      loadingMore.value = false;
      loadFailed.value = false;
      loadMoreFailed.value = false;
      return true;
    } catch (_) {
      if (version != _requestVersion) return false;
      loading.value = false;
      loadingMore.value = false;
      if (loadMore) {
        loadMoreFailed.value = true;
      } else if (!preserveContent) {
        loadFailed.value = true;
      }
      return false;
    }
  }

  Future<void> refreshTransactions(RefreshController controller) async {
    try {
      await loadTransactions(preserveContent: true);
    } finally {
      controller
        ..resetNoData()
        ..refreshCompleted();
    }
  }

  Future<void> loadMoreTransactions(RefreshController controller) async {
    if (pageNum.value >= pages.value) {
      controller.loadNoData();
      return;
    }
    final succeeded = await loadTransactions(loadMore: true);
    if (!succeeded) {
      controller.loadFailed();
    } else if (pageNum.value >= pages.value) {
      controller.loadNoData();
    } else {
      controller.loadComplete();
    }
  }

  void togglePeriodFilter() {
    if (!periodFilterExpanded.value) closeCurrencyFilter();
    periodFilterExpanded.toggle();
  }

  void closePeriodFilter() => periodFilterExpanded.value = false;

  void toggleCurrencyFilter() {
    if (!currencyFilterExpanded.value) closePeriodFilter();
    currencyFilterExpanded.toggle();
  }

  void closeCurrencyFilter() => currencyFilterExpanded.value = false;

  void selectCurrency(String currency) {
    selectedCurrencyLabel.value = currency;
    closeCurrencyFilter();
  }

  void openAdvancedFilter() {
    closePeriodFilter();
    closeCurrencyFilter();
    advancedFilterExpanded.value = true;
  }

  void closeAdvancedFilter() => advancedFilterExpanded.value = false;

  void completeAdvancedFilter(TransactionAdvancedFilterValue value) {
    advancedFilter.value = value;
    closeAdvancedFilter();
    loadTransactions();
  }

  void selectPeriod(String label, {bool closeFilter = true}) {
    final now = _dateOnly(DateTime.now());
    endTime.value = now;
    beginTime.value = switch (label) {
      '近7天' => now.subtract(const Duration(days: 7)),
      '近1个月' => now.subtract(const Duration(days: 30)),
      '近一个月' => now.subtract(const Duration(days: 30)),
      '近三个月' => now.subtract(const Duration(days: 90)),
      '近3个月' => now.subtract(const Duration(days: 90)),
      '近半年' => now.subtract(const Duration(days: 180)),
      '近一年' => now.subtract(const Duration(days: 365)),
      _ => null,
    };
    selectedPeriodLabel.value =
        label == '近一个月' || label == '近1个月' ? '近1个月' : label;
    if (closeFilter) closePeriodFilter();
    loadTransactions();
  }

  void selectCustomPeriodSelection(DateTime begin, DateTime end) {
    final start = _dateOnly(begin);
    final finish = _dateOnly(end);
    beginTime.value = start;
    endTime.value = finish;
    selectedPeriodLabel.value = '${_formatDate(start)}至${_formatDate(finish)}';
    closePeriodFilter();
    loadTransactions();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
