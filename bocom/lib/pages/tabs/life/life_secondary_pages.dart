import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../config/abc_config/account_city_builder.dart';
import '../../../routes/app_pages.dart';

const _lifeAssetRoot = 'assets/images/life_secondary';

class LifePaymentPage extends StatelessWidget {
  const LifePaymentPage({super.key});

  @override
  Widget build(BuildContext context) => const _RetainedImagePage(
        pageKey: Key('life-payment-page'),
        assetPath: '$_lifeAssetRoot/life_payment.png',
        sourceWidth: 645,
        sourceHeight: 1772,
        backgroundColor: Color(0xFFF5F7FA),
        cityOverlays: [_CityOverlay.payment],
        backWidth: 100,
        navigationHeight: 180,
      );
}

class LifeMoviePage extends StatelessWidget {
  const LifeMoviePage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-movie-page'),
        assetPath: '$_lifeAssetRoot/movie.png',
        sourceHeight: 2161,
        title: '电影',
        miniProgramNavigation: true,
        cityOverlays: [_CityOverlay.movie],
        backgroundColor: Color(0xFFF5F6F8),
      );
}

class LifePartyFeePage extends StatelessWidget {
  const LifePartyFeePage({super.key});

  @override
  Widget build(BuildContext context) => const _RetainedImagePage(
        pageKey: Key('life-party-fee-page'),
        assetPath: '$_lifeAssetRoot/party_fee.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        backgroundColor: Color(0xFF888888),
        dismissOnAnyTap: true,
        dismissKey: Key('life-party-fee-dismiss'),
        backWidth: 145,
        navigationHeight: 220,
      );
}

class LifeVipPage extends StatelessWidget {
  const LifeVipPage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-vip-page'),
        assetPath: '$_lifeAssetRoot/vip.png',
        sourceHeight: 2161,
        title: '唯品会',
        miniProgramNavigation: true,
        backgroundColor: Color(0xFFFFF6FA),
      );
}

class LifeSocialSecurityPage extends StatelessWidget {
  const LifeSocialSecurityPage({super.key});

  @override
  Widget build(BuildContext context) => const _RetainedImagePage(
        pageKey: Key('life-social-security-page'),
        assetPath: '$_lifeAssetRoot/social_security.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        backgroundColor: Color(0xFFFFFFFF),
        cityOverlays: [_CityOverlay.socialSecurity],
        backWidth: 145,
        navigationHeight: 220,
      );
}

class LifeRideCodePage extends StatelessWidget {
  const LifeRideCodePage({super.key});

  @override
  Widget build(BuildContext context) => const _RetainedImagePage(
        pageKey: Key('life-ride-code-page'),
        assetPath: '$_lifeAssetRoot/ride_code.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        backgroundColor: Color(0xFF205B8B),
        cityOverlays: [_CityOverlay.rideCode],
        dismissOnAnyTap: true,
        dismissKey: Key('life-ride-code-dismiss'),
        lightStatusBar: true,
        backWidth: 150,
        navigationHeight: 220,
      );
}

class LifeCultureTourismPage extends StatelessWidget {
  const LifeCultureTourismPage({super.key});

  @override
  Widget build(BuildContext context) => const _RetainedImagePage(
        pageKey: Key('life-culture-tourism-page'),
        assetPath: '$_lifeAssetRoot/culture_tourism.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        backgroundColor: Color(0xFFF0EADB),
        lightStatusBar: true,
        backWidth: 150,
        navigationHeight: 220,
      );
}

class LifeCreditPointsPage extends StatelessWidget {
  const LifeCreditPointsPage({super.key});

  @override
  Widget build(BuildContext context) => const _RetainedImagePage(
        pageKey: Key('life-credit-points-page'),
        assetPath: '$_lifeAssetRoot/credit_points.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        backgroundColor: Color(0xFF888888),
        dismissOnAnyTap: true,
        dismissKey: Key('life-credit-points-dismiss'),
        backWidth: 150,
        navigationHeight: 220,
      );
}

class LifeTongchengPage extends StatelessWidget {
  const LifeTongchengPage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-tongcheng-page'),
        assetPath: '$_lifeAssetRoot/tongcheng.png',
        sourceHeight: 2160,
        title: '同程',
        miniProgramNavigation: true,
        cityOverlays: [
          _CityOverlay.tongchengSearch,
          _CityOverlay.tongchengCardOne,
          _CityOverlay.tongchengCardTwo,
          _CityOverlay.tongchengCardThree,
        ],
        backgroundColor: Color(0xFFEAF0FB),
      );
}

