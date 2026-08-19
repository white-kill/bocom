import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'search_shared_header.dart';

// 搜索结果页
// 说明：当前页面使用已裁掉系统状态栏、但保留搜索栏和分类栏的结果截图，不额外叠加 AppBar。
class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({required this.query, super.key});

  static const double _sourceWidth = 1206;
  static const double _sourceHeight = 2479;
  static const double _removedStatusBarHeight = 143;

  final String query;

  void _openTransactionDetails() {
    Get.toNamed<void>(Routes.transactionDetail);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF7F7F7),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7F7F7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('search-results-page'),
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (_, constraints) {
                final scale = constraints.maxWidth / _sourceWidth;
                return SizedBox(
                  width: constraints.maxWidth,
                  height: _sourceHeight * scale,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/search/search_results_body.png',
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: SearchSharedHeader(
                          query: query,
                          onCancel: Get.back,
                          cancelKey: const Key('search-results-cancel'),
                        ),
                      ),
                      Positioned(
                        left: 44 * scale,
                        right: 44 * scale,
                        top: (600 - _removedStatusBarHeight) * scale,
                        height: 204 * scale,
                        child: Semantics(
                          button: true,
                          label: '交易明细清单',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _openTransactionDetails,
                          ),
                        ),
                      ),
                      Positioned(
                        key: const Key('search-result-transaction-detail'),
                        left: 44 * scale,
                        right: 44 * scale,
                        top: (804 - _removedStatusBarHeight) * scale,
                        height: 198 * scale,
                        child: Semantics(
                          button: true,
                          label: '交易明细',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _openTransactionDetails,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
