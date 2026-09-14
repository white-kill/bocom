import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:bocom/config/model/asset_diary_model.dart';
import 'account_asset_diary_state.dart';
import 'package:bocom/pages/component/indicator_loading.dart';
export 'package:bocom/config/model/asset_diary_model.dart' show AssetDiaryEntry;

class AccountAssetDiaryLogic extends GetxController {
  final AccountAssetDiaryState state = AccountAssetDiaryState();
  final navActionColor = Colors.black.obs;
  final navActionFlag = false.obs;
  final rangeIndex = 0.obs;
  final selectedDate = DateUtils.dateOnly(DateTime.now()).obs;
  final compareToday = false.obs;
  final data = <AssetDiaryEntry>[].obs;
  final detail = Rxn<AssetDiaryModel>();
  final currentDay = Rxn<AssetDiaryModel>();
  final loadingTrend = false.obs;
  final loadingDetail = false.obs;
  final loadFailed = false.obs;
  int _requestVersion = 0;
  static const ranges = ['近1月', '近3月', '近1年'];

  void onNavChange(bool changed) {
    navActionFlag.value = changed;
    navActionColor.value = Colors.black;
  }

  List<AssetDiaryEntry> get visibleEntries => data.toList();
  int get selectedIndex {
    final index = data.indexWhere((e) => DateUtils.isSameDay(e.date, selectedDate.value));
    return index < 0 ? 0 : index;
  }
  double? get amount => detail.value?.totalAssets;
  double? get availableBalance => detail.value?.availableBalance;
  double? get todayAmount => currentDay.value?.availableBalance;
  double? get comparisonChange => todayAmount == null || availableBalance == null
      ? null : todayAmount! - availableBalance!;
  double? get change => detail.value?.changeAmount;
  DateTime? get updatedAt => currentDay.value?.dataUpdateTime;

  @override
  void onReady() {
    super.onReady();
    loadTrend();
  }

  Future<void> loadTrend() async {
    final today = DateUtils.dateOnly(DateTime.now());
    selectedDate.value = today;
    await _load(today, updateTrend: true);
  }

  Future<void> _load(DateTime date, {required bool updateTrend}) async {
    final version = ++_requestVersion;
    final range = ranges[rangeIndex.value];
    loadingTrend.value = updateTrend;
    loadingDetail.value = true;
    loadFailed.value = false;
    detail.value = null;
    if (updateTrend) {
      data.clear();
      currentDay.value = null;
    }
    try {
      Future<dynamic> request() => Http.post(Apis.assetDiary, data: {
        'queryDate': DateFormat('yyyy-MM-dd').format(date),
        'rangeType': range,
      }, isLoading: false);
      final context = Get.overlayContext;
      final value = context == null
          ? await request()
          : await BocomLoading.run(context, request);
      if (version != _requestVersion || isClosed) return;
      if (value is! Map) throw const FormatException('Invalid asset diary response');
      final result = AssetDiaryModel.fromJson(Map<String, dynamic>.from(value));
      detail.value = result;
      if (updateTrend) {
        final today = DateUtils.dateOnly(DateTime.now());
        data.assignAll(result.trendList.where((entry) =>
            !entry.date.isAfter(today) &&
            (result.trendStartDate == null || !entry.date.isBefore(result.trendStartDate!)) &&
            (result.trendEndDate == null || !entry.date.isAfter(result.trendEndDate!))));
        currentDay.value = result;
        selectedDate.value = result.queryDate ?? date;
      }
    } catch (_) {
      if (version == _requestVersion && !isClosed) loadFailed.value = true;
    } finally {
      if (version == _requestVersion && !isClosed) {
        loadingTrend.value = false;
        loadingDetail.value = false;
      }
    }
  }

  void selectRange(int index) {
    if (index < 0 || index >= ranges.length || (rangeIndex.value == index && !loadFailed.value)) return;
    rangeIndex.value = index;
    loadTrend();
  }

  void selectIndex(int index) {
    if (loadingTrend.value || index < 0 || index >= data.length) return;
    selectDate(data[index].date);
  }

  void selectDate(DateTime date) {
    if (loadingTrend.value || !data.any((e) => DateUtils.isSameDay(e.date, date))) return;
    if (DateUtils.isSameDay(date, selectedDate.value) && !loadFailed.value) return;
    selectedDate.value = DateUtils.dateOnly(date);
    _load(selectedDate.value, updateTrend: false);
  }

  void retry() {
    if (data.isEmpty) {
      loadTrend();
    } else {
      _load(selectedDate.value, updateTrend: false);
    }
  }

  @override
  void onClose() {
    _requestVersion++;
    super.onClose();
  }
}
