import 'package:bocom/pages/component/indicator_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../print_confim/print_export_repository.dart';
import 'print_record_logic.dart';
import 'print_record_state.dart';

class PrintRecordPage extends BaseStateless {
  PrintRecordPage({
    Key? key,
    PrintRecordPageLoader? pageLoader,
  })  : logic = Get.put(PrintRecordLogic(pageLoader: pageLoader)),
        super(key: key, title: '申请记录');

  final PrintRecordLogic logic;
  PrintRecordState get state => logic.state;

  @override
  Color? get navColor => Colors.white;

  @override
  Color? get background => const Color(0xFFF7F7F7);

  @override
  List<Widget>? get rightAction => const [];

  @override
  Widget initBody(BuildContext context) {
    return Column(
      children: [
        Container(
          key: const Key('print-record-year-tip'),
          width: 1.sw,
          height: 44.w,
          color: const Color(0xFFFFF5F0),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: const BaseText(
            text: '以下是近一年您的开立申请记录。',
            fontSize: 15,
            color: Color(0xFFF0A15E),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (logic.loading.value && logic.records.isEmpty) {
              return const Center(
                child: BocomArcLoadingIndicator(
                  key: Key('print-record-loading'),
                ),
              );
            }
            if (logic.loadFailed.value && logic.records.isEmpty) {
              return _LoadFailed(onRetry: logic.loadRecords);
            }
            return RefreshConfiguration.copyAncestor(
              context: context,
              hideFooterWhenNotFull: false,
              child: SmartRefresher(
                key: const Key('print-record-refresher'),
                controller: state.refreshController,
                enablePullDown: true,
                enablePullUp: logic.records.isNotEmpty,
                header: _refreshHeader(),
                footer: _loadFooter(),
                onRefresh: () => logic.refreshRecords(state.refreshController),
                onLoading: () =>
                    logic.loadMoreRecords(state.refreshController),
                child: logic.records.isEmpty
                    ? const _EmptyRecords()
                    : ListView.separated(
                        padding: EdgeInsets.only(bottom: 24.w),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: logic.records.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.w),
                        itemBuilder: (_, index) =>
                            _PrintRecordCard(record: logic.records[index]),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _refreshHeader() => CustomHeader(
        height: 40.w,
        builder: (_, __) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BocomArcLoadingIndicator(dimension: 16.w, strokeWidth: 2.4.w),
              SizedBox(width: 8.w),
              const BaseText(
                text: '刷新中...',
                fontSize: 14,
                color: Color(0xFF555555),
              ),
            ],
          ),
        ).marginOnly(bottom: 10.w),
      );

  Widget _loadFooter() => CustomFooter(
        height: 60.w,
        builder: (_, mode) {
          if (mode == LoadStatus.noMore) {
            return const Center(
              child: BaseText(
                text: '—没有更多了—',
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            );
          }
          if (mode == LoadStatus.failed) {
            return const Center(
              child: BaseText(
                text: '加载失败，点击重试',
                fontSize: 14,
                color: Color(0xFF999999),
              ),
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

class _PrintRecordCard extends StatelessWidget {
  const _PrintRecordCard({required this.record});

  final PrintExportRecord record;

  @override
  Widget build(BuildContext context) {
    final detail = record.detail;
    final email = detail.email;
    final createTime = record.createTime.isNotEmpty
        ? record.createTime
        : detail.createTime;
    final code = detail.code;
    return Container(
      key: Key('print-record-${record.id}'),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(15.w, 14.w, 15.w, 14.w),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: BaseText(
                  text: '交易明细清单',
                  fontSize: 17,
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
                color: const Color(0xFFF0F6FF),
                child: BaseText(
                  text: record.status.isNotEmpty
                      ? record.status
                      : detail.status.isNotEmpty
                          ? detail.status
                          : '处理中',
                  fontSize: 12,
                  color: const Color(0xFF0075E9),
                ),
              ),
            ],
          ),
          Divider(height: 28.w, thickness: 0.5.w, color: const Color(0xFFE9E9E9)),
          const _RecordRow(label: '开立渠道', value: '手机银行'),
          SizedBox(height: 12.w),
          const _RecordRow(label: '证明类型', value: '电子版'),
          if (email.isNotEmpty) ...[
            SizedBox(height: 12.w),
            _RecordRow(label: '电子邮箱', value: email),
          ],
          if (createTime.isNotEmpty) ...[
            SizedBox(height: 12.w),
            _RecordRow(label: '申请日期', value: createTime),
          ],
          if (code.isNotEmpty) ...[
            SizedBox(height: 12.w),
            _RecordRow(label: '密码', value: code),
          ],
          if (record.status == '已完成' && email.isNotEmpty) ...[
            SizedBox(height: 22.w),
            const BaseText(
              text: '重新发送',
              fontSize: 15,
              color: Color(0xFF0075E9),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.w,
          child: BaseText(
            text: label,
            fontSize: 14,
            color: const Color(0xFF969EAC),
          ),
        ),
        Expanded(
          child: BaseText(
            text: value,
            fontSize: 14,
            maxLines: 2,
            textAlign: TextAlign.right,
            color: const Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 260.w,
          child: const Center(
            child: BaseText(
              text: '暂无申请记录',
              fontSize: 15,
              color: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const BaseText(
        text: '加载失败，点击重试',
        fontSize: 15,
        color: Color(0xFF999999),
      ).withOnTap(onTap: onRetry),
    );
  }
}
