import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import 'community_logic.dart';
import 'community_state.dart';

// 社区页
// 说明：当前页面使用不含导航栏和分类栏的推荐内容切图，顶部导航与横向分类栏由 Flutter 单独绘制。
class CommunityPage extends BaseStateless {
  CommunityPage({super.key});

  static const String _bodyAsset =
      'assets/images/community_section_recommend.png';

  final CommunityLogic logic = Get.put(CommunityLogic());
  final CommunityState state = Get.find<CommunityLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  bool get centerTitle => false;

  @override
  bool get noBackGround1 => false;

  @override
  Color? get navColor => const Color(0xFFF7F7F7);

  @override
  Color? get background => const Color(0xFFF6F6F6);

  @override
  double? get lefItemWidth => 78.w;

  @override
  Widget? get leftItem => const _CommunityHomeButton();

  @override
  Widget? get titleWidget => const _CommunitySearchBar();

  @override
  List<Widget>? get rightAction => const [
        _CommunityNavButton(
          semanticLabel: '提醒',
          assetName: 'community_nav_notification.png',
        ),
        _CommunityNavButton(
          semanticLabel: '客服',
          assetName: 'community_nav_service.png',
        ),
        SizedBox(width: 3),
      ];

  @override
  Widget initBody(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 44.w;

    return Column(
      children: [
        SizedBox(height: topInset),
        _CommunityCategoryBar(logic: logic),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              Image.asset(
                _bodyAsset,
                width: 1.sw,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                gaplessPlayback: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommunityHomeButton extends StatelessWidget {
  const _CommunityHomeButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '主页',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: Row(
            children: [
              Image.asset(
                'assets/images/community_nav_profile.png',
                width: 17.w,
                height: 18.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 6.w),
              Text(
                '主页',
                style: TextStyle(
                  color: const Color(0xFF171717),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunitySearchBar extends StatelessWidget {
  const _CommunitySearchBar();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '搜索',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(Routes.search),
        child: Container(
          height: 34.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.w),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/community_nav_search.png',
                width: 16.w,
                height: 16.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  '搜索',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF999999),
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/community_nav_voice.png',
                width: 22.w,
                height: 22.w,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityNavButton extends StatelessWidget {
  const _CommunityNavButton({
    required this.semanticLabel,
    required this.assetName,
  });

  final String semanticLabel;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: semanticLabel == '客服'
            ? () => Get.toNamed(Routes.customerService)
            : () {},
        child: SizedBox(
          width: 37.w,
          height: 44.w,
          child: Center(
            child: Image.asset(
              'assets/images/$assetName',
              width: 21.w,
              height: 21.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityCategoryBar extends StatelessWidget {
  const _CommunityCategoryBar({required this.logic});

  static const List<String> _categories = [
    '关注',
    '推荐',
    '讨论',
    '视频',
    '资讯',
    '财富广场',
    '7x24',
  ];

  final CommunityLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.w,
      color: const Color(0xFFF7F7F7),
      child: Obx(
        () {
          final selectedIndex = logic.selectedCategoryIndex.value;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 10.w, right: 8.w),
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (_, index) {
              final selected = selectedIndex == index;
              final isServiceTab = index == _categories.length - 1;

              return Semantics(
                button: true,
                selected: selected,
                label: _categories[index],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => logic.selectCategory(index),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9.w),
                    child: Column(
                      children: [
                        SizedBox(height: 12.w),
                        SizedBox(
                          height: 17.w,
                          child: isServiceTab
                              ? Image.asset(
                                  'assets/images/community_tab_7x24.png',
                                  width: 35.w,
                                  height: 14.w,
                                  fit: BoxFit.contain,
                                )
                              : Text(
                                  _categories[index],
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(0xFF171717)
                                        : const Color(0xFF5D5D5D),
                                    fontSize: 17.sp,
                                    height: 1,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                        ),
                        SizedBox(height: 8.w),
                        SizedBox(
                          width: 29.w,
                          height: 3.w,
                          child: selected
                              ? Image.asset(
                                  'assets/images/community_tab_indicator.png',
                                  fit: BoxFit.fill,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
