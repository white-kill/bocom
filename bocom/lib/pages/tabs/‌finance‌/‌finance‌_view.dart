import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import '‌finance‌_logic.dart';
import '‌finance‌_state.dart';

class FinancePage extends BaseStateless {
  FinancePage({super.key});

  static const List<_FinanceSection> _sections = [
    _FinanceSection(
      assetPath: 'assets/images/finance_section_01.png',
      sourceWidth: 1080,
      sourceHeight: 1183,
      hotspots: [
        _FinanceHotspot(
          label: '上证指数',
          route: Routes.financeWealthIndex,
          sourceRect: Rect.fromLTWH(42, 463, 249, 272),
        ),
        _FinanceHotspot(
          label: '深证成指',
          route: Routes.financeWealthIndex,
          sourceRect: Rect.fromLTWH(291, 463, 249, 272),
        ),
        _FinanceHotspot(
          label: '黄金(活期金)',
          route: Routes.financeWealthIndex,
          sourceRect: Rect.fromLTWH(540, 463, 249, 272),
        ),
        _FinanceHotspot(
          label: '交银指数',
          route: Routes.financeWealthIndex,
          sourceRect: Rect.fromLTWH(789, 463, 249, 272),
        ),
        _FinanceHotspot(
          label: '7X24快讯',
          route: Routes.financeFlashNews,
          sourceRect: Rect.fromLTWH(42, 727, 996, 126),
        ),
        _FinanceHotspot(
          label: '养“基”活动',
          route: Routes.financeWealthSelection,
          sourceRect: Rect.fromLTWH(0, 875, 216, 286),
        ),
        _FinanceHotspot(
          label: '好理给你',
          route: Routes.financeWealthForYou,
          sourceRect: Rect.fromLTWH(216, 875, 216, 286),
        ),
        _FinanceHotspot(
          label: '养老保障季',
          route: Routes.financePensionSeason,
          sourceRect: Rect.fromLTWH(432, 875, 216, 286),
        ),
        _FinanceHotspot(
          label: '交易明星',
          route: Routes.financeTradingStars,
          sourceRect: Rect.fromLTWH(648, 875, 216, 286),
        ),
        _FinanceHotspot(
          label: '行业基会',
          route: Routes.financeIndustryFund,
          sourceRect: Rect.fromLTWH(864, 875, 216, 286),
        ),
      ],
    ),
    _FinanceSection(
      assetPath: 'assets/images/finance_section_02.png',
      sourceWidth: 1080,
      sourceHeight: 1300,
      hotspots: [
        _FinanceHotspot(
          label: '财富精选',
          route: Routes.financeWealthSelection,
          sourceRect: Rect.fromLTWH(42, 0, 996, 975),
        ),
        _FinanceHotspot(
          label: '省心定投',
          route: Routes.financeRecurringInvestment,
          sourceRect: Rect.fromLTWH(40, 1005, 500, 257),
        ),
        _FinanceHotspot(
          label: '指数专区',
          route: Routes.financeIndexZone,
          sourceRect: Rect.fromLTWH(548, 1005, 492, 257),
        ),
      ],
    ),
    _FinanceSection(
      assetPath: 'assets/images/finance_section_03.png',
      sourceWidth: 1080,
      sourceHeight: 1474,
      hotspots: [
        _FinanceHotspot(
          label: '灵活存取',
          route: Routes.financeFlexibleInvestment,
          sourceRect: Rect.fromLTWH(40, 72, 1000, 912),
        ),
      ],
    ),
    _FinanceSection(
      assetPath: 'assets/images/finance_section_04.png',
      sourceWidth: 1080,
      sourceHeight: 395,
      hotspots: [
        _FinanceHotspot(
          label: '贷款推荐',
          route: Routes.financeLoanRecommendation,
          sourceRect: Rect.fromLTWH(40, 0, 1000, 330),
        ),
      ],
    ),
    _FinanceSection(
      assetPath: 'assets/images/finance_section_05.png',
      sourceWidth: 765,
      sourceHeight: 3816,
      hotspots: [
        _FinanceHotspot(
          label: '更多发现-7X24快讯',
          route: Routes.financeFlashNews,
          sourceRect: Rect.fromLTWH(390, 2400, 355, 575),
        ),
        _FinanceHotspot(
          label: '闲钱就放活期富',
          route: Routes.financeFlexibleInvestment,
          sourceRect: Rect.fromLTWH(390, 3000, 355, 816),
        ),
      ],
    ),
  ];

  final FinanceLogic logic = Get.put(FinanceLogic());
  final FinanceState state = Get.find<FinanceLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  bool get centerTitle => false;

