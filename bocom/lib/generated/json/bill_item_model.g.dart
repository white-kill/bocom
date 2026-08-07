import 'package:bocom/generated/json/base/json_convert_content.dart';
import 'package:bocom/config/model/bill_item_model.dart';

BillItemModel $BillItemModelFromJson(Map<String, dynamic> json) {
  final BillItemModel billItemModel = BillItemModel();
  final List<BillItemList>? list = (json['list'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<BillItemList>(e) as BillItemList).toList();
  if (list != null) {
    billItemModel.list = list;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    billItemModel.total = total;
  }
  final dynamic pages = json['pages'];
  if (pages != null) {
    billItemModel.pages = pages;
  }
  final String? incomeTotal = jsonConvert.convert<String>(json['incomeTotal']);
  if (incomeTotal != null) {
    billItemModel.incomeTotal = incomeTotal;
  }
  final String? expensesTotal = jsonConvert.convert<String>(
      json['expensesTotal']);
  if (expensesTotal != null) {
    billItemModel.expensesTotal = expensesTotal;
  }
  final dynamic customizeParam = json['customizeParam'];
  if (customizeParam != null) {
    billItemModel.customizeParam = customizeParam;
  }
  return billItemModel;
}

Map<String, dynamic> $BillItemModelToJson(BillItemModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['list'] = entity.list.map((v) => v.toJson()).toList();
  data['total'] = entity.total;
  data['pages'] = entity.pages;
  data['incomeTotal'] = entity.incomeTotal;
  data['expensesTotal'] = entity.expensesTotal;
  data['customizeParam'] = entity.customizeParam;
  return data;
}

extension BillItemModelExtension on BillItemModel {
  BillItemModel copyWith({
    List<BillItemList>? list,
    int? total,
    dynamic pages,
    String? incomeTotal,
    String? expensesTotal,
    dynamic customizeParam,
  }) {
    return BillItemModel()
      ..list = list ?? this.list
      ..total = total ?? this.total
      ..pages = pages ?? this.pages
      ..incomeTotal = incomeTotal ?? this.incomeTotal
      ..expensesTotal = expensesTotal ?? this.expensesTotal
      ..customizeParam = customizeParam ?? this.customizeParam;
  }
}

BillItemList $BillItemListFromJson(Map<String, dynamic> json) {
  final BillItemList billItemList = BillItemList();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    billItemList.id = id;
  }
  final String? excerpt = jsonConvert.convert<String>(json['excerpt']);
  if (excerpt != null) {
    billItemList.excerpt = excerpt;
  }
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    billItemList.amount = amount;
  }
  final String? accountBalance = jsonConvert.convert<String>(
      json['accountBalance']);
  if (accountBalance != null) {
    billItemList.accountBalance = accountBalance;
  }
  final String? day = jsonConvert.convert<String>(json['day']);
  if (day != null) {
    billItemList.day = day;
  }
  final String? week = jsonConvert.convert<String>(json['week']);
  if (week != null) {
    billItemList.week = week;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    billItemList.currency = currency;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    billItemList.type = type;
  }
  final String? transactionTime = jsonConvert.convert<String>(
      json['transactionTime']);
  if (transactionTime != null) {
    billItemList.transactionTime = transactionTime;
  }
  final String? oppositeName = jsonConvert.convert<String>(
      json['oppositeName']);
  if (oppositeName != null) {
    billItemList.oppositeName = oppositeName;
  }
  final String? month = jsonConvert.convert<String>(json['month']);
  if (month != null) {
    billItemList.month = month;
  }
  final String? year = jsonConvert.convert<String>(json['year']);
  if (year != null) {
    billItemList.year = year;
  }
  final String? incomeTotal = jsonConvert.convert<String>(json['incomeTotal']);
  if (incomeTotal != null) {
    billItemList.incomeTotal = incomeTotal;
  }
  final String? expensesTotal = jsonConvert.convert<String>(json['expensesTotal']);
  if (expensesTotal != null) {
    billItemList.expensesTotal = expensesTotal;
  }
  final BillItemListBillDetail? billDetail = jsonConvert.convert<
      BillItemListBillDetail>(json['billDetail']);
  if (billDetail != null) {
    billItemList.billDetail = billDetail;
  }
  return billItemList;
}

