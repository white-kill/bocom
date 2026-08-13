import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:bocom/utils/sp_util.dart';
import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/model/book_overview_model.dart';
import 'package:bocom/config/model/bill_item_model.dart';
import 'package:bocom/config/model/book_analysis_model.dart';
import 'package:bocom/config/app_config.dart';

import 'ledger_state.dart';

class LedgerLogic extends GetxController {
  final LedgerState state = LedgerState();

  final ledgerTypeList = [
    {
      'name': '总账本',
      'image': 'ledger_type_1',
      'selectImage': 'ledger_type_1_select',
      'smallImage': 'ledger_type_1_small',
      'manageImage': 'ledger_type_1_manage',
    },
    {
      'name': '投资账本',
      'image': 'ledger_type_2',
      'selectImage': 'ledger_type_2_select',
      'smallImage': 'ledger_type_2_small',
      'manageImage': 'ledger_type_2_manage',
    },
    {
      'name': '消费账本',
      'image': 'ledger_type_3',
      'selectImage': 'ledger_type_3_select',
      'smallImage': 'ledger_type_3_small',
      'manageImage': 'ledger_type_3_manage',
    },
    {
      'name': '薪资账本',
      'image': 'ledger_type_4',
      'selectImage': 'ledger_type_4_select',
      'smallImage': 'ledger_type_4_small',
      'manageImage': 'ledger_type_4_manage',
    },
  ];

  final ledgerType = 0.obs;
  final ledgerTypeExpanded = false.obs;
  final ledgerTab = 0.obs;
  final suppressHeaderAnimation = false.obs;
  final periodMode = 0.obs;
  final selectedPeriod =
      DateTime(DateTime.now().year, DateTime.now().month).obs;
  final periodPickerVisible = false.obs;
  // 0: 收起，1: 日期，2: 账户，3: 金额筛选
  final waterFilterExpanded = 0.obs;
  final waterLastFilter = 1.obs;
  final waterPeriodLabel = ''.obs;
  final waterAccount = '全部账户'.obs;
  final waterAmountFilter = ''.obs;
  final waterMinAmount = ''.obs;
  final waterMaxAmount = ''.obs;
  final waterAmountInputVersion = 0.obs;
  final Rxn<DateTime> waterBeginTime = Rxn<DateTime>();
  final Rxn<DateTime> waterEndTime = Rxn<DateTime>();
  final analysisPeriodLabel = ''.obs;
  final analysisAccount = '全部账户'.obs;
  final analysisIncomeExpenseType = 2.obs;
  final Rxn<DateTime> analysisBeginTime = Rxn<DateTime>();
  final Rxn<DateTime> analysisEndTime = Rxn<DateTime>();
  // 总览的
  final bookOverview = BookOverviewModel().obs;
  final bookDetailPage = BillItemModel().obs;
  int _bookDetailPageNum = 0;
  // 明细流水的
  final bookWaterPage = BillItemModel().obs;
  final bookAnalysis = BookAnalysisModel().obs;
  int _bookWaterPageNum = 0;

  void toggleLedgerType() {
    waterFilterExpanded.value = 0;
    ledgerTypeExpanded.toggle();
  }

  void selectLedgerType(int index) {
    ledgerType.value = index;
    ledgerTypeExpanded.value = false;
    getOverView();
    getBookDetailPage();
    getBookWaterPage();
    if (ledgerTab.value == 2) getBookAnalysis();
  }

