import 'package:get/get.dart';

import 'user_invest_info_state.dart';

class UserInvestInfoLogic extends GetxController {
  static const List<String> incomeSources = [
    '工资、劳务报酬',
    '生产经营所得',
    '利息、股息、转让等金融性资产收入',
    '出租、出售房地产等非金融性资产收入',
    '无固定收入',
  ];

  static const List<String> annualIncomes = [
    '5万以下',
    '5（含）-10万',
    '10（含）-30万',
    '30（含）-50万',
    '50（含）-100万',
    '100（含）-300万',
    '300（含）-500万',
    '500万以上',
  ];

  static const List<String> investmentExperiences = ['是', '否'];

  static const List<String> debtOptions = [
    '没有',
    '有，住房抵押贷款等长期定额债务',
    '有，信用卡欠款、消费信贷等短期信用债务',
    '有，亲戚朋友借款',
  ];

  final UserInvestInfoState state = UserInvestInfoState();

  void selectIncomeSource(String value) {
    if (incomeSources.contains(value)) {
      state.incomeSource.value = value;
    }
  }

  void selectAnnualIncome(String value) {
    if (annualIncomes.contains(value)) {
      state.annualIncome.value = value;
    }
  }

  void selectInvestmentExperience(String value) {
    if (investmentExperiences.contains(value)) {
      state.investmentExperience.value = value;
    }
  }

  void selectDebts(Iterable<String> values) {
    final selected = values.toSet();
    if (selected.contains(debtOptions.first)) {
      state.debts.assignAll([debtOptions.first]);
      return;
    }
    state.debts.assignAll(
      debtOptions.where((option) => selected.contains(option)),
    );
  }

  String get debtDisplayValue {
    if (state.debts.isEmpty) return '';
    return state.debts.contains(debtOptions.first) ? '没有' : '有';
  }
}
