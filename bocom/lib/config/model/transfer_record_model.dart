import 'package:bocom/generated/json/base/json_field.dart';
import 'package:bocom/generated/json/transfer_record_model.g.dart';
import 'dart:convert';
export 'package:bocom/generated/json/transfer_record_model.g.dart';

@JsonSerializable()
class TransferRecordModel {
	List<TransferRecordList> list = [];
	int total = 0;
	int pages = 0;
	String incomeTotal = '';
	String expensesTotal = '';
	dynamic customizeParam;

	TransferRecordModel();

	factory TransferRecordModel.fromJson(Map<String, dynamic> json) => $TransferRecordModelFromJson(json);

	Map<String, dynamic> toJson() => $TransferRecordModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class TransferRecordList {
	int id = 0;
	double amount = 0;
	String transactionTime = '';
	String oppositeName = '';
	String day = '';
	String oppositeAccount = '';
	String oppositeBankName = '';
	String status = '';
	String currency = '';
	String icon = '';
	late TransferRecordListDetail detail;

	TransferRecordList();

	factory TransferRecordList.fromJson(Map<String, dynamic> json) => $TransferRecordListFromJson(json);

	Map<String, dynamic> toJson() => $TransferRecordListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class TransferRecordListDetail {
	int id = 0;
	double amount = 0;
	String excerpt = '';
	String oppositeBankId = '';
	String transactionTime = '';
	String bankCard = '';
	String bankName = '';
	String type = '';
	String oppositeBankName = '';
	String oppositeName = '';
	String oppositeAccount = '';
	String icon = '';
	String transactionType = '';
	String transactionChannel = '';
	String certificateNo = '';
	String merchantBranch = '';
	String status = '';
	String postscriptno = '';
	String transactionLogno = '';

	TransferRecordListDetail();

	factory TransferRecordListDetail.fromJson(Map<String, dynamic> json) => $TransferRecordListDetailFromJson(json);

	Map<String, dynamic> toJson() => $TransferRecordListDetailToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}