  @override
  bool get noBackGround1 => false;

  @override
  Color? get navColor => const Color(0xFFF7F7F7);

  @override
  Color? get background => const Color(0xFFF7F7F7);

  @override
  double? get lefItemWidth => 106.w;

  @override
  Widget? get leftItem => const _FinanceRevenueCenter();

  @override
  Widget? get titleWidget => const _FinanceSearchBar();

  @override
  List<Widget>? get rightAction => const [
        _FinanceNavButton(
          semanticLabel: '客服',
          assetName: 'finance_nav_service.png',
        ),
        _FinanceNavButton(
          semanticLabel: '消息',
          assetName: 'finance_nav_message.png',
          showBadge: true,
        ),
        SizedBox(width: 4),
      ];

  @override
  Widget initBody(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 44.w;

    return Column(
      children: [
        SizedBox(height: topInset),
        _FinanceCategoryBar(logic: logic),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: _sections.length,
            itemBuilder: (_, index) =>
                _FinanceSectionImage(section: _sections[index]),
          ),
        ),
      ],
    );
  }
}

class _FinanceSection {
  const _FinanceSection({
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.hotspots,
  });

  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final List<_FinanceHotspot> hotspots;
}

class _FinanceHotspot {
  const _FinanceHotspot({
    required this.label,
    required this.route,
    required this.sourceRect,
  });

  final String label;
  final String route;
  final Rect sourceRect;
}

class _FinanceSectionImage extends StatelessWidget {
  const _FinanceSectionImage({required this.section});

  final _FinanceSection section;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final scale = constraints.maxWidth / section.sourceWidth;
        return SizedBox(
          key: Key('finance-section-${section.assetPath}'),
          width: constraints.maxWidth,
          height: section.sourceHeight * scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  section.assetPath,
                  fit: BoxFit.fill,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                ),
              ),
              for (final hotspot in section.hotspots)
                Positioned(
                  key: Key('finance-entry-${hotspot.label}'),
                  left: hotspot.sourceRect.left * scale,
                  top: hotspot.sourceRect.top * scale,
                  width: hotspot.sourceRect.width * scale,
                  height: hotspot.sourceRect.height * scale,
                  child: Semantics(
                    button: true,
                    label: hotspot.label,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed<void>(hotspot.route),
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

class _FinanceRevenueCenter extends StatelessWidget {
  const _FinanceRevenueCenter();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '收益中心',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.only(left: 13.w),
          child: Row(
            children: [
              Image.asset(
                'assets/images/finance_nav_revenue.png',
                width: 18.w,
                height: 18.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 6.w),
              Text(
                '收益中心',
                style: TextStyle(
                  color: const Color(0xFF151515),
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

class _FinanceSearchBar extends StatelessWidget {
  const _FinanceSearchBar();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '搜索',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(Routes.search),
        child: Container(
          width: 178.w,
          height: 34.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.w),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/finance_nav_search.png',
                width: 16.w,
                height: 16.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  '搜索',
                  style: TextStyle(
                    color: const Color(0xFF999999),
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/finance_nav_voice.png',
                width: 21.w,
                height: 21.w,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceNavButton extends StatelessWidget {
  const _FinanceNavButton({
    required this.semanticLabel,
    required this.assetName,
    this.showBadge = false,
  });

  final String semanticLabel;
  final String assetName;
  final bool showBadge;

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
          width: 34.w,
          height: 44.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/$assetName',
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
              if (showBadge)
                Positioned(
                  top: 6.w,
                  right: 3.w,
                  child: Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4D55),
                      shape: BoxShape.circle,
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

class _FinanceCategoryBar extends StatelessWidget {
  const _FinanceCategoryBar({required this.logic});

  static const List<String> _categories = [
    '推荐',
    '存款',
    '贷款',
    '理财',
    '基金',
    '保险',
    '黄金',
    '债券',
    '贵金属钱包',
    '外汇',
  ];

  final FinanceLogic logic;

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
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            itemBuilder: (_, index) {
              final selected = selectedIndex == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => logic.selectCategory(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11.w),
                  child: Column(
                    children: [
                      SizedBox(height: 21.w),
                      Text(
                        _categories[index],
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF171717)
                              : const Color(0xFF5D5D5D),
                          fontSize: 15.sp,
                          height: 1,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 2.w,
                        child: selected
                            ? Image.asset(
                                'assets/images/finance_tab_indicator.png',
                                width: 28.w,
                                height: 2.w,
                                fit: BoxFit.fill,
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 4.w),
                    ],
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
