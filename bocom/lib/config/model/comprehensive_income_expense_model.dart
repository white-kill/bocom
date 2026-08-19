class ComprehensiveIncomeExpenseModel {
  ComprehensiveIncomeExpenseModel({
    this.dateType,
    this.period,
    this.incomeTotal,
    this.expensesTotal,
    this.balance,
    this.balanceComparedPrevious,
    this.incomeBillCount,
    this.expenseBillCount,
    this.incomeComparedPrevious,
    this.expensesComparedPrevious,
    this.trendUnit,
    this.trendList = const [],
    this.incomeCategoryList = const [],
    this.expenseCategoryList = const [],
  });

  final String? dateType;
  final String? period;
  final String? incomeTotal;
  final String? expensesTotal;
  final String? balance;
  final String? balanceComparedPrevious;
  final int? incomeBillCount;
  final int? expenseBillCount;
  final String? incomeComparedPrevious;
  final String? expensesComparedPrevious;
  final String? trendUnit;
  final List<ComprehensiveIncomeExpenseTrendItem> trendList;
  final List<ComprehensiveBillCategoryItem> incomeCategoryList;
  final List<ComprehensiveBillCategoryItem> expenseCategoryList;

  factory ComprehensiveIncomeExpenseModel.fromJson(Map<String, dynamic> json) {
    return ComprehensiveIncomeExpenseModel(
      dateType: _asString(json['dateType']),
      period: _asString(json['period']),
      incomeTotal: _asString(json['incomeTotal']),
      expensesTotal: _asString(json['expensesTotal']),
      balance: _asString(json['balance']),
      balanceComparedPrevious: _asString(json['balanceComparedPrevious']),
      incomeBillCount: _asInt(json['incomeBillCount']),
      expenseBillCount: _asInt(json['expenseBillCount']),
      incomeComparedPrevious: _asString(json['incomeComparedPrevious']),
      expensesComparedPrevious: _asString(json['expensesComparedPrevious']),
      trendUnit: _asString(json['trendUnit']),
      trendList: _list(json['trendList'],
          (item) => ComprehensiveIncomeExpenseTrendItem.fromJson(item)),
      incomeCategoryList: _list(json['incomeCategoryList'],
          (item) => ComprehensiveBillCategoryItem.fromJson(item)),
      expenseCategoryList: _list(json['expenseCategoryList'],
          (item) => ComprehensiveBillCategoryItem.fromJson(item)),
    );
  }
}

class ComprehensiveIncomeExpenseTrendItem {
  const ComprehensiveIncomeExpenseTrendItem({
    this.dateTime,
    this.incomeTotal,
    this.expensesTotal,
  });

  final String? dateTime;
  final String? incomeTotal;
  final String? expensesTotal;

  factory ComprehensiveIncomeExpenseTrendItem.fromJson(
          Map<String, dynamic> json) =>
      ComprehensiveIncomeExpenseTrendItem(
        dateTime: _asString(json['dateTime']),
        incomeTotal: _asString(json['incomeTotal']),
        expensesTotal: _asString(json['expensesTotal']),
      );
}

class ComprehensiveBillCategoryItem {
  const ComprehensiveBillCategoryItem({
    this.categoryName,
    this.icon,
    this.billCount,
    this.amount,
    this.percentage,
  });

  final String? categoryName;
  final String? icon;
  final int? billCount;
  final String? amount;
  final String? percentage;

  factory ComprehensiveBillCategoryItem.fromJson(Map<String, dynamic> json) =>
      ComprehensiveBillCategoryItem(
        categoryName: _asString(json['categoryName']),
        icon: _asString(json['icon']),
        billCount: _asInt(json['billCount']),
        amount: _asString(json['amount']),
        percentage: _asString(json['percentage']),
      );
}

List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) convert) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((item) => convert(Map<String, dynamic>.from(item)))
      .toList();
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final result = value.toString();
  return result.isEmpty ? null : result;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
