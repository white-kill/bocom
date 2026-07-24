import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/component/bottom_sheet_widget.dart';

class SheetBottom {

  static show({
    String title = '请选择',
    Widget? child,
    BuildContext? context,
    Widget? leftWidget,
    Widget? rightWidget,
    Widget? topWidget,
    bool showTopText = false,
    Function? sureCallBack,
}){
    BaseBottomSheet.sheetContentWidget(
        title: title,
        context: context,
        // leftWidget: leftWidget??SizedBox(width: 24.w,),
        // rightWidget: rightWidget??SizedBox(width: 24.w,),
        leftWidget: !showTopText?leftWidget??SizedBox(width: 24.w,):Icon(Icons.clear,size: 24.w,color: Color(0xff999999),),
        rightWidget: !showTopText? rightWidget??SizedBox(width: 24.w,):Container(width: 24.w,),
        topWidget: topWidget,
        sureCallBack: sureCallBack,
        child:  Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: child,
        ));
  }

}