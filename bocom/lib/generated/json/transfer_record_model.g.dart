import 'package:bocom/generated/json/base/json_convert_content.dart';
import 'package:bocom/config/model/transfer_record_model.dart';

TransferRecordModel $TransferRecordModelFromJson(Map<String, dynamic> json) {
  final TransferRecordModel transferRecordModel = TransferRecordModel();
  final List<TransferRecordList>? list = (json['list'] as List<dynamic>?)
      ?.map(
          (e) =>
      jsonConvert.convert<TransferRecordList>(e) as TransferRecordList)
      .toList();
  if (list != null) {
    transferRecordModel.list = list;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    transferRecordModel.total = total;
  }
  final int? pages = jsonConvert.convert<int>(json['pages']);
  if (pages != null) {
    transferRecordModel.pages = pages;
  }
  final String? incomeTotal = jsonConvert.convert<String>(json['incomeTotal']);
  if (incomeTotal != null) {
    transferRecordModel.incomeTotal = incomeTotal;
  }
  final String? expensesTotal = jsonConvert.convert<String>(
      json['expensesTotal']);
  if (expensesTotal != null) {
    transferRecordModel.expensesTotal = expensesTotal;
  }
  final dynamic customizeParam = json['customizeParam'];
  if (customizeParam != null) {
    transferRecordModel.customizeParam = customizeParam;
  }
  return transferRecordModel;
}

Map<String, dynamic> $TransferRecordModelToJson(TransferRecordModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['list'] = entity.list.map((v) => v.toJson()).toList();
  data['total'] = entity.total;
  data['pages'] = entity.pages;
  data['incomeTotal'] = entity.incomeTotal;
  data['expensesTotal'] = entity.expensesTotal;
  data['customizeParam'] = entity.customizeParam;
  return data;
}

extension TransferRecordModelExtension on TransferRecordModel {
  TransferRecordModel copyWith({
    List<TransferRecordList>? list,
    int? total,
    int? pages,
    String? incomeTotal,
    String? expensesTotal,
    dynamic customizeParam,
  }) {
    return TransferRecordModel()
      ..list = list ?? this.list
      ..total = total ?? this.total
      ..pages = pages ?? this.pages
      ..incomeTotal = incomeTotal ?? this.incomeTotal
      ..expensesTotal = expensesTotal ?? this.expensesTotal
      ..customizeParam = customizeParam ?? this.customizeParam;
  }
}

TransferRecordList $TransferRecordListFromJson(Map<String, dynamic> json) {
  final TransferRecordList transferRecordList = TransferRecordList();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    transferRecordList.id = id;
  }
  final double? amount = jsonConvert.convert<double>(json['amount']);
  if (amount != null) {
    transferRecordList.amount = amount;
  }
  final String? transactionTime = jsonConvert.convert<String>(
      json['transactionTime']);
  if (transactionTime != null) {
    transferRecordList.transactionTime = transactionTime;
  }
  final String? oppositeName = jsonConvert.convert<String>(
      json['oppositeName']);
  if (oppositeName != null) {
    transferRecordList.oppositeName = oppositeName;
  }
  final String? day = jsonConvert.convert<String>(json['day']);
  if (day != null) {
    transferRecordList.day = day;
  }
  final String? oppositeAccount = jsonConvert.convert<String>(
      json['oppositeAccount']);
  if (oppositeAccount != null) {
    transferRecordList.oppositeAccount = oppositeAccount;
  }
  final String? oppositeBankName = jsonConvert.convert<String>(
      json['oppositeBankName']);
  if (oppositeBankName != null) {
    transferRecordList.oppositeBankName = oppositeBankName;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    transferRecordList.status = status;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    transferRecordList.currency = currency;
  }
  final String? icon = jsonConvert.convert<String>(json['icon']);
  if (icon != null) {
    transferRecordList.icon = icon;
  }
  final TransferRecordListDetail? detail = jsonConvert.convert<
      TransferRecordListDetail>(json['detail']);
  if (detail != null) {
    transferRecordList.detail = detail;
  }
  return transferRecordList;
}

Map<String, dynamic> $TransferRecordListToJson(TransferRecordList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['amount'] = entity.amount;
  data['transactionTime'] = entity.transactionTime;
  data['oppositeName'] = entity.oppositeName;
  data['day'] = entity.day;
  data['oppositeAccount'] = entity.oppositeAccount;
  data['oppositeBankName'] = entity.oppositeBankName;
  data['status'] = entity.status;
  data['currency'] = entity.currency;
  data['icon'] = entity.icon;
  data['detail'] = entity.detail.toJson();
  return data;
}

extension TransferRecordListExtension on TransferRecordList {
  TransferRecordList copyWith({
    int? id,
    double? amount,
    String? transactionTime,
    String? oppositeName,
    String? day,
    String? oppositeAccount,
    String? oppositeBankName,
    String? status,
    String? currency,
    String? icon,
    TransferRecordListDetail? detail,
  }) {
    return TransferRecordList()
      ..id = id ?? this.id
      ..amount = amount ?? this.amount
      ..transactionTime = transactionTime ?? this.transactionTime
      ..oppositeName = oppositeName ?? this.oppositeName
      ..day = day ?? this.day
      ..oppositeAccount = oppositeAccount ?? this.oppositeAccount
      ..oppositeBankName = oppositeBankName ?? this.oppositeBankName
      ..status = status ?? this.status
      ..currency = currency ?? this.currency
      ..icon = icon ?? this.icon
      ..detail = detail ?? this.detail;
  }
}

