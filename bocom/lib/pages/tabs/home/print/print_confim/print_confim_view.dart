import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'print_confim_logic.dart';
import 'print_confim_state.dart';

class PrintConfimPage extends BaseStateless {
  PrintConfimPage({Key? key}) : super(key: key, title: "开立交易明细");

  final PrintConfimLogic logic = Get.put(PrintConfimLogic());
  final PrintConfimState state = Get.find<PrintConfimLogic>().state;

  @override
  Color? get navColor => Colors.white;

  @override
  Color? get background => const Color(0xFFF5F5F5);

  @override
  List<Widget>? get rightAction => const [];

  @override
  Widget initBody(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ListView(
      padding: EdgeInsets.zero,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        SizedBox(height: 12.w),
        _emailRow(),
        _switchGroup([
          _SwitchItem(
            title: '展示我的完整账号/卡号',
            value: logic.showFullAccount,
          ),
          _SwitchItem(
            title: '展示我的证件类型、号码',
            value: logic.showCertificate,
          ),
          _SwitchItem(
            title: '展示交易地点',
            value: logic.showLocation,
          ),
          _SwitchItem(
            title: '展示账户余额',
            value: logic.showBalance,
            showDivider: false,
          ),
        ]),
        SizedBox(height: 10.w),
        _switchGroup([
          _SwitchItem(
            title: '展示对方账户信息',
            value: logic.showOppositeAccount,
            showDivider: false,
          ),
        ]),
        SizedBox(height: 30.w),
        _tips(),
        _submitButton(context)
      ],
    );
  }

  Widget _emailRow() => Container(
        height: 45.w,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 0.5.w,
              color: const Color(0xFFE3E5E8),
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Row(
          children: [
            const BaseText(
              text: '电子邮箱',
              fontSize: 15,
              color: Color(0xFF333333),
            ),
            SizedBox(width: 30.w),
            Expanded(
              child: TextField(
                controller: state.emailController,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF333333),
                ),
                decoration: InputDecoration(
                  hintText: '请输入',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFFC7CDD6),
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _switchGroup(List<_SwitchItem> items) => Container(
        color: Colors.white,
        child: Column(
          children: items.map(_switchRow).toList(growable: false),
        ),
      );

  Widget _switchRow(_SwitchItem item) => Column(
        children: [
          SizedBox(
            height: 45.w,
            child: Padding(
              padding: EdgeInsets.only(left: 15.w, right: 15.w),
              child: Row(
                children: [
                  Expanded(
                    child: BaseText(
                      text: item.title,
                      fontSize: 15,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  Obx(
                    () => Transform.scale(
                      scale: 0.82,
                      child: CupertinoSwitch(
                        value: item.value.value,
                        activeColor: const Color(0xFF0075F6),
                        trackColor: const Color(0xFFF7F8FA),
                        onChanged: (value) => item.value.value = value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (item.showDivider)
            Divider(
              height: 1,
              thickness: 0.5.w,
              indent: 15.w,
              endIndent: 15.w,
              color: const Color(0xFFE3E5E8),
            ),
        ],
      );

  Widget _tips() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BaseText(
              text: '温馨提示:',
              fontSize: 14,
              color: Color(0xFF8D99A8),
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 10.w),
            _tipText(
              '1.出于信息安全考虑，您所申请开立的交易明细清单将发送至您填写的邮箱地址，请确保邮箱地址正确。',
            ),
            SizedBox(height: 8.w),
            _tipText(
              '2.请您妥善保管所开立的交易明细清单，且不得对文本中的信息进行任何编辑和篡改，如因您保管不善导致文本中的信息泄露，或您自行对交易明细清单中的信息进行编辑或篡改，银行不承担责任，因银行存在过错依法应由银行承担的责任除外。',
            ),
            SizedBox(height: 8.w),
            _tipText('3.若选择展示对方信息，请在打印时选择横向打印。'),
          ],
        ),
      );

  Widget _tipText(String text) => BaseText(
    text: text,
    fontSize: 12,
    height: 1.55,
    maxLines: 100,
    color: const Color(0xFF8D99A8),
  );

  Widget _submitButton(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
          if (!logic.isEmailValid) {
            _showEmailErrorSheet(context);
            return;
          }
        },
        child: Container(
          height: 45.w,
          margin: EdgeInsets.only(left: 15.w, top: 30.w, right: 15.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0075F6),
            borderRadius: BorderRadius.circular(8.w),
          ),
          alignment: Alignment.center,
          child: const BaseText(
            text: '确认开立',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Future<void> _showEmailErrorSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) {
        final bottom = MediaQuery.paddingOf(context).bottom;
        return Container(
          height: 200.w + bottom,
          width: 1.sw,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
          ),
          child: Column(
            children: [
              SizedBox(height: 60.w),
              const BaseText(
                text: '邮箱格式错误',
                fontSize: 18,
                color: Color(0xFF111111),
                fontWeight: FontWeight.w500,
              ),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 45.w,
                  margin: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0075F6),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  alignment: Alignment.center,
                  child: const BaseText(
                    text: '知道了',
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: bottom + 18.w),
            ],
          ),
        );
      },
    );
  }
}

class _SwitchItem {
  const _SwitchItem({
    required this.title,
    required this.value,
    this.showDivider = true,
  });

  final String title;
  final RxBool value;
  final bool showDivider;
}
