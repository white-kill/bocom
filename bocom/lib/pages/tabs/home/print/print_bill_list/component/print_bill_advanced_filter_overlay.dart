import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../transaction_detail/filter/transaction_advanced_filter_model.dart';
import '../../../transaction_detail/filter/transaction_advanced_filter_panel.dart';

class PrintBillAdvancedFilterOverlay extends StatelessWidget {
  const PrintBillAdvancedFilterOverlay({
    super.key,
    required this.initialValue,
  });

  final TransactionAdvancedFilterValue initialValue;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final panelHeight = mediaQuery.size.height -
        mediaQuery.padding.bottom -
        44.w;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: panelHeight,
        child: Material(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 44.w,
                  width: 1.sw,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '筛选',
                        style: TextStyle(
                          color: const Color(0xFF111111),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Positioned(
                        left: 4.w,
                        top: 0,
                        bottom: 0,
                        width: 44.w,
                        child: Semantics(
                          button: true,
                          label: '关闭筛选',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.close,
                              color: const Color(0xFF111111),
                              size: 28.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TransactionAdvancedFilterPanel(
                    initialValue: initialValue,
                    actionsRequireChange: true,
                    onComplete: (value) => Navigator.of(context).pop(value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
