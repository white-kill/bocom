import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'search_results_view.dart';
import 'search_shared_header.dart';

// 搜索页
// 说明：页面使用不含状态栏和搜索导航的内容切图，顶部定位、搜索输入框和取消按钮由 Flutter 原生绘制。
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const double _sourceWidth = 1080;
  static const double _sourceHeight = 2134;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    Get.to<void>(() => SearchResultsPage(query: query));
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
        key: const Key('search-page'),
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SearchSharedHeader(
                controller: _controller,
                onSubmitted: (_) => _submitSearch(),
                onCancel: Get.back,
                cancelKey: const Key('search-page-cancel'),
              ),
              Expanded(
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
                                'assets/images/search/search_landing_body.png',
                                fit: BoxFit.fill,
                                gaplessPlayback: true,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              height: 200 * scale,
                              child: const ColoredBox(
                                color: Color(0xFFF7F7F7),
                              ),
                            ),
                            Positioned(
                              left: 39 * scale,
                              top: 0,
                              height: 55 * scale,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '历史搜索',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 40 * scale,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 38 * scale,
                              top: 0,
                              width: 60 * scale,
                              height: 60 * scale,
                              child: Icon(
                                Icons.delete_outline,
                                color: const Color(0xFF333333),
                                size: 46 * scale,
                              ),
                            ),
                            Positioned(
                              key: const Key('search-history-flow-print'),
                              left: 38 * scale,
                              top: 80 * scale,
                              width: 228 * scale,
                              height: 80 * scale,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 28 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    40 * scale,
                                  ),
                                ),
                                child: Text(
                                  '流水打印',
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 38 * scale,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 38 * scale,
                              top: 80 * scale,
                              width: 228 * scale,
                              height: 80 * scale,
                              child: Semantics(
                                button: true,
                                label: '历史搜索：流水打印',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => Get.to<void>(
                                    () => const SearchResultsPage(
                                      query: '流水打印',
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
