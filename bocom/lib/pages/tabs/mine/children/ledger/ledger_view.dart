import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:bocom/pages/component/indicator_loading.dart';
import 'package:bocom/config/model/bill_item_model.dart';

import 'ledger_logic.dart';
import 'ledger_state.dart';
import 'component/ledger_trend_chart.dart';

class LedgerPage extends BaseStateless {
  LedgerPage({super.key});

  final LedgerLogic logic = Get.put(LedgerLogic());
  final LedgerState state = Get.find<LedgerLogic>().state;

  @override
  bool get isShowAppBar => false;

  StackPosition contentPosition =
      StackPosition(designWidth: 1080, designHeight: 453, deviceWidth: 1.sw);

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

  Widget _buildStatistics() {
    // StackPosition stackPosition =
    // StackPosition(designWidth: 1080, designHeight: 453, deviceWidth: 1.sw);
    return Column(
      children: [
        SizedBox(
          width: contentPosition.getWidth(1080),
          height: contentPosition.getWidth(453),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image(
                  image: 'bg_ledger_statistics'.png,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: contentPosition.getX(80),
                top: contentPosition.getX(70),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const BaseText(
                      text: '8',
                      fontSize: 25,
                      color: Color(0xFF111111),
                    ),
                    const BaseText(
                      text: '月',
                      fontSize: 13,
                      color: Color(0xFF333333),
                    ).marginOnly(left: 2.w, bottom: 3.w),
                    const BaseText(
                      text: '共0笔',
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ).marginOnly(left: 13.w, bottom: 3.w),
                  ],
                ),
              ),
              Positioned(
                left: contentPosition.getX(80),
                top: contentPosition.getX(250),
                child: const BaseText(
                  text: '0.00',
                  fontSize: 20,
                  color: Color(0xFF111111),
                ),
              ),
              Positioned(
                left: contentPosition.getX(540),
                top: contentPosition.getX(250),
                child: const BaseText(
                  text: '0.00',
                  fontSize: 20,
                  color: Color(0xFF111111),
                ),
              ),
              Positioned(
                left: contentPosition.getX(175),
                top: contentPosition.getX(340),
                child: const BaseText(
                  text: '0.00',
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.w),
        Container(
          height: 44.w,
          margin: EdgeInsets.symmetric(horizontal: contentPosition.getX(30)),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Row(
            children: [
              const BaseText(
                text: '前3月平均支出0元/月',
                fontSize: 13,
                color: Color(0xFF333333),
              ),
              const Spacer(),
              Container(
                height: 28.w,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(15.w),
                ),
                child: const BaseText(
                  text: '设置预算',
                  fontSize: 12,
                  color: Color(0xFF4E83F2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerEntry() {
    return Container(
      height: 44.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.w),
      ),
      child: Row(
        children: [
          Image(
            image: 'ledger_fanfan_zhangben'.png,
            width: 20.w,
            height: 20.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10.w),
          const Expanded(
            child: BaseText(
              text: '翻翻我的收支账本',
              fontSize: 13,
              color: Color(0xFF333333),
            ),
          ),
          Image(
            image: 'ic_mine_amount_right'.png,
            width: 6.w,
            fit: BoxFit.fitWidth,
            color: Color(0xFF333333),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshHeader() {
    return CustomHeader(
      builder: (context, mode) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BocomArcLoadingIndicator(
                dimension: 16.w,
                strokeWidth: 2.4.w,
              ),
              SizedBox(width: 8.w),
              const BaseText(
                text: '刷新中...',
                fontSize: 14,
                color: Color(0xFF555555),
              ),
            ],
          ).marginOnly(bottom: 10.w),
        );
      },
    );
  }

  Widget _buildLoadFooter() {
    return CustomFooter(
      height: 60.w,
      builder: (context, mode) {
        if (mode == LoadStatus.noMore) {
          return Center(
            child: const BaseText(
              text: '—没有更多了—',
              fontSize: 14,
              color: Color(0xFF999999),
            ).marginOnly(top: 10.w),
          );
        }

        if (mode == LoadStatus.failed) {
          return Center(
            child: const BaseText(
              text: '加载失败，点击重试',
              fontSize: 14,
              color: Color(0xFF999999),
            ).marginOnly(top: 10.w),
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

  String _totalText(String value) => value.isEmpty ? '0.00' : value;

  String _weekText(String week) {
    const weeks = {
      '周一': '星期一',
      '周二': '星期二',
      '周三': '星期三',
      '周四': '星期四',
      '周五': '星期五',
      '周六': '星期六',
      '周日': '星期日',
    };
    return weeks[week] ?? week;
  }

  Widget _buildBillItem(
    BillItemList item, {
    required bool isFirst,
    required bool isLast,
  }) {
    final detail = item.billDetail;
    final title = item.oppositeName.isNotEmpty
        ? item.oppositeName
        : (detail?.oppositeName.isNotEmpty == true
            ? detail!.oppositeName
            : item.excerpt);
    final card = detail?.bankCard ?? '';
    final time = item.transactionTime.isNotEmpty
        ? item.transactionTime
        : (detail?.transactionTime ?? '');
    final isIncome = item.type == '1' ||
        item.type.toLowerCase() == 'income' ||
        item.type == '收入' ||
        item.amount.startsWith('+');
    final amount = item.amount.replaceFirst(RegExp(r'^[+-]'), '');
    final billType = detail?.billType ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? Radius.circular(14.w) : Radius.zero,
          topRight: isFirst ? Radius.circular(14.w) : Radius.zero,
          bottomLeft: isLast ? Radius.circular(14.w) : Radius.zero,
          bottomRight: isLast ? Radius.circular(14.w) : Radius.zero,
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: contentPosition.getX(30)),
      padding: EdgeInsets.all(15.w),
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
            Row(
              children: [
                const BaseText(
                    text: '收入', fontSize: 14, color: Color(0xFF999999)),
                BaseText(
                    text: _totalText(item.incomeTotal),
                    fontSize: 14,
                    color: const Color(0xFF333333)),
                SizedBox(width: 18.w),
                const BaseText(
                    text: '支出', fontSize: 14, color: Color(0xFF999999)),
                BaseText(
                    text: _totalText(item.expensesTotal),
                    fontSize: 14,
                    color: const Color(0xFF333333)),
              ],
            ),
            SizedBox(height: 16.w),
          ],
          if (item.day.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(14.w),
                  ),
                  child: BaseText(
                    text:
                        '${item.day}${item.week.isEmpty ? '' : ' ${_weekText(item.week)}'}',
                    fontSize: 14,
                    color: const Color(0xFF888888),
                  ),
                ),
                const Spacer(),
                const BaseText(
                    text: '收入', fontSize: 14, color: Color(0xFF888888)),
                BaseText(
                    text: _totalText(item.incomeTotal),
                    fontSize: 14,
                    color: const Color(0xFF666666)),
                SizedBox(width: 9.w),
                const BaseText(
                    text: '支出', fontSize: 14, color: Color(0xFF888888)),
                BaseText(
                    text: _totalText(item.expensesTotal),
                    fontSize: 14,
                    color: const Color(0xFF666666)),
              ],
            ),
            SizedBox(height: 17.w),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.w),
                child: Icon(Icons.sync_alt,
                    size: 22.w, color: const Color(0xFF333333)),
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
                    text:
                        '${isIncome ? '+' : '-'}${amount.isEmpty ? '0.00' : amount}',
                    fontSize: 16,
                    color: isIncome
                        ? const Color(0xFFFF565B)
                        : const Color(0xFF222222),
                  ),
                  if (billType.isNotEmpty) ...[
                    SizedBox(height: 4.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: BaseText(
                          text: billType,
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

  @override
  Widget initBody(BuildContext context) {
    return Column(
      children: [
        // 自定义头部 包括导航
        _buildHeader(context),
        // 内容部分
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF7F7F7),
            child: SmartRefresher(
              controller: state.refreshController,
              enablePullDown: true,
              enablePullUp: true,
              header: _buildRefreshHeader(),
              footer: _buildLoadFooter(),
              onRefresh: logic.refreshLedger,
              onLoading: logic.loadMoreLedger,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: state.dataList.length + 1,
                separatorBuilder: (context, index) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        _buildStatistics(),
                        LedgerTrendChart().marginSymmetric(
                          horizontal: contentPosition.getX(30),
                          vertical: 10.w,
                        ),
                        _buildLedgerEntry().marginSymmetric(
                          horizontal: contentPosition.getX(30),
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                      ],
                    );
                  }
                  return _buildBillItem(
                    state.dataList[index - 1],
                    isFirst: index == 1,
                    isLast: index == state.dataList.length,
                  );
                },
              ),
            ),
          ),
        ),
        // 底部tab部分
        _buildBottomTab(),
      ],
    ).withSizedBox(width: 1.sw, height: 1.sh);
  }
}
