
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/double_extension.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import '../../utils/sp_util.dart';
import '../dio/network.dart';
import '../model/member_info_model.dart';
import '../net_config/apis.dart';


class BocLogic extends GetxController {
  var showValue = false.obs;

  MemberInfoModel memberInfo = MemberInfoModel();


  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void onInit() {
    super.onInit();
    memberInfoData();
  }

  Future memberInfoData() async {

    if (token == '') return;
    await Http.post(Apis.memberInfo,isLoading: false).then((value) {
      if (value is Map<String, dynamic>) {
        memberInfo = MemberInfoModel.fromJson(value);
        update(['updateBalance','updateUI','updateCard']);
      }
    });

  }

  void showBalance({
    bool show = false,
  }) {
    showValue.value = show;
    update(['updateBalance', 'updateEyeBalance']);
  }

  String balance() {
    // var formatter = NumberFormat();
    // var formattedNumber = formatter.format(memberInfo.accountBalance);
    // return formattedNumber;
    return memberInfo.accountBalance.bankBalance;
  }

  String openOutlets(){
    if(memberInfo.bankList.isNotEmpty){
      return memberInfo.bankList.first.openOutlets;
    }
    return '--';
  }

  DateTime openTime(){
    return DateTime.parse(memberInfo.openTime);
  }

  String openCity(){
    if(memberInfo.openCity == ''){
      return memberInfo.city;
    }
    return memberInfo.openCity;
  }


  String cardInfo(){
    if(memberInfo.bankList.isNotEmpty){
      return '${memberInfo.bankList.first.bankName}（${memberInfo.bankList.first.bankCard.getLastFourByList()}）';
    }
    return '--';
  }

  String card(){
    if(memberInfo.bankList.isNotEmpty){
      return memberInfo.bankList.first.bankCard.maskBankCardNumber(
        fixStr: ' ',
        maskCharCount: 6,
      );
    }
    return '--';
  }

  String card1(){
    if(memberInfo.bankList.isNotEmpty){
      return memberInfo.bankList.first.bankCard;
    }
    return '--';
  }

  String card2(){
    if(memberInfo.bankList.isNotEmpty){
      return '${memberInfo.bankList.first.bankCard.substring(0,6)}****${memberInfo.bankList.first.bankCard.getLastFourByList()}';
    }
    return '--';
  }

  String cardFour(){
    if(memberInfo.bankList.isNotEmpty){
      return memberInfo.bankList.first.bankCard.getLastFourByList();
    }
    return '--';
  }

  String branchBelongs(){
    return memberInfo.branchBelongs.isEmpty ? '--' : memberInfo.branchBelongs;
  }


  String phone(){
    return memberInfo.phone.desensitize();
  }

  String realName(){
    return replaceFirstChar(memberInfo.realName);
  }

  String replaceFirstChar(String input) {
    if (input.isEmpty) return input;
    return input.replaceFirst(input[0], '*');
  }

}
