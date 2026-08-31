import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_idcard_info_logic.dart';
import 'user_idcard_info_state.dart';

class UserIdcardInfoPage extends BaseStateless {
  UserIdcardInfoPage({super.key, UserIdcardInfoLogic? logic})
      : logic = logic ?? Get.put(UserIdcardInfoLogic()),
        super(title: '证件信息维护') {
    this.logic.loadLocalAddress();
  }

  final UserIdcardInfoLogic logic;
  UserIdcardInfoState get state => logic.state;

  Future<void> _editAddress() async {
    final value = await Get.dialog<String>(
      _UserIdcardAddressDialog(
        initialValue: state.address.value,
      ),
    );
    if (value != null) logic.saveAddress(value);
  }

  @override
  Color? get navColor => const Color(0xffffffff);

  @override
  List<Widget>? get rightAction => [];

  @override
  Widget initBody(BuildContext context) {
    StackPosition position =
        StackPosition(designWidth: 1080, designHeight: 2172, deviceWidth: 1.sw);
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_id_card_manage'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(75),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  key: const Key('user-card-manage-name'),
                  text: '第二代居民身份证',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(215),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  key: const Key('user-card-manage-no'),
                  text: UserIdcardInfoLogic.maskIdCard(
                    logic.memberInfo.idCard,
                  ),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(340),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  key: const Key('user-card-manage-time'),
                  text: '${logic.memberInfo.certificateBeginTime.replaceAll('-', '.')}-${logic.memberInfo.certificateEndTime.replaceAll('-', '.')}',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(540),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (bocLogic) => Obx(
                  () => GestureDetector(
                    key: const Key('user-card-manage-address'),
                    onLongPress: _editAddress,
                    child: BaseText(
                      text: state.address.value,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF181818),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UserIdcardAddressDialog extends StatefulWidget {
  const _UserIdcardAddressDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_UserIdcardAddressDialog> createState() =>
      _UserIdcardAddressDialogState();
}

class _UserIdcardAddressDialogState extends State<_UserIdcardAddressDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改地址'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: '请输入地址'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
