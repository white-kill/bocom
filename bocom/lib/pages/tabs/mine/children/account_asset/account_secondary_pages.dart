import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../config/abc_config/boc_logic.dart';
import '../../../../../routes/app_pages.dart';

class AccountLiveData {
  const AccountLiveData({
    required this.bankName,
    required this.cardNumber,
    required this.realName,
    required this.phone,
    required this.branch,
    required this.paymentSystemNumber,
  });

  factory AccountLiveData.fromLogic(BocLogic? logic) {
    final member = logic?.memberInfo;
    final bank = member != null && member.bankList.isNotEmpty
        ? member.bankList.first
        : null;
    return AccountLiveData(
      bankName: _value(bank?.bankName),
      cardNumber: _value(bank?.bankCard),
      realName: _value(
        (bank?.realName.trim().isNotEmpty ?? false)
            ? bank?.realName
            : member?.realName,
      ),
      phone: _value(member?.phone),
      branch: _value(
        (bank?.openOutlets.trim().isNotEmpty ?? false)
            ? bank?.openOutlets
            : member?.branchBelongs,
      ),
      paymentSystemNumber: _value(
        member?.bankId.trim().isNotEmpty == true
            ? member?.bankId
            : member?.chapterCode,
      ),
    );
  }

  final String bankName;
  final String cardNumber;
  final String realName;
  final String phone;
  final String branch;
  final String paymentSystemNumber;

  String get lastFour {
    if (cardNumber == '--') return '--';
    return cardNumber.length <= 4
        ? cardNumber
        : cardNumber.substring(cardNumber.length - 4);
  }

  String get shortMaskedCard => lastFour == '--' ? '--' : '**$lastFour';

  String get maskedCard {
    if (cardNumber == '--') return '--';
    if (cardNumber.length <= 10) return shortMaskedCard;
    return '${cardNumber.substring(0, 6)} **** $lastFour';
  }

  String get compactMaskedCard {
    if (cardNumber == '--') return '--';
    if (cardNumber.length <= 10) return shortMaskedCard;
    return '${cardNumber.substring(0, 6)}****$lastFour';
  }

  static String _value(String? value) {
    final result = value?.trim() ?? '';
    return result.isEmpty ? '--' : result;
  }
}

class AccountLiveDataBuilder extends StatelessWidget {
  const AccountLiveDataBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, AccountLiveData data) builder;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BocLogic>()) {
      return builder(context, AccountLiveData.fromLogic(null));
    }
    return GetBuilder<BocLogic>(
      id: 'updateUI',
      builder: (logic) => builder(context, AccountLiveData.fromLogic(logic)),
    );
  }
}

// 资金转入页
// 说明：正文完整使用无导航切图，收款卡保持原稿的待选择状态。
class AccountFundsTransferPage extends StatelessWidget {
  const AccountFundsTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccountSlicePage(
      title: '资金转入',
      assetPath: 'assets/images/account_funds_transfer_body.png',
      sourceHeight: 2363,
    );
  }
}

