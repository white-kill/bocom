import 'package:flutter/cupertino.dart';

class LoginState {
  TextEditingController phoneTextController = TextEditingController();
  TextEditingController psdTextController = TextEditingController();

  final FocusNode accountFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  /// 0: 手机号输入  1: 密码输入
  int currentStep = 0;

  bool agreedToTerms = false;

  void dispose() {
    phoneTextController.dispose();
    psdTextController.dispose();
    accountFocusNode.dispose();
    passwordFocusNode.dispose();
  }
}
