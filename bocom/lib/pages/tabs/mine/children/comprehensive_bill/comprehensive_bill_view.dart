import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:bocom/config/model/comprehensive_income_expense_model.dart';
import 'package:bocom/pages/other/change_nav/change_nav_view.dart';

import 'comprehensive_bill_logic.dart';
import 'comprehensive_bill_state.dart';
import 'component/bill_switch_sheet.dart';
import 'component/asset_overview_trend_chart.dart';
import 'component/comprehensive_bill_note_sheet.dart';
import '../ledger/component/ledger_period_picker_sheet.dart';
import 'asset_bill_view.dart';
import '../account_asset/account_asset_view.dart';
import '../profit_center/profit_center_view.dart';
import '../ledger/ledger_view.dart';
import 'income_bill_view.dart';

class ComprehensiveBillPage extends BaseStateless {
  ComprehensiveBillPage({
    super.key,
    this.initialBillType = 0,
  })  : assert(initialBillType >= 0 && initialBillType <= 2),
        super(title: '') {
    logic.selectBillType(initialBillType);
  }

  /// 0：综合账单；1：资产账单；2：收益账单。
  final int initialBillType;

  final ComprehensiveBillLogic logic = Get.put(ComprehensiveBillLogic());
  final ComprehensiveBillState state = Get.find<ComprehensiveBillLogic>().state;

  @override
  bool get isShowAppBar => false;

  @override
  Color? get background => const Color(0xFFF6F6F6);

  final position4 = StackPosition(
    designWidth: 1080,
    designHeight: 637,
    deviceWidth: 1.sw,
  );

  final position7 = StackPosition(
    designWidth: 1080,
    designHeight: 1829,
    deviceWidth: 1.sw,
  );

  @override
  Widget initBody(BuildContext context) {
    return Obx(() => logic.billSwitchIndex.value == 1
        ? AssetBillContent(logic: logic)
        : logic.billSwitchIndex.value == 2
            ? IncomeBillContent(logic: logic)
        : _comprehensiveContent(context));
  }

