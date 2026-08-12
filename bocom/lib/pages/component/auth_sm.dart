import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import '../../config/app_config.dart';
import '../../utils/local_notifications.dart';

/// 转账短信通知所需的业务信息。
class AuthSmTransferContext {
  const AuthSmTransferContext({
    required this.payeeName,
    required this.cardLast4,
    required this.amountDisplay,
  });

  final String payeeName;
  final String cardLast4;
  final String amountDisplay;
}

typedef SmsCodeSender = Future<String> Function();
typedef SmsVerificationLauncher = Future<bool?> Function(
  BuildContext context,
  String phone,
  AuthSmTransferContext? transferContext,
);

/// 公共短信验证码校验入口。
///
/// 返回 `true` 表示验证码校验通过，关闭或校验未完成时返回 `false/null`。
Future<bool?> showSmsVerificationCode(
  BuildContext context, {
  required String phone,
  AuthSmTransferContext? transferContext,
  SmsCodeSender? codeSender,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.63),
    builder: (_) => SmsVerificationCodeSheet(
      phone: phone,
      transferContext: transferContext,
      codeSender: codeSender,
    ),
  );
}

// 短信验证码弹层
// 说明：弹层依据 1206x2622 参考图原生绘制，输入由系统电话数字键盘完成，不使用截图或自绘键盘。
class SmsVerificationCodeSheet extends StatefulWidget {
  const SmsVerificationCodeSheet({
    super.key,
    required this.phone,
    this.transferContext,
    this.codeSender,
  });

  final String phone;
  final AuthSmTransferContext? transferContext;
  final SmsCodeSender? codeSender;

  @override
  State<SmsVerificationCodeSheet> createState() =>
      _SmsVerificationCodeSheetState();
}

class _SmsVerificationCodeSheetState extends State<SmsVerificationCodeSheet> {
  static const _codeLength = 6;
  static const _resendSeconds = 60;
  static const _referenceWidth = 1206.0;
  static const _referencePanelHeight = 876.0;
  static const _referencePanelTop = 820.0;
  static const _titleFontSize = 53.0;
  static const _mainFontSize = 61.0;
  static const _supportingFontSize = 50.0;
  static const _footerFontSize = 48.0;
  static const _codeFontSize = 72.0;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _countdownTimer;
  String? _errorText;
  int _secondsRemaining = _resendSeconds;
  bool _isSending = false;
  bool _completed = false;
  late String _serialNumber;

  String get _phoneTail {
    final digits = widget.phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '--';
    return digits.substring(digits.length - 4);
  }

