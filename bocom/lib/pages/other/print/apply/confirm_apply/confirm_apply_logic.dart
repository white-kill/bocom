import 'package:bocom/config/app_config.dart';
import 'package:get/get.dart';

import 'confirm_apply_state.dart';

class ConfirmApplyLogic extends GetxController {
  final ConfirmApplyState state = ConfirmApplyState();



  String valueStr(String name){
     if(name == '姓名') return AppConfig.config.abcLogic.memberInfo.realName;
    if(name == '账户') return AppConfig.config.abcLogic.card();
    if(name == '查询时段') return '${state.reqPrint.beginTime.replaceAll('-', '/')}至${state.reqPrint.endTime.replaceAll('-', '/')}';
    if(name == '收支') return  state.reqPrint.transactionType == ''?'全部': state.reqPrint.transactionType;
    if(name == '币种') return state.reqPrint.currency;
    if(name == '展示交易对方信息') return state.reqPrint.showType.contains('0')?'是':'否';
    if(name == '展示完整卡号/账号') return state.reqPrint.showType.contains('1')?'是':'否';
    if(name == '邮箱') return state.reqPrint.email;
    if(name == '安全工具') return '手机交易码';
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments['showEmile'] == false){
      state.title.remove('邮箱');
    }
    state.reqPrint = Get.arguments['model'];
  }
}
