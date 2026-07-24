import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:wb_base_widget/component/count_down_btn.dart';
import 'package:wb_base_widget/extension/string_extension.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../../config/app_config.dart';
import '../../utils/local_notifications.dart';

/// 转账等场景下，通知文案使用 [Config.buildTransferAuthNotificationBody]。
class AuthSmTransferContext {
  const AuthSmTransferContext({
    required this.payeeName,
    required this.cardLast4,
    required this.amountDisplay,
  });

  final String payeeName;
  final String cardLast4;
  final String amountDisplay;
}

class AuthSm extends StatefulWidget {
  final VoidCallback callBack;
  final AuthSmTransferContext? transferContext;

  const AuthSm({
    super.key,
    required this.callBack,
    this.transferContext,
  });

  @override
  State<AuthSm> createState() => _AuthSmState();
}

class _AuthSmState extends State<AuthSm> {
  CountDownBtnController downBtnController = CountDownBtnController();

  String _typed = '';
  static const int _maxLength = 6;
  bool _submitted = false;

  final String code = Random().nextVerificationCode(6);
  late final String name =
      AppConfig.config.abcLogic.memberInfo.realName.removeFirstChar1();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      downBtnController.click();
      final cfg = AppConfig.config;
      final transfer = widget.transferContext;
      final String body;
      if (transfer != null) {
        body = cfg.buildTransferAuthNotificationBody(
          code: code,
          payee: transfer.payeeName,
          cardLast4: transfer.cardLast4,
          amount: transfer.amountDisplay,
        );
      } else {
        final smsId = Random().nextVerificationCode(4);
        body = cfg.buildAuthSmNotificationBody(
          code: code,
          name: name,
          smsId: smsId,
        );
      }
      NotificationHelper.getInstance().showNotification(
        title: cfg.authSmNotificationTitle,
        body: body,
        payload: 'payload',
      );
    });
  }

  void _submit() {
    if (_submitted || !mounted) return;
    _submitted = true;
    SmartDialog.dismiss();
    widget.callBack();
  }

  void _onDigitTap(String digit) {
    if (_typed.length >= _maxLength) return;
    setState(() => _typed += digit);
    if (_typed.length == _maxLength) {
      Future.delayed(const Duration(milliseconds: 150), () => _submit());
    }
  }

  void _onBackspace() {
    if (_typed.isEmpty) return;
    setState(() => _typed = _typed.substring(0, _typed.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final phone = AppConfig.config.abcLogic.memberInfo.phone;
    final phoneTail = phone.isEmpty ? '--' : phone.getLastFourByList();

    return SizedBox(
      width: 1.sw,
      height: 1.sh,
      child: Stack(
        children: [
          // 居中弹窗
          Positioned(
            top: 1.sh * 0.25,
            left: 1.sw * 0.075,
            child: Container(
              width: 1.sw * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox().expanded(),
                      BaseText(
                        text: '手机交易码',
                        fontSize: 16.sp,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ).expanded(),
                      BaseText(
                        text: '   ×',
                        fontSize: 20.sp,
                        color: const Color(0xff999999),
                      ).withOnTap(onTap: () => SmartDialog.dismiss()).expanded(),
                    ],
                  ).withPadding(
                    top: 14.w,
                    bottom: 14.w,
                    left: 16.w,
                    right: 16.w,
                  ),

                  Container(height: 0.5.w, color: const Color(0xffD8D8E0)),

                  // 提示文字
                  BaseText(
                    text: '已发送至尾号$phoneTail的手机',
                    fontSize: 14.sp,
                    color: const Color(0xff222222),
                  ).withPadding(top: 16.w, bottom: 16.w, left: 16.w),

                  // 圆点输入框
                  Container(
                    height: 50.w,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xff666666), width: 0.8),
                    ),
                    child: Row(
                      children: List.generate(_maxLength, (i) {
                        final digit = i < _typed.length ? _typed[i] : null;
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: i < _maxLength - 1
                                    ? const BorderSide(
                                        color: Color(0xffdedede), width: 0.8)
                                    : BorderSide.none,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: digit != null
                                ? Text(
                                    digit,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 12.w),

                  // 收不到短信 / 倒计时
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BaseText(
                        text: '收不到短信？',
                        fontSize: 12.sp,
                        color: const Color(0xff2D70ED),
                      ).withPadding(left: 12.w),
                      WzhCountDownBtn(
                        controller: downBtnController,
                        showBord: false,
                        textColor: Colors.black,
                        getVCode: () async => true,
                      ),
                    ],
                  ).withPadding(left: 18.w, right: 18.w),

                  SizedBox(height: 16.w),
                ],
              ),
            ),
          ),

          // 底部数字键盘
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _SafeKeyboard(
              onDigit: _onDigitTap,
              onBackspace: _onBackspace,
              onDone: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeKeyboard extends StatefulWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  const _SafeKeyboard({
    required this.onDigit,
    required this.onBackspace,
    required this.onDone,
  });

  @override
  State<_SafeKeyboard> createState() => _SafeKeyboardState();
}

class _SafeKeyboardState extends State<_SafeKeyboard> {
  late final List<String> _digits;

  @override
  void initState() {
    super.initState();
    _digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
      ..shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      [_digits[0], _digits[1], _digits[2]],
      [_digits[3], _digits[4], _digits[5]],
      [_digits[6], _digits[7], _digits[8]],
      ['', _digits[9], '⌫'],
    ];

    return Container(
      color: const Color(0xffD1D5DB),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 键盘标题栏
          SizedBox(
            height: 44.w,
            child: Row(
              children: [
                Expanded(child: SizedBox()),
                Text(
                  '中国银行安全键盘',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xff333333),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: widget.onDone,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Text(
                          '完成',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffDC0034),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 数字行
          ...rows.map((row) {
            return Row(
              children: row.map((key) {
                return Expanded(
                  child: _KeyCell(
                    label: key,
                    onDigit: widget.onDigit,
                    onBackspace: widget.onBackspace,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _KeyCell extends StatelessWidget {
  final String label;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _KeyCell({
    required this.label,
    required this.onDigit,
    required this.onBackspace,
  });

  bool get _isEmpty => label.isEmpty;
  bool get _isBackspace => label == '⌫';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isEmpty
          ? null
          : (_isBackspace ? onBackspace : () => onDigit(label)),
      child: Container(
        height: 56.w,
        margin: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: _isEmpty || _isBackspace
              ? const Color(0xffCDD0D6)
              : Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: (_isEmpty || _isBackspace)
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        alignment: Alignment.center,
        child: _isEmpty
            ? const SizedBox.shrink()
            : _isBackspace
                ? Icon(Icons.backspace_outlined,
                    size: 24.w, color: const Color(0xff555555))
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
      ),
    );
  }
}
