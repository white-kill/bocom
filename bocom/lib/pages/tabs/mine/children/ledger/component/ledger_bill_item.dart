import 'package:bocom/config/model/bill_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerBillItem extends StatelessWidget {
  const LedgerBillItem({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  final BillItemList item;
  final bool isFirst;
  final bool isLast;

  String _total(String value) => value.isEmpty ? '0.00' : value;

  String _week(String value) => const {
        '周一': '星期一',
        '周二': '星期二',
        '周三': '星期三',
        '周四': '星期四',
        '周五': '星期五',
        '周六': '星期六',
        '周日': '星期日',
      }[value] ?? value;

  @override
  Widget build(BuildContext context) {
    final detail = item.billDetail;
    final title = item.oppositeName.isNotEmpty
        ? item.oppositeName
        : (detail?.oppositeName.isNotEmpty == true
            ? detail!.oppositeName
            : item.excerpt);
    final card = detail?.bankCard ?? '';
    final time = item.transactionTime.isNotEmpty
        ? item.transactionTime
        : (detail?.transactionTime ?? '');
    final isIncome = item.type == '1' ||
        item.type.toLowerCase() == 'income' ||
        item.type == '收入' ||
        item.amount.startsWith('+');
    final amount = item.amount.replaceFirst(RegExp(r'^[+-]'), '');
    final billType = detail?.billType ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? Radius.circular(14.w) : Radius.zero,
          topRight: isFirst ? Radius.circular(14.w) : Radius.zero,
          bottomLeft: isLast ? Radius.circular(14.w) : Radius.zero,
          bottomRight: isLast ? Radius.circular(14.w) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.month.isNotEmpty) ...[
            BaseText(
              text: item.month.endsWith('月')
                  ? item.month
                  : '${item.month.split('-').last}月',
              fontSize: 18,
              color: const Color(0xFF333333),
            ),
            SizedBox(height: 9.w),
            _totals(color: const Color(0xFF333333)),
            SizedBox(height: 16.w),
          ],
          if (item.day.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(14.w),
                  ),
                  child: BaseText(
                    text: '${item.day}${item.week.isEmpty ? '' : ' ${_week(item.week)}'}',
                    fontSize: 14,
                    color: const Color(0xFF888888),
                  ),
                ),
                const Spacer(),
                _totals(color: const Color(0xFF666666)),
              ],
            ),
            SizedBox(height: 17.w),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.sync_alt, size: 22.w, color: const Color(0xFF333333)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BaseText(text: title, fontSize: 16, color: const Color(0xFF222222)),
                    SizedBox(height: 5.w),
                    BaseText(
                      text: [if (card.isNotEmpty) card, if (time.isNotEmpty) time].join(' '),
                      fontSize: 14,
                      color: const Color(0xFF999999),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BaseText(
                    text: '${isIncome ? '+' : '-'}${amount.isEmpty ? '0.00' : amount}',
                    fontSize: 16,
                    color: isIncome ? const Color(0xFFFF565B) : const Color(0xFF222222),
                  ),
                  if (billType.isNotEmpty) ...[
                    SizedBox(height: 4.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: BaseText(text: billType, fontSize: 12, color: const Color(0xFF999999)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totals({required Color color}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BaseText(text: '收入', fontSize: 14, color: Color(0xFF999999)),
          BaseText(text: _total(item.incomeTotal), fontSize: 14, color: color),
          SizedBox(width: 12.w),
          const BaseText(text: '支出', fontSize: 14, color: Color(0xFF999999)),
          BaseText(text: _total(item.expensesTotal), fontSize: 14, color: color),
        ],
      );
}
