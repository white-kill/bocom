import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/string_extension.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../../../../config/model/apply_record_model.dart';
import 'print_records_logic.dart';
import 'print_records_state.dart';

class PrintRecordsPage extends BaseStateless {
  PrintRecordsPage({Key? key}) : super(key: key, title: '申请记录');

  final PrintRecordsLogic logic = Get.put(PrintRecordsLogic());
  final PrintRecordsState state = Get.find<PrintRecordsLogic>().state;

  @override
  bool get enablePullDown => false;

  @override
  Widget initBody(BuildContext context) {
    return GetBuilder<PrintRecordsLogic>(
      builder: (_) {
        return refreshWidget(
            controller: state.refreshController,
            child: ListView.builder(
              itemBuilder: (context, index) {
                ApplyRecordList model = state.list[index];
                return model.email == '' ? _item1(model) : _item0(model);
              },
              itemCount: state.list.length,
            ));
      },
      id: 'updateUI',
    );
  }

  Widget _item0(ApplyRecordList model) {
    return Container(
      width: 1.sw,
      height: 185.w,
      margin: EdgeInsets.only(top: 10.w),
      padding: EdgeInsets.only(left: 15.w, right: 15.w),
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 15.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BaseText(text: model.bankCard),
              Row(
                children: [
                  Image(
                    image: 'sc_dd'.png3x,
                    width: 12.w,
                    height: 12.w,
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  BaseText(text: '已发送至邮箱')
                ],
              )
            ],
          ),
          SizedBox(
            height: 12.w,
          ),
          Container(
            width: 1.sw,
            height: 0.5.w,
            margin: EdgeInsets.only(left: 12.w, right: 12.w),
            color: Color(0xffF4F4F4),
          ),
          SizedBox(
            height: 12.w,
          ),
          _itemWidget(
              '申请时间', '${model.createTime.replaceAll('-', '/')}', model),
          SizedBox(
            height: 15.w,
          ),
          _itemWidget(
              '日期区间',
              '${model.beginTime.substring(0, 10).replaceAll('-', '/')}至${model.endTime.substring(0, 10).replaceAll('-', '/')}',
              model),
          SizedBox(
            height: 15.w,
          ),
          _itemWidget('申请邮箱', model.email, model),
          SizedBox(
            height: 15.w,
          ),
          Obx(() => _itemWidget('打开密码', model.code, model, onTap: () {
                if (logic.selectRecordId.value == model.id) {
                  logic.selectRecordId.value = 0;
                } else {
                  logic.selectRecordId.value = model.id;
                }
              })),
        ],
      ),
    );
  }

  Widget _item1(ApplyRecordList model) {
    return Container(
      width: 1.sw,
      height: 155.w,
      margin: EdgeInsets.only(top: 10.w),
      padding: EdgeInsets.only(left: 15.w, right: 15.w),
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 15.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BaseText(text: model.bankCard),
              Row(
                children: [
                  Image(
                    image: 'sc_dd'.png3x,
                    width: 12.w,
                    height: 12.w,
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  BaseText(text: model.status)
                ],
              )
            ],
          ),
          SizedBox(
            height: 12.w,
          ),
          Container(
            width: 1.sw,
            height: 0.5.w,
            margin: EdgeInsets.only(left: 12.w, right: 12.w),
            color: Color(0xffF4F4F4),
          ),
          SizedBox(
            height: 12.w,
          ),
          _itemWidget(
              '申请时间', '${model.createTime.replaceAll('-', '/')}', model),
          SizedBox(
            height: 15.w,
          ),
          _itemWidget(
              '日期区间',
              '${model.beginTime.substring(0, 10).replaceAll('-', '/')}至${model.endTime.substring(0, 10).replaceAll('-', '/')}',
              model),
          SizedBox(
            height: 15.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: 'xztag'.png3x,
                width: 21.w,
              ),
              BaseText(
                text: '预览并下载',
                color: Color(0xff0066EF),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _itemWidget(String name, String value, ApplyRecordList model,
      {Function? onTap}) {
    return Row(
      children: [
        BaseText(
          text: name,
          style: TextStyle(color: Color(0xff666666), fontSize: 13),
        ).withContainer(
          width: 100.w,
        ),
        name == '打开密码'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BaseText(
                    text: logic.selectRecordId.value != model.id
                        ? '******'
                        : value,
                    style: TextStyle(
                        color: Color.fromARGB(255, 171, 151, 151),
                        fontSize: 13),
                  ),
                  BaseText(text: '查看', color: Colors.blueAccent).withOnTap(
                      onTap: () {
                    onTap?.call();
                  })
                ],
              ).expanded()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BaseText(
                    text: value,
                    style: TextStyle(color: Color(0xff222222), fontSize: 13),
                  ),
                  SizedBox.shrink()
                ],
              ).expanded()
      ],
    );
  }
}
