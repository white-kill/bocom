import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const _referenceWidth = 402.0;

// 扫一扫页
// 说明：页面使用实时相机作为沉浸式背景，导航、动画扫描线与底部操作由 Flutter 单独绘制。
class ScanPage extends StatefulWidget {
  const ScanPage({
    super.key,
    this.enableCamera = true,
  });

  /// 仅供无相机的测试环境使用。
  final bool enableCamera;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _scanController;
  CameraController? _cameraController;
  bool _initializingCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    if (widget.enableCamera) _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_initializingCamera || _cameraController != null) return;
    _initializingCamera = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) return;
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _cameraController = controller);
    } catch (_) {
      // 模拟器或权限不可用时保留深色扫码背景。
    } finally {
      _initializingCamera = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableCamera) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final controller = _cameraController;
      _cameraController = null;
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        key: const Key('scan-page-scaffold'),
        backgroundColor: const Color(0xFF17191B),
        extendBody: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _referenceWidth;
            final pageHeight = constraints.maxHeight;
            final statusTop = MediaQuery.paddingOf(context).top;
            final bottomPanelHeight = 111 * scale;
            final bottomPanelTop = pageHeight - bottomPanelHeight;
            final actionSize = 54 * scale;
            final actionTop = bottomPanelTop - 86 * scale;
            final lineHeight = constraints.maxWidth * 77 / 945;
            final scanStart = statusTop + 58 * scale;
            final scanEnd = actionTop - lineHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                _CameraBackdrop(controller: _cameraController),
                const IgnorePointer(child: _ReadabilityOverlay()),
                AnimatedBuilder(
                  animation: _scanController,
                  child: Image.asset(
                    'assets/images/scan/scan_line.png',
                    key: const Key('scan-line-image'),
                    width: constraints.maxWidth,
                    fit: BoxFit.fill,
                  ),
                  builder: (_, child) {
                    final top = lerpDouble(
                      scanStart,
                      scanEnd,
                      _scanController.value,
                    )!;
                    return Positioned(
                      key: const Key('animated-scan-line'),
                      left: 0,
                      right: 0,
                      top: top,
                      height: lineHeight,
                      child: IgnorePointer(child: child),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: actionTop - 58 * scale,
                  height: 25 * scale,
                  child: IgnorePointer(
                    child: Center(
                      child: Text(
                        '请扫描二维码/条形码',
                        key: const Key('scan-instruction'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 29 * scale,
                  top: actionTop,
                  width: actionSize,
                  height: actionSize,
                  child: const _RoundScanAction(
                    semanticsLabel: '照亮',
                    iconAsset: 'assets/images/scan/flashlight.png',
                    iconWidth: 10,
                    iconHeight: 17,
                    label: '照亮',
                  ),
                ),
                Positioned(
                  right: 29 * scale,
                  top: actionTop,
                  width: actionSize,
                  height: actionSize,
                  child: const _RoundScanAction(
                    semanticsLabel: '相册',
                    iconAsset: 'assets/images/scan/gallery.png',
                    iconWidth: 14,
                    iconHeight: 14,
                    label: '相册',
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: bottomPanelTop,
                  bottom: 0,
                  child: const _BottomCodePanel(),
                ),
                Positioned(
                  left: 0,
                  top: statusTop + 9 * scale,
                  width: 56 * scale,
                  height: 48 * scale,
                  child: Semantics(
                    button: true,
                    label: '返回',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: Get.back,
                      child: Center(
                        child: Image.asset(
                          'assets/images/scan/back.png',
                          width: 8 * scale,
                          height: 15 * scale,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 80 * scale,
                  right: 80 * scale,
                  top: statusTop + 14 * scale,
                  height: 38 * scale,
                  child: IgnorePointer(
                    child: Center(
                      child: Text(
                        '扫一扫',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CameraBackdrop extends StatelessWidget {
  const _CameraBackdrop({required this.controller});

  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    if (controller?.value.isInitialized != true) {
      return const ColoredBox(color: Color(0xFF24272A));
    }
    final previewSize = controller!.value.previewSize;
    if (previewSize == null) {
      return const ColoredBox(color: Color(0xFF24272A));
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}

class _ReadabilityOverlay extends StatelessWidget {
  const _ReadabilityOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.04),
            Colors.black.withValues(alpha: 0.16),
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
    );
  }
}

class _RoundScanAction extends StatelessWidget {
  const _RoundScanAction({
    required this.semanticsLabel,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
  });

  final String semanticsLabel;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _referenceWidth;
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: Colors.black.withValues(alpha: 0.54),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconAsset,
                width: iconWidth * scale,
                height: iconHeight * scale,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 4 * scale),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13 * scale,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomCodePanel extends StatelessWidget {
  const _BottomCodePanel();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.48),
          child: const Row(
            children: [
              Expanded(
                child: _CodeAction(
                  semanticsLabel: '付款码',
                  iconAsset: 'assets/images/scan/payment_code.png',
                  iconWidth: 27,
                  iconHeight: 27,
                  label: '付款码',
                ),
              ),
              Expanded(
                child: _CodeAction(
                  semanticsLabel: '收款码',
                  iconAsset: 'assets/images/scan/collection_code.png',
                  iconWidth: 28,
                  iconHeight: 29,
                  label: '收款码',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeAction extends StatelessWidget {
  const _CodeAction({
    required this.semanticsLabel,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
  });

  final String semanticsLabel;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _referenceWidth;
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.only(top: 17 * scale, bottom: 8 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                iconAsset,
                width: iconWidth * scale,
                height: iconHeight * scale,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 13 * scale),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * scale,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
