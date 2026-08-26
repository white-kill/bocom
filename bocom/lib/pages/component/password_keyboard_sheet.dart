import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import '../../config/app_config.dart';
import '../../utils/stack_position.dart';
import 'indicator_loading.dart';

class TransactionPasswordContext {
  const TransactionPasswordContext({
    required this.payeeName,
    required this.amountDisplay,
    required this.bankName,
    required this.accountNumber,
  });

  final String payeeName;
  final String amountDisplay;
  final String bankName;
  final String accountNumber;

  String get primaryText => '转给 $payeeName $amountDisplay';

  String get secondaryText {
    final digits = accountNumber.replaceAll(RegExp(r'\s+'), '');
    final groups = <String>[];
    for (var start = 0; start < digits.length; start += 4) {
      final end = (start + 4).clamp(0, digits.length);
      groups.add(digits.substring(start, end));
    }
    return '$bankName ${groups.join(' ')}'.trim();
  }
}

typedef PasswordVerificationLauncher = Future<bool?> Function(
  BuildContext context,
  TransactionPasswordContext transaction,
);
typedef PasswordVerifier = Future<bool> Function(String password);

// 交易密码弹层
// 说明：交通银行安全键盘使用项目既有位图，转账对象、金额、银行、账号与六位输入状态由 Flutter 动态绘制。
class PasswordKeyboardSheet extends StatefulWidget {
  const PasswordKeyboardSheet({
    super.key,
    this.transaction,
    this.passwordVerifier,
    this.onPasswordCompleted,
  });

  final TransactionPasswordContext? transaction;
  final PasswordVerifier? passwordVerifier;
  final VoidCallback? onPasswordCompleted;

  static Future<bool?> showForVerification(
    BuildContext context, {
    TransactionPasswordContext? transaction,
    PasswordVerifier? passwordVerifier,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.63),
      builder: (_) => PasswordKeyboardSheet(
        transaction: transaction,
        passwordVerifier: passwordVerifier,
      ),
    );
  }

  /// 兼容原资产页调用；验证完成后显示加载动画并执行回调。
  static Future<bool?> show(
    BuildContext context, {
    Future<void> Function()? onCompleted,
    TransactionPasswordContext? transaction,
    PasswordVerifier? passwordVerifier,
  }) async {
    // 在打开 BottomSheet 之前保存根 Navigator 的 Overlay Context。
    // 后续 Loading 使用它定位，Alignment.center 即为整个屏幕中心，
    // 不会受 PasswordKeyboardSheet 自身高度影响。
    final rootOverlayContext =
        Navigator.of(context, rootNavigator: true).overlay?.context ?? context;
    final passwordCompleted = Completer<void>();
    BuildContext? sheetContext;
    final sheetResult = showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.63),
      builder: (modalContext) {
        sheetContext = modalContext;
        return PasswordKeyboardSheet(
          transaction: transaction,
          passwordVerifier: passwordVerifier,
          onPasswordCompleted: () {
            if (!passwordCompleted.isCompleted) passwordCompleted.complete();
          },
        );
      },
    );

    await Future.any<void>([
      passwordCompleted.future,
      sheetResult.then<void>((_) {}),
    ]);
    if (!passwordCompleted.isCompleted) return await sheetResult;

    if (rootOverlayContext.mounted) {
      await BocomLoading.show(
        rootOverlayContext,
      );
    }
    final modalContext = sheetContext;
    if (modalContext != null && modalContext.mounted) {
      Navigator.of(modalContext).pop(true);
    }
    final verified = await sheetResult;
    if (verified == true && context.mounted && onCompleted != null) {
      await onCompleted();
    }
    return verified;
  }

  @override
  State<PasswordKeyboardSheet> createState() => _PasswordKeyboardSheetState();
}

