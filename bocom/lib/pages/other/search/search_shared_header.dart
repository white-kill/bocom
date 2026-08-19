import 'package:flutter/material.dart';

import 'search_city_text.dart';

// 搜索页共享顶部
// 说明：搜索首页和结果页统一使用同一张已移除系统状态栏的顶部切图，城市与搜索词由 Flutter 动态覆盖。
class SearchSharedHeader extends StatelessWidget {
  const SearchSharedHeader({
    required this.onCancel,
    this.controller,
    this.query,
    this.onSubmitted,
    this.cancelKey,
    super.key,
  }) : assert(controller != null || query != null);

  static const double sourceWidth = 1206;
  static const double sourceHeight = 175;

  final TextEditingController? controller;
  final String? query;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onCancel;
  final Key? cancelKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final scale = constraints.maxWidth / sourceWidth;
        return SizedBox(
          key: const Key('search-shared-header'),
          width: constraints.maxWidth,
          height: sourceHeight * scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/search/search_shared_header.png',
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
              Positioned(
                left: 108 * scale,
                top: 45 * scale,
                width: 154 * scale,
                height: 112 * scale,
                child: const ColoredBox(color: Color(0xFFF7F7F7)),
              ),
              Positioned(
                left: 121 * scale,
                top: 45 * scale,
                width: 132 * scale,
                height: 112 * scale,
                child: Transform.translate(
                  offset: Offset(0, 7 * scale),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SearchCityText(fontSize: 50 * scale),
                  ),
                ),
              ),
              Positioned(
                left: 350 * scale,
                top: 76 * scale,
                width: 548 * scale,
                height: 65 * scale,
                child: const ColoredBox(color: Color(0xFFF7F7F7)),
              ),
              Positioned(
                left: 365 * scale,
                top: 55 * scale,
                width: 520 * scale,
                height: 102 * scale,
                child: controller == null
                    ? Transform.translate(
                        offset: Offset(0, 7 * scale),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            query ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 45 * scale,
                              height: 1,
                            ),
                          ),
                        ),
                      )
                    : TextField(
                        key: const Key('search-input'),
                        controller: controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: onSubmitted,
                        maxLines: 1,
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 45 * scale,
                          height: 1.1,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(top: 34 * scale),
                          border: InputBorder.none,
                          hintText: '安徽沃德专区',
                          hintStyle: TextStyle(
                            color: const Color(0xFFA7ACB8),
                            fontSize: 45 * scale,
                          ),
                        ),
                      ),
              ),
              Positioned(
                key: cancelKey,
                right: 18 * scale,
                top: 32 * scale,
                width: 168 * scale,
                height: 135 * scale,
                child: Semantics(
                  button: true,
                  label: '取消',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onCancel,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