class LifeSupermarketPage extends StatelessWidget {
  const LifeSupermarketPage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-supermarket-page'),
        assetPath: '$_lifeAssetRoot/supermarket.png',
        sourceHeight: 2160,
        title: '商超立减',
        miniProgramNavigation: true,
        backgroundColor: Color(0xFFF4F4F4),
      );
}

class LifeBookstorePage extends StatelessWidget {
  const LifeBookstorePage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-bookstore-page'),
        assetPath: '$_lifeAssetRoot/bookstore.png',
        sourceHeight: 2160,
        title: '博库商城',
        miniProgramNavigation: true,
        backgroundColor: Color(0xFF008A70),
      );
}

class LifeJdZonePage extends StatelessWidget {
  const LifeJdZonePage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-jd-zone-page'),
        assetPath: '$_lifeAssetRoot/jd_account.png',
        sourceHeight: 2160,
        title: '关联账号',
        miniProgramNavigation: true,
        backgroundColor: Color(0xFFFFFFFF),
      );
}

class LifeAppliancesPage extends StatelessWidget {
  const LifeAppliancesPage({super.key});

  @override
  Widget build(BuildContext context) => const _RetainedImagePage(
        pageKey: Key('life-appliances-page'),
        assetPath: '$_lifeAssetRoot/appliances.png',
        sourceWidth: 1080,
        sourceHeight: 2376,
        backgroundColor: Color(0xFFFFB24C),
        lightStatusBar: true,
        backWidth: 150,
        navigationHeight: 220,
      );
}

class LifeTeaZonePage extends StatelessWidget {
  const LifeTeaZonePage({super.key});

  @override
  Widget build(BuildContext context) => const _ImmersiveLongImagePage(
        pageKey: Key('life-tea-zone-page'),
        pinnedNavigationKey: Key('life-tea-zone-pinned-navigation'),
        assetPath: '$_lifeAssetRoot/tea_zone.png',
        sourceWidth: 1080,
        sourceHeight: 3898,
        sourceNavigationHeight: 176,
        sourceBackWidth: 145,
        title: '茶饮专区',
        backgroundColor: Color(0xFFFFECD5),
        initialLightStatusBar: true,
        showShareAction: true,
      );
}

class LifeNewEnergyPaymentPage extends StatelessWidget {
  const LifeNewEnergyPaymentPage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-new-energy-page'),
        assetPath: '$_lifeAssetRoot/new_energy.png',
        sourceHeight: 2165,
        title: '新能源缴费',
        dismissOnAnyTap: true,
        dismissKey: Key('life-new-energy-dismiss'),
        backgroundColor: Color(0xFF888888),
      );
}

class LifeFundCollectionPage extends StatelessWidget {
  const LifeFundCollectionPage({super.key});

  @override
  Widget build(BuildContext context) => const _NativeBodyImagePage(
        pageKey: Key('life-fund-collection-page'),
        assetPath: '$_lifeAssetRoot/fund_collection.png',
        sourceHeight: 2165,
        title: '定期转入计划',
        backgroundColor: Color(0xFFF7F7F7),
      );
}

class LifeCarbonGloryPage extends StatelessWidget {
  const LifeCarbonGloryPage({super.key});

  @override
  Widget build(BuildContext context) => const _ImmersiveLongImagePage(
        pageKey: Key('life-carbon-glory-page'),
        pinnedNavigationKey: Key('life-carbon-glory-pinned-navigation'),
        assetPath: '$_lifeAssetRoot/carbon_glory.png',
        sourceWidth: 638,
        sourceHeight: 4096,
        sourceNavigationHeight: 110,
        sourceBackWidth: 82,
        title: '碳星荣耀',
        backgroundColor: Color(0xFFF5FFF0),
        showShareAction: true,
      );
}

class _NativeBodyImagePage extends StatelessWidget {
  const _NativeBodyImagePage({
    required this.pageKey,
    required this.assetPath,
    required this.sourceHeight,
    required this.title,
    required this.backgroundColor,
    this.cityOverlays = const [],
    this.miniProgramNavigation = false,
    this.dismissOnAnyTap = false,
    this.dismissKey,
  });

  final Key pageKey;
  final String assetPath;
  final double sourceHeight;
  final String title;
  final Color backgroundColor;
  final List<_CityOverlay> cityOverlays;
  final bool miniProgramNavigation;
  final bool dismissOnAnyTap;
  final Key? dismissKey;