  /// 综合账单内容。页面壳只负责在综合账单和资产账单之间分发，
  /// 具体业务区域集中在各自的内容文件中，后续维护时不会互相干扰。
  Widget _comprehensiveContent(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Column(children: [
        _header(context),
        Expanded(
          child: SingleChildScrollView(
            controller: logic.scrollController,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 30.w),
            child: Column(children: [
              _assetOverview(context),
              _investmentIncome(context),
              _cashFlow(context),
              Container(
                key: state.sectionKeys[3],
                child: Stack(
                  children: [
                    Image(
                      image: 'bg_bill_model_4'.png3x,
                      width: 1.sw,
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                        top: 20.w,
                        child: SizedBox(
                          width: 100.w,
                          height: 30.w,
                        ).withOnTap(onTap: () => ComprehensiveBillNoteSheet.show(
                          context,
                          type: ComprehensiveBillNoteType.creditCard,
                        ))
                    ),
                    Positioned(
                      bottom: 20.w,
                      child: SizedBox(
                        width: 1.sw,
                        height: 60.w,
                      ).withOnTap(onTap: (){
                          Get.to(() => ChangeNavPage(), arguments: {
                            'image': 'bg_mine_xyk',
                            'title': '',
                            'hideRightAction': true,
                            'isOffset': true,
                            'navColor': Colors.white,
                            'changeTitleColor': Colors.transparent,
                            'defTitleColor': Colors.transparent,
                            'showBackgroundColor': false,
                          });
                      })
                    )
                  ],
                ),
              ),
              Container(
                key: state.sectionKeys[4],
                child: Stack(
                  children: [
                    Image(
                      image: 'bg_bill_model_5'.png3x,
                      width: 1.sw,
                      fit: BoxFit.fitWidth,
                    ),
                    Positioned(
                        top: 20.w,
                        child: SizedBox(
                          width: 120.w,
                          height: 30.w,
                        ).withOnTap(onTap: () => ComprehensiveBillNoteSheet.show(
                          context,
                          type: ComprehensiveBillNoteType.coupon,
                        ))
                    ),
                  ],
                ),
              ),
              Image(
                image: 'bg_bill_model_6'.png3x,
                key: state.sectionKeys[5],
                width: 1.sw,
                fit: BoxFit.fitWidth,
              ),
              _footprintModule()
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _header(BuildContext context) => Obx(() {
        final scrolled = logic.headerScrolled.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
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
          child: Stack(
            children: [
              if (!scrolled)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x00F6F6F6),
                          Color(0xFFF6F6F6),
                        ],
                        stops: [0, .55, 1],
                      ),
                    ),
                  ),
                ),
              Column(children: [
                _navigationBar(context),
                _anchorTabs(),
                _period(context),
              ]),
            ],
          ),
        );
      });

  Widget _footprintModule() => SizedBox(
        key: state.sectionKeys[6],
        width: 1.sw,
        height: position7.deviceHeight,
        child: Stack(children: [
          Positioned.fill(
            child: Image(
              image: 'bg_bill_model_7'.png3x,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: position7.getX(80),
            right: position7.getX(80),
            top: position7.getY(580),
            height: position7.getHeight(60),
            child: const Row(children: [
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '0',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '0',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
          ),
          Positioned(
            left: position7.getX(80),
            right: position7.getX(80),
            top: position7.getY(950),
            height: position7.getHeight(60),
            child: const Row(children: [
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '93',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '0',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
          ),
          Positioned(
            left: position7.getX(80),
            right: position7.getX(80),
            top: position7.getY(1250),
            height: position7.getHeight(60),
            child: const Row(children: [
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '10:01',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '23:21',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
          ),
          Positioned(
            left: position7.getX(80),
            right: position7.getX(80),
            top: position7.getY(1540),
            height: position7.getHeight(60),
            child: const Row(children: [
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '6',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: BaseText(
                    text: '11',
                    fontSize: 18,
                    color: Color(0xFF181818),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
          ),
        ]),
      );

  Widget _navigationBar(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: statusBarHeight + 44.w,
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
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
                  borderRadius: BorderRadius.circular(9.w)),
              child: Icon(Icons.arrow_back_ios_new, size: 21.w),
            ).withOnTap(onTap: () => Get.back()),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const BaseText(
                text: '综合账单',
                fontSize: 18,
                color: Color(0xFF181818),
                fontWeight: FontWeight.w600),
            SizedBox(width: 8.w),
            Image(
                image: 'ic_bill_switch'.png, width: 18.w, fit: BoxFit.fitWidth)
          ]).withOnTap(onTap: () => BillSwitchSheet.show(context, logic)),
        ]),
      ),
    );
  }

  Widget _anchorTabs() => SizedBox(
        height: 45.w,
        child: ListView.separated(
          controller: logic.tabController,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          scrollDirection: Axis.horizontal,
          itemCount: state.titles.length,
          separatorBuilder: (_, __) => SizedBox(width: 27.w),
          itemBuilder: (_, index) {
            return Obx(() {
              final selected = logic.selectedIndex.value == index;
              return Column(
                key: state.tabKeys[index],
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BaseText(
                      text: state.titles[index],
                      fontSize: 16,
                      color: selected
                          ? const Color(0xFF181818)
                          : const Color(0xFF555555),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
                  SizedBox(height: 7.w),
                  Container(
                      width: selected ? 30.w : 0,
                      height: 3.w,
                      decoration: BoxDecoration(
                          color: const Color(0xFF0875ED),
                          borderRadius: BorderRadius.circular(2.w))),
                ],
              ).withOnTap(onTap: () => logic.scrollTo(index));
            });
          },
        ),
      );

  Widget _period(BuildContext context) => Obx(() {
        final isYearMode = logic.periodMode.value == 1;
        final selectedPeriod = logic.selectedPeriod.value;
        return Row(children: [
          Container(
            height: 32.w,
            decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(22.w)),
            child: Row(children: [
              _periodItem('月账单', 0),
              _periodItem('年账单', 1),
            ]),
          ),
          const Spacer(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            BaseText(
                text: isYearMode
                    ? '${selectedPeriod.year}年'
                    : '${selectedPeriod.year}年${selectedPeriod.month}月',
                color: const Color(0xFF0875ED),
                fontSize: 14),
            Icon(
                logic.periodPickerVisible.value
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: const Color(0xFF0875ED),
                size: 22.w),
          ]).withOnTap(onTap: () => _showPeriodPicker(context)),
        ]).withContainer(
          padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 15.w),
        );
      });

  Widget _periodItem(String text, int index) {
    final selected = logic.periodMode.value == index;
    return Container(
      height: 28.w,
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22.w)),
      child: BaseText(
          text: text,
          fontSize: 13,
          color: selected ? const Color(0xFF0875ED) : const Color(0xFF555555)),
    ).withOnTap(onTap: () => logic.selectPeriodMode(index));
  }

  Future<void> _showPeriodPicker(BuildContext context) async {
    final selectedPeriod = logic.selectedPeriod.value;
    logic.periodPickerVisible.value = true;
    LedgerPeriodSelection? result;
    try {
      result = await LedgerPeriodPickerSheet.show(
        context,
        isYearMode: logic.periodMode.value == 1,
        initialYear: selectedPeriod.year,
        initialMonth: selectedPeriod.month,
      );
    } finally {
      logic.periodPickerVisible.value = false;
    }
    if (result == null) return;
    logic.selectPeriod(year: result.year, month: result.month);
  }

  Widget _assetOverview(BuildContext context) => Container(
        width: double.infinity,
        key: state.sectionKeys[0],
        margin: EdgeInsets.only(
            left: position4.getX(40), right: position4.getX(40)),
        padding: EdgeInsets.fromLTRB(17.w, 20.w, 17.w, 24.w),
        decoration: _cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const BaseText(
                text: '资产概览',
                fontSize: 17,
                color: Color(0xFF181818),
                fontWeight: FontWeight.w600),
            SizedBox(width: 7.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ComprehensiveBillNoteSheet.show(
                context,
                type: ComprehensiveBillNoteType.assetOverview,
              ),
              child: Icon(Icons.info_outline,
                  size: 18.w, color: const Color(0xFF8793A2)),
            ),
            const Spacer(),
            const BaseText(
              text: '我的资产',
              color: Color(0xFF0875ED),
              fontSize: 14,
            ).withOnTap(
              onTap: () => Get.to(() => AccountAssetPage(initialTabIndex: 1)),
            )
          ]),
          SizedBox(height: 20.w),
          Obx(() {
            final isYearMode = logic.periodMode.value == 1;
            final overview = logic.assetOverview.value;
            return Row(children: [
              Expanded(
                  child: _amount(isYearMode ? '年末总资产' : '月末总资产',
                      _apiAmount(overview.totalAssets))),
              Expanded(
                  child: _amount(isYearMode ? '当年变动' : '当月变动',
                      _apiAmount(overview.changeAmount))),
            ]);
          }),
          SizedBox(height: 13.w),
          Obx(() {
            final overview = logic.assetOverview.value;
            final validTrend = overview.trendList.where((item) {
              return item.dateTime != null &&
                  double.tryParse(item.assetBalance ?? '') != null;
            }).toList();
            final values = validTrend
                .map((item) => double.parse(item.assetBalance!))
                .toList();
            final dates = validTrend.map((item) => item.dateTime!).toList();
            final selectedIndex = validTrend.isEmpty
                ? -1
                : logic.selectedAssetTrendIndex.value
                    .clamp(0, validTrend.length - 1)
                    .toInt();
            final selectedTrend = selectedIndex < 0
                ? null
                : validTrend[selectedIndex];
            return Column(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Container(
                    width: 4.w, height: 12.w, color: const Color(0xFF28A7F2)),
                SizedBox(width: 6.w),
                BaseText(
                    text: selectedTrend?.dateTime == null && overview.assetDate == null
                        ? '暂无资产日期'
                        : '${_assetDateText(selectedTrend?.dateTime ?? overview.assetDate!)}资产',
                    fontSize: 13,
                    color: const Color(0xFF4A4A4A)),
                const Spacer(),
                BaseText(
                    text: _apiAmount(
                        selectedTrend?.assetBalance ?? overview.totalAssets),
                    fontSize: 14,
                    color: const Color(0xFF2B2B2B),
                    fontWeight: FontWeight.w600),
              ]),
              SizedBox(height: 30.w),
              if (validTrend.isEmpty)
                SizedBox(
                  height: 155.w,
                )
              else
                AssetOverviewTrendChart(
                  values: values,
                  dateValues: dates,
                  selectedIndex: selectedIndex,
                  onSelected: (index) =>
                      logic.selectedAssetTrendIndex.value = index,
                ),
            ]);
          }),
        ]),
      );

  Widget _amount(String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BaseText(text: label, fontSize: 14, color: const Color(0xFF4A4A4A)),
        SizedBox(height: 6.w),
        BaseText(
            text: value,
            fontSize: 22,
            color: const Color(0xFF2B2B2B),
            fontWeight: FontWeight.w600)
      ]);

  String _apiAmount(String? value) {
    final amount = double.tryParse(value ?? '');
    return amount == null ? '--' : _money(amount);
  }

  String _assetDateText(String value) {
    final parts = value.split('-');
    if (parts.length == 3) {
      return '${parts[0]}年${parts[1]}月${parts[2]}日';
    }
    if (parts.length == 2) return '${parts[0]}年${parts[1]}月';
    return value;
  }

  Widget _investmentIncome(BuildContext context) => Container(
        key: state.sectionKeys[1],
        width: double.infinity,
        margin: EdgeInsets.only(
            left: position4.getX(40),
            right: position4.getX(40),
            top: position4.getY(30)),
        padding: EdgeInsets.fromLTRB(17.w, 20.w, 17.w, 25.w),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const BaseText(
                  text: '投资收益',
                  fontSize: 17,
                  color: Color(0xFF181818),
                  fontWeight: FontWeight.w600),
              SizedBox(width: 7.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ComprehensiveBillNoteSheet.show(
                  context,
                  type: ComprehensiveBillNoteType.investmentIncome,
                ),
                child: Icon(Icons.info_outline,
                    size: 18.w, color: const Color(0xFF8793A2)),
              ),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {
                  Get.to(() => ProfitCenterPage())
                },
                child: const BaseText(
                  text: '收益中心', color: Color(0xFF0875ED), fontSize: 14),
              ),
            ]),
            SizedBox(height: 20.w),
            Obx(() {
              final isYearMode = logic.periodMode.value == 1;
              return Row(children: [
                Expanded(child: _incomeAmount(isYearMode ? '本年总收益' : '本月总收益')),
                Expanded(child: _incomeAmount(isYearMode ? '较去年' : '较上月')),
              ]);
            }),
          ],
        ),
      );

  Widget _incomeAmount(String label) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BaseText(text: label, fontSize: 14, color: const Color(0xFF4A4A4A)),
        SizedBox(height: 6.w),
        const BaseText(
            text: '- -',
            fontSize: 22,
            color: Color(0xFF2B2B2B),
            fontWeight: FontWeight.w600),
      ]);

  Widget _cashFlow(BuildContext context) => Container(
        key: state.sectionKeys[2],
        width: double.infinity,
        margin: EdgeInsets.only(
            left: position4.getX(40),
            right: position4.getX(40),
            top: position4.getY(30)),
        padding: EdgeInsets.fromLTRB(17.w, 20.w, 17.w, 15.w),
        decoration: _cardDecoration,
        child: Obx(() {
          final isYearMode = logic.periodMode.value == 1;
          final overview = logic.incomeExpenseOverview.value;
          final data = overview.trendList
              .where((item) => item.dateTime != null)
              .map((item) => CashFlowItem(
                    item.dateTime!,
                    double.tryParse(item.incomeTotal ?? '') ?? 0,
                    double.tryParse(item.expensesTotal ?? '') ?? 0,
                  ))
              .toList();
          final page = logic.cashFlowPage.value;
          final start = page;
          final visible = data.skip(start).take(3).toList();
          final income = double.tryParse(overview.incomeTotal ?? '') ?? 0;
          final expense = double.tryParse(overview.expensesTotal ?? '') ?? 0;
          final balance = double.tryParse(overview.balance ?? '');
          final balanceCompared =
              double.tryParse(overview.balanceComparedPrevious ?? '');
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const BaseText(
                      text: '收支',
                      fontSize: 17,
                      color: Color(0xFF181818),
                      fontWeight: FontWeight.w600),
                  SizedBox(width: 7.w),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ComprehensiveBillNoteSheet.show(
                      context,
                      type: ComprehensiveBillNoteType.cashFlow,
                    ),
                    child: Icon(Icons.info_outline,
                        size: 18.w, color: const Color(0xFF8793A2)),
                  ),
                  const Spacer(),
                  const BaseText(
                    text: '收支明细',
                    color: Color(0xFF0875ED),
                    fontSize: 14,
                  ).withOnTap(
                    onTap: () => Get.to(() => LedgerPage(initialTabIndex: 1)),
                  ),
                ]),
                SizedBox(height: 22.w),
                Row(children: [
                  Expanded(child: _cashFlowAmount('收入', overview.incomeTotal)),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: _cashFlowAmount('支出', overview.expensesTotal,
                              alignment: CrossAxisAlignment.end))),
                ]),
                SizedBox(height: 14.w),
                _incomeExpenseProgress(income, expense),
                SizedBox(height: 16.w),
                Row(children: [
                  BaseText(
                      text: '结余 ${_apiAmount(overview.balance)}',
                      fontSize: 14,
                      color: const Color(0xFF333333)),
                  SizedBox(
                    width: 40.w,
                  ),
                  BaseText(
                      text: isYearMode ? '较去年 ' : '较上月 ',
                      fontSize: 14,
                      color: const Color(0xFF666666)),
                  BaseText(
                      text: _comparedAmount(overview.balanceComparedPrevious),
                      fontSize: 14,
                      color: _changeColor(balanceCompared),
                      fontWeight: FontWeight.w600),
                ]),
                SizedBox(height: 18.w),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.w),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1F6FE),
                      borderRadius: BorderRadius.circular(8.w)),
                  child: BaseText(
                      text: balance != null && balance >= 0
                          ? '太棒了，${isYearMode ? '本年' : '本月'}存钱更多了，请继续加油哦！'
                          : '${isYearMode ? '本年' : '本月'}虽然没能存钱，但一定买到了梦想~',
                      fontSize: 14,
                      color: const Color(0xFF3F4852)),
                ),
                SizedBox(height: 18.w),
                _cashFlowLegend(),
                SizedBox(height: 10.w),
                _cashFlowChart(data, visible, page, isYearMode),
                SizedBox(height: 5.w),
                _cashFlowAnalysis(isYearMode, overview),
              ]);
        }),
      );

  Widget _cashFlowAmount(String label, String? value,
          {CrossAxisAlignment alignment = CrossAxisAlignment.start}) =>
      Column(crossAxisAlignment: alignment, children: [
        BaseText(text: label, fontSize: 14, color: const Color(0xFF4A4A4A)),
        SizedBox(height: 7.w),
        BaseText(
            text: _apiAmount(value),
            fontSize: 22,
            color: const Color(0xFF2B2B2B),
            fontWeight: FontWeight.w600),
      ]);

  Widget _incomeExpenseProgress(double income, double expense) {
    final total = income + expense;
    final incomeFlex =
        total <= 0 ? 1 : (income / total * 1000).round().clamp(1, 999).toInt();
    final expenseFlex = total <= 0 ? 1 : 1000 - incomeFlex;
    return SizedBox(
      height: 4.w,
      child: Row(children: [
        Expanded(
            flex: incomeFlex,
            child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF91BFF4),
                    borderRadius: BorderRadius.circular(3.w)))),
        SizedBox(width: 3.w),
        Expanded(
            flex: expenseFlex,
            child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFFFCAA4),
                    borderRadius: BorderRadius.circular(3.w)))),
      ]),
    );
  }

  Widget _cashFlowLegend() =>
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Container(width: 10.w, height: 10.w, color: const Color(0xFF62A2EB)),
        SizedBox(width: 5.w),
        const BaseText(text: '收入', fontSize: 12, color: Color(0xFF888888)),
        SizedBox(width: 15.w),
        Container(width: 10.w, height: 10.w, color: const Color(0xFFFFB171)),
        SizedBox(width: 5.w),
        const BaseText(text: '支出', fontSize: 12, color: Color(0xFF888888)),
      ]);

  Widget _cashFlowChart(List<CashFlowItem> allData, List<CashFlowItem> visible,
      int page, bool isYearMode) {
    final maxValue = allData.fold<double>(1, (value, item) {
      final itemMax = item.income > item.expense ? item.income : item.expense;
      return itemMax > value ? itemMax : value;
    });
    final hasPrevious = page > 0;
    final hasNext = page + 3 < allData.length;
    return SizedBox(
      height: 270.w,
      child: Stack(alignment: Alignment.center, children: [
        Positioned.fill(
          left: 40.w,
          right: 40.w,
          child: const CustomPaint(painter: _CashFlowGridPainter()),
        ),
        Positioned.fill(
          left: 40.w,
          right: 40.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in visible)
                Expanded(
                    child: _cashFlowBar(
                        item, maxValue, _cashFlowLabel(item, isYearMode))),
            ],
          ),
        ),
        if (hasPrevious)
          Positioned(
            left: 0,
            top: 112.w,
            height: 36.w,
            child: Center(
              child:
                  _chartArrow(Icons.chevron_left, logic.previousCashFlowPage),
            ),
          ),
        if (hasNext)
          Positioned(
            right: 0,
            top: 112.w,
            height: 36.w,
            child: Center(
              child: _chartArrow(Icons.chevron_right,
                  () => logic.nextCashFlowPage(allData.length)),
            ),
          ),
      ]),
    );
  }

  Widget _cashFlowBar(CashFlowItem item, double maxValue, String displayLabel) {
    final incomeHeight =
        (item.income / maxValue * 82.w).clamp(3.w, 82.w).toDouble();
    final expenseHeight =
        (item.expense / maxValue * 82.w).clamp(3.w, 82.w).toDouble();
    return Column(children: [
      SizedBox(
        height: 112.w,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          BaseText(
              text: _money(item.income),
              fontSize: 11,
              color: const Color(0xFF555555)),
          SizedBox(height: 4.w),
          _animatedCashFlowBar(
            key: ValueKey('income-${item.label}'),
            height: incomeHeight,
            color: item.income == 0
                ? const Color(0xFFD1D5DB)
                : const Color(0xFF62A2EB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
          ),
        ]),
      ),
      SizedBox(
        height: 36.w,
        child: Center(
            child: BaseText(
                text: displayLabel,
                fontSize: 12,
                color: const Color(0xFF333333))),
      ),
      SizedBox(
        height: 122.w,
        child: Column(children: [
          _animatedCashFlowBar(
            key: ValueKey('expense-${item.label}'),
            height: expenseHeight,
            color: item.expense == 0
                ? const Color(0xFFD1D5DB)
                : const Color(0xFFFFB171),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(3.w)),
          ),
          SizedBox(height: 4.w),
          BaseText(
              text: _money(item.expense),
              fontSize: 11,
              color: const Color(0xFF555555)),
        ]),
      ),
    ]);
  }

  String _cashFlowLabel(CashFlowItem item, bool isYearMode) {
    if (isYearMode) {
      return item.label.endsWith('年') ? item.label : '${item.label}年';
    }
    final match = RegExp(r'^(\d{4})(?:年|-)(\d{1,2})月?$').firstMatch(item.label);
    if (match == null) return item.label;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    if (year == DateTime.now().year && month > 1) return '$month月';
    return '$year年$month月';
  }

  Widget _animatedCashFlowBar({
    required Key key,
    required double height,
    required Color color,
    required BorderRadius borderRadius,
  }) =>
      TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0, end: height),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (_, animatedHeight, __) => Container(
          width: 20.w,
          height: animatedHeight,
          decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        ),
      );

  Widget _chartArrow(IconData icon, VoidCallback onTap) => Container(
        width: 26.w,
        height: 26.w,
        decoration: const BoxDecoration(
            color: Color(0xFFF1F6FE), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF62A2EB), size: 23.w),
      ).withOnTap(onTap: onTap);

  Widget _cashFlowAnalysis(
      bool isYearMode, ComprehensiveIncomeExpenseModel overview) {
    final type = logic.cashFlowDetailType.value;
    final isIncome = type == 0;
    final amount = isIncome ? overview.incomeTotal : overview.expensesTotal;
    final compared = isIncome
        ? overview.incomeComparedPrevious
        : overview.expensesComparedPrevious;
    final comparedValue = double.tryParse(compared ?? '');
    final count =
        isIncome ? overview.incomeBillCount : overview.expenseBillCount;
    final categories =
        isIncome ? overview.incomeCategoryList : overview.expenseCategoryList;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _analysisTab('总收入', 0, type),
        SizedBox(width: 10.w),
        _analysisTab('总支出', 1, type),
      ]),
      SizedBox(height: 18.w),
      BaseText(
          text:
              '${isYearMode ? '本年' : '本月'}${isIncome ? '总收入' : '总支出'}共 ${count ?? 0} 笔',
          fontSize: 16,
          color: const Color(0xFF2B2B2B),
          fontWeight: FontWeight.w500),
      SizedBox(height: 16.w),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(7.w)),
        child: Row(children: [
          const BaseText(text: '合计', fontSize: 13, color: Color(0xFF999999)),
          SizedBox(width: 7.w),
          BaseText(
              text: _apiAmount(amount),
              fontSize: 18,
              color: const Color(0xFF2B2B2B),
              fontWeight: FontWeight.w600),
          const Spacer(),
          BaseText(
              text: isYearMode ? '较去年' : '较上月',
              fontSize: 13,
              color: const Color(0xFF999999)),
          SizedBox(width: 5.w),
          BaseText(
              text: _comparedAmount(compared),
              fontSize: 15,
              color: _changeColor(comparedValue),
              fontWeight: FontWeight.w600),
        ]),
      ),
      SizedBox(height: 15.w),
      if (categories.isEmpty) ...[
        Padding(
          padding: EdgeInsets.only(top: 18.w, bottom: 10.w),
          child: Center(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/bg_lefger_water_empty.png',
                    width: 110.w,
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BaseText(
                          text: isIncome ? '暂无收入明细' : '暂无支出明细',
                          fontSize: 15,
                          color: const Color(0xFF333333),
                        )
                      ],
                    ).withSizedBox(width: 110.w),
                  )
                ],
              )),
        )
      ]
      else
        ...[
          BaseText(
              text: isIncome ? '钱从哪里来：' : '钱都去哪儿：',
              fontSize: 14,
              color: const Color(0xFF888888)
          ),
          for (final category in categories.take(3))
            _cashFlowCategory(category, isIncome),
        ],
      Center(
        child: const BaseText(
          text: '查看更多分析',
          fontSize: 13,
          color: Color(0xFF0875ED),
        ).withOnTap(
          onTap: () => Get.to(() => LedgerPage(initialTabIndex: 2)),
        ),
      ).marginOnly(top: 25.w),
    ]);
  }

  Widget _cashFlowCategory(
      ComprehensiveBillCategoryItem category, bool isIncome) {
    final percentage = double.tryParse(category.percentage ?? '') ?? 0;
    final progress = (percentage / 100).clamp(0.0, 1.0).toDouble();
    final iconUrl = category.icon ?? '';
    return Row(children: [
      SizedBox(
        width: 24.w,
        height: 24.w,
        child: iconUrl.isEmpty
            ? Icon(Icons.category_outlined,
                    size: 18.w, color: const Color(0xFF666666))
                .marginOnly(top: 3.w)
            : Image.network(
                iconUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.category_outlined,
                    size: 18.w, color: const Color(0xFF666666)),
              ).marginOnly(top: 3.w),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                BaseText(
                    text: category.categoryName ?? '--',
                    fontSize: 15,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: const Color(0xFF333333)),
                SizedBox(width: 10.w),
                BaseText(
                    text: '${percentage.toStringAsFixed(1)}%',
                    fontSize: 14,
                    color: const Color(0xFF999999)),
              ],
            ),
            BaseText(
                text: _apiAmount(category.amount),
                fontSize: 15,
                color: const Color(0xFF2B2B2B),
                fontWeight: FontWeight.w500),
          ]),
          SizedBox(height: 10.w),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F5),
              borderRadius: BorderRadius.circular(2.w),
            ),
            width: double.infinity,
            height: 4.w,
            child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress < 0.01 ? 0.01 : progress,
                  child: Container(
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: isIncome
                          ? const Color(0xFF3D8DF5)
                          : const Color(0xFFFFA761),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                )),
          )
        ]),
      ),
    ]).marginOnly(top: 20.w);
  }

  Widget _analysisTab(String text, int index, int selectedIndex) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.w),
        decoration: BoxDecoration(
            color:
                index == selectedIndex ? const Color(0xFFF1F6FE) : Colors.white,
            border: Border.all(
                color: index == selectedIndex
                    ? const Color(0xFF0875ED)
                    : const Color(0xFFD8DCE2)),
            borderRadius: BorderRadius.circular(18.w)),
        child: BaseText(
            text: text,
            fontSize: 15,
            color: index == selectedIndex
                ? const Color(0xFF0875ED)
                : const Color(0xFF333333)),
      ).withOnTap(onTap: () => logic.selectCashFlowDetailType(index));

  String _money(double value) {
    final negative = value < 0;
    final parts = value.abs().toStringAsFixed(2).split('.');
    final integer = parts.first
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '${negative ? '-' : ''}$integer.${parts.last}';
  }

  String _comparedAmount(String? value) {
    final amount = double.tryParse(value ?? '');
    if (amount == null) return '--';
    return '${amount > 0 ? '+' : ''}${_money(amount)}';
  }

  Color _changeColor(double? value) {
    if (value == null || value == 0) return const Color(0xFF666666);
    return value > 0 ? const Color(0xFFFF5257) : const Color(0xFF1AA36F);
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(10.w));
}

class _CashFlowGridPainter extends CustomPainter {
  const _CashFlowGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dashedPaint = Paint()
      ..color = const Color(0xFFD7DDE5)
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = const Color(0xFFC3CBD5)
      ..strokeWidth = 1;

    // 收入区三条虚线，支出区三条虚线。
    for (final ratio in const [0.08, 0.20, 0.32, 0.68, 0.80, 0.92]) {
      _drawDashedLine(canvas, size.width, size.height * ratio, dashedPaint);
    }

    // 收入和支出各自的 0 刻度实线，中间区域用于显示时间标签。
    for (final ratio in const [112 / 270, 148 / 270]) {
      canvas.drawLine(
        Offset(0, size.height * ratio),
        Offset(size.width, size.height * ratio),
        axisPaint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, double width, double y, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    var x = 0.0;
    while (x < width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dashWidth).clamp(0, width).toDouble(), y),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _CashFlowGridPainter oldDelegate) => false;
}
