import 'package:bocom/utils/sp_util.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import '../../config/app_config.dart';
import '../../config/dio/network.dart';
import '../../config/net_config/apis.dart';
import '../../routes/app_pages.dart';
import 'login_state.dart';

class LoginLogic extends GetxController {
  final LoginState state = LoginState();

  final currentStep = 0.obs;
  final agreedToTerms = false.obs;
  final isFormFilled = false.obs;

  /// 账号、密码均已填写且已勾选协议时，登录按钮显示可点击态
  bool get canLoginActive =>
      agreedToTerms.value && isFormFilled.value;

  @override
  void onInit() {
    super.onInit();
    state.phoneTextController.addListener(_onFormChanged);
    state.psdTextController.addListener(_onFormChanged);
  }

  @override
  void onClose() {
    state.phoneTextController.removeListener(_onFormChanged);
    state.psdTextController.removeListener(_onFormChanged);
    state.dispose();
    super.onClose();
  }

  void _onFormChanged() {
    isFormFilled.value = state.phoneTextController.text.trim().isNotEmpty &&
        state.psdTextController.text.isNotEmpty;
  }

  void toggleAgreement() {
    agreedToTerms.value = !agreedToTerms.value;
    state.agreedToTerms = agreedToTerms.value;
  }

  void goNextStep() {
    final phone = state.phoneTextController.text.trim();
    if (phone.isEmpty) {
      '请输入手机号'.showToast;
      return;
    }
    if (!agreedToTerms.value) {
      '请先阅读并同意相关协议'.showToast;
      return;
    }
    currentStep.value = 1;
    state.currentStep = 1;
  }

  void goBackStep() {
    if (currentStep.value == 1) {
      currentStep.value = 0;
      state.currentStep = 0;
    }
  }

  String maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  void goLogin() {
    if (state.phoneTextController.text.trim().isEmpty) {
      '请输入账号'.showToast;
      return;
    }

    if (state.psdTextController.text.isEmpty) {
      '请输入密码'.showToast;
      return;
    }

    if (!agreedToTerms.value) {
      '请先阅读并同意相关协议'.showToast;
      return;
    }

    Http.post(Apis.login, data: {
      "username": state.phoneTextController.text.trim(),
      "password": state.psdTextController.text
    }).then((value) {
      if (value != null && value['access_token'] != '') {
        'Bearer ${value['access_token']}'.saveToken;
        Http.setHeaders({'Authorization': token});
        AppConfig.config.abcLogic
            .memberInfoData()
            .then((v) => Get.offAllNamed(Routes.tabs));
      }
    });
  }
}
