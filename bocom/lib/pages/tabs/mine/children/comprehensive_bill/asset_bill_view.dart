import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';

import 'package:bocom/config/model/comprehensive_asset_overview_model.dart';
import 'comprehensive_bill_logic.dart';
import 'component/asset_overview_trend_chart.dart';
import 'component/bill_switch_sheet.dart';
import '../ledger/component/ledger_period_picker_sheet.dart';

/// 资产账单内容。
///
/// 资产账单和综合账单共用 [ComprehensiveBillLogic]，因此日期、月年模式、
/// 资产概览接口和趋势图选中状态保持一致；页面布局单独放在本文件，避免
/// `ComprehensiveBillPage` 继续承担所有账单类型的展示细节。
class AssetBillContent extends StatelessWidget {
  const AssetBillContent({super.key, required this.logic});

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
            child: Obx(() => _content()),
          ),
        ),
      ]),
    );
  }

  Widget _header(BuildContext context) => Obx(() {
        final scrolled = logic.headerScrolled.value;
        final selected = logic.selectedPeriod.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: scrolled ? Colors.white : null,
            gradient: scrolled
                ? null
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFFFAF1),
                      Color(0xFFF8FBFB),
                      Color(0xFFEAF5FF),
                    ],
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
                      text: '资产账单',
                      fontSize: 18,
                      color: Color(0xFF181818),
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(width: 8.w),
                    Image(image: 'ic_bill_switch'.png, width: 18.w),
                    ]).withOnTap(
                        onTap: () => BillSwitchSheet.show(context, logic)),
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

  Widget _content() {
    final overview = logic.assetOverview.value;
    final validTrend = overview.trendList
        .where((item) =>
            item.dateTime != null &&
            double.tryParse(item.assetBalance ?? '') != null)
        .toList();
    final values = validTrend
        .map((item) => double.parse(item.assetBalance!))
        .toList();
    final dates = validTrend.map((item) => item.dateTime!).toList();
    final selectedIndex = validTrend.isEmpty
        ? -1
        : logic.selectedAssetTrendIndex.value
            .clamp(0, validTrend.length - 1)
            .toInt();
    final selectedTrend = selectedIndex < 0 ? null : validTrend[selectedIndex];
    final total = double.tryParse(
            selectedTrend?.assetBalance ?? overview.totalAssets ?? '') ??
        0;
    return Column(children: [
      _summary(total),
      _trend(overview, values, dates, selectedIndex, selectedTrend),
      _detail(total),
    ]);
  }


  Widget _summary(double total) => Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(
            position4.getX(40), 0, position4.getX(40), 0),
        padding: EdgeInsets.fromLTRB(17.w, 25.w, 17.w, 28.w),
        decoration: _summaryDecoration,
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 20.w),
            SizedBox(
              width: position4.getWidth(280),
              height: position4.getHeight(280),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, progress, __) => CustomPaint(
                  painter: _AssetDistributionRingPainter(progress: progress),
                ),
              ),
            ),
            SizedBox(width: 25.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              BaseText(
                text: logic.periodMode.value == 1 ? '年末总资产' : '月末总资产',
                fontSize: 15,
                color: const Color(0xFF7C8188),
              ),
              SizedBox(height: 5.w),
              BaseText(
                text: _money(total),
                fontSize: 25,
                color: const Color(0xFF181818),
                fontWeight: FontWeight.w600,
              ),
            ]),
          ]),
          SizedBox(height: 20.w),
          _assetTypeCard(total),
          SizedBox(height: 15.w),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: const BaseText(
              text: '您的总资产超过了75%的同龄人',
              fontSize: 15,
              color: Color(0xFF53616D),
            ),
          ),
        ]),
      );

  Widget _assetTypeCard(double total) => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(13.w, 15.w, 13.w, 18.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD0D3D7)),
          borderRadius: BorderRadius.circular(9.w),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 7.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: const Color(0xFF48A7EF),
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
            SizedBox(width: 8.w),
            const BaseText(text: '活期余额', fontSize: 15, color: Color(0xFF333333)),
          ]),
          SizedBox(height: 8.w),
          const BaseText(text: '100%', fontSize: 14, color: Color(0xFF8B9198)),
          SizedBox(height: 5.w),
          BaseText(
            text: _money(total),
            fontSize: 14,
            color: const Color(0xFF181818),
            fontWeight: FontWeight.w600,
          ),
        ]),
      );

  Widget _trend(
          ComprehensiveAssetOverviewModel overview,
          List<double> values,
          List<String> dates,
          int selectedIndex,
          ComprehensiveAssetTrendItem? selectedTrend) => Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(
            position4.getX(40), position4.getY(30), position4.getX(40), 0),
        padding: EdgeInsets.fromLTRB(17.w, 20.w, 17.w, 16.w),
        decoration: _cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const BaseText(
                text: '资产走势', fontSize: 17, color: Color(0xFF181818), fontWeight: FontWeight.w600),
            const Spacer(),
            const BaseText(text: '资产日记', fontSize: 14, color: Color(0xFF0875ED)),
          ]),
          SizedBox(height: 15.w),
          _trendSummary(overview, values),
          SizedBox(height: 22.w),
          if (selectedTrend != null) _trendSelectedRow(selectedTrend),
          if (selectedTrend != null) SizedBox(height: 30.w),
          if (values.isEmpty)
            const SizedBox(
              height: 155,
              child: Center(child: BaseText(text: '暂无资产趋势数据', fontSize: 13, color: Color(0xFF999999))),
            )
          else
            AssetOverviewTrendChart(
              values: values,
              dateValues: dates,
              selectedIndex: selectedIndex,
              onSelected: (index) => logic.selectedAssetTrendIndex.value = index,
            ),
        ]),
      );

  Widget _trendSummary(
      ComprehensiveAssetOverviewModel overview, List<double> values) {
    final double average = values.isEmpty
        ? 0.0
        : values.reduce((left, right) => left + right) / values.length;
    final change = double.tryParse(overview.changeAmount ?? '') ?? 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Row(children: [
        _trendMetric(
          icon: Icons.show_chart,
          iconColor: const Color(0xFF78B5F7),
          label: logic.periodMode.value == 1 ? '本年资产变动' : '本月资产变动',
          value: _money(change),
        ),
        Container(width: 1, height: 25.w, color: const Color(0xFFDDE1E6)),
        _trendMetric(
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFFFFCB71),
          label: '日均资产',
          value: _money(average),
        ),
      ]),
    );
  }

  Widget _trendMetric({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(children: [
        SizedBox(width: 15.w),
        Container(
          width: 22.w,
          height: 22.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(.22),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Icon(icon, size: 18.w, color: iconColor),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BaseText(text: label, fontSize: 13, color: const Color(0xFF8B9198)),
              SizedBox(height: 3.w),
              BaseText(text: value, fontSize: 15, color: const Color(0xFF8B9198)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _trendSelectedRow(ComprehensiveAssetTrendItem item) => Row(children: [
        Container(
          width: 4.w,
          height: 16.w,
          color: const Color(0xFF2D93ED),
        ),
        SizedBox(width: 8.w),
        BaseText(
          text: '${_trendDateText(item.dateTime!)} 资产',
          fontSize: 15,
          color: const Color(0xFF555555),
        ),
        const Spacer(),
        BaseText(
          text: _money(double.tryParse(item.assetBalance ?? '') ?? 0),
          fontSize: 17,
          color: const Color(0xFF181818),
          fontWeight: FontWeight.w600,
        ),
      ]);

  String _trendDateText(String value) {
    final match = RegExp(r'^(?:\d{4}[-年])?(\d{1,2})[-月](\d{1,2})').firstMatch(value);
    if (match == null) return value;
    return '${match.group(1)!.padLeft(2, '0')}月${match.group(2)!.padLeft(2, '0')}日';
  }

  Widget _detail(double total) {
    final income = double.tryParse(
            logic.incomeExpenseOverview.value.incomeTotal ?? '') ??
        0.0;
    final expense = double.tryParse(
            logic.incomeExpenseOverview.value.expensesTotal ?? '') ??
        0.0;
    final incomeCount =
        logic.incomeExpenseOverview.value.incomeBillCount ?? 0;
    final expenseCount =
        logic.incomeExpenseOverview.value.expenseBillCount ?? 0;
    final periodLabel = logic.periodMode.value == 1 ? '年末' : '月末';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              position4.getX(40), position4.getY(30), 0, position4.getY(20)),
          child: const BaseText(
            text: '资产变动明细',
            fontSize: 14,
            color: Color(0xFF8B8F94),
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(
              position4.getX(40), 0, position4.getX(40), 0),
          padding: EdgeInsets.fromLTRB(17.w, 20.w, 17.w, 28.w),
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const BaseText(
                  text: '活期余额',
                  fontSize: 17,
                  color: Color(0xFF181818),
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                BaseText(
                  text: periodLabel,
                  fontSize: 15,
                  color: const Color(0xFF8B8F94),
                ),
                SizedBox(width: 14.w),
                BaseText(
                  text: _money(total),
                  fontSize: 18,
                  color: const Color(0xFF181818),
                  fontWeight: FontWeight.w600,
                ),
              ]),
              SizedBox(height: 20.w),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10.w, 12.w, 10.w, 12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Row(children: [
                  Expanded(
                    child: _detailAmount('总收入', income, count: incomeCount),
                  ),
                  Container(
                    width: 1,
                    height: 42.w,
                    color: const Color(0xFFDDE1E6),
                  ),
                  Expanded(
                    child: _detailAmount(
                      '总支出',
                      expense,
                      count: expenseCount,
                      showInfo: true,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailAmount(String label, double amount,
      {required int count, bool showInfo = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            BaseText(text: label, fontSize: 14, color: const Color(0xFF333333)),
            if (showInfo) ...[
              SizedBox(width: 5.w),
              Icon(Icons.info_outline, size: 15.w, color: const Color(0xFF8793A2)),
            ],
          ]),
          SizedBox(height: 6.w),
          BaseText(
            text: _money(amount),
            fontSize: 14,
            color: const Color(0xFF181818),
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 6.w),
          BaseText(
            text: '$count笔',
            fontSize: 14,
            color: const Color(0xFF7F8791),
          ),
        ],
      ),
    );
  }

  String _money(double value) => value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      );

  /// 资产汇总区域沿用设计图的轻量背景渐变：左侧暖白、右上浅蓝，
  /// 底部淡回白色，避免影响内部的明细卡和提示条层次。
  BoxDecoration get _summaryDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, .3, 1],
          colors: [
            Color(0xFFF1F8FF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
          ],
        ),
      );
}

class _AssetDistributionRingPainter extends CustomPainter {
  const _AssetDistributionRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * .2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(center, radius,
        Paint()..color = const Color(0xFFEEF3FA)..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false,
        Paint()..color = const Color(0xFF48A7EF)..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
  }

  @override
  bool shouldRepaint(covariant _AssetDistributionRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
