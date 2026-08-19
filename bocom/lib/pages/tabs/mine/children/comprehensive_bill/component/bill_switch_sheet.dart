import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';

import '../comprehensive_bill_logic.dart';

class BillSwitchSheet extends StatelessWidget {
  const BillSwitchSheet({super.key, required this.logic});

  final ComprehensiveBillLogic logic;

  static Future<void> show(
      BuildContext context, ComprehensiveBillLogic logic) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.48),
      builder: (_) => BillSwitchSheet(logic: logic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = logic.billSwitchIndex.value.obs;
    final position = StackPosition(
      designWidth: 1080,
      designHeight: 1272,
      deviceWidth: 1.sw,
    );
    const cardTops = [225.0, 492.0, 757.0];
    const iconTops = [312.0, 577.0, 842.0];

    return SizedBox(
      width: 1.sw,
      height: position.deviceHeight,
      child: Stack(children: [
        Positioned.fill(
          child: Image(
            image: 'bg_bill_switch_sheet'.png3x,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          left: position.getX(20),
          top: position.getY(20),
          width: position.getWidth(90),
          height: position.getHeight(100),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox.expand(),
          ),
        ),
        for (var index = 0; index < cardTops.length; index++) ...[
          Positioned(
            left: position.getX(65),
            right: position.getX(65),
            top: position.getY(cardTops[index]),
            height: position.getHeight(234),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                selectedIndex.value = index;
              },
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: position.getX(888),
            top: position.getY(iconTops[index]),
            width: position.getWidth(60),
            height: position.getHeight(61),
            child: IgnorePointer(
              child: Obx(() => Image(
                    image: (selectedIndex.value == index
                            ? 'ic_bill_switch_select'
                            : 'ic_bill_switch_unselect')
                        .png,
                    fit: BoxFit.fill,
                  )),
            ),
          ),
        ],
        Positioned(
          left: position.getX(40),
          right: position.getX(40),
          top: position.getY(1068),
          height: position.getHeight(130),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              logic.selectBillType(selectedIndex.value);
              Navigator.of(context).pop();
            },
            child: const SizedBox.expand(),
          ),
        ),
      ]),
    );
  }
}