class _PasswordKeyboardSheetState extends State<PasswordKeyboardSheet>
    with SingleTickerProviderStateMixin {
  static const _passwordLength = 6;
  static const _designWidth = 645.0;
  static const _transactionDesignHeight = 945.0;
  static const _accountDesignHeight = 785.0;
  static const _keyboardSourceTop = 295.0;
  static const _keyboardHeight = 460.0;
  static const _transactionKeyboardTop = 485.0;
  static const _accountKeyboardTop = 325.0;
  static const _titleFontSize = 29.0;
  static const _primaryFontSize = 33.0;
  static const _secondaryFontSize = 30.0;

  int _inputCount = 0;
  bool _completed = false;
  late final AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  Future<void> _inputDigit(String _) async {
    if (_completed || _inputCount >= _passwordLength) return;
    setState(() {
      _inputCount++;
    });
    if (_inputCount == _passwordLength) {
      _completed = true;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      if (widget.onPasswordCompleted != null) {
        widget.onPasswordCompleted!();
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _deleteDigit() {
    if (_completed || _inputCount == 0) return;
    setState(() {
      _inputCount--;
    });
  }

  void _close() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bottomSafeHeight = MediaQuery.paddingOf(context).bottom;
    // 转账场景需要保留收款人和账户信息的纵向空间；“我的账户”
    // 只显示一行提示，键盘整体上移，避免弹层遮挡过多页面内容。
    final isTransaction = widget.transaction != null;
    final designHeight =
        isTransaction ? _transactionDesignHeight : _accountDesignHeight;
    final keyboardTop =
        isTransaction ? _transactionKeyboardTop : _accountKeyboardTop;
    final position = StackPosition(
      designWidth: _designWidth,
      designHeight: designHeight,
      deviceWidth: width,
    );
    final transaction = widget.transaction;

    return SizedBox(
      key: const Key('password-keyboard-sheet'),
      width: width,
      height: position.getHeight(designHeight) + bottomSafeHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(position.getWidth(18)),
                ),
              ),
            ),
          ),
          Positioned(
            key: const Key('password-keyboard'),
            left: 0,
            right: 0,
            top: position.getY(keyboardTop),
            height: position.getHeight(_keyboardHeight) + bottomSafeHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minWidth: width,
                maxWidth: width,
                minHeight: position.getHeight(818),
                maxHeight: position.getHeight(818),
                child: Transform.translate(
                  offset: Offset(0, -position.getY(_keyboardSourceTop)),
                  child: Image(
                    image: 'bg_keyboard_sheet'.png3x,
                    width: width,
                    height: position.getHeight(818),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: position.getX(80),
            right: position.getX(80),
            top: position.getY(40),
            child: Text(
              '交易密码',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF242424),
                fontSize: position.getWidth(_titleFontSize),
                fontWeight: FontWeight.w600,
                height: 1.05,
              ),
            ),
          ),
          Positioned(
            left: position.getX(14),
            top: position.getY(20),
            width: position.getWidth(62),
            height: position.getHeight(62),
            child: IconButton(
              key: const Key('password-keyboard-close'),
              tooltip: '关闭',
              padding: EdgeInsets.zero,
              onPressed: _close,
              icon: Icon(
                Icons.close,
                size: position.getWidth(34),
                color: const Color(0xFF151515),
              ),
            ),
          ),
          if (transaction != null) ...[
            Positioned(
              left: position.getX(70),
              right: position.getX(70),
              top: position.getY(129),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '转给 ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text:
                          '${transaction.payeeName} ${transaction.amountDisplay}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF242424),
                  fontSize: position.getWidth(_primaryFontSize),
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: position.getX(45),
              right: position.getX(45),
              top: position.getY(175),
              child: Text(
                transaction.secondaryText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF969EAC),
                  fontSize: position.getWidth(_secondaryFontSize),
                  height: 1,
                ),
              ),
            ),
          ] else
            Positioned(
              right: position.getX(20),
              top: position.getY(35),
              child: Text(
                '切换认证',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0XFF005DDA),
                  fontSize: position.getWidth(_titleFontSize),
                  height: 1.05,
                ),
              ),
            ),
            Positioned(
                left: position.getX(40),
                right: position.getX(40),
                top: position.getY(129),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '请输入银行账号',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF242424),
                        fontSize: position.getWidth(22),
                        height: 1,
                      ),
                    ),
                    Text(
                      '(**${AppConfig.config.abcLogic.cardFour()})',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: position.getWidth(22),
                        height: 1,
                      ),
                    ),
                    Text(
                      '的交易密码',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF242424),
                        fontSize: position.getWidth(22),
                        height: 1,
                      ),
                    ),
                  ],
                )),
          Positioned(
            left: position.getX(98),
            top: transaction != null ? position.getY(224) : position.getY(184),
            width: position.getWidth(449),
            height: position.getHeight(64),
            child: Row(
              children: List.generate(
                _passwordLength,
                (index) => Expanded(
                  child: Container(
                    key: Key('password-code-box-$index'),
                    margin: EdgeInsets.symmetric(
                      horizontal: position.getWidth(5),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F4),
                      borderRadius: BorderRadius.circular(
                        position.getWidth(5),
                      ),
                    ),
                    child: index < _inputCount
                        ? Container(
                            key: Key('password-dot-$index'),
                            width: position.getWidth(19),
                            height: position.getWidth(19),
                            decoration: const BoxDecoration(
                              color: Color(0xFF292929),
                              shape: BoxShape.circle,
                            ),
                          )
                        : index == _inputCount
                            ? FadeTransition(
                                opacity: _cursorController,
                                child: Container(
                                  width: position.getWidth(2),
                                  height: position.getHeight(32),
                                  color: const Color(0xFF61A5FF),
                                ),
                              )
                            : null,
                  ),
                ),
              ),
            ),
          ),
          for (final key in const [
            _SecurityKey('6', 10, 499),
            _SecurityKey('7', 222, 499),
            _SecurityKey('1', 434, 499),
            _SecurityKey('0', 10, 591),
            _SecurityKey('2', 222, 591),
            _SecurityKey('9', 434, 591),
            _SecurityKey('3', 10, 682),
            _SecurityKey('4', 222, 682),
            _SecurityKey('5', 434, 682),
            _SecurityKey('8', 222, 773),
          ])
            Positioned(
              left: position.getX(key.left),
              top: transaction != null ? position.getY(key.top) :  position.getY(key.top - 160),
              width: position.getWidth(201),
              height: position.getHeight(80),
              child: Semantics(
                button: true,
                label: '安全键盘${key.digit}',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _inputDigit(key.digit),
                ),
              ),
            ),
          Positioned(
            left: position.getX(475),
            top: transaction != null ? position.getY(765) :  position.getY(765 - 160),
            width: position.getWidth(145),
            height: position.getHeight(90),
            child: Semantics(
              button: true,
              label: '删除密码数字',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _deleteDigit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityKey {
  const _SecurityKey(this.digit, this.left, this.top);

  final String digit;
  final double left;
  final double top;
}
