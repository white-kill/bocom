import 'package:bocom/generated/json/base/json_field.dart';
import 'package:bocom/generated/json/apply_record_model.g.dart';
import 'dart:convert';
export 'package:bocom/generated/json/apply_record_model.g.dart';

@JsonSerializable()
class ApplyRecordModel {
	List<ApplyRecordList> list = [];
	int total = 0;
	String incomeTotal = '';
	String expensesTotal = '';

	ApplyRecordModel();

	factory ApplyRecordModel.fromJson(Map<String, dynamic> json) => $ApplyRecordModelFromJson(json);

	Map<String, dynamic> toJson() => $ApplyRecordModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class ApplyRecordList {
	int id = 0;
	String bankCard = '';
	String email = '';
	String dateTimeRange = '';
	String status = '';
	String detailType = '';
	String code = '';
	String createTime = '';
	String fileUrl = '';
	String endTime = '';
	String beginTime = '';

	ApplyRecordList();

	factory ApplyRecordList.fromJson(Map<String, dynamic> json) => $ApplyRecordListFromJson(json);

	Map<String, dynamic> toJson() => $ApplyRecordListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}