// 银行卡挂失页
// 说明：正文使用无导航切图，仅覆盖参考图中已展示的当前登录账户卡号。
class AccountLossPage extends StatelessWidget {
  const AccountLossPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AccountSlicePage(
      title: '银行卡挂失',
      assetPath: 'assets/images/account_loss_body.png',
      sourceHeight: 2168,
      overlayBuilder: (_, scale) => AccountLiveDataBuilder(
        builder: (_, data) => Stack(
          children: [
            // Reference glyph bbox: x=736..1038, y=168..200.
            Positioned(
              top: 164.52 * scale,
              right: 33.93 * scale,
              child: Transform.scale(
                scaleX: 1,
                scaleY: 40 / 38,
                alignment: Alignment.topRight,
                child: Text(
                  data.compactMaskedCard,
                  key: const Key('account-loss-live-card'),
                  maxLines: 1,
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 42.66 * scale,
                    fontWeight: FontWeight.w400,
                    height: 1,
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

// 更多功能页
// 说明：当前页面使用不含导航栏的内容切图，返回导航与账户解绑热区由 Flutter 绘制。
class AccountMoreFunctionsPage extends StatelessWidget {
  const AccountMoreFunctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AccountSlicePage(
      title: '更多功能',
      assetPath: 'assets/images/account_more_functions_body.png',
      sourceHeight: 2168,
      hotspots: [
        _SliceHotspot(
          top: 790,
          height: 150,
          label: '账户解绑',
          onTap: () => Get.toNamed(Routes.accountUnbind),
        ),
      ],
    );
  }
}

// 申请账户页
// 说明：当前页面使用不含导航栏的内容切图，页面导航由 Flutter 单独绘制。
class AccountApplicationPage extends StatelessWidget {
  const AccountApplicationPage({super.key});

  @override
  Widget build(BuildContext context) => const _AccountSlicePage(
        title: '申请账户',
        assetPath: 'assets/images/account_application_body.png',
        sourceHeight: 2166,
      );
}

// 激活银行卡页
// 说明：当前页面使用不含导航栏的内容切图，页面导航由 Flutter 单独绘制。
class AccountActivationPage extends StatelessWidget {
  const AccountActivationPage({super.key});

  @override
  Widget build(BuildContext context) => const _AccountSlicePage(
        title: '激活银行卡',
        assetPath: 'assets/images/account_activation_body.png',
        sourceHeight: 2166,
      );
}

// 账户解绑页
// 说明：当前页面使用已移除示例卡号的内容切图，银行卡尾号由当前登录账户动态覆盖。
class AccountUnbindPage extends StatelessWidget {
  const AccountUnbindPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AccountSlicePage(
      title: '账户解绑',
      assetPath: 'assets/images/account_unbind_body.png',
      sourceHeight: 2166,
      overlayBuilder: (_, scale) => AccountLiveDataBuilder(
        builder: (_, data) => Positioned(
          // Reference glyph bbox: x=357..490, y=179..214.
          left: 355.94 * scale,
          top: 175.35 * scale,
          child: Transform.scale(
            scaleX: 1,
            scaleY: 43.5 / 41,
            alignment: Alignment.topLeft,
            child: Text(
              data.shortMaskedCard,
              key: const Key('account-unbind-live-card'),
              style: TextStyle(
                color: const Color(0xFF222222),
                fontSize: 45.94 * scale,
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

// 账户排序页
// 说明：当前页面使用已移除示例卡号的内容切图，银行卡尾号由当前登录账户动态覆盖。
class AccountSortPage extends StatelessWidget {
  const AccountSortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AccountSlicePage(
      title: '账户排序',
      assetPath: 'assets/images/account_sort_body.png',
      sourceHeight: 2166,
      overlayBuilder: (_, scale) => AccountLiveDataBuilder(
        builder: (_, data) => Positioned(
          // Reference glyph bbox: x=453..614, y=174..218.
          left: 450.17 * scale,
          top: 175.7 * scale,
          child: Transform.scale(
            // Font rasterization is stepped. Use the measured 42/44.02 size
            // step and restore only its reference-matched horizontal width.
            scaleX: 44.02 / 42,
            scaleY: 1,
            alignment: Alignment.topLeft,
            child: Text(
              '(${data.shortMaskedCard})',
              key: const Key('account-sort-live-card'),
              style: TextStyle(
                color: const Color(0xFF222222),
                fontSize: 42 * scale,
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

// 安心付 Pro 页
// 说明：当前页面保留 Slice 中的沉浸式导航与静态协议区，仅返回区域由 Flutter 提供交互。
class AccountFamilyPayPage extends StatelessWidget {
  const AccountFamilyPayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(
          builder: (_, constraints) {
            final scale = constraints.maxWidth / 1080;
            return SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                height: 2376 * scale,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/account_family_pay_page.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 150 * scale,
                      height: 210 * scale,
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
  }
}

Future<void> showAccountOutletDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭网点信息',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, _, __) => SafeArea(
      child: Center(
        child: AccountLiveDataBuilder(
          builder: (_, data) => LayoutBuilder(
            builder: (_, constraints) {
              final width = constraints.maxWidth - 30;
              final scale = width / 1000;
              return SizedBox(
                key: const Key('account-outlet-dialog'),
                width: width,
                height: 694 * scale,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/account_outlet_dialog.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      left: 250 * scale,
                      top: 238 * scale,
                      right: 50 * scale,
                      child: Text(
                        data.branch,
                        key: const Key('account-outlet-live-branch'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 38 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 330 * scale,
                      // The numeric fallback font's baseline sits 9.6 source
                      // px higher; compensate to preserve the measured 93 px
                      // reference baseline gap between the two rows.
                      top: 340.6 * scale,
                      right: 50 * scale,
                      child: Text(
                        data.paymentSystemNumber,
                        key: const Key('account-outlet-live-system-number'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 38 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 42 * scale,
                      bottom: 40 * scale,
                      width: 437 * scale,
                      height: 122 * scale,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _AccountSlicePage extends StatelessWidget {
  const _AccountSlicePage({
    required this.title,
    required this.assetPath,
    required this.sourceHeight,
    this.overlayBuilder,
    this.hotspots = const [],
  });

  final String title;
  final String assetPath;
  final double sourceHeight;
  final Widget Function(BuildContext context, double scale)? overlayBuilder;
  final List<_SliceHotspot> hotspots;

  @override
  Widget build(BuildContext context) {
    return _AccountScaffold(
      title: title,
      backgroundColor: const Color(0xFFF7F7F7),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final scale = constraints.maxWidth / 1080;
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: constraints.maxWidth,
              height: sourceHeight * scale,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(assetPath, fit: BoxFit.fill),
                  ),
                  if (overlayBuilder != null) overlayBuilder!(context, scale),
                  for (final hotspot in hotspots)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: hotspot.top * scale,
                      height: hotspot.height * scale,
                      child: Semantics(
                        button: true,
                        label: hotspot.label,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: hotspot.onTap,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliceHotspot {
  const _SliceHotspot({
    required this.top,
    required this.height,
    required this.label,
    required this.onTap,
  });

  final double top;
  final double height;
  final String label;
  final VoidCallback onTap;
}

class _AccountScaffold extends StatelessWidget {
  const _AccountScaffold({
    required this.title,
    required this.child,
    required this.backgroundColor,
  });

  final String title;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7F7F7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ColoredBox(
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Semantics(
                          button: true,
                          label: '返回',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: Get.back,
                            child: const SizedBox(
                              width: 54,
                              child: Center(
                                child: Icon(
                                  Icons.chevron_left,
                                  size: 32,
                                  color: Color(0xFF191919),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
