import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/model/comprehensive_asset_overview_model.dart';
import 'package:bocom/config/model/comprehensive_income_expense_model.dart';
import 'package:bocom/config/net_config/apis.dart';

import 'comprehensive_bill_state.dart';

class ComprehensiveBillLogic extends GetxController {
  final state = ComprehensiveBillState();
  final scrollController = ScrollController();
  final tabController = ScrollController();
  final selectedIndex = 0.obs;
  final periodMode = 0.obs;
  final selectedPeriod =
      DateTime(DateTime.now().year, DateTime.now().month).obs;
  final periodPickerVisible = false.obs;
  final headerScrolled = false.obs;
  final cashFlowPage = 0.obs;
  final cashFlowDetailType = 0.obs;
  final billSwitchIndex = 0.obs;
  final assetOverview = ComprehensiveAssetOverviewModel().obs;
  final assetOverviewLoading = false.obs;
  final selectedAssetTrendIndex = (-1).obs;
  final incomeExpenseOverview = ComprehensiveIncomeExpenseModel().obs;
  final incomeExpenseOverviewLoading = false.obs;
  int _assetOverviewRequestVersion = 0;
  int _incomeExpenseRequestVersion = 0;
  bool _scrollingToAnchor = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_updateSelectedTab);
    getAssetOverview();
    getIncomeExpenseOverview();
  }

  Future<void> scrollTo(int index) async {
    final context = state.sectionKeys[index].currentContext;
    if (context == null) return;
    _scrollingToAnchor = true;
    _select(index);
    await Scrollable.ensureVisible(context,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        alignment: .02);
    _scrollingToAnchor = false;
  }

  void _updateSelectedTab() {
    final scrolled = scrollController.hasClients &&
        scrollController.offset > 0;
    if (headerScrolled.value != scrolled) {
      headerScrolled.value = scrolled;
    }
    if (_scrollingToAnchor) return;
    var current = 0;
    for (var i = 0; i < state.sectionKeys.length; i++) {
      final render = state.sectionKeys[i].currentContext?.findRenderObject();
      if (render is RenderBox && render.localToGlobal(Offset.zero).dy <= 150.w) {
        current = i;
      }
    }
    _select(current);
  }

  void _select(int index) {
    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
    final context = state.tabKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 220), alignment: .5);
    }
  }

  void selectPeriodMode(int index) {
    if (periodMode.value == index) return;
    periodMode.value = index;
    cashFlowPage.value = 0;
    getAssetOverview();
    getIncomeExpenseOverview();
  }

  void selectPeriod({required int year, required int month}) {
    selectedPeriod.value = DateTime(year, month);
    getAssetOverview();
    getIncomeExpenseOverview();
  }

  Future<void> getAssetOverview() async {
    final requestVersion = ++_assetOverviewRequestVersion;
    final selected = selectedPeriod.value;
    final isYearMode = periodMode.value == 1;
    assetOverviewLoading.value = true;
    try {
      final value = await Http.post(
        Apis.comprehensiveAssetOverview,
        data: {
          'dateType': isYearMode ? '年' : '月',
          'period': isYearMode
              ? '${selected.year}'
              : '${selected.year}-${selected.month.toString().padLeft(2, '0')}',
        },
        isLoading: false,
      );
      if (requestVersion != _assetOverviewRequestVersion || value is! Map) {
        return;
      }
      assetOverview.value = ComprehensiveAssetOverviewModel.fromJson(
          Map<String, dynamic>.from(value));
      final trendCount = assetOverview.value.trendList
          .where((item) =>
              item.dateTime != null &&
              double.tryParse(item.assetBalance ?? '') != null)
          .length;
      selectedAssetTrendIndex.value = trendCount - 1;
    } catch (_) {
      if (requestVersion == _assetOverviewRequestVersion) {
        assetOverview.value = ComprehensiveAssetOverviewModel();
        selectedAssetTrendIndex.value = -1;
      }
    } finally {
      if (requestVersion == _assetOverviewRequestVersion) {
        assetOverviewLoading.value = false;
      }
    }
  }

  Future<void> getIncomeExpenseOverview() async {
    final requestVersion = ++_incomeExpenseRequestVersion;
    final selected = selectedPeriod.value;
    final isYearMode = periodMode.value == 1;
    incomeExpenseOverviewLoading.value = true;
    try {
      final value = await Http.post(
        Apis.comprehensiveIncomeExpenseOverview,
        data: {
          'dateType': isYearMode ? '年' : '月',
          'period': isYearMode
              ? '${selected.year}'
              : '${selected.year}-${selected.month.toString().padLeft(2, '0')}',
        },
        isLoading: false,
      );
      if (requestVersion != _incomeExpenseRequestVersion || value is! Map) {
        return;
      }
      final result = ComprehensiveIncomeExpenseModel.fromJson(
          Map<String, dynamic>.from(value));
      incomeExpenseOverview.value = result;
      cashFlowPage.value =
          (result.trendList.length - 3).clamp(0, result.trendList.length).toInt();
    } catch (_) {
      if (requestVersion == _incomeExpenseRequestVersion) {
        incomeExpenseOverview.value = ComprehensiveIncomeExpenseModel();
        cashFlowPage.value = 0;
      }
    } finally {
      if (requestVersion == _incomeExpenseRequestVersion) {
        incomeExpenseOverviewLoading.value = false;
      }
    }
  }

  void previousCashFlowPage() {
    if (cashFlowPage.value > 0) cashFlowPage.value--;
  }

  void nextCashFlowPage(int itemCount) {
    final lastStartIndex = (itemCount - 3).clamp(0, itemCount).toInt();
    if (cashFlowPage.value < lastStartIndex) cashFlowPage.value++;
  }

  void selectCashFlowDetailType(int index) {
    cashFlowDetailType.value = index;
  }

  void selectBillType(int index) {
    if (index < 0 || index > 2) return;
    billSwitchIndex.value = index;
  }

  @override
  void onClose() {
    scrollController.dispose();
    tabController.dispose();
    super.onClose();
  }
}
