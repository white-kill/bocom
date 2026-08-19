import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bocom/config/app_config.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'component/print_bill_custom_period_sheet.dart';
import 'component/print_bill_advanced_filter_overlay.dart';
import '../../transaction_detail/filter/transaction_advanced_filter_model.dart';
import 'print_bill_list_logic.dart';
import 'print_bill_list_state.dart';

// 社区页
// 说明：当前页面使用不含导航栏和分类栏的推荐内容切图，顶部导航与横向分类栏由 Flutter 单独绘制。
class PrintBillListPage extends BaseStateless {
  PrintBillListPage({Key? key}) : super(key: key, title: "开立交易明细");

  final PrintBillListLogic logic = Get.put(PrintBillListLogic());
  final PrintBillListState state = Get.find<PrintBillListLogic>().state;

  @override
  Color? get navColor => const Color(0xffFFFFFF);

  @override
  Color? get background => const Color(0xFFF6F6F6);

  @override
  List<Widget>? get rightAction => const [];

  @override
  Widget initBody(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 44.w;
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _AccountHeader(),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Obx(
                      () => _FilterBar(
                        periodLabel: logic.selectedPeriodLabel.value,
                        periodExpanded: logic.periodFilterExpanded.value,
                        currencyLabel: logic.selectedCurrencyLabel.value,
                        currencyExpanded: logic.currencyFilterExpanded.value,
                        filterActive: logic.advancedFilterExpanded.value ||
                            !logic.advancedFilter.value.isEmpty,
                        onPeriodTap: logic.togglePeriodFilter,
                        onCurrencyTap: logic.toggleCurrencyFilter,
                        onFilterTap: () => _showAdvancedFilter(context),
                      ),
                    ),
                    // 交易明细列表
                    Expanded(child: Container()),
                    SizedBox(
                      height: bottomInset,
                      width: 1.sw,
                      child: Column(
                        children: [
                          Container(
                            height: 44.w,
                            width: 1.sw,
                            color: const Color(0xFF0075F6),
                            child: Center(
                              child: BaseText(text: '去开立', color: Colors.white, fontSize: 17),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Obx(() {
                  final visible = logic.periodFilterExpanded.value;

                  return Positioned.fill(
                    top: _FilterBar.height,
                    child: IgnorePointer(
                      ignoring: !visible,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: visible ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: logic.closePeriodFilter,
                                child: const ColoredBox(
                                  color: Color(0x66000000),
                                ),
                              ),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              end: visible ? _periodPanelHeight : 0,
                            ),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            builder: (context, animatedHeight, child) =>
                                SizedBox(
                              width: 1.sw,
                              height: animatedHeight,
                              child: ClipRect(
                                child: OverflowBox(
                                  alignment: Alignment.topCenter,
                                  minWidth: 1.sw,
                                  maxWidth: 1.sw,
                                  minHeight: _periodPanelHeight,
                                  maxHeight: _periodPanelHeight,
                                  child: child,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              width: 1.sw,
                              height: _periodPanelHeight,
                              child: _buildPeriodPanel(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Obx(() {
                  final visible = logic.currencyFilterExpanded.value;

                  return Positioned.fill(
                    top: _FilterBar.height,
                    child: IgnorePointer(
                      ignoring: !visible,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: visible ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: logic.closeCurrencyFilter,
                                child: const ColoredBox(
                                  color: Color(0x66000000),
                                ),
                              ),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              end: visible ? _currencyPanelHeight : 0,
                            ),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            builder: (context, animatedHeight, child) =>
                                SizedBox(
                              width: 1.sw,
                              height: animatedHeight,
                              child: ClipRect(
                                child: OverflowBox(
                                  alignment: Alignment.topCenter,
                                  minWidth: 1.sw,
                                  maxWidth: 1.sw,
                                  minHeight: _currencyPanelHeight,
                                  maxHeight: _currencyPanelHeight,
                                  child: child,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              width: 1.sw,
                              height: _currencyPanelHeight,
                              child: _buildCurrencyPanel(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get _periodPanelHeight => 95.w;

  double get _currencyPanelHeight => 175.w;

  Widget _buildPeriodPanel(BuildContext context) {
    const periods = ['近1个月', '近3个月', '近半年', '近一年', '自定义'];
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15.w, 8.w, 15.w, 15.w),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: periods.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15.w,
            crossAxisSpacing: 15.w,
            childAspectRatio: 4.2,
          ),
          itemBuilder: (_, index) => _periodChoiceButton(
            periods[index],
            selected: _isPeriodSelected(periods[index]),
            onTap: () {
              if (periods[index] == '自定义') {
                _showCustomPeriodPicker(context);
              } else {
                logic.selectPeriod(periods[index]);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyPanel() {
    const currencies = [
      '人民币CNY',
      '美元USD',
      '港币HKD',
      '欧元EUR',
      '澳元AUD',
      '英镑GBP',
      '瑞士法郎CHF',
      '新加坡元SGD',
      '日元JPY',
      '加拿大元CAD',
      '新西兰元NZD',
    ];
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15.w, 8.w, 15.w, 20.w),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currencies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15.w,
            crossAxisSpacing: 15.w,
            childAspectRatio: 4.2,
          ),
          itemBuilder: (_, index) => _periodChoiceButton(
            currencies[index],
            selected: logic.selectedCurrencyLabel.value == currencies[index],
            onTap: () => logic.selectCurrency(currencies[index]),
          ),
        ),
      ),
    );
  }

  bool _isPeriodSelected(String period) {
    final label = logic.selectedPeriodLabel.value;
    return label == period || (period == '近一个月' && label == '近1个月');
  }

  Widget _periodChoiceButton(
    String text, {
    required bool selected,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.w),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE7F2FF) : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: BaseText(
            text: text,
            fontSize: 14,
            color: selected ? const Color(0xFF0075F6) : const Color(0xFF333333),
          ),
        ),
      );

  Future<void> _showCustomPeriodPicker(BuildContext context) async {
    logic.closePeriodFilter();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    final result = await PrintBillCustomPeriodSheet.show(
      context,
      initialStart: logic.beginTime.value ??
          DateTime.now().subtract(const Duration(days: 30)),
      initialEnd: logic.endTime.value ?? DateTime.now(),
    );
    if (result == null) return;
    logic.selectCustomPeriodSelection(result.start, result.end);
  }

  Future<void> _showAdvancedFilter(BuildContext context) async {
    logic.openAdvancedFilter();
    final result = await showGeneralDialog<TransactionAdvancedFilterValue>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: '关闭筛选',
      barrierColor: Colors.black.withValues(alpha: 0.36),
      pageBuilder: (context, animation, secondaryAnimation) =>
          PrintBillAdvancedFilterOverlay(
        initialValue: logic.advancedFilter.value,
      ),
    );
    if (result != null) logic.completeAdvancedFilter(result);
    logic.closeAdvancedFilter();
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 15.w),
      child: Row(
        children: [
          const BaseText(
            text: '卡号',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF252525),
          ),
          SizedBox(width: 12.w),
          Image.asset(
            'assets/images/transaction_detail/bank_logo.png',
            width: 33.w,
            height: 33.w,
          ).marginOnly(bottom: 5.w),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    BaseText(
                      text:
                          '交通银行 借记卡(**${AppConfig.config.abcLogic.cardFour()})',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF252525),
                    )
                  ],
                ),
                Row(
                  children: [
                    BaseText(
                      text:
                          '可用余额：${AppConfig.config.abcLogic.memberInfo.accountBalance.bankBalance}元',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF999999),
                    )
                  ],
                )
              ],
            ),
          ),
          Image(
            image: 'ic_mine_amount_right'.png,
            width: 8.w,
            fit: BoxFit.fitWidth,
            color: const Color(0xFF252525),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.periodLabel,
    required this.periodExpanded,
    required this.currencyLabel,
    required this.currencyExpanded,
    required this.filterActive,
    required this.onPeriodTap,
    required this.onCurrencyTap,
    required this.onFilterTap,
  });

  static double get height => 43.w;

  final String periodLabel;
  final bool periodExpanded;
  final String currencyLabel;
  final bool currencyExpanded;
  final bool filterActive;
  final VoidCallback onPeriodTap;
  final VoidCallback onCurrencyTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: '按时间范围筛选',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPeriodTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BaseText(
                      text: periodLabel,
                      key: const ValueKey(
                        'transaction_detail_selected_month',
                      ),
                      color: periodExpanded
                          ? const Color(0xFF0075F6)
                          : const Color(0xFF303030),
                      fontSize: 14,
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      periodExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: periodExpanded
                          ? const Color(0xFF0075F6)
                          : const Color(0xFF303030),
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: '按币种筛选',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCurrencyTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BaseText(
                      text: currencyLabel,
                      key: const ValueKey(
                        'transaction_detail_selected_money',
                      ),
                      color: currencyExpanded
                          ? const Color(0xFF0075F6)
                          : const Color(0xFF303030),
                      fontSize: 14,
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      currencyExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: currencyExpanded
                          ? const Color(0xFF0075F6)
                          : const Color(0xFF303030),
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 0.5.w,
            height: 20.w,
            color: const Color(0xFFE7E7E7),
          ),
          Semantics(
            button: true,
            label: '筛选交易明细',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onFilterTap,
              child: SizedBox(
                width: 75.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '筛选',
                      style: TextStyle(
                        color: filterActive
                            ? const Color(0xFF0075F6)
                            : const Color(0xFF303030),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Transform.translate(
                      offset: Offset(0, 1.w),
                      child: Image.asset(
                        filterActive
                            ? 'assets/images/transaction_detail/filter_icon_active.png'
                            : 'assets/images/transaction_detail/filter_icon.png',
                        key: const ValueKey('transaction_filter_icon'),
                        width: 9.w,
                        height: 10.5.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
