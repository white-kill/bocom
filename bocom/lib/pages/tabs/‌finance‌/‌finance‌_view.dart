import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import '‌finance‌_logic.dart';
import '‌finance‌_state.dart';

class FinancePage extends BaseStateless {
  FinancePage({super.key});

  static const List<String> _sectionAssets = [
    'assets/images/finance_section_01.png',
    'assets/images/finance_section_02.png',
    'assets/images/finance_section_03.png',
    'assets/images/finance_section_04.png',
    'assets/images/finance_section_05.png',
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
            itemCount: _sectionAssets.length,
            itemBuilder: (_, index) => Image.asset(
              _sectionAssets[index],
              width: 1.sw,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              gaplessPlayback: true,
            ),
          ),
        ),
      ],
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
        onTap: () {},
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
