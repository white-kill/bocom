import 'package:bocom/generated/json/base/json_convert_content.dart';
import 'package:bocom/config/model/member_info_model.dart';

MemberInfoModel $MemberInfoModelFromJson(Map<String, dynamic> json) {
  final MemberInfoModel memberInfoModel = MemberInfoModel();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    memberInfoModel.id = id;
  }
  final String? bankId = jsonConvert.convert<String>(json['bankId']);
  if (bankId != null) {
    memberInfoModel.bankId = bankId;
  }
  final String? realName = jsonConvert.convert<String>(json['realName']);
  if (realName != null) {
    memberInfoModel.realName = realName;
  }
  final String? cardAlias = jsonConvert.convert<String>(json['cardAlias']);
  if (cardAlias != null) {
    memberInfoModel.cardAlias = cardAlias;
  }
  final double? accountBalance = jsonConvert.convert<double>(
      json['accountBalance']);
  if (accountBalance != null) {
    memberInfoModel.accountBalance = accountBalance;
  }
  final String? appAccount = jsonConvert.convert<String>(json['appAccount']);
  if (appAccount != null) {
    memberInfoModel.appAccount = appAccount;
  }
  final String? idCard = jsonConvert.convert<String>(json['idCard']);
  if (idCard != null) {
    memberInfoModel.idCard = idCard;
  }
  final String? chapterCode = jsonConvert.convert<String>(json['chapterCode']);
  if (chapterCode != null) {
    memberInfoModel.chapterCode = chapterCode;
  }
  final String? branchBelongs = jsonConvert.convert<String>(
      json['branchBelongs']);
  if (branchBelongs != null) {
    memberInfoModel.branchBelongs = branchBelongs;
  }
  final String? sex = jsonConvert.convert<String>(json['sex']);
  if (sex != null) {
    memberInfoModel.sex = sex;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    memberInfoModel.city = city;
  }
  final String? openCity = jsonConvert.convert<String>(json['openCity']);
  if (openCity != null) {
    memberInfoModel.openCity = openCity;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    memberInfoModel.phone = phone;
  }
  final String? account = jsonConvert.convert<String>(json['account']);
  if (account != null) {
    memberInfoModel.account = account;
  }
  final String? serialNumber = jsonConvert.convert<String>(
      json['serialNumber']);
  if (serialNumber != null) {
    memberInfoModel.serialNumber = serialNumber;
  }
  final String? certificateBeginTime = jsonConvert.convert<String>(
      json['certificateBeginTime']);
  if (certificateBeginTime != null) {
    memberInfoModel.certificateBeginTime = certificateBeginTime;
  }
  final String? certificateEndTime = jsonConvert.convert<String>(
      json['certificateEndTime']);
  if (certificateEndTime != null) {
    memberInfoModel.certificateEndTime = certificateEndTime;
  }
  final String? loginTime = jsonConvert.convert<String>(json['loginTime']);
  if (loginTime != null) {
    memberInfoModel.loginTime = loginTime;
  }
  final String? openTime = jsonConvert.convert<String>(json['openTime']);
  if (openTime != null) {
    memberInfoModel.openTime = openTime;
  }
  final int? payStatus = jsonConvert.convert<int>(json['payStatus']);
  if (payStatus != null) {
    memberInfoModel.payStatus = payStatus;
  }
  final List<MemberInfoBankList>? bankList = (json['bankList'] as List<
      dynamic>?)
      ?.map(
          (e) =>
      jsonConvert.convert<MemberInfoBankList>(e) as MemberInfoBankList)
      .toList();
  if (bankList != null) {
    memberInfoModel.bankList = bankList;
  }
  final String? starRating = jsonConvert.convert<String>(json['starRating']);
  if (starRating != null) {
    memberInfoModel.starRating = starRating;
  }
  final int? points = jsonConvert.convert<int>(json['points']);
  if (points != null) {
    memberInfoModel.points = points;
  }
  final int? couponsNum = jsonConvert.convert<int>(json['couponsNum']);
  if (couponsNum != null) {
    memberInfoModel.couponsNum = couponsNum;
  }
  final String? credit = jsonConvert.convert<String>(json['credit']);
  if (credit != null) {
    memberInfoModel.credit = credit;
  }
  final double? incomeTotal = jsonConvert.convert<double>(json['incomeTotal']);
  if (incomeTotal != null) {
    memberInfoModel.incomeTotal = incomeTotal;
  }
  final double? expensesTotal = jsonConvert.convert<double>(
      json['expensesTotal']);
  if (expensesTotal != null) {
    memberInfoModel.expensesTotal = expensesTotal;
  }
  final int? peas = jsonConvert.convert<int>(json['peas']);
  if (peas != null) {
    memberInfoModel.peas = peas;
  }
  return memberInfoModel;
}

