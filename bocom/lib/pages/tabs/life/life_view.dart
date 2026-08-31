import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/config/abc_config/account_city_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import 'life_logic.dart';
import 'life_state.dart';

String lifeGreetingForHour(int hour) {
  assert(hour >= 0 && hour <= 23);
  if (hour < 12) return '上午好';
  if (hour < 13) return '中午好';
  if (hour < 18) return '下午好';
  return '晚上好';
}

// 生活页
// 说明：当前页面使用不含导航栏的 01、02 内容切图，透明渐变导航由 BaseStateless 单独绘制。
class LifePage extends BaseStateless {
  LifePage({super.key});

  static const List<String> _sectionAssets = [
    'assets/images/life_section_01.png',
    'assets/images/life_section_02.png',
  ];

  static const List<_LifeHomeHotspot> _primaryHotspots = [
    _LifeHomeHotspot('生活缴费', 40, 392, 200, 190, Routes.lifePayment),
    _LifeHomeHotspot('碳星荣耀', 440, 392, 200, 190, Routes.lifeCarbonGlory),
    _LifeHomeHotspot('淘票票', 640, 392, 200, 190, Routes.lifeMovie),
    _LifeHomeHotspot('博库商城', 840, 392, 200, 190, Routes.lifeBookstore),
    _LifeHomeHotspot('京东专区', 40, 582, 200, 190, Routes.lifeJdZone),
    _LifeHomeHotspot('同程', 240, 582, 200, 190, Routes.lifeTongcheng),
    _LifeHomeHotspot('商超立减', 440, 582, 200, 190, Routes.lifeSupermarket),
    _LifeHomeHotspot('文旅专区', 640, 582, 200, 190, Routes.lifeCultureTourism),
    _LifeHomeHotspot('党费', 840, 582, 200, 190, Routes.lifePartyFee),
    _LifeHomeHotspot('电影票', 240, 772, 200, 190, Routes.lifeMovie),
    _LifeHomeHotspot('乘车码', 440, 772, 200, 190, Routes.lifeRideCode),
    _LifeHomeHotspot('唯品会', 640, 772, 200, 190, Routes.lifeVip),
    _LifeHomeHotspot('更多', 840, 772, 200, 190, Routes.lifeMoreServices),
    _LifeHomeHotspot(
      '智慧文旅用星出游',
      40,
      1001,
      1002,
      264,
      Routes.lifeCultureTourism,
    ),
    _LifeHomeHotspot('家电数码', 40, 1295, 244, 349, Routes.lifeAppliances),
    _LifeHomeHotspot(
      '用星出游',
      284,
      1295,
      245,
      349,
      Routes.lifeCultureTourism,
    ),
    _LifeHomeHotspot(
      '新能源缴费',
      553,
      1295,
      244,
      349,
      Routes.lifeNewEnergyPayment,
    ),
    _LifeHomeHotspot(
      '资金归集',
      797,
      1295,
      245,
      349,
      Routes.lifeFundCollection,
    ),
    _LifeHomeHotspot(
      '精选推荐机场服务',
      80,
      1800,
      230,
      333,
      Routes.lifeCultureTourism,
    ),
    _LifeHomeHotspot(
      '精选推荐春秋出行',
      310,
      1800,
      230,
      333,
      Routes.lifeCultureTourism,
    ),
    _LifeHomeHotspot(
      '精选推荐商超立减',
      770,
      1800,
      230,
      333,
      Routes.lifeSupermarket,
    ),
  ];

  static const List<_LifeHomeHotspot> _recommendationHotspots = [
    _LifeHomeHotspot('推荐文旅专区', 25, 500, 280, 430, Routes.lifeCultureTourism),
    _LifeHomeHotspot('推荐商超立减', 25, 940, 280, 420, Routes.lifeSupermarket),
    _LifeHomeHotspot('推荐乘车码', 25, 1370, 280, 420, Routes.lifeRideCode),
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
  double? get lefItemWidth => 70.w;

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
      physics: const ClampingScrollPhysics(),
      itemCount: _sectionAssets.length,
      itemBuilder: (_, index) {
        final section = Image.asset(
          _sectionAssets[index],
          width: 1.sw,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          gaplessPlayback: true,
        );
        if (index != 0) {
          return AspectRatio(
            key: const Key('life-home-recommendation-section'),
            aspectRatio: 609 / 3792,
            child: LayoutBuilder(
              builder: (_, constraints) {
                final sourceScale = constraints.maxWidth / 609;
                return Stack(
                  children: [
                    Positioned.fill(child: section),
                    for (final hotspot in _recommendationHotspots)
                      Positioned(
                        left: hotspot.left * sourceScale,
                        top: hotspot.top * sourceScale,
                        width: hotspot.width * sourceScale,
                        height: hotspot.height * sourceScale,
                        child: Semantics(
                          button: true,
                          label: hotspot.label,
                          child: GestureDetector(
                            key: Key('life-home-hotspot-${hotspot.label}'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Get.toNamed<void>(hotspot.route),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }

        return AspectRatio(
          key: const Key('life-home-primary-section'),
          aspectRatio: 1080 / 2133,
          child: LayoutBuilder(
            builder: (_, constraints) {
              final sourceScale = constraints.maxWidth / 1080;
              return Stack(
                children: [
                  Positioned.fill(child: section),
                  Positioned(
                    left: 20.w,
                    top: 100.w,
                    child: Text(
                      '${lifeGreetingForHour(DateTime.now().hour)}!',
                      key: const Key('life-greeting'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                  for (final hotspot in _primaryHotspots)
                    Positioned(
                      left: hotspot.left * sourceScale,
                      top: hotspot.top * sourceScale,
                      width: hotspot.width * sourceScale,
                      height: hotspot.height * sourceScale,
                      child: Semantics(
                        button: true,
                        label: hotspot.label,
                        child: GestureDetector(
                          key: Key('life-home-hotspot-${hotspot.label}'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Get.toNamed<void>(hotspot.route),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _LifeHomeHotspot {
  const _LifeHomeHotspot(
    this.label,
    this.left,
    this.top,
    this.width,
    this.height,
    this.route,
  );

  final String label;
  final double left;
  final double top;
  final double width;
  final double height;
  final String route;
}

class _LifeCitySelector extends StatelessWidget {
  const _LifeCitySelector({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground = isDark ? const Color(0xFF171717) : Colors.white;

    return AccountCityBuilder(
      builder: (_, city) => Semantics(
        button: true,
        label: '当前城市，$city',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.only(left: 13.w),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/search/search_location.png',
                  key: const Key('life-city-location-icon'),
                  width: 17.w,
                  height: 20.w,
                  fit: BoxFit.contain,
                  color: foreground,
                  colorBlendMode: BlendMode.srcIn,
                  excludeFromSemantics: true,
                ),
                SizedBox(width: 3.w),
                Text(
                  city,
                  key: const Key('life-city-label'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        onTap: () => Get.toNamed(Routes.scan),
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
