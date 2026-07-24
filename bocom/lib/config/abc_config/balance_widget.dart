import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'boc_logic.dart';

class BalanceWidget extends StatefulWidget {
  final Widget? child;
  final int length;
  final TextStyle? hitStyle;
  final double size;

  const BalanceWidget({
    super.key,
    this.child,
    this.hitStyle,
    this.length = 4,
    this.size = 11
  });

  @override
  State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BocLogic>(
      builder: (BocLogic c) {
        if (!c.showValue.value) {
          return Row(
            children: List.generate(widget.length, (index) => index + 1).map((e) {
              return Image(
                image: 'ic_xinxin'.png3x,
                width: widget.size.w,
                height: widget.size.w,
              ).withPadding(right: 2.w);
            }).toList(),
          );
          // return BaseText(
          //   text: '*' * widget.length,
          //   style: widget.hitStyle ??
          //       TextStyle(
          //         fontSize: 24.sp,
          //         color: Colors.black,
          //       ),
          // );
        } else {
          return widget.child ?? const SizedBox.shrink();
        }
      },
      id: 'updateBalance',
    );
  }
}
