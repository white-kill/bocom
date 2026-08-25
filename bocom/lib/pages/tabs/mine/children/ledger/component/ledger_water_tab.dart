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

class LedgerWaterTab extends StatelessWidget {
  LedgerWaterTab({
    super.key,
    required this.logic,
    required this.state,
  });

  final LedgerLogic logic;
  final LedgerState state;
  final StackPosition _position = StackPosition(
    designWidth: 1080,
    designHeight: 420,
    deviceWidth: 1.sw,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: const Color(0xFFF7F7F7),
        child: Obx(() {
          final dataList = logic.bookWaterPage.value.list;
          return RefreshConfiguration.copyAncestor(
            context: context,
            hideFooterWhenNotFull: false,
            child: SmartRefresher(
              controller: state.waterRefreshController,
              enablePullDown: true,
              enablePullUp: dataList.isNotEmpty,
              header: _refreshHeader(),
              footer: _loadFooter(),
              onRefresh: () =>
                  logic.refreshLedger(state.waterRefreshController),
              onLoading: () =>
                  logic.loadMoreLedger(state.waterRefreshController),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: dataList.isEmpty ? 2 : dataList.length + 1,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  if (index == 0) return _overviewHeader();
                  if (dataList.isEmpty) return _emptyWidget();
                  return LedgerBillItem(
                    item: dataList[index - 1],
                    isFirst: index == 1,
                    isLast: index == dataList.length,
                    onDetailUpdated: () {
                      logic.bookWaterPage.refresh();
                      logic.getBookWaterPage();
                    },
                    topCornerBackgroundGradient: const LinearGradient(
                      colors: [
                        Color(0xFFECF7FF),
                        Color(0xFFEBF4FF),
                        Color(0xFFEAF5FF),
                        Color(0xFFE7F3FE),
                        Color(0xFFD8EFFE),
                      ],
                      stops: [0, 0.23, 0.5, 0.77, 1],
                    ),
                  ).marginSymmetric(horizontal: _position.getX(40));
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyWidget() {
    return Container(
      height: 260.w,
      margin: EdgeInsets.symmetric(horizontal: _position.getX(40)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: 'bg_lefger_water_empty_1'.png,
            width: 110.w,
            height: 120.w,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }
  

  Widget _overviewHeader() => Column(
        children: [
          Obx(() {
            final model = logic.bookWaterPage.value;
            final income = double.tryParse(model.incomeTotal) ?? 0;
            final expenses = double.tryParse(model.expensesTotal) ?? 0;
            return SizedBox(
              width: _position.getWidth(1080),
              height: _position.getWidth(453),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image(image: 'bg_ledger_water'.png, fit: BoxFit.fill),
                  ),
                  Positioned(
                    left: _position.getX(80),
                    top: _position.getX(70),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BaseText(
                          text: '${DateTime.now().year}年',
                          fontSize: 14,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                        const BaseText(text: '共', fontSize: 14, color: Color(0xFF999999))
                            .marginOnly(left: 13.w),
                        BaseText(text: '${model.total}', fontSize: 14, color: const Color(0xFF333333))
                            .marginOnly(left: 2.w),
                        const BaseText(text: '笔', fontSize: 14, color: Color(0xFF999999))
                            .marginOnly(left: 2.w),
                      ],
                    ),
                  ),
                  _amount(left: 80, top: 255, text: _value(model.incomeTotal), fontSize: 20),
                  _amount(left: 540, top: 255, text: _value(model.expensesTotal), fontSize: 20),
                  _amount(left: 175, top: 360, text: (income - expenses).toStringAsFixed(2), fontSize: 14),
                ],
              ),
            );
          }),
        ],
      );

  String _value(String value) => value.isEmpty ? '0.00' : value;

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
