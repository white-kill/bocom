import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import 'life_logic.dart';
import 'life_state.dart';

// 生活页
// 说明：当前页面使用不含导航栏的 01、02 内容切图，透明渐变导航由 BaseStateless 单独绘制。
class LifePage extends BaseStateless {
  LifePage({super.key});

  static const List<String> _sectionAssets = [
    'assets/images/life_section_01.png',
    'assets/images/life_section_02.png',
  ];

  final LifeLogic logic = Get.put(LifeLogic());
  final LifeState state = Get.find<LifeLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  bool get centerTitle => false;

  @override
  Color? get background => const Color(0xFFF7F7F7);

  @override
  Color? get navColor => const Color(0xFFF7F7F7);

  @override
  double? get lefItemWidth => 65.w;

  @override
  Widget? get leftItem => Obx(
        () => _LifeCitySelector(isDark: logic.isNavDark.value),
      );

  @override
  Widget? get titleWidget => Obx(
        () => _LifeSearchBar(isDark: logic.isNavDark.value),
      );

  @override
  List<Widget>? get rightAction => [
        Obx(
          () => _LifeScanButton(isDark: logic.isNavDark.value),
        ),
        SizedBox(width: 3.w),
      ];

  @override
  Function(bool change)? get onNotificationNavChange => logic.setNavDark;

  @override
  Widget initBody(BuildContext context) {
    return ListView.builder(
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
    );
  }
}

class _LifeCitySelector extends StatelessWidget {
  const _LifeCitySelector({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground = isDark ? const Color(0xFF171717) : Colors.white;

    return Semantics(
      button: true,
      label: '当前城市，上海',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.only(left: 13.w),
          child: Row(
            children: [
              Container(
                width: 13.w,
                height: 13.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFF0F0F0)
                      : Colors.white.withValues(alpha: 0.24),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 13.w,
                  color: foreground,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                '上海',
                style: TextStyle(
                  color: foreground,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifeSearchBar extends StatelessWidget {
  const _LifeSearchBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final suffix = isDark ? 'dark' : 'light';
    final foreground =
        isDark ? const Color(0xFF999999) : Colors.white.withValues(alpha: 0.94);

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
            color: isDark ? Colors.white : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(18.w),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/home_nav_search_$suffix.png',
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
                    color: foreground,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/home_nav_voice_$suffix.png',
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

class _LifeScanButton extends StatelessWidget {
  const _LifeScanButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '扫一扫',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: SizedBox(
          width: 39.w,
          height: 44.w,
          child: Center(
            child: Image.asset(
              'assets/images/home_nav_scan_${isDark ? 'dark' : 'light'}.png',
              width: 23.w,
              height: 23.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
