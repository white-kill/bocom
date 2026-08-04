import 'dart:math' as math;

import 'package:bocom/config/app_config.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'asset_logic.dart';
import 'asset_state.dart';

class AssetPage extends BaseStateless {
  AssetPage({super.key}) : super(title: '');

  final AssetLogic logic = Get.put(AssetLogic());
  final AssetState state = Get.find<AssetLogic>().state;

  @override
  bool get isChangeNav => true;

  @override
  Widget? get titleWidget => Obx(() => BaseText(
        text: '我的资产',
        fontSize: 18.sp,
        color: logic.navActionColor.value,
      ));

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          Obx(() => logic.navActionFlag.value
              ? Image(
                  image: 'nav_back_white'.png,
                  width: 16.w,
                  height: 16.w,
                ).withOnTap(onTap: () {
                  Get.back();
                })
              : Image(
                  image: 'nav_back_light'.png,
                  width: 28.w,
                  height: 28.w,
                ).withOnTap(onTap: () {
                  Get.back();
                })),
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Obx(() => logic.navActionFlag.value
            ? Image(
                image: 'nav_kf_white'.png,
                width: 18.w,
                height: 18.w,
              )
            : Image(
                image: 'nav_kf_light'.png,
                width: 28.w,
                height: 28.w,
              )),
        SizedBox(
          width: 15.w,
        )
      ];

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionFlag.value = v;
        logic.navActionColor.value = v ? Colors.black : Colors.white;
      };

  @override
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 1416, deviceWidth: 1.sw);
    StackPosition position2 =
        StackPosition(designWidth: 1080, designHeight: 626, deviceWidth: 1.sw);
    return Column(
      children: [
        Expanded(
            child: ListView(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          children: [
            Stack(
              children: [
                Image(
                  image: 'bg_my_asset_1'.png3x,
                  width: 1.sw,
                  fit: BoxFit.fitWidth,
                ),
                Positioned(
                  right: position1.getX(70),
                  top: position1.getY(255),
                  child: Obx(
                    () => Image(
                      image: (!logic.amountVisible.value
                              ? 'my_asset_eye_open'
                              : 'my_asset_eye_close')
                          .png,
                      width: position1.getWidth(38),
                      fit: BoxFit.fitWidth,
                    ).withOnTap(onTap: logic.toggleAmountVisible),
                  ),
                ),
                Positioned(
                    left: position1.getX(45),
                    top: position1.getY(325),
                    child: Obx(
                      () => BaseText(
                        text: logic.amountVisible.value
                            ? AppConfig.config.abcLogic.memberInfo
                                .accountBalance.bankBalance
                            : '****',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    )),
                Positioned(
                  left: position1.getX(545),
                  top: position1.getY(325),
                  child: Obx(
                    () => BaseText(
                      text: logic.amountVisible.value ? '0.00' : '****',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: position1.getX(40),
                  top: position1.getY(420),
                  child: BaseText(
                    text:
                        '${AppConfig.config.abcLogic.memberInfo.realName}交行资产更新至${logic.nowDate.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFFADCBFF),
                    ),
                  ),
                ),
                Positioned(
                  left: position1.getX(77),
                  top: position1.getY(730),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, progress, child) {
                      return CustomPaint(
                        size: Size.square(position1.getWidth(286)),
                        painter: _AssetDistributionRingPainter(
                          progress: progress,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                    right: position1.getX(70),
                    top: position1.getY(743),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BaseText(
                            text: logic.amountVisible.value ? '100%' : '****',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4c4c4c),
                            ),
                          ),
                          BaseText(
                            text: logic.amountVisible.value
                                ? AppConfig.config.abcLogic.memberInfo
                                    .accountBalance.bankBalance
                                : '****',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ).withSizedBox(width: position1.getWidth(460)),
                    )),
                Positioned(
                    right: position1.getX(70),
                    top: position1.getY(853),
                    child: Obx(
                          () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BaseText(
                            text: logic.amountVisible.value ? '0%' : '****',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4c4c4c),
                            ),
                          ),
                          BaseText(
                            text: logic.amountVisible.value
                                ? '0.00'
                                : '****',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ).withSizedBox(width: position1.getWidth(460)),
                    )),

                Positioned(
                    right: position1.getX(70),
                    top: position1.getY(958),
                    child: Obx(
                          () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BaseText(
                            text: logic.amountVisible.value ? '0%' : '****',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4c4c4c),
                            ),
                          ),
                          BaseText(
                            text: logic.amountVisible.value
                                ? '0.00'
                                : '****',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ).withSizedBox(width: position1.getWidth(460)),
                    )),
                Positioned(
                  left: position1.getX(235),
                  top: position1.getY(1170),
                  child: Obx(
                        () => BaseText(
                      text: logic.amountVisible.value ? '--' : '****',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Image(
                  image: 'bg_my_asset_2'.png3x,
                  width: 1.sw,
                  fit: BoxFit.fitWidth,
                ),
                Positioned(
                    right: position2.getX(130),
                    top: position2.getY(393),
                    child: Obx(
                      () => BaseText(
                        text: logic.amountVisible.value
                            ? AppConfig.config.abcLogic.memberInfo
                                .accountBalance.bankBalance
                            : '****',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    )),
              ],
            ),
            Image(
              image: 'bg_my_asset_3'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ],
        )),
        Image(
          image: 'bg_my_asset_bottom'.png3x,
          width: 1.sw,
          fit: BoxFit.fitWidth,
        ),
      ],
    );
  }
}

class _AssetDistributionRingPainter extends CustomPainter {
  const _AssetDistributionRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.126;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final ringRect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFEEF3FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      ringRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = const Color(0xFF61A4EF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant _AssetDistributionRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