  @override
  Widget build(BuildContext context) {
    final page = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _LifeNavigationBar(
                title: title,
                miniProgram: miniProgramNavigation,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    const sourceWidth = 1080.0;
                    final scale = constraints.maxWidth / sourceWidth;
                    return SingleChildScrollView(
                      key: pageKey,
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: sourceHeight * scale,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                assetPath,
                                fit: BoxFit.fill,
                                gaplessPlayback: true,
                              ),
                            ),
                            for (final overlay in cityOverlays)
                              _AccountCityOverlay(
                                overlay: overlay,
                                scale: scale,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!dismissOnAnyTap) return page;
    return Semantics(
      button: true,
      label: '点击任意位置返回',
      child: GestureDetector(
        key: dismissKey,
        behavior: HitTestBehavior.opaque,
        onTap: Get.back,
        child: page,
      ),
    );
  }
}

class _RetainedImagePage extends StatelessWidget {
  const _RetainedImagePage({
    required this.pageKey,
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.backgroundColor,
    required this.backWidth,
    required this.navigationHeight,
    this.cityOverlays = const [],
    this.dismissOnAnyTap = false,
    this.dismissKey,
    this.lightStatusBar = false,
  });

  final Key pageKey;
  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final Color backgroundColor;
  final double backWidth;
  final double navigationHeight;
  final List<_CityOverlay> cityOverlays;
  final bool dismissOnAnyTap;
  final Key? dismissKey;
  final bool lightStatusBar;