  @override
  void initState() {
    super.initState();
    _serialNumber = _newSerialNumber();
    _controller.addListener(_handleCodeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _sendCode();
    });
  }

  String _newSerialNumber() =>
      (10 + Random().nextInt(90)).toString().padLeft(2, '0');

  Future<String> _defaultSendCode() async {
    final code = Random().nextVerificationCode(_codeLength);
    final config = AppConfig.config;
    final transfer = widget.transferContext;
    final String body;
    if (transfer != null) {
      body = config.buildTransferAuthNotificationBody(
        code: code,
        payee: transfer.payeeName,
        cardLast4: transfer.cardLast4,
        amount: transfer.amountDisplay,
      );
    } else {
      final name = config.abcLogic.memberInfo.realName.removeFirstChar1();
      body = config.buildAuthSmNotificationBody(
        code: code,
        name: name,
        smsId: Random().nextVerificationCode(4),
      );
    }
    await NotificationHelper.getInstance().showNotification(
      title: config.authSmNotificationTitle,
      body: body,
      payload: 'sms_verification',
    );
    return code;
  }

  Future<void> _sendCode() async {
    if (_isSending) return;
    setState(() {
      _isSending = true;
      _errorText = null;
      _serialNumber = _newSerialNumber();
    });
    try {
      await (widget.codeSender?.call() ?? _defaultSendCode());
      if (!mounted) return;
      _startCountdown();
    } catch (_) {
      if (mounted) setState(() => _errorText = '验证码发送失败，请重试');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = _resendSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _handleCodeChanged() {
    setState(() => _errorText = null);
    if (_controller.text.length == _codeLength) _complete();
  }

  Future<void> _complete() async {
    if (_completed) return;
    _completed = true;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(true);
  }

  void _close() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller
      ..removeListener(_handleCodeChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = media.size.width / _referenceWidth;
    final keyboardInset = media.viewInsets.bottom;
    final referencePanelHeight = _referencePanelHeight * scale;
    final panelHeight = keyboardInset > 0
        ? max(
            referencePanelHeight,
            media.size.height - keyboardInset - _referencePanelTop * scale,
          )
        : referencePanelHeight;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          key: const Key('sms-verification-sheet'),
          width: media.size.width,
          height: panelHeight,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32 * scale),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  left: 24 * scale,
                  top: 32 * scale,
                  width: 72 * scale,
                  height: 72 * scale,
                  child: IconButton(
                    key: const Key('sms-verification-close'),
                    tooltip: '关闭',
                    padding: EdgeInsets.zero,
                    onPressed: _close,
                    icon: Icon(
                      Icons.close,
                      size: 47 * scale,
                      color: const Color(0xFF151515),
                    ),
                  ),
                ),
                Positioned(
                  left: 120 * scale,
                  right: 120 * scale,
                  top: 49 * scale,
                  child: Text(
                    '短信验证码',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF222222),
                      fontSize: _titleFontSize * scale,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                    ),
                  ),
                ),
                Positioned(
                  left: 30 * scale,
                  right: 30 * scale,
                  top: 226 * scale,
                  child: Column(
                    children: [
                      Text(
                        '已发送至尾号(**$_phoneTail)的手机',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF242424),
                          fontSize: _mainFontSize * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.05,
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '5分钟内有效',
                            style: TextStyle(
                              color: const Color(0xFF969EAC),
                              fontSize: _supportingFontSize * scale,
                              height: 1,
                            ),
                          ),
                          SizedBox(width: 24 * scale),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _secondsRemaining == 0 && !_isSending
                                ? _sendCode
                                : null,
                            child: Text(
                              '收不到短信?',
                              style: TextStyle(
                                color: const Color(0xFF0875E8),
                                fontSize: _supportingFontSize * scale,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 156 * scale,
                  right: 156 * scale,
                  top: 436 * scale,
                  height: 156 * scale,
                  child: _VerificationBoxes(
                    code: _controller.text,
                    hasFocus: _focusNode.hasFocus,
                    scale: scale,
                    onTap: _focusNode.requestFocus,
                  ),
                ),
                Positioned(
                  left: 44 * scale,
                  right: 44 * scale,
                  top: 650 * scale,
                  child: Row(
                    children: [
                      Text(
                        _errorText ?? '验证码核对序号：$_serialNumber',
                        style: TextStyle(
                          color: _errorText == null
                              ? const Color(0xFF969EAC)
                              : const Color(0xFFE34D59),
                          fontSize: _footerFontSize * scale,
                          height: 1,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _secondsRemaining == 0 && !_isSending
                            ? _sendCode
                            : null,
                        child: Text(
                          _isSending
                              ? '发送中'
                              : _secondsRemaining > 0
                                  ? '${_secondsRemaining}s后重获'
                                  : '重新获取',
                          style: TextStyle(
                            color: const Color(0xFF969EAC),
                            fontSize: _footerFontSize * scale,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 156 * scale,
                  right: 156 * scale,
                  top: 436 * scale,
                  height: 156 * scale,
                  child: Opacity(
                    opacity: 0.01,
                    child: TextField(
                      key: const Key('sms-verification-input'),
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      showCursor: false,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(_codeLength),
                      ],
                    ),
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

class _VerificationBoxes extends StatelessWidget {
  const _VerificationBoxes({
    required this.code,
    required this.hasFocus,
    required this.scale,
    required this.onTap,
  });

  final String code;
  final bool hasFocus;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          for (var index = 0; index < 6; index++) ...[
            Expanded(
              child: Container(
                key: Key('sms-code-box-$index'),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: hasFocus && index == code.length && code.length < 6
                      ? Border.all(
                          color: const Color(0xFF0875E8), width: 2 * scale)
                      : null,
                ),
                child: index < code.length
                    ? Text(
                        code[index],
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize:
                              _SmsVerificationCodeSheetState._codeFontSize *
                                  scale,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : hasFocus && index == code.length && code.length < 6
                        ? Container(
                            width: 2 * scale,
                            height: 55 * scale,
                            color: const Color(0xFFB7D7FF),
                          )
                        : null,
              ),
            ),
            if (index < 5) SizedBox(width: (index == 2 ? 90 : 30) * scale),
          ],
        ],
      ),
    );
  }
}
