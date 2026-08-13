import 'dart:convert';

import 'package:bocom/generated/json/base/json_field.dart';
import 'package:bocom/generated/json/book_overview_model.g.dart';

export 'package:bocom/generated/json/book_overview_model.g.dart';

@JsonSerializable()
class BookOverviewModel {
  String bookType = '';
  String periodType = '';
  String period = '';
  int billCount = 0;
  String incomeTotal = '';
  String expensesTotal = '';
  String balance = '';
  String lastThreeMonthAverageExpenses = '';
  String trendUnit = '';
  String trendStartTime = '';
  String trendEndTime = '';
  List<BookOverviewTrendList> trendList = [];

  BookOverviewModel();

  factory BookOverviewModel.fromJson(Map<String, dynamic> json) =>
      $BookOverviewModelFromJson(json);

  Map<String, dynamic> toJson() => $BookOverviewModelToJson(this);

  @override
  String toString() => jsonEncode(this);
}

@JsonSerializable()
class BookOverviewTrendList {
  String dateTime = '';
  String incomeTotal = '';
  String expensesTotal = '';

  BookOverviewTrendList();

  factory BookOverviewTrendList.fromJson(Map<String, dynamic> json) =>
      $BookOverviewTrendListFromJson(json);

  Map<String, dynamic> toJson() => $BookOverviewTrendListToJson(this);

  @override
  String toString() => jsonEncode(this);
}