TransferRecordListDetail $TransferRecordListDetailFromJson(
    Map<String, dynamic> json) {
  final TransferRecordListDetail transferRecordListDetail = TransferRecordListDetail();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    transferRecordListDetail.id = id;
  }
  final double? amount = jsonConvert.convert<double>(json['amount']);
  if (amount != null) {
    transferRecordListDetail.amount = amount;
  }
  final String? excerpt = jsonConvert.convert<String>(json['excerpt']);
  if (excerpt != null) {
    transferRecordListDetail.excerpt = excerpt;
  }
  final String? oppositeBankId = jsonConvert.convert<String>(
      json['oppositeBankId']);
  if (oppositeBankId != null) {
    transferRecordListDetail.oppositeBankId = oppositeBankId;
  }
  final String? transactionTime = jsonConvert.convert<String>(
      json['transactionTime']);
  if (transactionTime != null) {
    transferRecordListDetail.transactionTime = transactionTime;
  }
  final String? bankCard = jsonConvert.convert<String>(json['bankCard']);
  if (bankCard != null) {
    transferRecordListDetail.bankCard = bankCard;
  }
  final String? bankName = jsonConvert.convert<String>(json['bankName']);
  if (bankName != null) {
    transferRecordListDetail.bankName = bankName;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    transferRecordListDetail.type = type;
  }
  final String? oppositeBankName = jsonConvert.convert<String>(
      json['oppositeBankName']);
  if (oppositeBankName != null) {
    transferRecordListDetail.oppositeBankName = oppositeBankName;
  }
  final String? oppositeName = jsonConvert.convert<String>(
      json['oppositeName']);
  if (oppositeName != null) {
    transferRecordListDetail.oppositeName = oppositeName;
  }
  final String? oppositeAccount = jsonConvert.convert<String>(
      json['oppositeAccount']);
  if (oppositeAccount != null) {
    transferRecordListDetail.oppositeAccount = oppositeAccount;
  }
  final String? icon = jsonConvert.convert<String>(json['icon']);
  if (icon != null) {
    transferRecordListDetail.icon = icon;
  }
  final String? transactionType = jsonConvert.convert<String>(
      json['transactionType']);
  if (transactionType != null) {
    transferRecordListDetail.transactionType = transactionType;
  }
  final String? transactionChannel = jsonConvert.convert<String>(
      json['transactionChannel']);
  if (transactionChannel != null) {
    transferRecordListDetail.transactionChannel = transactionChannel;
  }
  final String? certificateNo = jsonConvert.convert<String>(
      json['certificateNo']);
  if (certificateNo != null) {
    transferRecordListDetail.certificateNo = certificateNo;
  }
  final String? merchantBranch = jsonConvert.convert<String>(
      json['merchantBranch']);
  if (merchantBranch != null) {
    transferRecordListDetail.merchantBranch = merchantBranch;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    transferRecordListDetail.status = status;
  }
  final String? postscriptno = jsonConvert.convert<String>(
      json['postscriptno']);
  if (postscriptno != null) {
    transferRecordListDetail.postscriptno = postscriptno;
  }
  final String? transactionLogno = jsonConvert.convert<String>(
      json['transactionLogno']);
  if (transactionLogno != null) {
    transferRecordListDetail.transactionLogno = transactionLogno;
  }
  return transferRecordListDetail;
}

Map<String, dynamic> $TransferRecordListDetailToJson(
    TransferRecordListDetail entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['amount'] = entity.amount;
  data['excerpt'] = entity.excerpt;
  data['oppositeBankId'] = entity.oppositeBankId;
  data['transactionTime'] = entity.transactionTime;
  data['bankCard'] = entity.bankCard;
  data['bankName'] = entity.bankName;
  data['type'] = entity.type;
  data['oppositeBankName'] = entity.oppositeBankName;
  data['oppositeName'] = entity.oppositeName;
  data['oppositeAccount'] = entity.oppositeAccount;
  data['icon'] = entity.icon;
  data['transactionType'] = entity.transactionType;
  data['transactionChannel'] = entity.transactionChannel;
  data['certificateNo'] = entity.certificateNo;
  data['merchantBranch'] = entity.merchantBranch;
  data['status'] = entity.status;
  data['postscriptno'] = entity.postscriptno;
  data['transactionLogno'] = entity.transactionLogno;
  return data;
}

extension TransferRecordListDetailExtension on TransferRecordListDetail {
  TransferRecordListDetail copyWith({
    int? id,
    double? amount,
    String? excerpt,
    String? oppositeBankId,
    String? transactionTime,
    String? bankCard,
    String? bankName,
    String? type,
    String? oppositeBankName,
    String? oppositeName,
    String? oppositeAccount,
    String? icon,
    String? transactionType,
    String? transactionChannel,
    String? certificateNo,
    String? merchantBranch,
    String? status,
    String? postscriptno,
    String? transactionLogno,
  }) {
    return TransferRecordListDetail()
      ..id = id ?? this.id
      ..amount = amount ?? this.amount
      ..excerpt = excerpt ?? this.excerpt
      ..oppositeBankId = oppositeBankId ?? this.oppositeBankId
      ..transactionTime = transactionTime ?? this.transactionTime
      ..bankCard = bankCard ?? this.bankCard
      ..bankName = bankName ?? this.bankName
      ..type = type ?? this.type
      ..oppositeBankName = oppositeBankName ?? this.oppositeBankName
      ..oppositeName = oppositeName ?? this.oppositeName
      ..oppositeAccount = oppositeAccount ?? this.oppositeAccount
      ..icon = icon ?? this.icon
      ..transactionType = transactionType ?? this.transactionType
      ..transactionChannel = transactionChannel ?? this.transactionChannel
      ..certificateNo = certificateNo ?? this.certificateNo
      ..merchantBranch = merchantBranch ?? this.merchantBranch
      ..status = status ?? this.status
      ..postscriptno = postscriptno ?? this.postscriptno
      ..transactionLogno = transactionLogno ?? this.transactionLogno;
  }
}