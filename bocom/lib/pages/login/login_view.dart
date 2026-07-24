import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:bocom/utils/stack_position.dart';

import 'login_logic.dart';
import 'login_state.dart';
import 'widget/login_floating_input.dart';

class LoginPage extends BaseStateless {
  LoginPage({Key? key}) : super(key: key);

  final LoginLogic logic = Get.put(LoginLogic());
  final LoginState state = Get.find<LoginLogic>().state;

  @override
  Color? get background => Colors.white;

  @override
  bool get isChangeNav => true;

  @override
  double? get lefItemWidth => 0.w;

  @override
  Widget? get leftItem => const SizedBox.shrink();

  @override
  Widget initBody(BuildContext context) {
    StackPosition stackPosition = StackPosition(
      designWidth: 1080,
      designHeight: 487,
      deviceWidth: 1.sw,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image(
                      image: 'bg_login_1'.png3x,
                      width: 1.sw,
                      fit: BoxFit.fitWidth,
                    ),
                    Container(
                      width: 1.sw,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LoginFloatingInput(
                            label: '请输入手机号/用户名/卡号/身份证号',
                            controller: state.phoneTextController,
                            focusNode: state.accountFocusNode,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                state.passwordFocusNode.requestFocus(),
                          ),
                          SizedBox(height: 12.h),
                          LoginFloatingInput(
                            label: '请输入登录密码',
                            controller: state.psdTextController,
                            focusNode: state.passwordFocusNode,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => logic.goLogin(),
                          ),
                          SizedBox(height: 8.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: BaseText(
                                text: '找回用户名/密码',
                                fontSize: 14,
                                color: Color(0XFF0D6ACD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Stack(
                      children: [
                        Image(
                          image: 'bg_login_2'.png3x,
                          width: 1.sw,
                          fit: BoxFit.fitWidth,
                        ),
                        Positioned(
                          top: stackPosition.getX(230),
                          left: 30.w,
                          child: Obx(() => Image(
                            image: (logic.canLoginActive
                                    ? 'login_btn_check'
                                    : 'login_btn')
                                .png,
                            width: 1.sw - 60.w,
                            fit: BoxFit.fitWidth,
                          ).withOnTap(onTap: () => logic.goLogin())),
                        ),
                        Positioned(
                          top: stackPosition.getX(10),
                          left: 30.w,
                          child: Obx(() => Image(
                            image: (logic.agreedToTerms.value
                                    ? 'login_read_check'
                                    : 'login_read')
                                .png,
                            width: stackPosition.getWidth(60),
                            fit: BoxFit.fitWidth,
                          ).withOnTap(onTap: () => logic.toggleAgreement())),
                        )
                      ]
                    )
                  ],
                ),
                Image(
                  image: 'bg_login_3'.png3x,
                  width: 1.sw,
                  fit: BoxFit.fitWidth,
                ).marginOnly(bottom: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
