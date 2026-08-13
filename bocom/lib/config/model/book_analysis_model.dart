import 'dart:convert';

import 'package:bocom/generated/json/base/json_field.dart';
import 'package:bocom/generated/json/book_analysis_model.g.dart';

export 'package:bocom/generated/json/book_analysis_model.g.dart';

@JsonSerializable()
class BookAnalysisModel {
  String bookType = '';
  String dateType = '';
  String period = '';
  int incomeExpenseType = 2;
  int billCount = 0;
  String totalAmount = '';
  String comparedPrevious = '';
  List<BookAnalysisCategoryList> categoryList = [];
  int incomeBillCount = 0;
  String incomeTotal = '';
  String incomeComparedPrevious = '';
  int expenseBillCount = 0;
  String expensesTotal = '';
  String expensesComparedPrevious = '';
  String balance = '';
  String balanceComparedPrevious = '';
  List<BookAnalysisTrendList> trendList = [];
  List<BookAnalysisRankList> incomeRankList = [];
  List<BookAnalysisRankList> expenseRankList = [];

  BookAnalysisModel();

  factory BookAnalysisModel.fromJson(Map<String, dynamic> json) =>
      $BookAnalysisModelFromJson(json);
  Map<String, dynamic> toJson() => $BookAnalysisModelToJson(this);
  @override
  String toString() => jsonEncode(this);
}

@JsonSerializable()
class BookAnalysisCategoryList {
  String categoryName = '';
  String icon = '';
  int billCount = 0;
  String amount = '';
  String percentage = '';

  BookAnalysisCategoryList();
  factory BookAnalysisCategoryList.fromJson(Map<String, dynamic> json) =>
      $BookAnalysisCategoryListFromJson(json);
  Map<String, dynamic> toJson() => $BookAnalysisCategoryListToJson(this);
}

@JsonSerializable()
class BookAnalysisTrendList {
  String dateTime = '';
  String incomeTotal = '';
  String expensesTotal = '';

  BookAnalysisTrendList();
  factory BookAnalysisTrendList.fromJson(Map<String, dynamic> json) =>
      $BookAnalysisTrendListFromJson(json);
  Map<String, dynamic> toJson() => $BookAnalysisTrendListToJson(this);
}

@JsonSerializable()
class BookAnalysisRankList {
  int rank = 0;
  int id = 0;
  String excerpt = '';
  String amount = '';
  String transactionTime = '';
  int type = 0;
  String bankCardText = '';

  BookAnalysisRankList();
  factory BookAnalysisRankList.fromJson(Map<String, dynamic> json) =>
      $BookAnalysisRankListFromJson(json);
  Map<String, dynamic> toJson() => $BookAnalysisRankListToJson(this);
}
