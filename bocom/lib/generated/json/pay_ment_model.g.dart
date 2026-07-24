import 'package:bocom/generated/json/base/json_convert_content.dart';
import 'package:bocom/config/model/pay_ment_model.dart';
import 'package:bocom/config/model/bill_item_model.dart';


PayMentModel $PayMentModelFromJson(Map<String, dynamic> json) {
  final PayMentModel payMentModel = PayMentModel();
  final List<PayMentList>? list = (json['list'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<PayMentList>(e) as PayMentList).toList();
  if (list != null) {
    payMentModel.list = list;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    payMentModel.total = total;
  }
  final int? pages = jsonConvert.convert<int>(json['pages']);
  if (pages != null) {
    payMentModel.pages = pages;
  }
  final double? incomeTotal = jsonConvert.convert<double>(json['incomeTotal']);
  if (incomeTotal != null) {
    payMentModel.incomeTotal = incomeTotal;
  }
  final double? expensesTotal = jsonConvert.convert<double>(
      json['expensesTotal']);
  if (expensesTotal != null) {
    payMentModel.expensesTotal = expensesTotal;
  }
  final dynamic customizeParam = json['customizeParam'];
  if (customizeParam != null) {
    payMentModel.customizeParam = customizeParam;
  }
  return payMentModel;
}

Map<String, dynamic> $PayMentModelToJson(PayMentModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['list'] = entity.list.map((v) => v.toJson()).toList();
  data['total'] = entity.total;
  data['pages'] = entity.pages;
  data['incomeTotal'] = entity.incomeTotal;
  data['expensesTotal'] = entity.expensesTotal;
  data['customizeParam'] = entity.customizeParam;
  return data;
}

extension PayMentModelExtension on PayMentModel {
  PayMentModel copyWith({
    List<PayMentList>? list,
    int? total,
    int? pages,
    double? incomeTotal,
    double? expensesTotal,
    dynamic customizeParam,
  }) {
    return PayMentModel()
      ..list = list ?? this.list
      ..total = total ?? this.total
      ..pages = pages ?? this.pages
      ..incomeTotal = incomeTotal ?? this.incomeTotal
      ..expensesTotal = expensesTotal ?? this.expensesTotal
      ..customizeParam = customizeParam ?? this.customizeParam;
  }
}

PayMentList $PayMentListFromJson(Map<String, dynamic> json) {
  final PayMentList payMentList = PayMentList();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    payMentList.id = id;
  }
  final String? excerpt = jsonConvert.convert<String>(json['excerpt']);
  if (excerpt != null) {
    payMentList.excerpt = excerpt;
  }
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    payMentList.amount = amount;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    payMentList.type = type;
  }
  final String? month = jsonConvert.convert<String>(json['month']);
  if (month != null) {
    payMentList.month = month;
  }
  final String? day = jsonConvert.convert<String>(json['day']);
  if (day != null) {
    payMentList.day = day;
  }
  final String? week = jsonConvert.convert<String>(json['week']);
  if (week != null) {
    payMentList.week = week;
  }
  final String? icon = jsonConvert.convert<String>(json['icon']);
  if (icon != null) {
    payMentList.icon = icon;
  }
  final String? transactionTime = jsonConvert.convert<String>(
      json['transactionTime']);
  if (transactionTime != null) {
    payMentList.transactionTime = transactionTime;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    payMentList.currency = currency;
  }
  final String? bankCard = jsonConvert.convert<String>(json['bankCard']);
  if (bankCard != null) {
    payMentList.bankCard = bankCard;
  }
  final String? transactionCategory = jsonConvert.convert<String>(
      json['transactionCategory']);
  if (transactionCategory != null) {
    payMentList.transactionCategory = transactionCategory;
  }
  final String? incomeTotal = jsonConvert.convert<String>(json['incomeTotal']);
  if (incomeTotal != null) {
    payMentList.incomeTotal = incomeTotal;
  }
  final String? expensesTotal = jsonConvert.convert<String>(
      json['expensesTotal']);
  if (expensesTotal != null) {
    payMentList.expensesTotal = expensesTotal;
  }
  final BillItemListBillDetail? billDetail = jsonConvert.convert<
      BillItemListBillDetail>(json['billDetail']);
  if (billDetail != null) {
    payMentList.billDetail = billDetail;
  }
  return payMentList;
}

Map<String, dynamic> $PayMentListToJson(PayMentList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['excerpt'] = entity.excerpt;
  data['amount'] = entity.amount;
  data['type'] = entity.type;
  data['month'] = entity.month;
  data['day'] = entity.day;
  data['week'] = entity.week;
  data['icon'] = entity.icon;
  data['transactionTime'] = entity.transactionTime;
  data['currency'] = entity.currency;
  data['bankCard'] = entity.bankCard;
  data['transactionCategory'] = entity.transactionCategory;
  data['incomeTotal'] = entity.incomeTotal;
  data['expensesTotal'] = entity.expensesTotal;
  data['billDetail'] = entity.billDetail?.toJson();
  return data;
}

extension PayMentListExtension on PayMentList {
  PayMentList copyWith({
    int? id,
    String? excerpt,
    String? amount,
    String? type,
    String? month,
    String? day,
    String? week,
    String? icon,
    String? transactionTime,
    String? currency,
    String? bankCard,
    String? transactionCategory,
    String? incomeTotal,
    String? expensesTotal,
    BillItemListBillDetail? billDetail,
  }) {
    return PayMentList()
      ..id = id ?? this.id
      ..excerpt = excerpt ?? this.excerpt
      ..amount = amount ?? this.amount
      ..type = type ?? this.type
      ..month = month ?? this.month
      ..day = day ?? this.day
      ..week = week ?? this.week
      ..icon = icon ?? this.icon
      ..transactionTime = transactionTime ?? this.transactionTime
      ..currency = currency ?? this.currency
      ..bankCard = bankCard ?? this.bankCard
      ..transactionCategory = transactionCategory ?? this.transactionCategory
      ..incomeTotal = incomeTotal ?? this.incomeTotal
      ..expensesTotal = expensesTotal ?? this.expensesTotal
      ..billDetail = billDetail ?? this.billDetail;
  }
}