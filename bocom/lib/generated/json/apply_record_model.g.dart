import 'package:bocom/generated/json/base/json_convert_content.dart';
import 'package:bocom/config/model/apply_record_model.dart';

ApplyRecordModel $ApplyRecordModelFromJson(Map<String, dynamic> json) {
  final ApplyRecordModel applyRecordModel = ApplyRecordModel();
  final List<ApplyRecordList>? list = (json['list'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<ApplyRecordList>(e) as ApplyRecordList)
      .toList();
  if (list != null) {
    applyRecordModel.list = list;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    applyRecordModel.total = total;
  }
  final String? incomeTotal = jsonConvert.convert<String>(json['incomeTotal']);
  if (incomeTotal != null) {
    applyRecordModel.incomeTotal = incomeTotal;
  }
  final String? expensesTotal = jsonConvert.convert<String>(
      json['expensesTotal']);
  if (expensesTotal != null) {
    applyRecordModel.expensesTotal = expensesTotal;
  }
  return applyRecordModel;
}

Map<String, dynamic> $ApplyRecordModelToJson(ApplyRecordModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['list'] = entity.list.map((v) => v.toJson()).toList();
  data['total'] = entity.total;
  data['incomeTotal'] = entity.incomeTotal;
  data['expensesTotal'] = entity.expensesTotal;
  return data;
}

extension ApplyRecordModelExtension on ApplyRecordModel {
  ApplyRecordModel copyWith({
    List<ApplyRecordList>? list,
    int? total,
    String? incomeTotal,
    String? expensesTotal,
  }) {
    return ApplyRecordModel()
      ..list = list ?? this.list
      ..total = total ?? this.total
      ..incomeTotal = incomeTotal ?? this.incomeTotal
      ..expensesTotal = expensesTotal ?? this.expensesTotal;
  }
}

ApplyRecordList $ApplyRecordListFromJson(Map<String, dynamic> json) {
  final ApplyRecordList applyRecordList = ApplyRecordList();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    applyRecordList.id = id;
  }
  final String? bankCard = jsonConvert.convert<String>(json['bankCard']);
  if (bankCard != null) {
    applyRecordList.bankCard = bankCard;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    applyRecordList.email = email;
  }
  final String? dateTimeRange = jsonConvert.convert<String>(
      json['dateTimeRange']);
  if (dateTimeRange != null) {
    applyRecordList.dateTimeRange = dateTimeRange;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    applyRecordList.status = status;
  }
  final String? detailType = jsonConvert.convert<String>(json['detailType']);
  if (detailType != null) {
    applyRecordList.detailType = detailType;
  }
  final String? code = jsonConvert.convert<String>(json['code']);
  if (code != null) {
    applyRecordList.code = code;
  }
  final String? createTime = jsonConvert.convert<String>(json['createTime']);
  if (createTime != null) {
    applyRecordList.createTime = createTime;
  }
  final String? fileUrl = jsonConvert.convert<String>(json['fileUrl']);
  if (fileUrl != null) {
    applyRecordList.fileUrl = fileUrl;
  }
  final String? endTime = jsonConvert.convert<String>(json['endTime']);
  if (endTime != null) {
    applyRecordList.endTime = endTime;
  }
  final String? beginTime = jsonConvert.convert<String>(json['beginTime']);
  if (beginTime != null) {
    applyRecordList.beginTime = beginTime;
  }
  return applyRecordList;
}

Map<String, dynamic> $ApplyRecordListToJson(ApplyRecordList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['bankCard'] = entity.bankCard;
  data['email'] = entity.email;
  data['dateTimeRange'] = entity.dateTimeRange;
  data['status'] = entity.status;
  data['detailType'] = entity.detailType;
  data['code'] = entity.code;
  data['createTime'] = entity.createTime;
  data['fileUrl'] = entity.fileUrl;
  data['endTime'] = entity.endTime;
  data['beginTime'] = entity.beginTime;
  return data;
}

extension ApplyRecordListExtension on ApplyRecordList {
  ApplyRecordList copyWith({
    int? id,
    String? bankCard,
    String? email,
    String? dateTimeRange,
    String? status,
    String? detailType,
    String? code,
    String? createTime,
    String? fileUrl,
    String? endTime,
    String? beginTime,
  }) {
    return ApplyRecordList()
      ..id = id ?? this.id
      ..bankCard = bankCard ?? this.bankCard
      ..email = email ?? this.email
      ..dateTimeRange = dateTimeRange ?? this.dateTimeRange
      ..status = status ?? this.status
      ..detailType = detailType ?? this.detailType
      ..code = code ?? this.code
      ..createTime = createTime ?? this.createTime
      ..fileUrl = fileUrl ?? this.fileUrl
      ..endTime = endTime ?? this.endTime
      ..beginTime = beginTime ?? this.beginTime;
  }
}