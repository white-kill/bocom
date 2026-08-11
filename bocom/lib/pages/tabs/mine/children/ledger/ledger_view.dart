import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'component/ledger_overview_tab.dart';
import 'component/ledger_analysis_tab.dart';
import 'component/ledger_period_picker_sheet.dart';
import 'component/ledger_water_tab.dart';
import 'component/ledger_water_period_sheet.dart';
import 'ledger_logic.dart';
import 'ledger_state.dart';

class LedgerPage extends BaseStateless {
  LedgerPage({super.key});

  final LedgerLogic logic = Get.put(LedgerLogic());
  final LedgerState state = Get.find<LedgerLogic>().state;

  @override
  bool get isShowAppBar => false;

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Obx(() {
        final expanded = logic.ledgerTypeExpanded.value;
        final selectedIndex = logic.ledgerType.value;
        final selectedLedger = logic.ledgerTypeList[selectedIndex];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: statusBarHeight + (expanded ? 310.w : 140.w),
          child: Stack(
            children: [
              Positioned.fill(
                bottom: 50.w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: expanded
                          ? const [Color(0xFF1D4B78), Color(0xFF173F69)]
                          : const [Color(0xFF477BAE), Color(0xFF6974B2)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15.w,
                right: 15.w,
                top: statusBarHeight + 18.w,
                child: SizedBox(
                  height: 32.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image(
                          image: (expanded ? 'ledger_back_2' : 'ledger_back_1')
                              .png,
                          width: 26.w,
                          height: 26.w,
                        ).withOnTap(onTap: () => Get.back()),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image(
                            image: selectedLedger['smallImage']!.png,
                            width: 16.w,
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(width: 5.w),
                          BaseText(
                            text: selectedLedger['name']!,
                            fontSize: 16,
                            color: Colors.white,
                          ).marginOnly(bottom: 5.w),
                          SizedBox(width: 8.w),
                          Image(
                            image: (expanded
                                    ? 'ledger_type_up'
                                    : 'ledger_type_down')
                                .png,
                            width: 8.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ],
                      ).withOnTap(onTap: logic.toggleLedgerType),
                    ],
                  ),
                ),
              ),
              if (expanded) ...[
                Positioned(
                  left: 15.w,
                  right: 15.w,
                  top: statusBarHeight + 70.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        List.generate(logic.ledgerTypeList.length, (index) {
                      final item = logic.ledgerTypeList[index];
                      final selected = index == selectedIndex;
                      return SizedBox(
                        width: 72.w,
                        child: Column(
                          children: [
                            Image(
                              image: (selected
                                      ? item['selectImage']!
                                      : item['image']!)
                                  .png,
                              width: 56.w,
                              height: 64.w,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 5.w),
                            BaseText(
                              text: item['name']!,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ).withOnTap(
                        onTap: () => logic.selectLedgerType(index),
                      );
                    }),
                  ),
                ),
                Positioned(
                  left: 15.w,
                  right: 15.w,
                  top: statusBarHeight + 185.w,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6685A4),
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                          child: const BaseText(
                            text: '＋ 新建账本',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 31.w),
                      Container(
                        height: 36.w,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF103B67),
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                        child: Row(
                          children: [
                            const BaseText(
                              text: '排序',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            Container(
                              width: 1,
                              height: 17.w,
                              margin: EdgeInsets.symmetric(horizontal: 12.w),
                              color: const Color(0xFF6D849D),
                            ),
                            const BaseText(
                              text: '更多',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: logic.ledgerTab.value == 0
                    ? _buildPeriodSelector(context)
                    : _buildWaterPeriodSelector(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final isYearMode = logic.periodMode.value == 1;
    final selectedPeriod = logic.selectedPeriod.value;
    final now = DateTime.now();
    final isCurrentPeriod = isYearMode
        ? selectedPeriod.year == now.year
        : selectedPeriod.year == now.year && selectedPeriod.month == now.month;

    return Container(
      height: 67.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 110.w,
            height: 30.w,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(18.w),
            ),
            child: Row(
              children: List.generate(2, (index) {
                final selected = logic.periodMode.value == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => logic.selectPeriodMode(index),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16.w),
                      ),
                      child: BaseText(
                        text: index == 0 ? '月度' : '年度',
                        fontSize: 12,
                        color: selected
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF333333),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showPeriodPicker(context),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BaseText(
                    text: isYearMode
                        ? '${selectedPeriod.year}年'
                        : '${selectedPeriod.year}年${selectedPeriod.month}月',
                    fontSize: 14,
                    color: isCurrentPeriod
                        ? const Color(0xFF333333)
                        : const Color(0xFF1976D2),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    logic.periodPickerVisible.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: isCurrentPeriod
                        ? const Color(0xFF333333)
                        : const Color(0xFF1976D2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterPeriodSelector(BuildContext context) {
    final isYearMode = logic.periodMode.value == 1;
    final selectedPeriod = logic.selectedPeriod.value;

    final expandedFilter = logic.waterFilterExpanded.value;
    final periodActive = expandedFilter == 1;
    final accountActive = expandedFilter == 2;
    final amountActive = expandedFilter == 3;
    final defaultPeriodText = isYearMode
        ? '${selectedPeriod.year}年'
        : '${selectedPeriod.year}年${selectedPeriod.month}月';

    return Obx(() {
      final visible =
          logic.ledgerTab.value == 1 && logic.waterFilterExpanded.value != 0;
      return Container(
        height: 67.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
          color: visible ? Colors.white : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: _buildWaterSelectorItem(
                  onTap: () => logic.toggleWaterFilter(1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BaseText(
                        text: logic.ledgerTab.value == 2
                            ? '2024年'
                            : logic.waterPeriodLabel.value.isEmpty
                                ? defaultPeriodText
                                : logic.waterPeriodLabel.value,
                        fontSize: 14,
                        color: periodActive
                            ? const Color(0xFF0075F6)
                            : const Color(0xFF333333),
                      ),
                      SizedBox(width: 5.w),
                      _buildSelectorArrow(periodActive, active: periodActive),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _buildWaterSelectorItem(
                  onTap: () => logic.toggleWaterFilter(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BaseText(
                        text: logic.waterAccount.value,
                        fontSize: 14,
                        color: accountActive
                            ? const Color(0xFF0075F6)
                            : const Color(0xFF333333),
                      ),
                      SizedBox(width: 5.w),
                      _buildSelectorArrow(accountActive, active: accountActive),
                    ],
                  ),
                ),
              ),
            ),
            if (logic.ledgerTab.value == 1) ...[
              Container(
                width: 1,
                height: 24.w,
                margin: EdgeInsets.only(left: 8.w, right: 15.w),
                color: const Color(0xFFE5E5E5),
              ),
              _buildWaterSelectorItem(
                onTap: () => logic.toggleWaterFilter(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BaseText(
                      text: '筛选',
                      fontSize: 14,
                      color: amountActive
                          ? const Color(0xFF0075F6)
                          : const Color(0xFF333333),
                    ),
                    SizedBox(width: 5.w),
                    Image.asset(
                      amountActive
                          ? 'assets/images/transaction_detail/filter_icon_active.png'
                          : 'assets/images/transaction_detail/filter_icon.png',
                      key: const ValueKey('transaction_filter_icon'),
                      width: 9.w,
                      height: 10.5.w,
                      fit: BoxFit.fill,
                    )
                  ],
                ),
              ),
            ]
          ],
        ),
      );
    });
  }

  Widget _buildWaterSelectorItem({
    required VoidCallback onTap,
    required Widget child,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.w),
          child: child,
        ),
      );

  Widget _buildSelectorArrow(bool expanded, {bool active = false}) => Icon(
        expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        size: 20.w,
        color: active ? const Color(0xFF0075F6) : const Color(0xFF333333),
      );

  double _waterPanelHeight(int filter) {
    switch (filter) {
      case 1:
        return 85.w;
      case 2:
        return 150.w;
      case 3:
        return logic.waterAmountFilter.value == '自定义' ? 220.w : 170.w;
      default:
        return 0;
    }
  }

  Widget _buildWaterFilterPanel(BuildContext context, int filter) {
    return ColoredBox(
      color: Colors.white,
      child: switch (filter) {
        1 => _buildWaterPeriodPanel(context),
        2 => _buildWaterAccountPanel(),
        3 => _buildWaterAmountPanel(),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildWaterPeriodPanel(BuildContext context) {
    const periods = ['近7天', '近一个月', '近三个月', '近半年', '近一年', '自定义'];
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 18.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: periods.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 12.w,
          childAspectRatio: 4.2,
        ),
        itemBuilder: (_, index) => _waterChoiceButton(
          periods[index],
          selected: logic.waterPeriodLabel.value == periods[index],
          onTap: () {
            if (periods[index] == '自定义') {
              _showWaterCustomPeriodPicker(context);
            } else {
              logic.selectWaterPeriod(periods[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWaterAccountPanel() {
    const accounts = ['全部账户', '借记卡(**2037)', '手工记账'];
    return Column(
      children: accounts
          .map(
            (account) => Expanded(
              child: InkWell(
                onTap: () => logic.selectWaterAccount(account),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: BaseText(
                          text: account,
                          fontSize: 14,
                          color: logic.waterAccount.value == account
                              ? const Color(0xFF0075F6)
                              : const Color(0xFF333333),
                        ),
                      ),
                      if (logic.waterAccount.value == account)
                        Icon(Icons.check,
                            color: const Color(0xFF0075F6), size: 24.w),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWaterAmountPanel() {
    const amounts = ['100以内', '100-1千', '1千-1万', '1万以上', '自定义'];
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15.w, 0.w, 15.w, 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BaseText(
                text: '金额',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              SizedBox(height: 12.w),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: amounts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.w,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 4.2,
                ),
                itemBuilder: (_, index) => _waterChoiceButton(
                  amounts[index],
                  selected: logic.waterAmountFilter.value == amounts[index],
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    logic.selectWaterAmount(amounts[index]);
                  },
                ),
              ),
              if (logic.waterAmountFilter.value == '自定义') ...[
                SizedBox(height: 18.w),
                _buildCustomAmountFields(),
              ],
            ],
          ),
        ),
        const Spacer(),
        Container(
          height: 43.w,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE1E4E8), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    logic.resetWaterAmount();
                  },
                  child: const Center(
                    child: BaseText(
                        text: '重置', fontSize: 16, color: Color(0xFF0075F6)),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    logic.closeWaterFilter();
                  },
                  child: const ColoredBox(
                    color: Color(0xFF0075F6),
                    child: Center(
                      child: BaseText(
                          text: '完成', fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAmountFields() {
    final inputVersion = logic.waterAmountInputVersion.value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildAmountField(
            key: ValueKey('minimum-amount-$inputVersion'),
            initialValue: logic.waterMinAmount.value,
            hintText: '最小金额',
            onChanged: (value) => logic.waterMinAmount.value = value,
          ),
        ),
        SizedBox(
          width: 36.w,
          height: 34.w,
          child: const Center(
            child: BaseText(
              text: '至',
              fontSize: 14,
              color: Color(0xFF8B95A5),
            ),
          ),
        ),
        Expanded(
          child: _buildAmountField(
            key: ValueKey('maximum-amount-$inputVersion'),
            initialValue: logic.waterMaxAmount.value,
            hintText: '最大金额',
            onChanged: (value) => logic.waterMaxAmount.value = value,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField({
    required Key key,
    required String initialValue,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) =>
      Container(
        height: 34.w,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE1E4E8), width: 1),
          ),
        ),
        child: Row(
          children: [
            const BaseText(
              text: '¥',
              fontSize: 15,
              color: Color(0xFF333333),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextFormField(
                key: key,
                initialValue: initialValue,
                onChanged: onChanged,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,10}(\.\d{0,2})?'),
                  ),
                ],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD1D6DE),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8.w),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _waterChoiceButton(
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

  Future<void> _showWaterCustomPeriodPicker(BuildContext context) async {
    logic.closeWaterFilter();
    // 先完成顶部筛选层的收起动画，再打开底部 Sheet。
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    final result = await LedgerWaterPeriodSheet.show(
      context,
      initialDate: logic.selectedPeriod.value,
    );
    if (result == null) return;

    logic.periodMode.value = result.mode == 1 ? 1 : 0;
    logic.selectPeriod(year: result.start.year, month: result.start.month);
    logic.waterPeriodLabel.value = result.mode == 0
        ? '${result.start.year}年${result.start.month}月'
        : result.mode == 1
            ? '${result.start.year}年'
            : '自定义';
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

  Widget _buildBottomTab() {
    const names = ['总览', '明细流水', '分析', '管理'];

    return Obx(() {
      final selectedIndex = logic.ledgerTab.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64.w,
            child: Row(
              children: List.generate(names.length, (index) {
                final selected = selectedIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () => logic.selectLedgerTab(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: (selected
                                  ? 'ledger_tab_${index + 1}_select'
                                  : 'ledger_tab_${index + 1}')
                              .png,
                          width: 20.w,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(height: 4.w),
                        BaseText(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          text: names[index],
                          fontSize: 12,
                          color: selected
                              ? const Color(0xFF222222)
                              : const Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabContent() {
    return Obx(() {
      switch (logic.ledgerTab.value) {
        case 0:
          return LedgerOverviewTab(logic: logic, state: state);
        case 1:
          return LedgerWaterTab(logic: logic, state: state);
        case 2:
          return const LedgerAnalysisTab();
        case 3:
          return const ColoredBox(
            color: Color(0xFFF7F7F7),
            child: SizedBox.expand(),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }

  @override
  Widget initBody(BuildContext context) {
    final waterFilterTop = MediaQuery.paddingOf(context).top + 140.w;

    return Stack(
      children: [
        Column(
          children: [
            // 自定义头部 包括导航
            _buildHeader(context),
            // 内容部分
            Expanded(child: _buildTabContent()),
            // 底部tab部分
            _buildBottomTab(),
          ],
        ),
        Obx(() {
          final visible = logic.ledgerTab.value == 1 &&
              logic.waterFilterExpanded.value != 0;
          final filter = visible
              ? logic.waterFilterExpanded.value
              : logic.waterLastFilter.value;

          return Positioned.fill(
            top: waterFilterTop,
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
                        onTap: logic.closeWaterFilter,
                        child: const ColoredBox(color: Color(0x66000000)),
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      end: visible ? _waterPanelHeight(filter) : 0,
                    ),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    builder: (context, animatedHeight, child) => SizedBox(
                      width: 1.sw,
                      height: animatedHeight,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minWidth: 1.sw,
                          maxWidth: 1.sw,
                          minHeight: _waterPanelHeight(filter),
                          maxHeight: _waterPanelHeight(filter),
                          child: child,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: 1.sw,
                      height: _waterPanelHeight(filter),
                      child: _buildWaterFilterPanel(context, filter),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ).withSizedBox(width: 1.sw, height: 1.sh);
  }
}