  @override
  Widget build(BuildContext context) {
    final body = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            lightStatusBar ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            lightStatusBar ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(
          builder: (_, constraints) {
            final scale = constraints.maxWidth / sourceWidth;
            return SingleChildScrollView(
              key: pageKey,
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: constraints.maxWidth,
                height: sourceHeight * scale,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                    ),
                    for (final overlay in cityOverlays)
                      _AccountCityOverlay(overlay: overlay, scale: scale),
                    if (!dismissOnAnyTap)
                      Positioned(
                        left: 0,
                        top: 0,
                        width: backWidth * scale,
                        height: navigationHeight * scale,
                        child: Semantics(
                          button: true,
                          label: '返回',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: Get.back,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (!dismissOnAnyTap) return body;
    return Semantics(
      button: true,
      label: '点击任意位置返回',
      child: GestureDetector(
        key: dismissKey,
        behavior: HitTestBehavior.opaque,
        onTap: Get.back,
        child: body,
      ),
    );
  }
}

class _ImmersiveLongImagePage extends StatefulWidget {
  const _ImmersiveLongImagePage({
    required this.pageKey,
    required this.pinnedNavigationKey,
    required this.assetPath,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.sourceNavigationHeight,
    required this.sourceBackWidth,
    required this.title,
    required this.backgroundColor,
    this.initialLightStatusBar = false,
    this.showShareAction = false,
  });

  final Key pageKey;
  final Key pinnedNavigationKey;
  final String assetPath;
  final double sourceWidth;
  final double sourceHeight;
  final double sourceNavigationHeight;
  final double sourceBackWidth;
  final String title;
  final Color backgroundColor;
  final bool initialLightStatusBar;
  final bool showShareAction;

  @override
  State<_ImmersiveLongImagePage> createState() =>
      _ImmersiveLongImagePageState();
}

class _ImmersiveLongImagePageState extends State<_ImmersiveLongImagePage> {
  late final ScrollController _controller;
  bool _showPinnedNavigation = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(keepScrollOffset: false)
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_controller.hasClients) return;
    final scale = MediaQuery.sizeOf(context).width / widget.sourceWidth;
    final next = _controller.offset >= widget.sourceNavigationHeight * scale;
    if (next == _showPinnedNavigation) return;
    setState(() => _showPinnedNavigation = next);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _showPinnedNavigation
        ? Brightness.dark
        : widget.initialLightStatusBar
            ? Brightness.light
            : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        statusBarBrightness:
            brightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: widget.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final scale = constraints.maxWidth / widget.sourceWidth;
                  return SingleChildScrollView(
                    key: widget.pageKey,
                    controller: _controller,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: widget.sourceHeight * scale,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              widget.assetPath,
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            width: widget.sourceBackWidth * scale,
                            height: widget.sourceNavigationHeight * scale,
                            child: Semantics(
                              button: true,
                              label: '返回',
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: Get.back,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: IgnorePointer(
                ignoring: !_showPinnedNavigation,
                child: AnimatedOpacity(
                  key: widget.pinnedNavigationKey,
                  opacity: _showPinnedNavigation ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: _LifePinnedNavigation(
                    title: widget.title,
                    showShareAction: widget.showShareAction,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifeNavigationBar extends StatelessWidget {
  const _LifeNavigationBar({required this.title, required this.miniProgram});

  final String title;
  final bool miniProgram;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _LifeNavigationButton(
              label: '返回',
              onTap: Get.back,
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 23,
                color: Color(0xFF263746),
              ),
            ),
          ),
          if (miniProgram)
            Positioned(
              right: 7,
              top: 7,
              bottom: 7,
              child: Semantics(
                label: '小程序菜单',
                button: true,
                child: Image.asset(
                  '$_lifeAssetRoot/mini_program_actions.png',
                  width: 84,
                  fit: BoxFit.fill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LifePinnedNavigation extends StatelessWidget {
  const _LifePinnedNavigation({
    required this.title,
    required this.showShareAction,
  });

  final String title;
  final bool showShareAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _LifeNavigationButton(
                  label: '返回',
                  onTap: Get.back,
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 23,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (showShareAction)
                const Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: _LifeNavigationButton(
                    label: '分享',
                    onTap: _emptyTap,
                    child: Icon(
                      Icons.ios_share_outlined,
                      size: 23,
                      color: Color(0xFF1A1A1A),
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

void _emptyTap() {}

class _LifeNavigationButton extends StatelessWidget {
  const _LifeNavigationButton({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(width: 48, child: Center(child: child)),
      ),
    );
  }
}

enum _CityOverlay {
  payment,
  movie,
  rideCode,
  socialSecurity,
  tongchengSearch,
  tongchengCardOne,
  tongchengCardTwo,
  tongchengCardThree,
}

class _AccountCityOverlay extends StatelessWidget {
  const _AccountCityOverlay({required this.overlay, required this.scale});

  final _CityOverlay overlay;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AccountCityBuilder(
      builder: (_, city) {
        switch (overlay) {
          case _CityOverlay.payment:
            return _positionedCity(
              key: const Key('life-payment-account-city'),
              city: city,
              left: 541,
              top: 210,
              width: 52,
              height: 30,
              fontSize: 20.5,
              color: const Color(0xFF171717),
              alignment: Alignment.centerRight,
            );
          case _CityOverlay.movie:
            return _positionedCity(
              key: const Key('life-movie-account-city'),
              city: city,
              left: 101,
              top: 765,
              width: 90,
              height: 44,
              fontSize: 34.75,
              color: const Color(0xFF333333),
            );
          case _CityOverlay.rideCode:
            return _positionedCity(
              key: const Key('life-ride-code-account-city'),
              city: city,
              left: 86,
              top: 221,
              width: 120,
              height: 87,
              fontSize: 43,
              color: const Color(0xFF778089),
            );
          case _CityOverlay.socialSecurity:
            return _positionedCity(
              key: const Key('life-social-security-account-city'),
              city: city,
              left: 918,
              top: 133,
              width: 76,
              height: 38,
              fontSize: 34.5,
              color: const Color(0xFF1D1D1D),
            );
          case _CityOverlay.tongchengSearch:
            return _positionedCity(
              key: const Key('life-tongcheng-search-account-city'),
              city: '$city出发',
              left: 117,
              top: 54,
              width: 145,
              height: 42,
              fontSize: 37,
              color: const Color(0xFF111111),
              alignment: Alignment.centerLeft,
            );
          case _CityOverlay.tongchengCardOne:
            return _tongchengCardCity(city, 638, 'one');
          case _CityOverlay.tongchengCardTwo:
            return _tongchengCardCity(city, 1118, 'two');
          case _CityOverlay.tongchengCardThree:
            return _tongchengCardCity(city, 1598, 'three');
        }
      },
    );
  }

  Widget _tongchengCardCity(String city, double top, String suffix) {
    return _positionedCity(
      key: Key('life-tongcheng-card-$suffix-account-city'),
      city: '$city出发',
      left: 118,
      top: top,
      width: 119,
      height: 34,
      fontSize: 28,
      color: Colors.white,
    );
  }

  Widget _positionedCity({
    required Key key,
    required String city,
    required double left,
    required double top,
    required double width,
    required double height,
    required double fontSize,
    required Color color,
    Alignment alignment = Alignment.center,
  }) {
    return Positioned(
      left: left * scale,
      top: top * scale,
      width: width * scale,
      height: height * scale,
      child: Semantics(
        label: '当前城市，$city',
        child: Align(
          alignment: alignment,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              city,
              key: key,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: fontSize * scale,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LifeMoreServicesPage extends StatefulWidget {
  const LifeMoreServicesPage({super.key});

  @override
  State<LifeMoreServicesPage> createState() => _LifeMoreServicesPageState();
}

class _LifeMoreServicesPageState extends State<LifeMoreServicesPage> {
  static const double _sourceWidth = 1080;
  static const double _menuSourceWidth = 265;
  static const double _contentSourceWidth = 815;
  static const double _menuItemSourceHeight = 134;
  static const double _menuLabelSourceTop = 17.3;
  static const double _selectedIndicatorSourceTop = 10;
  static const double _selectedIndicatorSourceHeight = 49;
  static const double _gridTop = 95;
  static const double _rowExtent = 176;

  static const List<_LifeServiceSection> _sections = [
    _LifeServiceSection(
      id: 'payment',
      title: '充值缴费',
      asset: '$_lifeAssetRoot/more_payment.png',
      sourceHeight: 914,
      hotspots: [
        _LifeServiceHotspot('生活缴费', 0, 0, Routes.lifePayment),
      ],
    ),
    _LifeServiceSection(
      id: 'transport',
      title: '交通出行',
      asset: '$_lifeAssetRoot/more_transport.png',
      sourceHeight: 730,
      hotspots: [
        _LifeServiceHotspot('文旅专区', 0, 0, Routes.lifeCultureTourism),
        _LifeServiceHotspot('同程', 0, 2, Routes.lifeTongcheng),
        _LifeServiceHotspot('乘车码', 1, 0, Routes.lifeRideCode),
      ],
    ),
    _LifeServiceSection(
      id: 'shopping',
      title: '甄选购物',
      asset: '$_lifeAssetRoot/more_shopping.png',
      sourceHeight: 906,
      hotspots: [
        _LifeServiceHotspot('商超立减', 0, 0, Routes.lifeSupermarket),
        _LifeServiceHotspot('京东专区', 0, 1, Routes.lifeJdZone),
        _LifeServiceHotspot('唯品会', 1, 0, Routes.lifeVip),
        _LifeServiceHotspot('博库商城', 2, 2, Routes.lifeBookstore),
      ],
    ),
    _LifeServiceSection(
      id: 'government',
      title: '政务服务',
      asset: '$_lifeAssetRoot/more_government.png',
      sourceHeight: 729,
      hotspots: [
        _LifeServiceHotspot('社保专区', 0, 0, Routes.lifeSocialSecurity),
        _LifeServiceHotspot('党费', 0, 1, Routes.lifePartyFee),
      ],
    ),
    _LifeServiceSection(
      id: 'entertainment',
      title: '餐饮娱乐',
      asset: '$_lifeAssetRoot/more_entertainment.png',
      sourceHeight: 726,
      hotspots: [
        _LifeServiceHotspot('电影票', 0, 2, Routes.lifeMovie),
        _LifeServiceHotspot('淘票票电影', 1, 0, Routes.lifeMovie),
        _LifeServiceHotspot('茶饮专区', 2, 1, Routes.lifeTeaZone),
      ],
    ),
    _LifeServiceSection(
      id: 'car',
      title: '车主生活',
      asset: '$_lifeAssetRoot/more_car.png',
      sourceHeight: 551,
    ),
    _LifeServiceSection(
      id: 'housing',
      title: '住房安居',
      asset: '$_lifeAssetRoot/more_housing.png',
      sourceHeight: 554,
    ),
    _LifeServiceSection(
      id: 'local',
      title: '本地生活',
      asset: '$_lifeAssetRoot/more_local.png',
      sourceHeight: 723,
      hotspots: [
        _LifeServiceHotspot('新能源缴费', 0, 0, Routes.lifeNewEnergyPayment),
      ],
    ),
    _LifeServiceSection(
      id: 'more',
      title: '更多服务',
      asset: '$_lifeAssetRoot/more_services.png',
      sourceHeight: 2128,
    ),
  ];

  final ScrollController _menuController = ScrollController();
  final ScrollController _contentController = ScrollController();
  int _selectedIndex = 0;
  int? _programmaticTarget;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_handleContentScroll);
  }

  @override
  void dispose() {
    _contentController
      ..removeListener(_handleContentScroll)
      ..dispose();
    _menuController.dispose();
    super.dispose();
  }

  void _handleContentScroll() {
    if (_programmaticTarget != null || !_contentController.hasClients) return;
    if (_contentController.position.extentAfter <= 1) {
      _selectMenu(_sections.length - 1);
      return;
    }
    final offset = _contentController.offset + 1;
    var start = 0.0;
    var index = 0;
    for (var i = 1; i < _sections.length; i++) {
      start += _sections[i - 1].sourceHeight * _scale;
      if (offset < start) break;
      index = i;
    }
    _selectMenu(index);
  }

  void _selectMenu(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealMenu(index));
  }

  void _revealMenu(int index) {
    if (!_menuController.hasClients) return;
    final extent = _menuItemSourceHeight * _scale;
    final top = index * extent;
    final bottom = top + extent;
    final position = _menuController.position;
    var target = position.pixels;
    if (top < position.pixels) {
      target = top;
    } else if (bottom > position.pixels + position.viewportDimension) {
      target = bottom - position.viewportDimension;
    }
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    _menuController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollToSection(int index) async {
    if (!_contentController.hasClients) return;
    var target = 0.0;
    for (var i = 0; i < index; i++) {
      target += _sections[i].sourceHeight * _scale;
    }
    target = target.clamp(
      _contentController.position.minScrollExtent,
      _contentController.position.maxScrollExtent,
    );
    _programmaticTarget = index;
    _selectMenu(index);
    try {
      await _contentController.animateTo(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _programmaticTarget = null;
      if (mounted) _handleContentScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (_, constraints) {
              _scale = constraints.maxWidth / _sourceWidth;
              return Column(
                children: [
                  const _LifeNavigationBar(
                    title: '生活服务',
                    miniProgram: false,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: _menuSourceWidth * _scale,
                          child: _buildMenu(),
                        ),
                        Expanded(child: _buildContent()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: ListView.builder(
        key: const Key('life-more-menu'),
        controller: _menuController,
        padding: EdgeInsets.zero,
        itemExtent: _menuItemSourceHeight * _scale,
        physics: const ClampingScrollPhysics(),
        itemCount: _sections.length,
        itemBuilder: (_, index) {
          final section = _sections[index];
          final selected = index == _selectedIndex;
          return Semantics(
            button: true,
            selected: selected,
            label: section.title,
            child: GestureDetector(
              key: Key('life-more-menu-${section.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _scrollToSection(index),
              child: Stack(
                children: [
                  Positioned(
                    left: 36 * _scale,
                    top: _menuLabelSourceTop * _scale,
                    child: Text(
                      section.title,
                      key: Key('life-more-menu-label-${section.id}'),
                      maxLines: 1,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF087BF1)
                            : const Color(0xFF606060),
                        fontSize: (selected ? 43 : 40) * _scale,
                        fontWeight:
                            selected ? FontWeight.w500 : FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      key: Key('life-more-menu-indicator-${section.id}'),
                      right: 0,
                      top: _selectedIndicatorSourceTop * _scale,
                      width: 7 * _scale,
                      height: _selectedIndicatorSourceHeight * _scale,
                      child: const ColoredBox(color: Color(0xFF087BF1)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return ListView.builder(
      key: const Key('life-more-content'),
      controller: _contentController,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemCount: _sections.length,
      itemBuilder: (_, index) {
        final section = _sections[index];
        return SizedBox(
          key: Key('life-more-section-${section.id}'),
          width: _contentSourceWidth * _scale,
          height: section.sourceHeight * _scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  section.asset,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
              for (final hotspot in section.hotspots)
                Positioned(
                  left: hotspot.column * (_contentSourceWidth / 3) * _scale,
                  top: (_gridTop + hotspot.row * _rowExtent) * _scale,
                  width: (_contentSourceWidth / 3) * _scale,
                  height: _rowExtent * _scale,
                  child: Semantics(
                    button: true,
                    label: hotspot.label,
                    child: GestureDetector(
                      key: Key(
                        'life-more-service-${section.id}-${hotspot.label}',
                      ),
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

class _LifeServiceSection {
  const _LifeServiceSection({
    required this.id,
    required this.title,
    required this.asset,
    required this.sourceHeight,
    this.hotspots = const [],
  });

  final String id;
  final String title;
  final String asset;
  final double sourceHeight;
  final List<_LifeServiceHotspot> hotspots;
}

class _LifeServiceHotspot {
  const _LifeServiceHotspot(this.label, this.row, this.column, this.route);

  final String label;
  final int row;
  final int column;
  final String route;
}
