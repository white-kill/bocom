import 'package:bocom/utils/abc_button.dart';
import 'package:bocom/utils/color_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:bocom/pages/component/sheet_widget/picker_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wb_base_widget/component/grid_view_widget.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'apply_logic.dart';
import 'apply_state.dart';

class RightWidget extends StatefulWidget {
  const RightWidget({super.key});

  @override
  State<RightWidget> createState() => _RightWidgetState();
}

class _RightWidgetState extends State<RightWidget> {
  List title = ['近3月', '近6月', '近1年'];

  String selectTitle = '近1年';

  final ApplyLogic logic = Get.put(ApplyLogic());
  final ApplyState state = Get.find<ApplyLogic>().state;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = MediaQuery.of(context).padding.top + 44.w;
    return Container(
      width: 1.sw * 0.88,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: navHeight,
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(
              right: 16.w,
              bottom: 12.w,
            ),
            child: BaseText(
              text: '取消',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: BColors.mainColor),
            ),
          ),
          Container(
            width: 1.sw,
            height: 0.5.w,
            margin: EdgeInsets.only(left: 12.w, right: 12.w),
            color: Color(0xffF4F4F4),
          ),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: 1.sw,
                padding: EdgeInsets.only(left: 12.w, top: 12.w, bottom: 12.w),
                alignment: Alignment.centerLeft,
                child: BaseText(
                  text: '交易时间',
                  fontSize: 15,
                ),
              ),
              VerticalGridView(
                padding: EdgeInsets.only(left: 12.w, right: 12.w),
                widgetBuilder: (_, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: selectTitle == title[index]
                            ? BColors.mainColor.withOpacity(0.1)
                            : const Color(0xffF7F7F9),
                        borderRadius: BorderRadius.all(Radius.circular(6.w))),
                    alignment: Alignment.center,
                    child: BaseText(
                      text: title[index],
                      style: TextStyle(
                        color: selectTitle == title[index]
                            ? BColors.mainColor
                            : Colors.black,
                        fontSize: 12.sp,
                      ),
                    ),
                  ).withOnTap(onTap: () {
                    selectTitle = title[index];
                    state.beginTime = state.getTimeRange(selectTitle).first;
                    state.endTime = state.getTimeRange(selectTitle).last;
                    setState(() {});
                  });
                },
                itemCount: title.length,
                crossCount: 3,
                mainHeight: 32.w,
                spacing: 10.w,
                crossSpacing: 15.w,
              ),
              SizedBox(
                height: 15.w,
              ),
              Container(
                width: 1.sw,
                height: 0.5.w,
                margin: EdgeInsets.only(left: 12.w, right: 12.w),
                color: Color(0xffF4F4F4),
              ),
              SizedBox(
                height: 15.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // '${state.reqPrint.beginTime.replaceAll('-', '/')}至${state.reqPrint.endTime.replaceAll('-', '/')}',
                  BaseText(
                    text: state.beginTime.replaceAll('-', '/'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xff222222)),
                  )
                      .withSizedBox(
                    width: (1.sw * 0.88 - 40.w) / 2,
                  )
                      .withOnTap(onTap: () {
                    SmartDialog.show(
                      alignment: Alignment.bottomCenter,
                      builder: (context) {
                        return _pickTime(
                            dateTimePickerNotifier: state.pickerNotifier1,
                            time: state.beginTime,
                            showDya: true,
                            onConfirm: () {
                              state.beginTime = state.temBeginTime1;
                              setState(() {});
                            },
                            onCancel: () {
                              state.temBeginTime1 = state.beginTime;
                            },
                            onDateTimeChanged: (date) {
                              String time =
                                  DateFormat('yyyy-MM-dd').format(date);
                              state.temBeginTime1 = time;
                              setState(() {});
                            });
                      },
                    );
                  }),
                  Container(
                    width: 6.w,
                    height: 1,
                    color: Color(0xff222222),
                  ),
                  BaseText(
                    text: state.endTime.replaceAll('-', '/'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xff222222)),
                  )
                      .withSizedBox(
                    width: (1.sw * 0.88 - 40.w) / 2,
                  )
                      .withOnTap(onTap: () {
                    SmartDialog.show(
                      alignment: Alignment.bottomCenter,
                      builder: (context) {
                        return _pickTime(
                            dateTimePickerNotifier: state.pickerNotifier2,
                            time: state.endTime,
                            showDya: true,
                            onConfirm: () {
                              state.endTime = state.temEndTime1;
                              setState(() {});
                            },
                            onCancel: () {
                              state.temEndTime1 = state.endTime;
                            },
                            onDateTimeChanged: (date) {
                              String time =
                                  DateFormat('yyyy-MM-dd').format(date);
                              state.temEndTime1 = time;
                              setState(() {});
                            });
                      },
                    );
                  }),
                ],
              ),
              SizedBox(
                height: 15.w,
              ),
              Container(
                width: 1.sw,
                height: 0.5.w,
                margin: EdgeInsets.only(left: 12.w, right: 12.w),
                color: Color(0xffF4F4F4),
              ),
              SizedBox(
                height: 15.w,
              ),
              BaseText(
                text: '支持开立时间十年内且跨度不超过一年的交易记录',
                style: TextStyle(color: Color(0xff666666), fontSize: 13),
              ).withPadding(left: 12.w)
            ],
          ).expanded(),
          Row(
            children: [
              AbcButton(
                title: '重置',
                bgColor: Colors.white,
                titleColor: const Color(0xffCF0000),
                border: Border(
                  top: BorderSide(width: 1.w, color: const Color(0xFFE7E7E7)),
                ),
                onTap: () {
                  state.beginTime = state.getTimeRange('近1年').first;
                  state.endTime = state.getTimeRange('近1年').last;
                },
              ).expanded(),
              AbcButton(
                title: '确认',
                bgColor: Color(0xffCF0000),
                onTap: () {
                  SmartDialog.dismiss();
                  state.reqPrint.beginTime = state.beginTime;
                  state.reqPrint.endTime = state.endTime;
                  logic.update(['updateTime']);
                },
              ).expanded(),
            ],
          ),
          SizedBox(
            height: ScreenUtil().bottomBarHeight,
          )
        ],
      ),
    );
  }

  Widget _pickTime({
    DateTimePickerNotifier? dateTimePickerNotifier,
    ValueChanged<DateTime>? onDateTimeChanged,
    bool showDya = true,
    bool showMonth = true,
    Function? onConfirm,
    Function? onCancel,
    required String time,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.w),
            topRight: Radius.circular(8.w),
          )),
      height: 260.w,
      child: Column(
        children: [
          Container(
            height: 45.w,
            padding: EdgeInsets.only(left: 15.w, right: 15.w),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.w),
                  topRight: Radius.circular(8.w),
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BaseText(
                  text: '取消',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ).withOnTap(onTap: () {
                  onCancel?.call();
                  SmartDialog.dismiss();
                }),
                BaseText(
                  text: '确认',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ).withOnTap(onTap: () {
                  onConfirm?.call();
                  SmartDialog.dismiss();
                }),
              ],
            ),
          ),
          Container(
            width: 1.sw,
            height: 210.w,
            child: DateTimePicker(
              dateTimePickerNotifier: dateTimePickerNotifier,
              showDay: showDya,
              showMonth: showMonth,
              // minimumDate 精确限制到日，今天往前整 10 年再加 1 天
              // 例：今天 2026-03-26 → 最早可选 2016-03-27
              minimumDate: () {
                final now = DateTime.now();
                return DateTime(now.year - 10, now.month, now.day + 1);
              }(),
              initialDateTime: DateTime.tryParse(time),
              onDateTimeChanged: (DateTime date) {
                onDateTimeChanged?.call(date);
              },
            ),
          )
        ],
      ),
    );
  }
}
