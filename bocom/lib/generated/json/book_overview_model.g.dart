import 'package:bocom/config/model/book_overview_model.dart';
import 'package:bocom/generated/json/base/json_convert_content.dart';

BookOverviewModel $BookOverviewModelFromJson(Map<String, dynamic> json) {
  final model = BookOverviewModel();
  model.bookType = jsonConvert.convert<String>(json['bookType']) ?? '';
  model.periodType = jsonConvert.convert<String>(json['periodType']) ?? '';
  model.period = jsonConvert.convert<String>(json['period']) ?? '';
  model.billCount = jsonConvert.convert<int>(json['billCount']) ?? 0;
  model.incomeTotal = jsonConvert.convert<String>(json['incomeTotal']) ?? '';
  model.expensesTotal = jsonConvert.convert<String>(json['expensesTotal']) ?? '';
  model.balance = jsonConvert.convert<String>(json['balance']) ?? '';
  model.lastThreeMonthAverageExpenses =
      jsonConvert.convert<String>(json['lastThreeMonthAverageExpenses']) ?? '';
  model.trendUnit = jsonConvert.convert<String>(json['trendUnit']) ?? '';
  model.trendStartTime =
      jsonConvert.convert<String>(json['trendStartTime']) ?? '';
  model.trendEndTime =
      jsonConvert.convert<String>(json['trendEndTime']) ?? '';
  model.trendList = (json['trendList'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map(BookOverviewTrendList.fromJson)
          .toList() ??
      [];
  return model;
}

Map<String, dynamic> $BookOverviewModelToJson(BookOverviewModel entity) => {
      'bookType': entity.bookType,
      'periodType': entity.periodType,
      'period': entity.period,
      'billCount': entity.billCount,
      'incomeTotal': entity.incomeTotal,
      'expensesTotal': entity.expensesTotal,
      'balance': entity.balance,
      'lastThreeMonthAverageExpenses': entity.lastThreeMonthAverageExpenses,
      'trendUnit': entity.trendUnit,
      'trendStartTime': entity.trendStartTime,
      'trendEndTime': entity.trendEndTime,
      'trendList': entity.trendList.map((item) => item.toJson()).toList(),
    };

BookOverviewTrendList $BookOverviewTrendListFromJson(
    Map<String, dynamic> json) {
  return BookOverviewTrendList()
    ..dateTime = jsonConvert.convert<String>(json['dateTime']) ?? ''
    ..incomeTotal = jsonConvert.convert<String>(json['incomeTotal']) ?? ''
    ..expensesTotal = jsonConvert.convert<String>(json['expensesTotal']) ?? '';
}

Map<String, dynamic> $BookOverviewTrendListToJson(
        BookOverviewTrendList entity) =>
    {
      'dateTime': entity.dateTime,
      'incomeTotal': entity.incomeTotal,
      'expensesTotal': entity.expensesTotal,
    };
