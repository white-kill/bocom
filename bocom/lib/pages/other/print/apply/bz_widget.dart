import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/component/picker_widget.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'apply_logic.dart';
import 'apply_state.dart';

class BzWidget extends StatefulWidget {
  const BzWidget({super.key});

  @override
  State<BzWidget> createState() => _BzWidgetState();
}

class _BzWidgetState extends State<BzWidget> {
  String currency = '全部';

  final ApplyState state = Get.find<ApplyLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BaseText(
          text: currency,
          style: TextStyle(fontSize: 15, color: Color(0xff222222)),
        ).withOnTap(onTap: () {
          AlterPickerTime.showDataPick(
            context,
            dataList: ['全部', '人民币元'],
            onConfirm: (List v) {
              currency = v.first;
              setState(() {});
              state.reqPrint.currency = currency;
            },
          );
        }),
        Image(
          image: 'ic_jt_right'.png3x,
          color: Color(0xff222222),
          width: 22.w,
        )
      ],
    );
  }
}