Map<String, dynamic> $MemberInfoModelToJson(MemberInfoModel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['bankId'] = entity.bankId;
  data['realName'] = entity.realName;
  data['cardAlias'] = entity.cardAlias;
  data['accountBalance'] = entity.accountBalance;
  data['appAccount'] = entity.appAccount;
  data['idCard'] = entity.idCard;
  data['chapterCode'] = entity.chapterCode;
  data['branchBelongs'] = entity.branchBelongs;
  data['sex'] = entity.sex;
  data['city'] = entity.city;
  data['openCity'] = entity.openCity;
  data['phone'] = entity.phone;
  data['account'] = entity.account;
  data['serialNumber'] = entity.serialNumber;
  data['certificateBeginTime'] = entity.certificateBeginTime;
  data['certificateEndTime'] = entity.certificateEndTime;
  data['loginTime'] = entity.loginTime;
  data['openTime'] = entity.openTime;
  data['payStatus'] = entity.payStatus;
  data['bankList'] = entity.bankList.map((v) => v.toJson()).toList();
  data['starRating'] = entity.starRating;
  data['points'] = entity.points;
  data['couponsNum'] = entity.couponsNum;
  data['credit'] = entity.credit;
  data['incomeTotal'] = entity.incomeTotal;
  data['expensesTotal'] = entity.expensesTotal;
  data['peas'] = entity.peas;
  return data;
}

extension MemberInfoModelExtension on MemberInfoModel {
  MemberInfoModel copyWith({
    String? id,
    String? bankId,
    String? realName,
    String? cardAlias,
    double? accountBalance,
    String? appAccount,
    String? idCard,
    String? chapterCode,
    String? branchBelongs,
    String? sex,
    String? city,
    String? openCity,
    String? phone,
    String? account,
    String? serialNumber,
    String? certificateBeginTime,
    String? certificateEndTime,
    String? loginTime,
    String? openTime,
    int? payStatus,
    List<MemberInfoBankList>? bankList,
    String? starRating,
    int? points,
    int? couponsNum,
    String? credit,
    double? incomeTotal,
    double? expensesTotal,
    int? peas,
  }) {
    return MemberInfoModel()
      ..id = id ?? this.id
      ..bankId = bankId ?? this.bankId
      ..realName = realName ?? this.realName
      ..cardAlias = cardAlias ?? this.cardAlias
      ..accountBalance = accountBalance ?? this.accountBalance
      ..appAccount = appAccount ?? this.appAccount
      ..idCard = idCard ?? this.idCard
      ..chapterCode = chapterCode ?? this.chapterCode
      ..branchBelongs = branchBelongs ?? this.branchBelongs
      ..sex = sex ?? this.sex
      ..city = city ?? this.city
      ..openCity = openCity ?? this.openCity
      ..phone = phone ?? this.phone
      ..account = account ?? this.account
      ..serialNumber = serialNumber ?? this.serialNumber
      ..certificateBeginTime = certificateBeginTime ?? this.certificateBeginTime
      ..certificateEndTime = certificateEndTime ?? this.certificateEndTime
      ..loginTime = loginTime ?? this.loginTime
      ..openTime = openTime ?? this.openTime
      ..payStatus = payStatus ?? this.payStatus
      ..bankList = bankList ?? this.bankList
      ..starRating = starRating ?? this.starRating
      ..points = points ?? this.points
      ..couponsNum = couponsNum ?? this.couponsNum
      ..credit = credit ?? this.credit
      ..incomeTotal = incomeTotal ?? this.incomeTotal
      ..expensesTotal = expensesTotal ?? this.expensesTotal
      ..peas = peas ?? this.peas;
  }
}

