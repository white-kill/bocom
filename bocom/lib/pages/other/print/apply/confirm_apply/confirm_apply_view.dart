import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:bocom/pages/other/print/apply/req_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/component/alter_widget.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../../../../../utils/abc_button.dart';
import '../../../../component/auth_sm.dart';
import 'confirm_apply_logic.dart';
import 'confirm_apply_state.dart';

class ConfirmApplyPage extends BaseStateless {
  ConfirmApplyPage({Key? key}) : super(key: key,title: '确认信息');

  final ConfirmApplyLogic logic = Get.put(ConfirmApplyLogic());
  final ConfirmApplyState state = Get.find<ConfirmApplyLogic>().state;



  @override
  Widget initBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Column(
          children: state.title.map((e){
            if(e == '') return SizedBox(height: 12.w,);
            return Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10.w,horizontal: 20.w),
              child: Row(
                children: [
                  BaseText(text: e,maxLines: 2,).withContainer(
                    width: 80.w
                  ),
                  SizedBox(width: 20.w,),
                  BaseText(text: logic.valueStr(e),style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),)
                ],
              ),
            );
          }).toList(),
        ),

        AbcButton(
          title: '下一步',
          width: 345.w,
          height: 43.w,
          radius: 4.w,
          margin: EdgeInsets.only(
            left: 15.w,
            right: 15.w,
            top: 60.w,
          ),onTap: (){
          AlterWidget.alterWidget(builder: (BuildContext context) {
            return  AuthSm(callBack: (){
              print(state.reqPrint.toJson());
              Http.post(Apis.print,data: state.reqPrint.toJson()).then((v){
                Get.back();
                Get.back();
              });
            },);
          }
          );
        },)
      ],
    );
  }
}
