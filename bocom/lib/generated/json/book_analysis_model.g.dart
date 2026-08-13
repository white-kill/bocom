import 'package:bocom/config/model/book_analysis_model.dart';
import 'package:bocom/generated/json/base/json_convert_content.dart';

String _string(dynamic value) => value?.toString() ?? '';

BookAnalysisModel $BookAnalysisModelFromJson(Map<String, dynamic> json) {
  final model = BookAnalysisModel();
  model.bookType = _string(json['bookType']);
  model.dateType = _string(json['dateType']);
  model.period = _string(json['period']);
  model.incomeExpenseType =
      jsonConvert.convert<int>(json['incomeExpenseType']) ?? 2;
  model.billCount = jsonConvert.convert<int>(json['billCount']) ?? 0;
  model.totalAmount = _string(json['totalAmount']);
  model.comparedPrevious = _string(json['comparedPrevious']);
  model.categoryList = (json['categoryList'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) =>
              BookAnalysisCategoryList.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      [];
  model.incomeBillCount =
      jsonConvert.convert<int>(json['incomeBillCount']) ?? 0;
  model.incomeTotal = _string(json['incomeTotal']);
  model.incomeComparedPrevious = _string(json['incomeComparedPrevious']);
  model.expenseBillCount =
      jsonConvert.convert<int>(json['expenseBillCount']) ?? 0;
  model.expensesTotal = _string(json['expensesTotal']);
  model.expensesComparedPrevious = _string(json['expensesComparedPrevious']);
  model.balance = _string(json['balance']);
  model.balanceComparedPrevious = _string(json['balanceComparedPrevious']);
  model.trendList = (json['trendList'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) =>
              BookAnalysisTrendList.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      [];
  model.incomeRankList = _rankList(json['incomeRankList']);
  model.expenseRankList = _rankList(json['expenseRankList']);
  return model;
}

List<BookAnalysisRankList> _rankList(dynamic value) =>
    (value as List<dynamic>?)
        ?.whereType<Map>()
        .map((e) => BookAnalysisRankList.fromJson(Map<String, dynamic>.from(e)))
        .toList() ??
    [];

Map<String, dynamic> $BookAnalysisModelToJson(BookAnalysisModel e) => {
      'bookType': e.bookType,
      'dateType': e.dateType,
      'period': e.period,
      'incomeExpenseType': e.incomeExpenseType,
      'billCount': e.billCount,
      'totalAmount': e.totalAmount,
      'comparedPrevious': e.comparedPrevious,
      'categoryList': e.categoryList.map((x) => x.toJson()).toList(),
      'incomeBillCount': e.incomeBillCount,
      'incomeTotal': e.incomeTotal,
      'incomeComparedPrevious': e.incomeComparedPrevious,
      'expenseBillCount': e.expenseBillCount,
      'expensesTotal': e.expensesTotal,
      'expensesComparedPrevious': e.expensesComparedPrevious,
      'balance': e.balance,
      'balanceComparedPrevious': e.balanceComparedPrevious,
      'trendList': e.trendList.map((x) => x.toJson()).toList(),
      'incomeRankList': e.incomeRankList.map((x) => x.toJson()).toList(),
      'expenseRankList': e.expenseRankList.map((x) => x.toJson()).toList(),
    };

BookAnalysisCategoryList $BookAnalysisCategoryListFromJson(
        Map<String, dynamic> json) =>
    BookAnalysisCategoryList()
      ..categoryName = _string(json['categoryName'])
      ..icon = _string(json['icon'])
      ..billCount = jsonConvert.convert<int>(json['billCount']) ?? 0
      ..amount = _string(json['amount'])
      ..percentage = _string(json['percentage']);
Map<String, dynamic> $BookAnalysisCategoryListToJson(
        BookAnalysisCategoryList e) =>
    {
      'categoryName': e.categoryName,
      'icon': e.icon,
      'billCount': e.billCount,
      'amount': e.amount,
      'percentage': e.percentage,
    };

BookAnalysisTrendList $BookAnalysisTrendListFromJson(
        Map<String, dynamic> json) =>
    BookAnalysisTrendList()
      ..dateTime = _string(json['dateTime'])
      ..incomeTotal = _string(json['incomeTotal'])
      ..expensesTotal = _string(json['expensesTotal']);
Map<String, dynamic> $BookAnalysisTrendListToJson(BookAnalysisTrendList e) => {
      'dateTime': e.dateTime,
      'incomeTotal': e.incomeTotal,
      'expensesTotal': e.expensesTotal,
    };

BookAnalysisRankList $BookAnalysisRankListFromJson(Map<String, dynamic> json) =>
    BookAnalysisRankList()
      ..rank = jsonConvert.convert<int>(json['rank']) ?? 0
      ..id = jsonConvert.convert<int>(json['id']) ?? 0
      ..excerpt = _string(json['excerpt'])
      ..amount = _string(json['amount'])
      ..transactionTime = _string(json['transactionTime'])
      ..type = jsonConvert.convert<int>(json['type']) ?? 0
      ..bankCardText = _string(json['bankCardText']);
Map<String, dynamic> $BookAnalysisRankListToJson(BookAnalysisRankList e) => {
      'rank': e.rank,
      'id': e.id,
      'excerpt': e.excerpt,
      'amount': e.amount,
      'transactionTime': e.transactionTime,
      'type': e.type,
      'bankCardText': e.bankCardText,
    };