Map<String, dynamic> $BillItemListToJson(BillItemList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['excerpt'] = entity.excerpt;
  data['amount'] = entity.amount;
  data['accountBalance'] = entity.accountBalance;
  data['day'] = entity.day;
  data['week'] = entity.week;
  data['currency'] = entity.currency;
  data['type'] = entity.type;
  data['transactionTime'] = entity.transactionTime;
  data['oppositeName'] = entity.oppositeName;
  data['month'] = entity.month;
  data['year'] = entity.year;
  data['incomeTotal'] = entity.incomeTotal;
  data['expensesTotal'] = entity.expensesTotal;
  data['billDetail'] = entity.billDetail?.toJson();
  return data;
}

extension BillItemListExtension on BillItemList {
  BillItemList copyWith({
    int? id,
    String? excerpt,
    String? amount,
    String? accountBalance,
    String? day,
    String? week,
    String? currency,
    String? type,
    String? transactionTime,
    String? oppositeName,
    String? month,
    String? year,
    String? incomeTotal,
    String? expensesTotal,
    BillItemListBillDetail? billDetail,
  }) {
    return BillItemList()
      ..id = id ?? this.id
      ..excerpt = excerpt ?? this.excerpt
      ..amount = amount ?? this.amount
      ..accountBalance = accountBalance ?? this.accountBalance
      ..day = day ?? this.day
      ..week = week ?? this.week
      ..currency = currency ?? this.currency
      ..type = type ?? this.type
      ..transactionTime = transactionTime ?? this.transactionTime
      ..oppositeName = oppositeName ?? this.oppositeName
      ..month = month ?? this.month
      ..year = year ?? this.year
      ..incomeTotal = incomeTotal ?? this.incomeTotal
      ..expensesTotal = expensesTotal ?? this.expensesTotal
      ..billDetail = billDetail ?? this.billDetail;
  }
}

BillItemListBillDetail $BillItemListBillDetailFromJson(
    Map<String, dynamic> json) {
  final BillItemListBillDetail billItemListBillDetail = BillItemListBillDetail();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    billItemListBillDetail.id = id;
  }
  final String? bankName = jsonConvert.convert<String>(json['bankName']);
  if (bankName != null) {
    billItemListBillDetail.bankName = bankName;
  }
  final String? transactionType = jsonConvert.convert<String>(
      json['transactionType']);
  if (transactionType != null) {
    billItemListBillDetail.transactionType = transactionType;
  }
  final String? oppositeBankId = jsonConvert.convert<String>(
      json['oppositeBankId']);
  if (oppositeBankId != null) {
    billItemListBillDetail.oppositeBankId = oppositeBankId;
  }
  final String? bankCard = jsonConvert.convert<String>(json['bankCard']);
  if (bankCard != null) {
    billItemListBillDetail.bankCard = bankCard;
  }
  final String? excerpt = jsonConvert.convert<String>(json['excerpt']);
  if (excerpt != null) {
    billItemListBillDetail.excerpt = excerpt;
  }
  final double? amount = jsonConvert.convert<double>(json['amount']);
  if (amount != null) {
    billItemListBillDetail.amount = amount;
  }
  final double? accountBalance = jsonConvert.convert<double>(
      json['accountBalance']);
  if (accountBalance != null) {
    billItemListBillDetail.accountBalance = accountBalance;
  }
  final String? transactionTime = jsonConvert.convert<String>(
      json['transactionTime']);
  if (transactionTime != null) {
    billItemListBillDetail.transactionTime = transactionTime;
  }
  final String? oppositeAccount = jsonConvert.convert<String>(
      json['oppositeAccount']);
  if (oppositeAccount != null) {
    billItemListBillDetail.oppositeAccount = oppositeAccount;
  }
  final String? accountsTime = jsonConvert.convert<String>(
      json['accountsTime']);
  if (accountsTime != null) {
    billItemListBillDetail.accountsTime = accountsTime;
  }
  final String? merchantBranch = jsonConvert.convert<String>(
      json['merchantBranch']);
  if (merchantBranch != null) {
    billItemListBillDetail.merchantBranch = merchantBranch;
  }
  final String? oppositeName = jsonConvert.convert<String>(
      json['oppositeName']);
  if (oppositeName != null) {
    billItemListBillDetail.oppositeName = oppositeName;
  }
  final String? oppositeBankName = jsonConvert.convert<String>(
      json['oppositeBankName']);
  if (oppositeBankName != null) {
    billItemListBillDetail.oppositeBankName = oppositeBankName;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    billItemListBillDetail.type = type;
  }
  final String? transactionChannel = jsonConvert.convert<String>(
      json['transactionChannel']);
  if (transactionChannel != null) {
    billItemListBillDetail.transactionChannel = transactionChannel;
  }
  final String? billType = jsonConvert.convert<String>(json['billType']);
  if (billType != null) {
    billItemListBillDetail.billType = billType;
  }
  final String? transactionCategory = jsonConvert.convert<String>(
      json['transactionCategory']);
  if (transactionCategory != null) {
    billItemListBillDetail.transactionCategory = transactionCategory;
  }
  final String? postscriptno = jsonConvert.convert<String>(
      json['postscriptno']);
  if (postscriptno != null) {
    billItemListBillDetail.postscriptno = postscriptno;
  }
  final String? transactionObject = jsonConvert.convert<String>(
      json['transactionObject']);
  if (transactionObject != null) {
    billItemListBillDetail.transactionObject = transactionObject;
  }
  return billItemListBillDetail;
}

