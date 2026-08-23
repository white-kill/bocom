import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bocom/config/app_config.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:intl/intl.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/pages/component/indicator_loading.dart';
import 'package:bocom/utils/stack_position.dart';
import 'component/print_bill_custom_period_sheet.dart';
import 'component/print_bill_advanced_filter_overlay.dart';
import '../../transaction_detail/filter/transaction_advanced_filter_model.dart';
import '../../transaction_detail/transaction_bill_detail_view.dart';
import '../../transaction_detail/transaction_detail_repository.dart';
import '../print_confim/print_confim_view.dart';
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
          _AccountHeader(logic),
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
                    Expanded(child: _buildTransactionList(context)),
                    Obx(
                      () => SizedBox(
                        height: bottomInset,
                        width: 1.sw,
                        child: Column(
                          children: [
                            Container(
                              height: 44.w,
                              width: 1.sw,
                              color: logic.entries.isEmpty
                                  ? const Color(0xFFC4C8D0)
                                  : const Color(0xFF0075F6),
                              child: const Center(
                                child: BaseText(
                                    text: '去开立',
                                    color: Colors.white,
                                    fontSize: 17),
                              ),
                            ).withOnTap(
                              onTap: logic.entries.isEmpty
                                  ? null
                                  : () => Get.to(
                                        () => PrintConfimPage(
                                          exportParams:
                                              logic.buildPrintExportFilters(),
                                        ),
                                      ),
                            )
                          ],
                        ),
                      )
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

  Widget _buildTransactionList(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: const Color(0xFFF7F7F7),
        child: Obx(() {
          final dataList = logic.entries;
          return RefreshConfiguration.copyAncestor(
            context: context,
            hideFooterWhenNotFull: false,
            child: SmartRefresher(
              controller: state.refreshController,
              enablePullDown: true,
              enablePullUp: dataList.isNotEmpty,
              header: _refreshHeader(),
              footer: _loadFooter(),
              onRefresh: () =>
                  logic.refreshTransactions(state.refreshController),
              onLoading: () =>
                  logic.loadMoreTransactions(state.refreshController),
              child: ListView.separated(
                padding: EdgeInsets.only(top: 12.w),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: dataList.isEmpty ? 1 : dataList.length,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  if (dataList.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h,),
                        Image.asset(
                          'assets/images/ic_print_empty.png',
                          width: 70.w,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(height: 10.h,),
                        const BaseText(
                          text: '交易记录为空',
                          fontSize: 12,
                          color: Color(0xFF333333),
                        )
                      ],
                    ).marginOnly(top: 30.w);
                  }
                  final entry = dataList[index];
                  return Semantics(
                    button: true,
                    label: '查看${entry.record.title}交易详情',
                    child: Container(
                      color: Colors.white,
                      child: _buildTransactionRow(entry, index),
                    ).withOnTap(onTap: () => _openBillDetail(entry)),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  void _openBillDetail(TransactionBillEntry entry) {
    Get.to<void>(
      () => TransactionBillDetailPage(
        billId: entry.id,
        initialDetail: entry.detail,
      ),
    );
  }

  Widget _buildTransactionRow(TransactionBillEntry entry, int index) {
    final record = entry.record;
    final amount = NumberFormat('#,##0.00').format(record.amount.abs());
    return SizedBox(
      height: 94.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 105.w,
              top: 10.w,
              child: Text(
                record.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            Positioned(
              left: 0,
              top: 35.w,
              child: Text(
                record.channel,
                style: TextStyle(
                  color: const Color(0xFF969696),
                  fontSize: 14.sp,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 57.w,
              child: Text(
                DateFormat('yyyy-MM-dd HH:mm:ss').format(record.occurredAt),
                style: TextStyle(
                  color: const Color(0xFF969696),
                  fontSize: 14.sp,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 9.w,
              child: Text(
                '${record.isIncome ? '+' : '-'}$amount',
                style: TextStyle(
                  color: record.isIncome
                      ? const Color(0xFFB12D2D)
                      : const Color(0xFF1D1D1D),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 35.w,
              child: Text(
                '余额: ${record.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: const Color(0xFF969696),
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (index != logic.entries.length - 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Divider(height: 0.5.w, thickness: 0.5.w),
              ),
          ],
        ),
      ),
    );
  }

  Widget _refreshHeader() => CustomHeader(
        builder: (_, __) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BocomArcLoadingIndicator(dimension: 16.w, strokeWidth: 2.4.w),
            ],
          ).marginOnly(bottom: 10.w),
        ),
      );

  Widget _loadFooter() => CustomFooter(
        height: 60.w,
        builder: (_, mode) {
          if (mode == LoadStatus.noMore) {
            return Center(
              child: const BaseText(
                      text: '—没有更多了—', fontSize: 14, color: Color(0xFF999999))
                  .marginOnly(top: 10.w),
            );
          }
          if (mode == LoadStatus.failed) {
            return Center(
              child: const BaseText(
                      text: '加载失败，点击重试', fontSize: 14, color: Color(0xFF999999))
                  .marginOnly(top: 10.w),
            );
          }
          return Center(
            child: Image(
              image: 'global_loading'.gif,
              width: 60.w,
              height: 30.w,
              fit: BoxFit.contain,
            ),
          );
        },
      );

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
  _AccountHeader(this.logic);

  PrintBillListLogic logic;

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
    ).withOnTap(onTap: () {
      logic.periodFilterExpanded.value = false;
      logic.currencyFilterExpanded.value = false;
      logic.closeAdvancedFilter();
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          StackPosition position = StackPosition(
              designWidth: 1080, designHeight: 1517, deviceWidth: 1.sw);
          return SizedBox(
            height: position.deviceHeight,
            width: 1.sw,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image(
                    image: 'bg_print_account'.png3x,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                    left: position.getX(490),
                    top: position.getY(245),
                    child: BaseText(
                      text: '(**${AppConfig.config.abcLogic.cardFour()})',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF252525),
                    )),
                Positioned(
                    left: position.getX(350),
                    top: position.getY(305),
                    child: BaseText(
                      text:
                          '${AppConfig.config.abcLogic.memberInfo.accountBalance.bankBalance}元',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF777777),
                    )),
              ],
            ),
          );
        },
      );
    });
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
