import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'transaction_filter_model.dart';

// 交易明细快捷时间筛选面板
// 说明：面板仅负责展示六种预设范围，日期滚轮由独立底部筛选组件承接。
class TransactionQuickFilterPanel extends StatelessWidget {
  const TransactionQuickFilterPanel({
    required this.onSelected,
    super.key,
  });

  final ValueChanged<TransactionQuickRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 38.w, 14.w, 20.w),
        child: GridView.count(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 3.15,
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 12.w,
          children: [
            for (final range in TransactionQuickRange.values)
              Semantics(
                button: true,
                label: '选择${range.label}',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(range),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Center(
                      child: Text(
                        range.label,
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
