import 'package:bocom/config/app_config.dart';
import 'package:bocom/pages/other/print/apply/bz_widget.dart';
import 'package:bocom/pages/other/print/apply/confirm_apply/confirm_apply_view.dart';
import 'package:bocom/pages/other/print/apply/right_widget.dart';
import 'package:bocom/pages/other/print/apply/sz_widget.dart';
import 'package:bocom/utils/abc_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/component/alter_widget.dart';
import 'package:wb_base_widget/component/text_field_widget.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../../../../utils/color_util.dart';
import 'apply_logic.dart';
import 'apply_state.dart';

class ApplyPage extends BaseStateless {
  ApplyPage({Key? key}) : super(key: key, title: '交易流水打印申请');

  final ApplyLogic logic = Get.put(ApplyLogic());
  final ApplyState state = Get.find<ApplyLogic>().state;

  @override
  Widget initBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 92.5.w,
          width: 360.w,
          margin: EdgeInsets.all(
            10.w,
          ),
          padding: EdgeInsets.only(
            left: 15.w,
            right: 15.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6.w)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BaseText(
                    text: '姓名',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  BaseText(
                    text: AppConfig.config.abcLogic.memberInfo.realName,
                    style: TextStyle(fontSize: 15, color: Color(0xff6C6C6C)),
                  ),
                ],
              ).expanded(),
              Container(
                width: 1.sw,
                height: 0.5.w,
                color: Color(0xffF4F4F4),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BaseText(
                    text: '账户',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  BaseText(
                    text: AppConfig.config.abcLogic.card(),
                    style: TextStyle(fontSize: 15, color: Color(0xff6C6C6C)),
                  ),
                ],
              ).expanded(),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.w),
          padding: EdgeInsets.only(left: 15.w, right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6.w)),
          ),
          child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  width: 1.sw,
                  height: 48.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BaseText(
                        text: state.titles[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      _leftWidget(state.titles[index]),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  width: 1.sw,
                  height: 0.5.w,
                  color: Color(0xffF4F4F4),
                );
              },
              itemCount: state.titles.length),
        ),
        Container(
          width: 360.w,
          margin: EdgeInsets.all(
            10.w,
          ),
          padding: EdgeInsets.only(
            left: 15.w,
            right: 15.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6.w)),
          ),
          child: Obx(() => Column(
                children: [
                  Container(
                    width: 1.sw,
                    height: 48.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BaseText(
                          text: '是否发送邮箱',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        CupertinoSwitch(
                            value: logic.showEmile.value,
                            activeColor: const Color.fromARGB(255, 3, 134, 91),
                            onChanged: (bool value) {
                              logic.showEmile.value = value;
                              if (value == false) {
                                state.reqPrint.email == '';
                              }
                            })
                      ],
                    ),
                  ),
                  !logic.showEmile.value
                      ? const SizedBox.shrink()
                      : Container(
                          width: 1.sw,
                          height: 0.5.w,
                          color: Color(0xffF4F4F4),
                        ),
                  !logic.showEmile.value
                      ? const SizedBox.shrink()
                      : Container(
                          width: 1.sw,
                          height: 48.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BaseText(
                                text: '邮箱',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(
                                width: 80.w,
                              ),
                              TextFieldWidget(
                                hintText: '请输入',
                                onChanged: (v) {
                                  state.reqPrint.email = v;
                                },
                              ).expanded(),
                            ],
                          ),
                        ),
                ],
              )),
        ),
        AbcButton(
          title: '下一步',
          width: 345.w,
          height: 43.w,
          radius: 4.w,
          margin: EdgeInsets.only(
            left: 15.w,
            right: 15.w,
            top: 34.w,
          ),
          onTap: () {
            AlterWidget.alterWidget(
                dismiss: true,
                builder: (context) {
                  return Container(
                    width: 1.sw * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.w),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BaseText(
                          text: '请核对您的邮箱',
                          style: TextStyle(
                            fontSize: 16,
                            color: titleColor ?? Colors.black,
                          ),
                        ).withPadding(top: 12.w),
                        SizedBox(
                          height: 15.w,
                        ),
                        Container(
                          width: 1.sw * 0.8,
                          height: 45.w,
                          color: BColors.mainColor.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: 'tag12'.png,
                                width: 16,
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '您正在使用语音播报服务，需打开播报开关',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: '立\n即开启',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        BaseText(
                          maxLines: 20,
                          text: '邮箱${state.reqPrint.email}，请确保无误。'
                              '后续交易流水文件将经过加密发送至您指定的邮箱。',
                          style: TextStyle(color: Color(0xff666666)),
                        ).withContainer(
                            width: 1.sw * 0.7,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                top: 20.w,
                                left: 12.w,
                                right: 12.w,
                                bottom: 25.w)),
                        Row(
                          children: [
                            AbcButton(
                              title: '更改',
                              bgColor: Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(4.w)),
                              titleColor: const Color(0xffCF0000),
                              border: Border(
                                top: BorderSide(
                                    width: 1.w, color: const Color(0xFFE7E7E7)),
                              ),
                              onTap: () {
                                SmartDialog.dismiss();
                              },
                            ).expanded(),
                            AbcButton(
                              title: '确认',
                              bgColor: Color(0xffCF0000),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(4.w)),
                              onTap: () {
                                SmartDialog.dismiss();
                                state.reqPrint.showType =
                                    state.showTypeList.join(',');
                                Get.to(() => ConfirmApplyPage(), arguments: {
                                  'model': state.reqPrint,
                                  'showEmile': logic.showEmile.value
                                });
                              },
                            ).expanded(),
                          ],
                        ),
                      ],
                    ),
                  );
                });
          },
        )
      ],
    );
  }

  Widget _leftWidget(String name) {
    if (name == '查询时段') {
      return GetBuilder<ApplyLogic>(builder: (_){
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BaseText(
              text:
              '${state.reqPrint.beginTime.replaceAll('-', '/')}至${state.reqPrint.endTime.replaceAll('-', '/')}',
              style: TextStyle(fontSize: 15, color: Color(0xff222222)),
            ),
            Image(
              image: 'ic_jt_right'.png3x,
              color: Color(0xff222222),
              width: 22.w,
            )
          ],
        ).withOnTap(onTap: () {
          SmartDialog.show(
            alignment: Alignment.centerRight,
            builder: (context) {
              return const RightWidget();
            },
          );
        });
      },id: 'updateTime',);
    }
    if (name == '收支') {
      return SzWidget();
    }
    if (name == '币种') {
      return const BzWidget();
    }
    if (name == '展示交易对方信息') {
      return Obx(() => CupertinoSwitch(
          value: logic.dfinfo.value,
          activeColor: const Color.fromARGB(255, 3, 134, 91),
          onChanged: (bool value) {
            logic.dfinfo.value = value;
            if (value) {
              state.showTypeList.remove('0');
              state.showTypeList.add('0');
            } else {
              state.showTypeList.remove('0');
            }
          }));
    }
    if (name == '展示完整卡号/账号') {
      return Obx(() => CupertinoSwitch(
          value: logic.wzCardNo.value,
          activeColor: const Color.fromARGB(255, 3, 134, 91),
          onChanged: (bool value) {
            logic.wzCardNo.value = value;
            if (value) {
              state.showTypeList.remove('1');
              state.showTypeList.add('1');
            } else {
              state.showTypeList.remove('1');
            }
          }));
    }
    return const SizedBox.shrink();
  }
}
