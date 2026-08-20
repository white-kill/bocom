import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import '../print_record/print_record_view.dart';
import 'print_result_logic.dart';
import 'print_result_state.dart';

class PrintResultPage extends BaseStateless {
  PrintResultPage({
    Key? key,
    required this.email,
    required this.code,
  }) : super(key: key, title: '开立结果');

  final String email;
  final String code;

  final PrintResultLogic logic = Get.put(PrintResultLogic());
  final PrintResultState state = Get.find<PrintResultLogic>().state;

  @override
  Color? get navColor => Colors.white;

  @override
  Color? get background => const Color(0xFFF7F7F7);

  @override
  double? get lefItemWidth => 100.w;

  @override
  Widget? get leftItem => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => Get.back(),
    child: Container(
      key: const Key('print-result-safe-exit'),
      width: 60.w,
      alignment: Alignment.center,
      child: Text(
        '安全退出',
        style: TextStyle(
          color: const Color(0xFF0075E9),
          fontSize: 16.sp,
        ),
      ),
    ),
  );

  @override
  List<Widget>? get rightAction => [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.back(),
          child: Container(
            key: const Key('print-result-done'),
            width: 60.w,
            alignment: Alignment.center,
            child: Text(
              '完成',
              style: TextStyle(
                color: const Color(0xFF0075E9),
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ];

  void _openPrintRecords() => Get.to(() => PrintRecordPage());

  String get _maskedEmail {
    final separator = email.lastIndexOf('@');
    if (separator <= 0) return email;
    final localPart = email.substring(0, separator);
    final suffix = email.substring(separator);
    final visibleLength = localPart.length < 3 ? localPart.length : 3;
    final visible = localPart.substring(0, visibleLength);
    final hidden = '*' * (localPart.length - visibleLength);
    return '$visible$hidden$suffix';
  }

  @override
  Widget initBody(BuildContext context) {
    final position = StackPosition(
      designWidth: 1080,
      designHeight: 2167,
      deviceWidth: 1.sw,
    );
    final bodyTextStyle = TextStyle(
      color: const Color(0xFF333333),
      fontSize: position.getWidth(39),
      height: 1.55,
      fontWeight: FontWeight.w400,
    );
    final orangeTextStyle = bodyTextStyle.copyWith(
      color: const Color(0xFFFF7900),
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_print_result'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              left: position.getX(82),
              right: position.getX(82),
              top: position.getY(410),
              child: Text(
                '1.您的交易明细正在生成，稍后将发送至您的邮箱：\n$_maskedEmail。',
                key: const Key('print-result-email-message'),
                style: bodyTextStyle,
              ),
            ),
            Positioned(
              left: position.getX(82),
              right: position.getX(72),
              top: position.getY(565),
              child: Text.rich(
                key: const Key('print-result-security-message'),
                TextSpan(
                  style: bodyTextStyle,
                  children: [
                    const TextSpan(
                      text: '2.出于信息安全考虑，您所申请开立的交易明细将以加密文件方式发送至您填写的邮箱地址，',
                    ),
                    TextSpan(
                      text: '文件解压密码为$code',
                      style: orangeTextStyle,
                    ),
                    const TextSpan(text: '，后续您也可以在'),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Semantics(
                        button: true,
                        label: '申请记录',
                        child: GestureDetector(
                          key: const Key('print-result-inline-record'),
                          behavior: HitTestBehavior.opaque,
                          onTap: _openPrintRecords,
                          child: Text('申请记录', style: orangeTextStyle),
                        ),
                      ),
                    ),
                    const TextSpan(text: '中查看该密码。'),
                  ],
                ),
              ),
            ),
            Positioned(
              left: position.getX(300),
              right: position.getX(300),
              top: position.getY(860),
              height: position.getHeight(105),
              child: Semantics(
                button: true,
                label: '查看申请记录',
                child: SizedBox.expand(
                  key: const Key('print-result-record-button'),
                ).withOnTap(onTap: _openPrintRecords),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
