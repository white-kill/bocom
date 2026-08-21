import 'dart:convert';

import 'package:bocom/generated/json/base/json_field.dart';
import 'package:bocom/generated/json/member_info_model.g.dart';


@JsonSerializable()
class MemberInfoModel {
	String id = '';
	String bankId = '';
	String realName = '';
	String cardAlias = '';
	double accountBalance = 0;
	String appAccount = '';
	String idCard = '';
	String chapterCode = '';
	String branchBelongs = '';
	String sex = '';
	String city = '';
	String openCity = '';
	String phone = '';
	String account = '';
	String serialNumber = '';
	String certificateBeginTime = '';
	String certificateEndTime = '';
	String loginTime = '';
	String openTime = '';
	int payStatus = 0;
	List<MemberInfoBankList> bankList = [];
	String starRating = '';
	int points = 0;
	int couponsNum = 0;
	String credit = '';
	double incomeTotal = 0;
	double expensesTotal = 0;
	int peas = 0;

	MemberInfoModel();

	factory MemberInfoModel.fromJson(Map<String, dynamic> json) => $MemberInfoModelFromJson(json);

	Map<String, dynamic> toJson() => $MemberInfoModelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class MemberInfoBankList {
	String bankCard = '';
	String realName = '';
	double accountBalance = 0;
	String bankName = '';
	String openOutlets = '';
	String openTime = '';
	String cardType = '';
	String starRating = '';
	String openCity = '';
	String branchBelongs = '';

	MemberInfoBankList();

	factory MemberInfoBankList.fromJson(Map<String, dynamic> json) => $MemberInfoBankListFromJson(json);

	Map<String, dynamic> toJson() => $MemberInfoBankListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