  void selectLedgerTab(int index) {
    if (ledgerTab.value == index) return;
    suppressHeaderAnimation.value = true;
    waterFilterExpanded.value = 0;
    ledgerTab.value = index;
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      suppressHeaderAnimation.value = false;
    });
    if (index == 1 && bookWaterPage.value.list.isEmpty) {
      getBookWaterPage();
    }
    if (index == 2) getBookAnalysis();
  }

  void toggleWaterFilter(int index) {
    ledgerTypeExpanded.value = false;
    waterLastFilter.value = index;
    waterFilterExpanded.value = waterFilterExpanded.value == index ? 0 : index;
  }

  void closeWaterFilter() => waterFilterExpanded.value = 0;

  void selectWaterPeriod(String label) {
    waterPeriodLabel.value = label;
    final now = _dateOnly(DateTime.now());
    waterEndTime.value = now;
    waterBeginTime.value = switch (label) {
      '近7天' => now.subtract(const Duration(days: 7)),
      '近一个月' => now.subtract(const Duration(days: 30)),
      '近三个月' => now.subtract(const Duration(days: 90)),
      '近半年' => now.subtract(const Duration(days: 180)),
      '近一年' => now.subtract(const Duration(days: 365)),
      _ => null,
    };
    closeWaterFilter();
    getBookWaterPage();
  }

  void selectAnalysisPeriod(String label) {
    analysisPeriodLabel.value = label;
    final now = _dateOnly(DateTime.now());
    analysisEndTime.value = now;
    analysisBeginTime.value = switch (label) {
      '近7天' => now.subtract(const Duration(days: 7)),
      '近一个月' => now.subtract(const Duration(days: 30)),
      '近三个月' => now.subtract(const Duration(days: 90)),
      '近半年' => now.subtract(const Duration(days: 180)),
      '近一年' => now.subtract(const Duration(days: 365)),
      _ => null,
    };
    closeWaterFilter();
    getBookAnalysis();
  }

  void selectAnalysisPeriodSelection(int mode, DateTime begin, DateTime end) {
    if (mode == 2) {
      analysisBeginTime.value = _dateOnly(begin);
      analysisEndTime.value = _dateOnly(end);
      analysisPeriodLabel.value = '${_formatDate(begin)}至${_formatDate(end)}';
    } else {
      analysisBeginTime.value = null;
      analysisEndTime.value = null;
      periodMode.value = mode;
      selectedPeriod.value = DateTime(begin.year, mode == 1 ? 1 : begin.month);
      analysisPeriodLabel.value = '';
    }
    closeWaterFilter();
    getBookAnalysis();
  }

  void selectAnalysisAccount(String account) {
    analysisAccount.value = account;
    closeWaterFilter();
    getBookAnalysis();
  }

  void selectAnalysisIncomeExpenseType(int type) {
    if (analysisIncomeExpenseType.value == type) return;
    analysisIncomeExpenseType.value = type;
    getBookAnalysis();
  }

  void selectWaterCustomPeriod(DateTime beginTime, DateTime endTime) {
    final begin = _dateOnly(beginTime);
    final end = _dateOnly(endTime);
    waterPeriodLabel.value = '${_formatDate(begin)}至${_formatDate(end)}';
    waterBeginTime.value = begin;
    waterEndTime.value = end;
    closeWaterFilter();
    getBookWaterPage();
  }

  void selectWaterAccount(String account) {
    waterAccount.value = account;
    closeWaterFilter();
    getBookWaterPage();
  }

  void selectWaterAmount(String amount) {
    waterAmountFilter.value = amount;
  }

  void resetWaterAmount() {
    waterAmountFilter.value = '';
    waterMinAmount.value = '';
    waterMaxAmount.value = '';
    waterAmountInputVersion.value++;
  }

  void applyWaterAmount() {
    closeWaterFilter();
    getBookWaterPage();
  }

  void selectPeriodMode(int index) {
    periodMode.value = index;
    getOverView();
    getBookDetailPage();
  }

  void selectPeriod({required int year, required int month}) {
    waterPeriodLabel.value = '';
    selectedPeriod.value = DateTime(year, month);
    getOverView();
    getBookDetailPage();
  }

  Future<void> refreshLedger(RefreshController refreshController) async {
    try {
      if (identical(refreshController, state.overviewRefreshController)) {
        await Future.wait([getOverView(), getBookDetailPage()]);
      } else {
        await getBookWaterPage();
      }
    } finally {
      refreshController
        ..resetNoData()
        ..refreshCompleted();
    }
  }

  Future<void> loadMoreLedger(RefreshController refreshController) async {
    if (identical(refreshController, state.overviewRefreshController)) {
      final hasMore = await getBookDetailPage(loadMore: true);
      hasMore
          ? refreshController.loadComplete()
          : refreshController.loadNoData();
      return;
    }
    final hasMore = await getBookWaterPage(loadMore: true);
    hasMore ? refreshController.loadComplete() : refreshController.loadNoData();
  }

  Future<void> getOverView() async {
    if (token == '') return;
    final selected = selectedPeriod.value;
    final isYear = periodMode.value == 1;
    final period = isYear
        ? '${selected.year}'
        : '${selected.year}-${selected.month.toString().padLeft(2, '0')}';
    final value = await Http.post(
      Apis.bookOverView,
      data: {
        'bookType': ledgerTypeList[ledgerType.value]['name'],
        'periodType': isYear ? '年度' : '月度',
        'period': period,
      },
      isLoading: false,
    );
    if (value is Map) {
      bookOverview.value =
          BookOverviewModel.fromJson(Map<String, dynamic>.from(value));
    }
  }

  Future<bool> getBookDetailPage({bool loadMore = false}) async {
    if (token == '') return false;
    final current = bookDetailPage.value;
    if (loadMore && current.pages > 0 && _bookDetailPageNum >= current.pages) {
      return false;
    }

    final selected = selectedPeriod.value;
    final isYear = periodMode.value == 1;
    final pageNum = loadMore ? _bookDetailPageNum + 1 : 1;
    final period = isYear
        ? '${selected.year}'
        : '${selected.year}-${selected.month.toString().padLeft(2, '0')}';
    final value = await Http.post(
      Apis.bookDetailPage,
      data: {
        'pageNum': pageNum,
        'pageSize': 10,
        'bookType': ledgerTypeList[ledgerType.value]['name'],
        'type': isYear ? '年' : '月',
        'period': period,
      },
      isLoading: false,
    );
    if (value is! Map) return false;

    final result = BillItemModel.fromJson(Map<String, dynamic>.from(value));
    final previousMonth = loadMore
        ? current.list
            .map((item) => item.month)
            .lastWhere((value) => value.isNotEmpty, orElse: () => '')
        : '';
    final previousDay = loadMore
        ? current.list
            .map((item) => item.day)
            .lastWhere((value) => value.isNotEmpty, orElse: () => '')
        : '';
    _normalizeBookDetailHeaders(
      result.list,
      previousMonth: previousMonth,
      previousDay: previousDay,
    );
    if (loadMore) {
      result.list = [...current.list, ...result.list];
    }
    _bookDetailPageNum = pageNum;
    bookDetailPage.value = result;
    if (!loadMore) {
      state.overviewRefreshController.resetNoData();
    }
    return result.pages > pageNum;
  }

  void _normalizeBookDetailHeaders(
    List<BillItemList> list, {
    required String previousMonth,
    required String previousDay,
    bool hideMonthWhenMonthly = true,
  }) {
    var month = previousMonth;
    var day = previousDay;
    for (final item in list) {
      final rawMonth = item.month;
      final rawDay = item.day;
      if (rawMonth.isNotEmpty) {
        if (rawMonth == month ||
            (hideMonthWhenMonthly && periodMode.value != 1)) {
          item.month = '';
        } else {
          month = rawMonth;
          day = '';
        }
      }
      if (rawDay.isNotEmpty) {
        if (rawDay == day) {
          item.day = '';
        } else {
          day = rawDay;
        }
      }
    }
  }

  Future<bool> getBookWaterPage({bool loadMore = false}) async {
    if (token == '') return false;
    final current = bookWaterPage.value;
    if (loadMore && current.pages > 0 && _bookWaterPageNum >= current.pages) {
      return false;
    }

    final pageNum = loadMore ? _bookWaterPageNum + 1 : 1;
    final params = <String, dynamic>{
      'pageNum': pageNum,
      'pageSize': 10,
      'bookType': ledgerTypeList[ledgerType.value]['name'],
    };
    final begin = waterBeginTime.value;
    final end = waterEndTime.value;
    if (begin != null || end != null) {
      if (begin != null) params['beginTime'] = _formatDate(begin);
      if (end != null) params['endTime'] = _formatDate(end);
    } else {
      final selected = selectedPeriod.value;
      final isYear = periodMode.value == 1;
      params['type'] = isYear ? '年' : '月';
      params['period'] = isYear
          ? '${selected.year}'
          : '${selected.year}-${selected.month.toString().padLeft(2, '0')}';
    }

    final account = waterAccount.value;
    if (account == '手工记账') {
      params['bankCard'] = '手工记账';
    } else if (account != '全部账户') {
      final card = AppConfig.config.abcLogic.card1();
      if (card != '--' && card.isNotEmpty) params['bankCard'] = card;
    }
    _appendWaterAmountParams(params);

    final value = await Http.post(
      Apis.bookDetailPage,
      data: params,
      isLoading: false,
    );
    if (value is! Map) return false;

    final result = BillItemModel.fromJson(Map<String, dynamic>.from(value));
    final previousMonth = loadMore
        ? current.list.map((e) => e.month).lastWhere(
              (value) => value.isNotEmpty,
              orElse: () => '',
            )
        : '';
    final previousDay = loadMore
        ? current.list.map((e) => e.day).lastWhere(
              (value) => value.isNotEmpty,
              orElse: () => '',
            )
        : '';
    _normalizeBookDetailHeaders(
      result.list,
      previousMonth: previousMonth,
      previousDay: previousDay,
      hideMonthWhenMonthly: false,
    );
    if (loadMore) result.list = [...current.list, ...result.list];
    _bookWaterPageNum = pageNum;
    bookWaterPage.value = result;
    if (!loadMore) state.waterRefreshController.resetNoData();
    return result.pages > pageNum;
  }

  void _appendWaterAmountParams(Map<String, dynamic> params) {
    switch (waterAmountFilter.value) {
      case '100以内':
        params['maxAmount'] = 100;
        break;
      case '100-1千':
        params['minAmount'] = 100;
        params['maxAmount'] = 1000;
        break;
      case '1千-1万':
        params['minAmount'] = 1000;
        params['maxAmount'] = 10000;
        break;
      case '1万以上':
        params['minAmount'] = 10000;
        break;
      case '自定义':
        final min = double.tryParse(waterMinAmount.value.trim());
        final max = double.tryParse(waterMaxAmount.value.trim());
        if (min != null) params['minAmount'] = min;
        if (max != null) params['maxAmount'] = max;
        break;
    }
  }

  Future<void> getBookAnalysis() async {
    if (token == '') return;
    final params = <String, dynamic>{
      'bookType': ledgerTypeList[ledgerType.value]['name'],
      'incomeExpenseType': analysisIncomeExpenseType.value,
    };
    final begin = analysisBeginTime.value;
    final end = analysisEndTime.value;
    if (begin != null && end != null) {
      params['dateType'] = '自定义';
      params['beginTime'] = _formatDate(begin);
      params['endTime'] = _formatDate(end);
    } else {
      final selected = selectedPeriod.value;
      final isYear = periodMode.value == 1;
      params['dateType'] = isYear ? '年' : '月';
      params['period'] = isYear
          ? '${selected.year}'
          : '${selected.year}-${selected.month.toString().padLeft(2, '0')}';
    }
    final account = analysisAccount.value;
    if (account == '手工记账') {
      params['bankCard'] = '手工记账';
    } else if (account != '全部账户') {
      final card = AppConfig.config.abcLogic.card1();
      if (card != '--' && card.isNotEmpty) params['bankCard'] = card;
    }
    final value =
        await Http.post(Apis.bookAnalysis, data: params, isLoading: false);
    if (value is Map) {
      bookAnalysis.value =
          BookAnalysisModel.fromJson(Map<String, dynamic>.from(value));
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _formatDate(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  @override
  void onInit() {
    super.onInit();
    getOverView();
    getBookDetailPage();
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
