import 'package:bocom/pages/component/indicator_loading.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:get/get.dart';

import '../ledger_logic.dart';
import '../ledger_state.dart';
import 'ledger_bill_item.dart';
import 'ledger_trend_chart.dart';

class LedgerOverviewTab extends StatelessWidget {
  LedgerOverviewTab({
    super.key,
    required this.logic,
    required this.state,
  });

  final LedgerLogic logic;
  final LedgerState state;
  final StackPosition _position = StackPosition(
    designWidth: 1080,
    designHeight: 453,
    deviceWidth: 1.sw,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7F7),
      child: SmartRefresher(
        controller: state.overviewRefreshController,
        enablePullDown: true,
        enablePullUp: true,
        header: _refreshHeader(),
        footer: _loadFooter(),
        onRefresh: () => logic.refreshLedger(state.overviewRefreshController),
        onLoading: () => logic.loadMoreLedger(state.overviewRefreshController),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: state.dataList.length + 1,
          separatorBuilder: (_, __) => const SizedBox.shrink(),
          itemBuilder: (context, index) {
            if (index == 0) return _overviewHeader();
            return LedgerBillItem(
              item: state.dataList[index - 1],
              isFirst: index == 1,
              isLast: index == state.dataList.length,
            ).marginSymmetric(horizontal: _position.getX(30));
          },
        ),
      ),
    );
  }

  Widget _overviewHeader() => Column(
        children: [
          _statistics(),
          Obx(
            () => LedgerTrendChart(
              title: logic.periodMode.value == 1 ? '近一年收支' : '近一月收支',
            ).marginSymmetric(
              horizontal: _position.getX(30),
              vertical: 10.w,
            ),
          ),
          _ledgerEntry().marginSymmetric(horizontal: _position.getX(30)),
          SizedBox(height: 10.w),
        ],
      );

  Widget _statistics() => Column(
        children: [
          SizedBox(
            width: _position.getWidth(1080),
            height: _position.getWidth(453),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image(image: 'bg_ledger_statistics'.png, fit: BoxFit.fill),
                ),
                Obx(() {
                  final selectedPeriod = logic.selectedPeriod.value;
                  final isYearMode = logic.periodMode.value == 1;
                  return Positioned(
                    left: _position.getX(80),
                    top: _position.getX(70),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        BaseText(
                          text: isYearMode
                              ? '${selectedPeriod.year}'
                              : '${selectedPeriod.month}',
                          fontSize: 25,
                          color: const Color(0xFF111111),
                        ),
                        BaseText(
                          text: isYearMode ? '年' : '月',
                          fontSize: 13,
                          color: const Color(0xFF333333),
                        ).marginOnly(left: 2.w, bottom: 3.w),
                        const BaseText(
                          text: '共0笔',
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ).marginOnly(left: 13.w, bottom: 3.w),
                      ],
                    ),
                  );
                }),
                _amount(left: 80, top: 250, text: '0.00', fontSize: 20),
                _amount(left: 540, top: 250, text: '0.00', fontSize: 20),
                _amount(left: 175, top: 340, text: '0.00', fontSize: 14),
              ],
            ),
          ),
          SizedBox(height: 10.w),
          Container(
            height: 44.w,
            margin: EdgeInsets.symmetric(horizontal: _position.getX(30)),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Row(
              children: [
                const BaseText(text: '前3月平均支出0元/月', fontSize: 13, color: Color(0xFF333333)),
                const Spacer(),
                Container(
                  height: 28.w,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FF),
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                  child: const BaseText(text: '设置预算', fontSize: 12, color: Color(0xFF4E83F2)),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _amount({
    required double left,
    required double top,
    required String text,
    required double fontSize,
  }) =>
      Positioned(
        left: _position.getX(left),
        top: _position.getX(top),
        child: BaseText(text: text, fontSize: fontSize, color: const Color(0xFF111111)),
      );

  Widget _ledgerEntry() => Container(
        height: 44.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.w),
        ),
        child: Row(
          children: [
            Image(image: 'ledger_fanfan_zhangben'.png, width: 20.w, height: 20.w),
            SizedBox(width: 10.w),
            const Expanded(
              child: BaseText(text: '翻翻我的收支账本', fontSize: 13, color: Color(0xFF333333)),
            ),
            Image(
              image: 'ic_mine_amount_right'.png,
              width: 6.w,
              fit: BoxFit.fitWidth,
              color: const Color(0xFF333333),
            ),
          ],
        ),
      );

  Widget _refreshHeader() => CustomHeader(
        builder: (_, __) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BocomArcLoadingIndicator(dimension: 16.w, strokeWidth: 2.4.w),
              SizedBox(width: 8.w),
              const BaseText(text: '刷新中...', fontSize: 14, color: Color(0xFF555555)),
            ],
          ).marginOnly(bottom: 10.w),
        ),
      );

  Widget _loadFooter() => CustomFooter(
        height: 60.w,
        builder: (_, mode) {
          if (mode == LoadStatus.noMore) {
            return Center(
              child: const BaseText(text: '—没有更多了—', fontSize: 14, color: Color(0xFF999999))
                  .marginOnly(top: 10.w),
            );
          }
          if (mode == LoadStatus.failed) {
            return Center(
              child: const BaseText(text: '加载失败，点击重试', fontSize: 14, color: Color(0xFF999999))
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
}
