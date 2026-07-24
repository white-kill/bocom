import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/component/grid_view_widget.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class BaseBottomSheet {
  static Future sheetContentWidget({
    String title = '请选择',
    required Widget child,
    Widget? topWidget,
    Widget? leftWidget,
    Widget? rightWidget,
    Color? bgColor,
    BuildContext? context,
    Function? sureCallBack,
  }) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      context:context?? Get.context!,
      builder: (context) {
        return CpdAlterWidget(
          title: title,
          topWidget: topWidget,
          child1: child,
          bgColor: bgColor,
          leftWidget: leftWidget,
          rightWidget: rightWidget,
          sureCallBack: sureCallBack,
        );
      },
    );
  }
}

class CpdAlterWidget extends StatefulWidget {
  final String title;
  final Widget child1;
  final Widget? topWidget;
  final Color? bgColor;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final Function? sureCallBack;

  const CpdAlterWidget({
    super.key,
    required this.title,
    required this.child1,
    this.topWidget,
    this.bgColor,
    this.leftWidget,
    this.rightWidget,
    this.sureCallBack,
  });

  @override
  State<CpdAlterWidget> createState() => _CpdAlterWidgetState();
}

class _CpdAlterWidgetState extends State<CpdAlterWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: _decoration(widget.bgColor),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            widget.topWidget?? _topWidget(),
            Container(
              width: 1.sw,
              height: 0.5.w,
              color: Color.fromARGB(255, 235, 235, 235),
            ),
            widget.child1,
            SizedBox(height: 10.w,)
          ],
        ),
      ).withContainer(
        width: 1.sw,
        height: 1.sh,
        color: Colors.transparent,
        alignment: Alignment.bottomCenter,
      ),
    );
  }

  Decoration _decoration(Color? bgColor) {
    return BoxDecoration(
      color: bgColor??Colors.white,
      // borderRadius: BorderRadius.only(
      //   topLeft: Radius.circular(8.w),
      //   topRight: Radius.circular(8.w),
      // ),
    );
  }

  Widget _topWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [


       (widget.leftWidget?? BaseText(
          text:'取消',
          color: Colors.blueAccent,
        )).withOnTap(onTap: () {
          Navigator.of(context).pop();
        }),
        
        BaseText(
          text: widget.title,
          style: TextStyle(
            fontSize: 16.sp,
          ),
        ),


       ( widget.rightWidget?? BaseText(
         text:'确认',
          color: Colors.blueAccent,
        )).withOnTap(onTap: () {
          widget.sureCallBack?.call();
          Navigator.of(context).pop();
        }),

      ],
    ).withPadding(
      left: 10.w,
      right: 10.w,
      top: 14.w,
      bottom: 14.w,
    );
  }
}
