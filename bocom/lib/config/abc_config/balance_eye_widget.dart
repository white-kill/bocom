import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';

import 'boc_logic.dart';

class BalanceEyeWidget extends StatefulWidget {
  final String openEye;
  final String closeEye;
  final double width;
  final double height;
  final Color? color;
  final Widget? appendWidget;

  const BalanceEyeWidget({
    super.key,
    required this.openEye,
    required this.closeEye,
    this.width = 18,
    this.height = 10,
    this.color,
    this.appendWidget,
  });

  @override
  State<BalanceEyeWidget> createState() => _BalanceEyeWidgetState();
}

class _BalanceEyeWidgetState extends State<BalanceEyeWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BocLogic>(
      builder: (c) {
        return Row(
          children: [
            Image(
              image: c.showValue.value
                  ? widget.openEye.png3x
                  : widget.closeEye.png3x,
              width: widget.width.w,
              height: widget.height.w,
            ).withOnTap(onTap: () {
              c.showBalance(show: !c.showValue.value);
            }),
            if (c.showValue.value) SizedBox(width: 6.w),
            if (c.showValue.value)
              widget.appendWidget ?? const SizedBox.shrink(),
          ],
        );
      },
      id: 'updateEyeBalance',
    );
  }
}
