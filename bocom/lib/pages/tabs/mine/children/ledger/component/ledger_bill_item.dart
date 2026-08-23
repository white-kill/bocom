import 'package:bocom/config/model/bill_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import '../subpages/detail/ledger_detail_view.dart';

class LedgerBillItem extends StatelessWidget {
  const LedgerBillItem({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
    this.topCornerBackgroundGradient,
    this.onDetailUpdated,
  });

  final BillItemList item;
  final bool isFirst;
  final bool isLast;
  final Gradient? topCornerBackgroundGradient;
  final VoidCallback? onDetailUpdated;

  String _total(String value) => value.isEmpty ? '0.00' : value;

  String _week(String value) =>
      const {
        '周一': '星期一',
        '周二': '星期二',
        '周三': '星期三',
        '周四': '星期四',
        '周五': '星期五',
        '周六': '星期六',
        '周日': '星期日',
      }[value] ??
      value;

  @override
  Widget build(BuildContext context) {
    final detail = item.billDetail;
    final title = item.oppositeName.isNotEmpty
        ? item.oppositeName
        : (detail?.oppositeName.isNotEmpty == true
            ? detail!.oppositeName
            : item.excerpt);
    final card = detail?.bankCard.isNotEmpty == true
        ? '借记卡(${detail?.bankCard.substring(detail.bankCard.length - 6)})'
        : (detail?.bankName ?? '');
    final time = item.transactionTime.isNotEmpty
        ? (item.transactionTime.substring(5, 16).startsWith('0')
            ? item.transactionTime.substring(6, 16)
            : item.transactionTime.substring(5, 16))
        : (detail?.transactionTime ?? '');
    final isIncome = item.type == '1' ||
        item.type.toLowerCase() == 'income' ||
        item.type == '收入' ||
        item.amount.startsWith('+');
    final rawAmount = item.amount.replaceFirst(RegExp(r'^[+-]'), '').trim();
    final amount = double.tryParse(rawAmount.replaceAll(',', ''))
            ?.toStringAsFixed(2) ??
        '0.00';
    bool includeInTotal = detail?.includeInTotal ?? true;

    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.to(
        () => LedgerDetailPage(
          item: item,
          onUpdated: onDetailUpdated,
        ),
      ),
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 10.w),
        // margin: EdgeInsets.symmetric(horizontal: 10.w),
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
              _totals(
                income: item.monthIncomeTotal,
                expenses: item.monthExpensesTotal,
                color: const Color(0xFF333333),
              ),
              SizedBox(height: 16.w),
            ],
            if (item.day.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(14.w),
                    ),
                    child: BaseText(
                      text: item.day,
                      fontSize: 14,
                      color: const Color(0xFF888888),
                    ),
                  ),
                  const Spacer(),
                  _totals(
                    income: item.dayIncomeTotal,
                    expenses: item.dayExpensesTotal,
                    color: const Color(0xFF666666),
                  ),
                ],
              ),
              SizedBox(height: 17.w),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                item.icon.isEmpty
                    ? Icon(Icons.sync_alt,
                        size: 22.w, color: const Color(0xFF333333))
                    : Image.network(
                        item.icon,
                        width: 22.w,
                        height: 22.w,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.sync_alt,
                          size: 22.w,
                          color: const Color(0xFF333333),
                        ),
                      ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText(
                          text: title,
                          fontSize: 16,
                          color: const Color(0xFF222222)),
                      SizedBox(height: 5.w),
                      BaseText(
                        text: [
                          if (card.isNotEmpty) card,
                          if (time.isNotEmpty) time
                        ].join(' '),
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
                      text: '${isIncome ? '+' : '-'}$amount',
                      fontSize: 16,
                      color: isIncome
                          ? const Color(0xFFFF565B)
                          : const Color(0xFF222222),
                    ),
                    if (!includeInTotal) ...[
                      SizedBox(height: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 9.w, vertical: 2.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: BaseText(
                            text: '不计入',
                            fontSize: 12,
                            color: const Color(0xFF999999)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isFirst && topCornerBackgroundGradient != null) {
      return DecoratedBox(
        decoration: BoxDecoration(gradient: topCornerBackgroundGradient),
        child: content,
      );
    }

    return content;
  }

  Widget _totals({
    required String income,
    required String expenses,
    required Color color,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BaseText(text: '收入', fontSize: 14, color: Color(0xFF999999)),
          BaseText(text: _total(income), fontSize: 14, color: color),
          SizedBox(width: 12.w),
          const BaseText(text: '支出', fontSize: 14, color: Color(0xFF999999)),
          BaseText(text: _total(expenses), fontSize: 14, color: color),
        ],
      );
}
