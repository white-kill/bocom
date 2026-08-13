import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/model/bill_item_model.dart';
import 'package:bocom/config/model/book_analysis_model.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerAnalysisCategoryDetailPage extends StatefulWidget {
  const LedgerAnalysisCategoryDetailPage({
    super.key,
    required this.params,
    required this.category,
  });

  final Map<String, dynamic> params;
  final BookAnalysisCategoryList category;

  @override
  State<LedgerAnalysisCategoryDetailPage> createState() =>
      _LedgerAnalysisCategoryDetailPageState();
}

class _LedgerAnalysisCategoryDetailPageState
    extends State<LedgerAnalysisCategoryDetailPage> {
  final RefreshController _refreshController = RefreshController();
  BillItemModel _data = BillItemModel();
  int _pageNum = 0;
  bool _loading = true;

  bool get _isIncome => (widget.params['incomeExpenseType'] as int? ?? 2) == 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<bool> _load({bool loadMore = false}) async {
    if (loadMore && _data.pages > 0 && _pageNum >= _data.pages) {
      _refreshController.loadNoData();
      return false;
    }
    final pageNum = loadMore ? _pageNum + 1 : 1;
    final params = Map<String, dynamic>.from(widget.params)
      ..['pageNum'] = pageNum
      ..['pageSize'] = 10
      ..['categoryName'] = widget.category.categoryName;
    final value = await Http.post(
      Apis.bookAnalysisCategoryDetailPage,
      data: params,
      isLoading: false,
    );
    if (!mounted) return false;
    if (value is! Map) {
      setState(() => _loading = false);
      if (loadMore) _refreshController.loadFailed();
      return false;
    }
    final result = BillItemModel.fromJson(Map<String, dynamic>.from(value));
    if (loadMore) result.list = [..._data.list, ...result.list];
    setState(() {
      _data = result;
      _pageNum = pageNum;
      _loading = false;
    });
    final hasMore = result.pages > pageNum;
    if (loadMore) {
      hasMore
          ? _refreshController.loadComplete()
          : _refreshController.loadNoData();
    } else if (!hasMore && result.list.isNotEmpty) {
      // 首次请求时 SmartRefresher 还未挂载，直接调用 loadNoData 会丢失状态。
      // 等列表完成首帧渲染后再切换 Footer 为 noMore。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshController.loadNoData();
      });
    }
    return hasMore;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF222222), size: 22),
        ),
        title: BaseText(
          text: widget.category.categoryName,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF222222),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshConfiguration.copyAncestor(
              context: context,
              // 全局配置为 true，列表不足一屏时会隐藏 Footer。
              // 分类明细需要在首次仅有几条数据时也显示“没有更多了”。
              hideFooterWhenNotFull: false,
              child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: false,
                enablePullUp: true,
                footer: _loadFooter(),
                onLoading: () => _load(loadMore: true),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _data.list.length + 1,
                  separatorBuilder: (_, index) => index == 0
                      ? SizedBox(height: 14.w)
                      : Divider(
                          height: 1,
                          indent: 15.w,
                          endIndent: 15.w,
                          color: const Color(0xFFE2E4E7),
                        ),
                  itemBuilder: (_, index) {
                    if (index == 0) return _header();
                    return _billItem(_data.list[index - 1]);
                  },
                ),
              ),
            ),
    );
  }

  Widget _header() => Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(15.w, 25.w, 15.w, 25.w),
        child: Column(
          children: [
            BaseText(
              text: '${_periodText()} ${widget.category.categoryName}'.trim(),
              fontSize: 17,
              color: const Color(0xFF333333),
            ),
            SizedBox(height: 10.w),
            BaseText(
              text: _amount(widget.category.amount),
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2A2A2A),
            ),
            SizedBox(height: 12.w),
            BaseText(
              text: '共${_data.total}笔',
              fontSize: 17,
              color: const Color(0xFF94A0B1),
            ),
          ],
        ),
      );

  Widget _billItem(BillItemList item) {
    final detail = item.billDetail;
    final title = item.oppositeName.isNotEmpty
        ? item.oppositeName
        : (detail?.oppositeName.isNotEmpty == true
            ? detail!.oppositeName
            : item.excerpt);
    final rawCard = detail?.bankCard ?? '';
    final card = rawCard.isNotEmpty
        ? '借记卡(**${rawCard.length >= 4 ? rawCard.substring(rawCard.length - 4) : rawCard})'
        : (detail?.bankName ?? '');
    final time = item.transactionTime.isNotEmpty
        ? item.transactionTime.substring(0, 16)
        : (detail?.transactionTime ?? '');
    final amount = item.amount.replaceFirst(RegExp(r'^[+-]'), '');
    return Container(
      height: 76.w,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          item.icon.isEmpty
              ? Icon(Icons.receipt_long_outlined,
                  size: 22.w, color: const Color(0xFF333333))
              : Image.network(item.icon,
                  width: 22.w,
                  height: 22.w,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.receipt_long_outlined,
                      size: 22.w,
                      color: const Color(0xFF333333))),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText(
                  text: title,
                  fontSize: 16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: const Color(0xFF333333),
                ),
                SizedBox(height: 5.w),
                BaseText(
                  text: [card, time].where((e) => e.isNotEmpty).join(' '),
                  fontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: const Color(0xFF999999),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          BaseText(
            text: '${_isIncome ? '+' : '−'}${_amount(amount)}',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF222222),
          ),
        ],
      ),
    );
  }

  Widget _loadFooter() => CustomFooter(
        height: 60.w,
        builder: (_, mode) {
          if (mode == LoadStatus.noMore) {
            return const Center(
              child: BaseText(
                  text: '—没有更多了—', fontSize: 14, color: Color(0xFF999999)),
            ).marginOnly(top: 10.w);
          }
          if (mode == LoadStatus.failed) {
            return const Center(
              child: BaseText(
                  text: '加载失败，点击重试', fontSize: 14, color: Color(0xFF999999)),
            ).marginOnly(top: 10.w);
          }
          return Center(
            child: Image.asset(
              'assets/images/global_loading.gif',
              width: 60.w,
              height: 30.w,
              fit: BoxFit.contain,
            ),
          );
        },
      );

  String _periodText() {
    final type = widget.params['dateType']?.toString() ?? '';
    final period = widget.params['period']?.toString() ?? '';
    if (type == '月') {
      final parts = period.split('-');
      if (parts.length == 2) {
        return '${parts[0]}年${int.tryParse(parts[1]) ?? parts[1]}月';
      }
    }
    if (type == '年') return '${period}年';
    final begin = widget.params['beginTime']?.toString() ?? '';
    final end = widget.params['endTime']?.toString() ?? '';
    if (begin.isEmpty || end.isEmpty) return '';
    return '${begin.replaceAll('-', '/')}–${end.replaceAll('-', '/')}';
  }

  String _amount(String value) {
    final number = double.tryParse(value.replaceAll(',', '')) ?? 0;
    final parts = number.abs().toStringAsFixed(2).split('.');
    final chars = parts.first.split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) result.add(',');
      result.add(chars[i]);
    }
    return '${result.reversed.join()}.${parts.last}';
  }
}
