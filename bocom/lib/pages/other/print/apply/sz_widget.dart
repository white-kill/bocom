import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'apply_logic.dart';
import 'apply_state.dart';

class SzWidget extends StatefulWidget {
  const SzWidget({super.key});

  @override
  State<SzWidget> createState() => _SzWidgetState();
}

class _SzWidgetState extends State<SzWidget> {

  List titles = [
    '全部',
    '收入',
    '支出'
  ];

  String selectTitle = '全部';
  final ApplyState state = Get.find<ApplyLogic>().state;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5.w,
      children: titles.map((e){
        bool sel = selectTitle == e;
        return Container(
          width: 66.w,
          height: 35.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel?Color(0xffFDF5F7):Color(0xffF4F4F4),
            borderRadius: BorderRadius.all(Radius.circular(4.w,)),
            border: sel?Border.all(color: Color(0xffDC0034),width: 1.w):null
          ),
          child: BaseText(text: e,style: TextStyle(
            color: sel?Color(0xffDC0034):Color(0xff222222),
            fontWeight: FontWeight.bold,
            fontSize: 13
          ),),
        ).withOnTap(onTap: (){
          selectTitle = e;
          if(e == '全部'){
            state.reqPrint.transactionType = '';
          }else {
            state.reqPrint.transactionType = e;
          }
          setState(() {});
        });
      }).toList(),
    );
  }
}
