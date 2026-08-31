import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_base_info_logic.dart';
import 'user_base_info_state.dart';

class UserBaseInfoPage extends BaseStateless {
  UserBaseInfoPage({super.key, UserBaseInfoLogic? logic})
      : logic = logic ?? Get.put(UserBaseInfoLogic()),
        super(title: '基本身份信息') {
    this.logic.loadLocalValues();
  }

  final UserBaseInfoLogic logic;
  UserBaseInfoState get state => logic.state;

  Future<void> _editValue({
    required String title,
    required String initialValue,
    required bool Function(String) save,
  }) async {
    final value = await Get.dialog<String>(
      _UserBaseInfoEditDialog(
        title: title,
        initialValue: initialValue,
      ),
    );
    if (value != null) save(value);
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
              image: 'bg_user_base_info'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(65),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  key: const Key('user-info-manage-name'),
                  text: logic.realName(),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(210),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => BaseText(
                  key: const Key('user-info-manage-sex'),
                  text: logic.memberInfo.sex == '1' ? '男' : '女',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(355),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (bocLogic) => Obx(
                  () => GestureDetector(
                    key: const Key('user-info-manage-date'),
                    onLongPress: () => _editValue(
                      title: '出生日期',
                      initialValue: state.date.value,
                      save: logic.saveDate,
                    ),
                    child: BaseText(
                      text: state.date.value,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF181818),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: position.getX(100),
              top: position.getY(480),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (logic) => const BaseText(
                  key: Key('user-info-manage-guoji'),
                  text: '中国',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            Positioned(
              left: position.getX(370),
              top: position.getY(980),
              child: GetBuilder<BocLogic>(
                id: 'updateUI',
                builder: (bocLogic) => Obx(
                  () => GestureDetector(
                    key: const Key('user-info-manage-pingyin'),
                    onLongPress: () => _editValue(
                      title: '姓名拼音',
                      initialValue: state.pinyin.value,
                      save: logic.savePinyin,
                    ),
                    child: BaseText(
                      text: state.pinyin.value,
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

class _UserBaseInfoEditDialog extends StatefulWidget {
  const _UserBaseInfoEditDialog({
    required this.title,
    required this.initialValue,
  });

  final String title;
  final String initialValue;

  @override
  State<_UserBaseInfoEditDialog> createState() =>
      _UserBaseInfoEditDialogState();
}

class _UserBaseInfoEditDialogState extends State<_UserBaseInfoEditDialog> {
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
      title: Text('修改${widget.title}'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: '请输入${widget.title}'),
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