MemberInfoBankList $MemberInfoBankListFromJson(Map<String, dynamic> json) {
  final MemberInfoBankList memberInfoBankList = MemberInfoBankList();
  final String? bankCard = jsonConvert.convert<String>(json['bankCard']);
  if (bankCard != null) {
    memberInfoBankList.bankCard = bankCard;
  }
  final String? realName = jsonConvert.convert<String>(json['realName']);
  if (realName != null) {
    memberInfoBankList.realName = realName;
  }
  final double? accountBalance = jsonConvert.convert<double>(
      json['accountBalance']);
  if (accountBalance != null) {
    memberInfoBankList.accountBalance = accountBalance;
  }
  final String? bankName = jsonConvert.convert<String>(json['bankName']);
  if (bankName != null) {
    memberInfoBankList.bankName = bankName;
  }
  final String? openOutlets = jsonConvert.convert<String>(json['openOutlets']);
  if (openOutlets != null) {
    memberInfoBankList.openOutlets = openOutlets;
  }
  final String? openTime = jsonConvert.convert<String>(json['openTime']);
  if (openTime != null) {
    memberInfoBankList.openTime = openTime;
  }
  final String? cardType = jsonConvert.convert<String>(json['cardType']);
  if (cardType != null) {
    memberInfoBankList.cardType = cardType;
  }
  final String? starRating = jsonConvert.convert<String>(json['starRating']);
  if (starRating != null) {
    memberInfoBankList.starRating = starRating;
  }
  final String? openCity = jsonConvert.convert<String>(json['openCity']);
  if (openCity != null) {
    memberInfoBankList.openCity = openCity;
  }
  final String? branchBelongs = jsonConvert.convert<String>(
      json['branchBelongs']);
  if (branchBelongs != null) {
    memberInfoBankList.branchBelongs = branchBelongs;
  }
  return memberInfoBankList;
}

Map<String, dynamic> $MemberInfoBankListToJson(MemberInfoBankList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['bankCard'] = entity.bankCard;
  data['realName'] = entity.realName;
  data['accountBalance'] = entity.accountBalance;
  data['bankName'] = entity.bankName;
  data['openOutlets'] = entity.openOutlets;
  data['openTime'] = entity.openTime;
  data['cardType'] = entity.cardType;
  data['starRating'] = entity.starRating;
  data['openCity'] = entity.openCity;
  data['branchBelongs'] = entity.branchBelongs;
  return data;
}

extension MemberInfoBankListExtension on MemberInfoBankList {
  MemberInfoBankList copyWith({
    String? bankCard,
    String? realName,
    double? accountBalance,
    String? bankName,
    String? openOutlets,
    String? openTime,
    String? cardType,
    String? starRating,
    String? openCity,
    String? branchBelongs,
  }) {
    return MemberInfoBankList()
      ..bankCard = bankCard ?? this.bankCard
      ..realName = realName ?? this.realName
      ..accountBalance = accountBalance ?? this.accountBalance
      ..bankName = bankName ?? this.bankName
      ..openOutlets = openOutlets ?? this.openOutlets
      ..openTime = openTime ?? this.openTime
      ..cardType = cardType ?? this.cardType
      ..starRating = starRating ?? this.starRating
      ..openCity = openCity ?? this.openCity
      ..branchBelongs = branchBelongs ?? this.branchBelongs;
  }
}
