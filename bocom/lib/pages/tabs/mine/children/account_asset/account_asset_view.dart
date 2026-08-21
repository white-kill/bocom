import 'dart:math' as math;

import 'package:bocom/config/app_config.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/pages/component/password_keyboard_sheet.dart';

import 'account_asset_logic.dart';
import 'account_asset_state.dart';
import 'bank_detail_dialog.dart';

// 我的账户/我的资产页
// 说明：当前页面使用不含导航栏的账户与资产内容切图，动态余额、导航和功能热区由 Flutter 单独绘制。
class AccountAssetPage extends BaseStateless {
  AccountAssetPage({
    super.key,
    this.initialTabIndex = 1,
  })  : assert(initialTabIndex == 0 || initialTabIndex == 1),
        logic = Get.put(AccountAssetLogic()),
        super(title: '') {
    logic.onBottomItemClick(initialTabIndex);
  }

  /// 0：我的账户；1：我的资产。
  final int initialTabIndex;
  final AccountAssetLogic logic;
  AccountAssetState get state => logic.state;

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 56.w;

  @override
  Widget? get titleWidget => Obx(() => BaseText(
        text: logic.bottomItemIndex.value == 0 ? '我的账户' : '我的资产',
        fontSize: 18,
        color: logic.bottomItemIndex.value == 0
            ? Colors.black
            : logic.navActionColor.value,
      ));

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          Obx(
            () => SizedBox(
              width: 35.w,
              height: 35.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_back_white'.png,
                        height: 19.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: logic.bottomItemIndex.value == 0
                            ? 'nav_back_light_white'.png
                            : 'nav_back_light'.png,
                        width: 35.w,
                        height: 35.w,
                        fit: BoxFit.contain,
                      ),
              ),
            ).withOnTap(onTap: () => Get.back()),
          ),
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Obx(
          () => Semantics(
            button: true,
            label: '客服',
            child: SizedBox(
              width: 36.w,
              height: 36.w,
              child: Center(
                child: logic.navActionFlag.value
                    ? Image(
                        image: 'nav_kf_white'.png,
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.contain,
                      )
                    : Image(
                        image: logic.bottomItemIndex.value == 0
                            ? 'nav_kf_light_white'.png
                            : 'nav_kf_light'.png,
                        width: 36.w,
                        height: 36.w,
                        fit: BoxFit.contain,
                      ),
              ),
            ).withOnTap(
              onTap: () => Get.toNamed(Routes.customerService),
            ),
          ),
        ),
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
    StackPosition positionBottom =
        StackPosition(designWidth: 1080, designHeight: 146, deviceWidth: 1.sw);
    return Column(
      children: [
        Expanded(
          child: Obx(
            () => logic.bottomItemIndex.value == 0
                ? _AccountContent(logic: logic)
                : _AssetContent(logic: logic),
          ),
        ),
        Stack(
          children: [
            Obx(
              () => Image(
                image: logic.bottomItemIndex.value == 0
                    ? 'bg_my_account_bottom'.png3x
                    : 'bg_my_asset_bottom'.png3x,
                width: 1.sw,
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              width: 1.sw,
              height: positionBottom.getHeight(146),
              child: Row(
                children: [
                  Container().withOnTap(onTap: () {
                    logic.onBottomItemClick(0);
                  }).expanded(),
                  Container().withOnTap(onTap: () {
                    logic.onBottomItemClick(1);
                  }).expanded(),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}

class _AccountContent extends StatelessWidget {
  const _AccountContent({required this.logic});

  final AccountAssetLogic logic;

  @override
  Widget build(BuildContext context) {
    final topPlaceholderHeight = MediaQuery.of(context).padding.top + 44.w;
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 1098, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          height: topPlaceholderHeight,
          color: const Color(0xFFF7F7F7),
        ),
        Stack(
          children: [
            Image(
              image: 'bg_my_account_1'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
                right: position1.getX(480),
                top: position1.getY(165),
                child: BaseText(
                  text: '**${AppConfig.config.abcLogic.cardFour()}',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.black,
                )),
            Positioned(
              right: position1.getX(40),
              top: position1.getY(30),
              child: Obx(
                () => Row(
                  children: [
                    BaseText(
                      text: logic.amountVisible.value ? '隐藏余额' : '显示余额',
                      fontSize: 13,
                      color: const Color(0xFF333333),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Image(
                      image: (!logic.amountVisible.value
                              ? 'my_asset_eye_open'
                              : 'my_asset_eye_close')
                          .png,
                      width: position1.getWidth(38),
                      fit: BoxFit.fitWidth,
                      color: const Color(0xFF333333),
                    ),
                  ],
                ).withOnTap(onTap: logic.toggleAmountVisible),
              ),
            ),
            Positioned(
                right: position1.getX(140),
                top: position1.getY(445),
                child: Obx(
                  () => BaseText(
                    text: logic.amountVisible.value
                        ? AppConfig.config.abcLogic.memberInfo.accountBalance
                            .bankBalance
                        : '****',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                )),
            Positioned(
              right: position1.getX(310),
              top: position1.getY(165),
              child: SizedBox(
                height: position1.getHeight(100),
                width: position1.getWidth(320),
              ).withOnTap(
                onTap: () => PasswordKeyboardSheet.show(
                  context,
                  onCompleted: () async {
                    await BankDetailDialog.show(context);
                  },
                ),
              ),
            ),
            Positioned(
              left: position1.getX(40),
              top: position1.getY(560),
              width: position1.getWidth(250),
              height: position1.getHeight(125),
              child: Semantics(
                button: true,
                label: '交易明细',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.toNamed(Routes.transactionDetail),
                ),
              ),
            ),
          ],
        ),
        Image(
          image: 'bg_my_account_2'.png3x,
          width: 1.sw,
          fit: BoxFit.fitWidth,
        ),
      ],
    );
  }
}

class _AssetContent extends StatelessWidget {
  const _AssetContent({required this.logic});

  final AccountAssetLogic logic;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    StackPosition position1 =
        StackPosition(designWidth: 1080, designHeight: 1349, deviceWidth: 1.sw);
    // 新素材由原图顶部裁掉了 67 个设计像素，动态覆盖层同步上移。
    final assetImageTopCrop = position1.getY(67);
    StackPosition position2 =
        StackPosition(designWidth: 1080, designHeight: 626, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          key: const Key('asset-status-bar-gradient-spacer'),
          width: 1.sw,
          height: statusBarHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF327EF4),
                Color(0xFF337DF1),
                Color(0xFF307BF1),
                Color(0xFF317AF3),
                Color(0xFF2F78F1),
                Color(0xFF2F78F1),
                Color(0xFF337AF3),
                Color(0xFF347EF2),
                Color(0xFF3B83F2),
                Color(0xFF4B86F6),
                Color(0xFF5B8AF9),
                Color(0xFF638DF8),
                Color(0xFF648EF9),
              ],
              stops: [
                0,
                0.0833,
                0.1667,
                0.25,
                0.3333,
                0.4167,
                0.5,
                0.5833,
                0.6667,
                0.75,
                0.8333,
                0.9167,
                1,
              ],
            ),
          ),
        ),
        Stack(
          children: [
            Image(
              image: 'bg_my_asset_1'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              right: position1.getX(70),
              top: position1.getY(255) - assetImageTopCrop,
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
                top: position1.getY(325) - assetImageTopCrop,
                child: Obx(
                  () => BaseText(
                    text: logic.amountVisible.value
                        ? AppConfig.config.abcLogic.memberInfo.accountBalance
                            .bankBalance
                        : '****',
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                    color: Colors.white,
                  ),
                )),
            Positioned(
              left: position1.getX(545),
              top: position1.getY(325) - assetImageTopCrop,
              child: Obx(
                () => BaseText(
                  text: logic.amountVisible.value ? '0.00' : '****',
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: position1.getX(40),
              top: position1.getY(420) - assetImageTopCrop,
              child: BaseText(
                text:
                    '${AppConfig.config.abcLogic.memberInfo.realName}交行资产更新至${logic.nowDate.value}',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: const Color(0xFFADCBFF),
              ),
            ),
            Positioned(
              left: position1.getX(77),
              top: position1.getY(730) - assetImageTopCrop,
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
                top: position1.getY(743) - assetImageTopCrop,
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BaseText(
                        text: logic.amountVisible.value ? '100%' : '****',
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                      BaseText(
                        text: logic.amountVisible.value
                            ? AppConfig.config.abcLogic.memberInfo
                                .accountBalance.bankBalance
                            : '****',
                        fontSize: 15,
                        color: const Color(0xFF111111),
                        fontWeight: FontWeight.w600,
                      )
                    ],
                  ).withSizedBox(width: position1.getWidth(460)),
                )),
            Positioned(
                right: position1.getX(70),
                top: position1.getY(853) - assetImageTopCrop,
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BaseText(
                        text: logic.amountVisible.value ? '0%' : '****',
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                      BaseText(
                        text: logic.amountVisible.value ? '0.00' : '****',
                        fontSize: 15,
                        color: const Color(0xFF111111),
                        fontWeight: FontWeight.w600,
                      )
                    ],
                  ).withSizedBox(width: position1.getWidth(460)),
                )),
            Positioned(
                right: position1.getX(70),
                top: position1.getY(958) - assetImageTopCrop,
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BaseText(
                        text: logic.amountVisible.value ? '0%' : '****',
                        fontSize: 14,
                        color: const Color(0xFF666666),
                      ),
                      BaseText(
                        text: logic.amountVisible.value ? '0.00' : '****',
                        fontSize: 15,
                        color: const Color(0xFF111111),
                        fontWeight: FontWeight.w600,
                      )
                    ],
                  ).withSizedBox(width: position1.getWidth(460)),
                )),
            Positioned(
              left: position1.getX(235),
              top: position1.getY(1170) - assetImageTopCrop,
              child: Obx(
                () => BaseText(
                  text: logic.amountVisible.value ? '--' : '****',
                  fontSize: 14,
                  color: const Color(0xFF333333),
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
                        ? AppConfig.config.abcLogic.memberInfo.accountBalance
                            .bankBalance
                        : '****',
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: const Color(0xFF111111),
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
