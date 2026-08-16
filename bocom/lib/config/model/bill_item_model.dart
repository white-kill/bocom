import 'package:bocom/generated/json/base/json_field.dart';
import 'package:bocom/generated/json/bill_item_model.g.dart';
import 'dart:convert';
export 'package:bocom/generated/json/bill_item_model.g.dart';

@JsonSerializable()
class BillItemModel {
  List<BillItemList> list = [];
  int total = 0;
  int pages = 0;
  String incomeTotal = '';
  String expensesTotal = '';
  dynamic customizeParam;

  BillItemModel();

  factory BillItemModel.fromJson(Map<String, dynamic> json) =>
      $BillItemModelFromJson(json);

  Map<String, dynamic> toJson() => $BillItemModelToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class BillItemList {
  int id = 0;
  String excerpt = '';
  String amount = '';
  String accountBalance = '';
  String day = '';
  String week = '';
  String currency = '';
  String type = '';
  String transactionTime = '';
  String oppositeName = '';
  String month = '';
  String year = '';
  String icon = '';
  String dayIncomeTotal = '';
  String dayExpensesTotal = '';
  String monthIncomeTotal = '';
  String monthExpensesTotal = '';
  String incomeTotal = '';
  String expensesTotal = '';
  BillItemListBillDetail? billDetail;

  BillItemList();

  factory BillItemList.fromJson(Map<String, dynamic> json) =>
      $BillItemListFromJson(json);

  Map<String, dynamic> toJson() => $BillItemListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class BillItemListBillDetail {
  int id = 0;
  String bankName = '';
  String transactionType = '';
  String oppositeBankId = '';
  String bankCard = '';
  String excerpt = '';
  double amount = 0;
  double accountBalance = 0;
  String transactionTime = '';
  String oppositeAccount = '';
  String accountsTime = '';
  String merchantBranch = '';
  String oppositeName = '';
  String oppositeBankName = '';
  String type = '';
  String transactionChannel = '';
  String billType = '';
  String transactionCategory = '';
  String postscriptno = '';

  /// 交易对象（本人 / 家庭公用 等），可与接口字段对齐
  String transactionObject = '';

  /// 所属账本：1-投资账本，2-消费账本，4-薪资账本
  List<int> bookTypes = [];

  BillItemListBillDetail();

  factory BillItemListBillDetail.fromJson(Map<String, dynamic> json) =>
      $BillItemListBillDetailFromJson(json);

  Map<String, dynamic> toJson() => $BillItemListBillDetailToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
