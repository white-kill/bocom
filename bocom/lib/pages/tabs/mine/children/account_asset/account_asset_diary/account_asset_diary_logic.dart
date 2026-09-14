import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'account_asset_diary_state.dart';

class AssetDiaryEntry {
  const AssetDiaryEntry({required this.date, required this.amount});
  final DateTime date;
  final double amount;
}

class AccountAssetDiaryLogic extends GetxController {
  AccountAssetDiaryLogic({List<AssetDiaryEntry>? entries, DateTime? now})
      : updatedAt = now ?? DateTime.now() {
    // 演示数据仅用于接口接入前的页面展示；接口接入后传入每日资产记录。
    final today = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
    data = entries ?? List.generate(366, (index) => AssetDiaryEntry(
      date: today.subtract(Duration(days: 365 - index)),
      amount: 138.80,
    ));
    data.sort((a, b) => a.date.compareTo(b.date));
    if (data.isNotEmpty) selectedDate.value = data.last.date;
  }

  final AccountAssetDiaryState state = AccountAssetDiaryState();
  final navActionColor = Colors.black.obs;
  final navActionFlag = false.obs;

  void onNavChange(bool changed) {
    navActionFlag.value = changed;
    navActionColor.value = Colors.black;
  }

  final DateTime updatedAt;
  late final List<AssetDiaryEntry> data;
  final rangeIndex = 0.obs;
  final selectedDate = DateTime.now().obs;
  final compareToday = false.obs;

  List<AssetDiaryEntry> get visibleEntries {
    if (data.isEmpty) return [];
    final end = data.last.date;
    final days = [30, 90, 365][rangeIndex.value];
    final start = end.subtract(Duration(days: days - 1));
    return data.where((entry) => !entry.date.isBefore(start)).toList();
  }

  int get selectedIndex {
    final index = visibleEntries.indexWhere((e) => e.date == selectedDate.value);
    return index < 0 ? 0 : index;
  }

  AssetDiaryEntry? get selected => visibleEntries.isEmpty ? null : visibleEntries[selectedIndex];
  double get amount => selected?.amount ?? 0;
  double get todayAmount => data.isEmpty ? 0 : data.last.amount;
  double get change {
    final index = data.indexWhere((e) => e.date == selectedDate.value);
    return index > 0 ? data[index].amount - data[index - 1].amount : 0;
  }

  void selectRange(int index) {
    rangeIndex.value = index;
    final entries = visibleEntries;
    if (entries.isNotEmpty && !entries.any((e) => e.date == selectedDate.value)) {
      selectedDate.value = entries.last.date;
    }
  }

  void selectIndex(int index) {
    final entries = visibleEntries;
    if (index >= 0 && index < entries.length) selectedDate.value = entries[index].date;
  }

  void selectDate(DateTime date) {
    for (final entry in visibleEntries) {
      if (entry.date.year == date.year && entry.date.month == date.month && entry.date.day == date.day) {
        selectedDate.value = entry.date;
        return;
      }
    }
  }
}
