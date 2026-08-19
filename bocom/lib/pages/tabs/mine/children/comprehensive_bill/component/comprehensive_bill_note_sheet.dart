import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

enum ComprehensiveBillNoteType {
  assetOverview,
  investmentIncome,
  cashFlow,
  creditCard,
  coupon,
}

class ComprehensiveBillNoteSheet extends StatelessWidget {
  const ComprehensiveBillNoteSheet({
    super.key,
    required this.type,
  });

  final ComprehensiveBillNoteType type;

  static Future<void> show(
    BuildContext context, {
    required ComprehensiveBillNoteType type,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.48),
      builder: (_) => ComprehensiveBillNoteSheet(type: type),
    );
  }

  String get _title => switch (type) {
        ComprehensiveBillNoteType.assetOverview => '资产概览说明',
        ComprehensiveBillNoteType.investmentIncome => '投资收益说明',
        ComprehensiveBillNoteType.cashFlow => '收支账单说明',
        ComprehensiveBillNoteType.creditCard => '信用卡账单说明',
        ComprehensiveBillNoteType.coupon => '礼券红包说明',
      };

  String get _content => switch (type) {
        ComprehensiveBillNoteType.assetOverview =>
          '1.月（年）末总资产展示的是您该月（年）末最后1天24点左右的数据（延期交易资产展示的是次日凌晨02:30的数据），且包含了您尚未添加账户的资产。\n2.展示“--”时，表示该数据尚未生成。\n3.涉及资产统计口径，可能导致展示数据与实际情况存在差异。所有数据仅供参考，不作为对账凭证。',
        ComprehensiveBillNoteType.investmentIncome =>
          '1.收益统计您当前已添加账户的活期盈、活期富、活钱+、理财、基金、存款、债券、商业养老金和私募资管产品，其余产品实际产生的收益暂不计入。其中，“活钱+”是交通银行为投资者精选的可快赎货币基金、现金理财等产品。被归入“活钱+”的产品持仓和收益将单独展示。可能导致部分产品的持仓和收益原先被统计在理财或基金中，后被统计在“活钱+”中。\n2.因各产品的收益更新时间不同，若部分产品收益未更新，将暂以0元计入。因数据同步延时可能存在展示的收益数据与“我的理财”、“我的基金”等各资产持仓页面中展示的收益数据不一致，此时请以各资产持仓页面展示数据为准。\n3.收益仅供参考，最终产品投资情况请以产品管理人确认为准。',
        ComprehensiveBillNoteType.cashFlow =>
          '1.收支数据实时汇总您当前已绑定的储蓄卡、信用卡及您通过“记一笔”手动记账的全部交易。本人银行卡同名互转、还交行信用卡、投资理财交易默认不计入统计，您可根据需要将任意交易设置为“计入统计”或“不计入统计”，修改设置后将重新计算账单。\n2.信用卡外币交易将折算为人民币进行统计，折算后金额仅供参考。',
        ComprehensiveBillNoteType.creditCard =>
          '1、外币交易将折算为人民币进行统计，折算后金额仅供参考。\n2、已攒积分和抵用积分均不包含退款交易导致的积分增减。',
        ComprehensiveBillNoteType.coupon =>
          '获券共计总额仅统计在交易时可直接抵扣现金的支付券。例如您获得了1张“满20减10元”的支付券，则获券总额为10元。',
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(15.w, 40.w, 15.w, 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/ic_comprehensive_bill_note.png',
                width: 60.w,
                height: 60.w,
              ),
              if(type != ComprehensiveBillNoteType.coupon) ...[
                SizedBox(height: 25.w),
                BaseText(
                  text: _title,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF181818),
                ),
              ],
              SizedBox(height: 25.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 230.w),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: BaseText(
                        text: _content,
                        fontSize: 14,
                        maxLines: 1000,
                        color: const Color(0xFF303030),
                        height: 1.65,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 35.w),
              SizedBox(
                width: double.infinity,
                height: 52.w,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0875ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.w),
                    ),
                  ),
                  child: const BaseText(
                    text: '我知道了',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
