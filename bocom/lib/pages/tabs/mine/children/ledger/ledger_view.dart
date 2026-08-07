import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import 'component/ledger_overview_tab.dart';
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
                child: _buildPeriodSelector(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPeriodSelector() {
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
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: const BaseText(
                      text: '月度',
                      fontSize: 12,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: BaseText(
                      text: '年度',
                      fontSize: 12,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BaseText(
                text: '2026年8月',
                fontSize: 13,
                color: Color(0xFF333333),
              ),
              SizedBox(width: 2.w),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Color(0xFF333333),
              ),
            ],
          ),
        ],
      ),
    );
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
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
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
        case 2:
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
    return Column(
      children: [
        // 自定义头部 包括导航
        _buildHeader(context),
        // 内容部分
        Expanded(child: _buildTabContent()),
        // 底部tab部分
        _buildBottomTab(),
      ],
    ).withSizedBox(width: 1.sw, height: 1.sh);
  }
}
