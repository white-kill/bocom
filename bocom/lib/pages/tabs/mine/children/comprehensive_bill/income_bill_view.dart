import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';

import 'comprehensive_bill_logic.dart';
import 'component/bill_switch_sheet.dart';
import '../ledger/component/ledger_period_picker_sheet.dart';

/// 收益账单内容。页面壳由 ComprehensiveBillPage 负责账单类型分发，
/// 本文件只维护收益账单的布局，避免和综合/资产账单相互耦合。
class IncomeBillContent extends StatelessWidget {
  const IncomeBillContent({super.key, required this.logic});

  final ComprehensiveBillLogic logic;

  // 资产账单按 1080 宽设计稿定位，设计稿坐标统一通过 StackPosition 换算。
  StackPosition get position4 => StackPosition(
    designWidth: 1080,
    designHeight: 637,
    deviceWidth: 1.sw,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Column(children: [
        _header(context),
        Expanded(
          child: SingleChildScrollView(
            controller: logic.scrollController,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 30.w),
            child: Obx(_body),
          ),
        ),
      ]),
    );
  }

  Widget _header(BuildContext context) => Obx(() {
        final selected = logic.selectedPeriod.value;
        final scrolled = logic.headerScrolled.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: scrolled ? Colors.white : null,
            gradient: scrolled
                ? null
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFFFFAF1), Color(0xFFF8FBFB), Color(0xFFEAF5FF)],
                    stops: [0, .5, 1],
                  ),
          ),
          child: Column(children: [
            SizedBox(
              height: MediaQuery.paddingOf(context).top + 44.w,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                child: Stack(alignment: Alignment.center, children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      margin: EdgeInsets.only(left: 15.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9.w),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 21.w),
                    ).withOnTap(onTap: () => Get.back()),
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const BaseText(
                      text: '收益账单',
                      fontSize: 18,
                      color: Color(0xFF181818),
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(width: 8.w),
                    Image(image: 'ic_bill_switch'.png, width: 18.w),
                  ]).withOnTap(onTap: () => BillSwitchSheet.show(context, logic)),
                ]),
              ),
            ),
            _period(context, selected),
          ]),
        );
      });

  Widget _period(BuildContext context, DateTime selected) => Row(children: [
    Container(
      height: 32.w,
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(22.w),
      ),
      child: Row(children: [
        _periodItem('月账单', 0),
        _periodItem('年账单', 1),
      ]),
    ),
    const Spacer(),
    Row(mainAxisSize: MainAxisSize.min, children: [
      BaseText(
        text: logic.periodMode.value == 1
            ? '${selected.year}年'
            : '${selected.year}年${selected.month}月',
        color: const Color(0xFF0875ED),
        fontSize: 14,
      ),
      Icon(Icons.keyboard_arrow_down,
          color: const Color(0xFF0875ED), size: 22.w),
    ]).withOnTap(onTap: () => _showPeriodPicker(context)),
  ]).withContainer(
    padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 15.w),
  );

  Widget _periodItem(String text, int index) {
    final selected = logic.periodMode.value == index;
    return Container(
      height: 28.w,
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(22.w),
      ),
      child: BaseText(
        text: text,
        fontSize: 13,
        color: selected ? const Color(0xFF0875ED) : const Color(0xFF555555),
      ),
    ).withOnTap(onTap: () => logic.selectPeriodMode(index));
  }

  Future<void> _showPeriodPicker(BuildContext context) async {
    final selected = logic.selectedPeriod.value;
    final result = await LedgerPeriodPickerSheet.show(
      context,
      isYearMode: logic.periodMode.value == 1,
      initialYear: selected.year,
      initialMonth: selected.month,
    );
    if (result != null) {
      logic.selectPeriod(year: result.year, month: result.month);
    }
  }

  Widget _body() {
    final overview = logic.incomeExpenseOverview.value;
    final isYear = logic.periodMode.value == 1;
    final totalIncome = overview.incomeTotal;
    final compared = double.tryParse(overview.incomeComparedPrevious ?? '') ?? 0.0;
    final holding = double.tryParse(overview.balance ?? '') ?? 0.0;
    return Column(children: [
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(position4.getX(40), 0, position4.getX(40), 0),
        padding: EdgeInsets.fromLTRB(0, 20.w, 0, 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Expanded(child: _metric('${isYear ? '本年' : '本月'}总收益', _amount(totalIncome), true)),
          Container(width: 1, height: 40.w, color: const Color(0xFFDDE1E6)),
          Expanded(
            child: _metric(
              '${isYear ? '年末' : '月末'}持仓',
              _money(holding),
              false,
              suffix: '${isYear ? '较去年' : '较上月'} ${_money(compared)}',
            ),
          ),
        ]),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(position4.getX(40), position4.getY(40), 0, 12.w),
          child: const BaseText(text: '收益明细', fontSize: 15, color: Color(0xFF8B8F94)),
        ),
      ),
    ]);
  }


  Widget _metric(String title, String value, bool info, {String? suffix}) =>
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BaseText(text: title, fontSize: 15, color: const Color(0xFF8B8F94)),
          if (info) ...[
            SizedBox(width: 5.w),
            Icon(Icons.info_outline, size: 18.w, color: const Color(0xFF8793A2)),
          ],
        ]),
        SizedBox(height: 8.w),
        BaseText(text: value, fontSize: 22, color: const Color(0xFF2B2B2B), fontWeight: FontWeight.w600),
        if (suffix != null) ...[
          SizedBox(height: 9.w),
          BaseText(text: suffix, fontSize: 14, color: const Color(0xFF8B8F94)),
        ],
      ]);

  String _amount(String? value) {
    if (value == null || value.isEmpty) return '--';
    final parsed = double.tryParse(value);
    return parsed == null ? value : _money(parsed);
  }

  String _money(double value) => value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
