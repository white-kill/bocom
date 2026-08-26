import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_info_manage_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'nickname_edit_view.dart';
import 'user_info_logic.dart';
import 'user_info_state.dart';

class UserInfoPage extends BaseStateless {
  UserInfoPage({super.key}) : super(title: '个人资料');

  final UserInfoLogic logic = Get.put(UserInfoLogic());
  final UserInfoState state = Get.find<UserInfoLogic>().state;

  @override
  Color? get navColor => const Color(0xffF7F7F7);

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          SizedBox(
            width: 30.w,
            height: 30.w,
            child: Center(
              child: Image(
                image: 'nav_back_light_white'.png,
                width: 29.5.w,
                height: 29.5.w,
                fit: BoxFit.contain,
              ),
            ),
          ).withOnTap(onTap: () => Get.back()),
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Semantics(
          button: true,
          label: '客服',
          child: SizedBox(
            width: 30.w,
            height: 30.w,
            child: Center(
              child: Image(
                image: 'nav_kf_light_white'.png,
                width: 29.w,
                height: 29.w,
                fit: BoxFit.contain,
              ),
            ),
          ).withOnTap(
            onTap: () => Get.toNamed(Routes.customerService),
          ),
        ),
        SizedBox(
          width: 15.w,
        )
      ];

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 1080, designHeight: 2164, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_mine_info'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              top: position.getY(255),
              right: position.getX(125),
              child: Obx(
                () => BaseText(
                  text: state.nickname.value,
                  color: Colors.black,
                  fontSize: 15,
                ).withOnTap(onTap: _editNickname),
              ),
            ),
            Positioned(
              key: const Key('user-info-manage-hotspot'),
              left: position.getX(40),
              top: position.getY(510),
              width: position.getWidth(1000),
              height: position.getHeight(135),
              child: const SizedBox.expand().withOnTap(
                onTap: _openUserInfoManage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editNickname() async {
    final nickname = await Get.to<String>(
      () => NicknameEditPage(initialNickname: state.nickname.value),
    );
    if (nickname != null) {
      logic.saveNickname(nickname);
    }
  }

  void _openUserInfoManage() {
    Get.to<void>(() => UserInfoManagePage());
  }
}
