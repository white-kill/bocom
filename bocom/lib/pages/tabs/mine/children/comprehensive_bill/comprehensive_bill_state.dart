import 'package:flutter/material.dart';

class ComprehensiveBillState {
  final titles = const ['资产概览', '投资收益', '收支', '信用卡', '礼券红包', '社区互动', '我的足迹'];
  late final sectionKeys = List.generate(titles.length, (_) => GlobalKey());
  late final tabKeys = List.generate(titles.length, (_) => GlobalKey());
}

class CashFlowItem {
  const CashFlowItem(this.label, this.income, this.expense);

  final String label;
  final double income;
  final double expense;
}
