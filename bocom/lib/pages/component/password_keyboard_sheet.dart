import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:bocom/config/app_config.dart';
import 'indicator_loading.dart';

class PasswordKeyboardSheet extends StatefulWidget {
  const PasswordKeyboardSheet({super.key, this.onCompleted});

  final Future<void> Function()? onCompleted;

  static Future<T?> show<T>(
    BuildContext context, {
    Future<void> Function()? onCompleted,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => PasswordKeyboardSheet(onCompleted: onCompleted),
    );
  }

  @override
  State<PasswordKeyboardSheet> createState() =>
      _PasswordKeyboardSheetState();
}

class _PasswordKeyboardSheetState extends State<PasswordKeyboardSheet>
    with SingleTickerProviderStateMixin {
  static const int _passwordLength = 6;

  int _inputCount = 0;
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

  Future<void> _inputDigit() async {
    if (_inputCount >= _passwordLength) return;
    setState(() => _inputCount++);
    if (_inputCount == _passwordLength) {
      await BocomLoading.show(context);
      Get.back();
      await widget.onCompleted?.call();
    }
  }

  void _deleteDigit() {
    if (_inputCount == 0) return;
    setState(() => _inputCount--);
  }

  @override
  Widget build(BuildContext context) {
    StackPosition stackPosition =
        StackPosition(designWidth: 645, designHeight: 818, deviceWidth: 1.sw);
    return SizedBox(
      width: 1.sw,
      height: stackPosition.getHeight(818),
      child: Stack(
        children: [
          Image(
            image: 'bg_keyboard_sheet'.png3x,
            width: 1.sw,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            left: 0,
            top: stackPosition.getY(100),
            width: 1.sw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BaseText(
                  text: '请输入银行账号',
                  fontSize: 12,
                  color: Colors.black,
                ),
                BaseText(
                  text: '(**${AppConfig.config.abcLogic.cardFour()})',
                  fontSize: 13,
                  color: Colors.orangeAccent,
                ),
                const BaseText(
                  text: '的交易密码',
                  fontSize: 12,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          Positioned(
            left: stackPosition.getX(102.5),
            top: stackPosition.getY(150),
            width: stackPosition.getWidth(440),
            height: stackPosition.getHeight(61),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _inputDigit,
              child: Row(
                children: List.generate(
                  _passwordLength,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: stackPosition.getWidth(5),
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F2F4),
                        borderRadius:
                            BorderRadius.circular(stackPosition.getWidth(4)),
                      ),
                      child: index < _inputCount
                          ? Container(
                              width: stackPosition.getWidth(19),
                              height: stackPosition.getWidth(19),
                              decoration: const BoxDecoration(
                                color: Color(0xFF292929),
                                shape: BoxShape.circle,
                              ),
                            )
                          : index == _inputCount
                              ? FadeTransition(
                                  opacity: _cursorController,
                                  child: Container(
                                    width: stackPosition.getWidth(2),
                                    height: stackPosition.getHeight(32),
                                    color: const Color(0xFF61A5FF),
                                  ),
                                )
                              : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: stackPosition.getY(300),
            width: 1.sw,
            height: stackPosition.getHeight(380),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _inputDigit,
            ),
          ),
          Positioned(
            left: stackPosition.getX(475),
            top: stackPosition.getY(565),
            width: stackPosition.getWidth(145),
            height: stackPosition.getHeight(110),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _deleteDigit,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: stackPosition.getWidth(72),
            height: stackPosition.getHeight(80),
            child: const SizedBox.expand().withOnTap(onTap: () => Get.back()),
          ),
        ],
      ),
    );
  }
}
