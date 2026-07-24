import 'package:bocom/pages/component/sheet_widget/picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/component/bottom_sheet_widget.dart';

class AbcPicker {

  static Future showNewTime({
    String title = '请选择',
     DateTime? initialDateTime,
     ValueChanged<DateTime>? onDateTimeChanged,
     DateTimePickerNotifier? dateTimePickerNotifier,
    BuildContext? context,
    Function? sureCallBack,
    int lastYear = 1,
  }) async {
    await BaseBottomSheet.sheetContentWidget(
        title: title,
        context: context,
        sureCallBack: sureCallBack,
        child:  Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.only(
            //   topLeft: Radius.circular(8.w),
            //   topRight: Radius.circular(8.w),
            // ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200.w,
                child: DateTimePicker(
                  dateTimePickerNotifier: dateTimePickerNotifier,
                  onDateTimeChanged: onDateTimeChanged,
                  initialDateTime: initialDateTime,
                  lastYear: lastYear,
                ),
              )
            ],
          ),
        ));
  }

}