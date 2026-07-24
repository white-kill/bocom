import 'package:bocom/config/model/bill_item_model.dart';
import 'package:bocom/generated/json/base/json_field.dart';
import 'package:bocom/generated/json/pay_ment_model.g.dart';
import 'dart:convert';
export 'package:bocom/generated/json/pay_ment_model.g.dart';

@JsonSerializable()
class PayMentModel {
	List<PayMentList> list = [];
	int total = 0;
	int pages = 0;
	double incomeTotal = 0;
	double expensesTotal = 0;
	dynamic customizeParam;

	PayMentModel();

	factory PayMentModel.fromJson(Map<String, dynamic> json) => $PayMentModelFromJson(json);

	Map<String, dynamic> toJson() => $PayMentModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PayMentList {
	int id = 0;
	String excerpt = '';
	String amount = '';
	String type = '';
	String month = '';
	String day = '';
	String week = '';
	String icon = '';
	String transactionTime = '';
	String currency = '';
	String bankCard = '';
	String transactionCategory = '';
	String incomeTotal = '';
	String expensesTotal = '';
	BillItemListBillDetail? billDetail;

	PayMentList();

	factory PayMentList.fromJson(Map<String, dynamic> json) => $PayMentListFromJson(json);

	Map<String, dynamic> toJson() => $PayMentListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}