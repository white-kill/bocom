import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

// 付款码开通页
// 说明：当前页面使用仅裁掉系统状态栏、保留页面导航的完整参考图。
class HomePaymentCodePage extends StatelessWidget {
  const HomePaymentCodePage({super.key});

  static const double _sourceWidth = 1080;
  static const double _sourceHeight = 2280;

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFEAF5FF),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: _PaymentCodeBody(),
        ),
      ),
    );
  }
}

class _PaymentCodeBody extends StatelessWidget {
  const _PaymentCodeBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final scale = constraints.maxWidth / HomePaymentCodePage._sourceWidth;
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: constraints.maxWidth,
            height: HomePaymentCodePage._sourceHeight * scale,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _SlicedReferenceImage(
                    assets: const [
                      'assets/images/home_payment_code_page_01.png',
                      'assets/images/home_payment_code_page_02.png',
                      'assets/images/home_payment_code_page_03.png',
                    ],
                    sourceHeights: const [760, 760, 760],
                    scale: scale,
                  ),
                ),
                Positioned(
                  left: 18 * scale,
                  top: 0,
                  width: 116 * scale,
                  height: 96 * scale,
                  child: Semantics(
                    button: true,
                    label: '返回',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: Get.back,
                    ),
                  ),
                ),
                Positioned(
                  right: 24 * scale,
                  top: 0,
                  width: 190 * scale,
                  height: 96 * scale,
                  child: Semantics(
                    button: true,
                    label: '常见问题',
                    child: const SizedBox.expand(),
                  ),
                ),
                Positioned(
                  left: 40 * scale,
                  right: 40 * scale,
                  bottom: 54 * scale,
                  height: 124 * scale,
                  child: Semantics(
                    button: true,
                    label: '阅读协议并开通',
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 我的安全页
// 说明：当前页面使用用户提供的完整 Slice，返回与客服按钮使用原始独立图片覆盖。
class HomeSecurityPage extends StatelessWidget {
  const HomeSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeReferencePage(
      imageAssets: [
        'assets/images/home_security_page_01.png',
        'assets/images/home_security_page_02.png',
        'assets/images/home_security_page_03.png',
        'assets/images/home_security_page_04.png',
        'assets/images/home_security_page_05.png',
      ],
      imageSourceHeights: [820, 820, 820, 820, 816],
      backAsset: 'assets/images/home_security_back.png',
      serviceAsset: 'assets/images/home_security_service.png',
      sourceWidth: 1025,
      backLeft: 38,
      backTop: 109,
      backWidth: 69,
      backHeight: 70,
      serviceLeft: 918,
      serviceTop: 109,
      serviceWidth: 69,
      serviceHeight: 70,
      pinnedSourceHeight: 205,
      pageBackground: Color(0xFFF7F7F7),
    );
  }
}

// 爱宠信用卡页
// 说明：当前页面使用用户提供的完整 Slice，返回与客服按钮使用原始独立图片覆盖。
class HomeCreditCardPage extends StatelessWidget {
  const HomeCreditCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeReferencePage(
      imageAssets: [
        'assets/images/home_credit_card_page_01.png',
        'assets/images/home_credit_card_page_02.png',
        'assets/images/home_credit_card_page_03.png',
        'assets/images/home_credit_card_page_04.png',
      ],
      imageSourceHeights: [752, 752, 752, 750],
      backAsset: 'assets/images/home_credit_card_back.png',
      serviceAsset: 'assets/images/home_credit_card_service.png',
      sourceWidth: 1080,
      backLeft: 39,
      backTop: 115,
      backWidth: 74,
      backHeight: 73,
      serviceLeft: 967,
      serviceTop: 115,
      serviceWidth: 74,
      serviceHeight: 73,
      pinnedSourceHeight: 215,
      pageBackground: Color(0xFFF7F7F7),
    );
  }
}

class _HomeReferencePage extends StatefulWidget {
  const _HomeReferencePage({
    required this.imageAssets,
    required this.imageSourceHeights,
    required this.backAsset,
    required this.serviceAsset,
    required this.sourceWidth,
    required this.backLeft,
    required this.backTop,
    required this.backWidth,
    required this.backHeight,
    required this.serviceLeft,
    required this.serviceTop,
    required this.serviceWidth,
    required this.serviceHeight,
    required this.pinnedSourceHeight,
    required this.pageBackground,
  });

  final List<String> imageAssets;
  final List<double> imageSourceHeights;
  final String backAsset;
  final String serviceAsset;
  final double sourceWidth;
  final double backLeft;
  final double backTop;
  final double backWidth;
  final double backHeight;
  final double serviceLeft;
  final double serviceTop;
  final double serviceWidth;
  final double serviceHeight;
  final double pinnedSourceHeight;
  final Color pageBackground;

  @override
  State<_HomeReferencePage> createState() => _HomeReferencePageState();
}

class _HomeReferencePageState extends State<_HomeReferencePage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Each page opens from its own top rather than inheriting the home feed's
    // PageStorage offset.
    _scrollController = ScrollController(keepScrollOffset: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: widget.pageBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: widget.pageBackground,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (_, constraints) {
            final scale = constraints.maxWidth / widget.sourceWidth;
            final pinnedHeight = widget.pinnedSourceHeight * scale;
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      key: PageStorageKey(widget.imageAssets.first),
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      child: _SlicedReferenceImage(
                        assets: widget.imageAssets,
                        sourceHeights: widget.imageSourceHeights,
                        scale: scale,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: pinnedHeight,
                    child: IgnorePointer(
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minWidth: constraints.maxWidth,
                          maxWidth: constraints.maxWidth,
                          minHeight: widget.imageSourceHeights.first * scale,
                          maxHeight: widget.imageSourceHeights.first * scale,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: widget.imageSourceHeights.first * scale,
                            child: Image.asset(
                              widget.imageAssets.first,
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _navigationImage(
                    semanticLabel: '返回',
                    assetPath: widget.backAsset,
                    left: widget.backLeft * scale,
                    top: widget.backTop * scale,
                    width: widget.backWidth * scale,
                    height: widget.backHeight * scale,
                    onTap: Get.back,
                  ),
                  _navigationImage(
                    semanticLabel: '客服',
                    assetPath: widget.serviceAsset,
                    left: widget.serviceLeft * scale,
                    top: widget.serviceTop * scale,
                    width: widget.serviceWidth * scale,
                    height: widget.serviceHeight * scale,
                    onTap: () => Get.toNamed(Routes.customerService),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _navigationImage({
    required String semanticLabel,
    required String assetPath,
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Image.asset(assetPath, fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class _SlicedReferenceImage extends StatelessWidget {
  const _SlicedReferenceImage({
    required this.assets,
    required this.sourceHeights,
    required this.scale,
  }) : assert(assets.length == sourceHeights.length);

  final List<String> assets;
  final List<double> sourceHeights;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        assets.length,
        (index) => SizedBox(
          width: double.infinity,
          height: sourceHeights[index] * scale,
          child: Image.asset(
            assets[index],
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