Map<String, dynamic> $BillItemListBillDetailToJson(
    BillItemListBillDetail entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['bankName'] = entity.bankName;
  data['transactionType'] = entity.transactionType;
  data['oppositeBankId'] = entity.oppositeBankId;
  data['bankCard'] = entity.bankCard;
  data['excerpt'] = entity.excerpt;
  data['amount'] = entity.amount;
  data['accountBalance'] = entity.accountBalance;
  data['transactionTime'] = entity.transactionTime;
  data['oppositeAccount'] = entity.oppositeAccount;
  data['accountsTime'] = entity.accountsTime;
  data['merchantBranch'] = entity.merchantBranch;
  data['oppositeName'] = entity.oppositeName;
  data['oppositeBankName'] = entity.oppositeBankName;
  data['type'] = entity.type;
  data['transactionChannel'] = entity.transactionChannel;
  data['billType'] = entity.billType;
  data['transactionCategory'] = entity.transactionCategory;
  data['postscriptno'] = entity.postscriptno;
  data['transactionObject'] = entity.transactionObject;
  return data;
}

extension BillItemListBillDetailExtension on BillItemListBillDetail {
  BillItemListBillDetail copyWith({
    int? id,
    String? bankName,
    String? transactionType,
    String? oppositeBankId,
    String? bankCard,
    String? excerpt,
    double? amount,
    double? accountBalance,
    String? transactionTime,
    String? oppositeAccount,
    String? accountsTime,
    String? merchantBranch,
    String? oppositeName,
    String? oppositeBankName,
    String? type,
    String? transactionChannel,
    String? billType,
    String? transactionCategory,
    String? postscriptno,
    String? transactionObject,
  }) {
    return BillItemListBillDetail()
      ..id = id ?? this.id
      ..bankName = bankName ?? this.bankName
      ..transactionType = transactionType ?? this.transactionType
      ..oppositeBankId = oppositeBankId ?? this.oppositeBankId
      ..bankCard = bankCard ?? this.bankCard
      ..excerpt = excerpt ?? this.excerpt
      ..amount = amount ?? this.amount
      ..accountBalance = accountBalance ?? this.accountBalance
      ..transactionTime = transactionTime ?? this.transactionTime
      ..oppositeAccount = oppositeAccount ?? this.oppositeAccount
      ..accountsTime = accountsTime ?? this.accountsTime
      ..merchantBranch = merchantBranch ?? this.merchantBranch
      ..oppositeName = oppositeName ?? this.oppositeName
      ..oppositeBankName = oppositeBankName ?? this.oppositeBankName
      ..type = type ?? this.type
      ..transactionChannel = transactionChannel ?? this.transactionChannel
      ..billType = billType ?? this.billType
      ..transactionCategory = transactionCategory ?? this.transactionCategory
      ..postscriptno = postscriptno ?? this.postscriptno
      ..transactionObject = transactionObject ?? this.transactionObject;
  }
}
