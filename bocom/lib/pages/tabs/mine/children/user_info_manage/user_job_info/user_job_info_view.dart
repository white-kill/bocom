import 'package:bocom/config/app_config.dart';
import 'package:bocom/utils/stack_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_job_info_logic.dart';
import 'user_job_region_sheet.dart';

class UserJobInfoPage extends BaseStateless {
  UserJobInfoPage({super.key, UserJobInfoLogic? logic})
      : logic = logic ?? Get.put(_defaultLogic()),
        super(title: '职业及联络信息');

  final UserJobInfoLogic logic;

  static UserJobInfoLogic _defaultLogic() {
    final phone = AppConfig.config.abcLogic.phone();
    return UserJobInfoLogic(
      initialValues: {
        if (phone.isNotEmpty) UserJobInfoLogic.residencePhoneKey: phone,
      },
    );
  }

  static const List<_JobFieldConfig> _fields = [
    _JobFieldConfig(
      keyName: UserJobInfoLogic.emailKey,
      label: 'Email地址',
      inputHint: '请输入您的电子邮箱地址',
      pageHint: '',
      top: 70,
      keyboardType: TextInputType.emailAddress,
      validationKind: _JobValidationKind.email,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.residencePhoneKey,
      label: '常住电话',
      inputHint: '请输入区号-固定电话或手机号',
      pageHint: '请输入区号-固定电话或手机号',
      top: 210,
      keyboardType: TextInputType.phone,
      validationKind: _JobValidationKind.phone,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.residenceDetailKey,
      label: '常住详细地址',
      inputHint: '请输入您的详细地址',
      pageHint: '请输入您的详细地址',
      top: 470,
      validationKind: _JobValidationKind.detailAddress,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.familyPhoneKey,
      label: '家庭电话',
      inputHint: '请输入区号-固定电话或手机号',
      pageHint: '请输入区号-固定电话或手机号',
      top: 650,
      keyboardType: TextInputType.phone,
      validationKind: _JobValidationKind.phone,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.familyDetailKey,
      label: '家庭详细地址',
      inputHint: '请输入您的详细地址',
      pageHint: '请输入您的详细地址',
      top: 915,
      validationKind: _JobValidationKind.detailAddress,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.companyNameKey,
      label: '单位名称',
      inputHint: '请输入您的单位名称',
      pageHint: '请输入您的单位名称',
      top: 1350,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.companyPhoneKey,
      label: '单位电话',
      inputHint: '请输入区号-固定电话或手机号',
      pageHint: '请输入区号-固定电话或手机号',
      top: 1480,
      keyboardType: TextInputType.phone,
      validationKind: _JobValidationKind.phone,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.companyDetailKey,
      label: '单位详细地址',
      inputHint: '请输入您的详细地址',
      pageHint: '请输入您的详细地址',
      top: 1740,
      validationKind: _JobValidationKind.detailAddress,
    ),
  ];

  static const List<_JobRegionConfig> _regionFields = [
    _JobRegionConfig(
      keyName: UserJobInfoLogic.residenceRegionKey,
      top: 335,
    ),
    _JobRegionConfig(
      keyName: UserJobInfoLogic.familyRegionKey,
      top: 785,
    ),
    _JobRegionConfig(
      keyName: UserJobInfoLogic.companyRegionKey,
      top: 1615,
    ),
  ];

  Future<void> _editField(
    BuildContext context,
    _JobFieldConfig config,
  ) async {
    final result = await showModalBottomSheet<_JobEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (sheetContext) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.58,
          child: _JobEditSheet(
            key: const Key('user-job-edit-sheet'),
            config: config,
            currentValue: logic.valueOf(config.keyName),
          ),
        ),
      ),
    );
    if (result == null) return;
    if (result.delete) {
      logic.deleteField(config.keyName);
    } else {
      if (config.validationKind == _JobValidationKind.detailAddress) {
        final confirmed = await _confirmAddress(context);
        if (confirmed != true) return;
      }
      logic.updateField(config.keyName, result.value);
    }
  }

  Future<bool?> _confirmAddress(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.34,
        child: Material(
          key: const Key('user-job-address-confirm-sheet'),
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 36, 18, 12),
              child: Column(
                children: [
                  const BaseText(
                    text: '提示',
                    color: Color(0xFF181818),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 26),
                  const BaseText(
                    text: '按监管部门相关规定，地址应详尽至门牌号，请确认该地址为可收到邮件的具体地址，如确认无误，请忽略本提示',
                    color: Color(0xFF181818),
                    fontSize: 16,
                    height: 1.7,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext, false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0075F6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const BaseText(
                              text: '取消',
                              color: Color(0xFF0075F6),
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(sheetContext, true),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF0075F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const BaseText(
                              text: '确定',
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectRegion(
    BuildContext context,
    _JobRegionConfig config,
  ) async {
    final selected = await showModalBottomSheet<JobRegionSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.78,
        child: JobRegionPickerSheet(),
      ),
    );
    if (selected == null) return;
    logic.updateRegion(config.keyName, selected.regions);
  }

  @override
  Color? get navColor => const Color(0xFFFFFFFF);

  @override
  List<Widget>? get rightAction => [];

  @override
  Widget initBody(BuildContext context) {
    final position = StackPosition(
      designWidth: 1080,
      designHeight: 2172,
      deviceWidth: 1.sw,
    );
    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image(
              image: 'bg_user_job'.png3x,
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
            for (final config in _fields)
              _positionedField(context, position, config),
            for (final config in _regionFields)
              _positionedRegion(context, position, config),
          ],
        ),
      ],
    );
  }

  Widget _positionedField(
    BuildContext context,
    StackPosition position,
    _JobFieldConfig config,
  ) {
    final widgetKey = config.keyName.replaceAll('_', '-');
    return Positioned(
      left: position.getX(320),
      right: position.getX(75),
      top: position.getY(config.top),
      height: position.getHeight(72),
      child: GestureDetector(
        key: Key('user-job-$widgetKey'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _editField(context, config),
        child: ColoredBox(
          color: Colors.white,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final value = logic.valueOf(config.keyName);
              return BaseText(
                key: Key('user-job-$widgetKey-value'),
                text: value.isEmpty ? config.pageHint : value,
                color: value.isEmpty
                    ? const Color(0xFFB7BCC5)
                    : const Color(0xFF181818),
                fontSize: 15,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _positionedRegion(
    BuildContext context,
    StackPosition position,
    _JobRegionConfig config,
  ) {
    final widgetKey = config.keyName.replaceAll('_', '-');
    return Positioned(
      left: position.getX(320),
      right: position.getX(75),
      top: position.getY(config.top),
      height: position.getHeight(72),
      child: GestureDetector(
        key: Key('user-job-$widgetKey'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _selectRegion(context, config),
        child: ColoredBox(
          color: Colors.white,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final value = logic.valueOf(config.keyName);
              return BaseText(
                key: Key('user-job-$widgetKey-value'),
                text: value.isEmpty ? '请选择省、市、区（县）' : value,
                color: value.isEmpty
                    ? const Color(0xFFB7BCC5)
                    : const Color(0xFF181818),
                fontSize: 15,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _JobEditSheet extends StatefulWidget {
  const _JobEditSheet({
    super.key,
    required this.config,
    required this.currentValue,
  });

  final _JobFieldConfig config;
  final String currentValue;

  @override
  State<_JobEditSheet> createState() => _JobEditSheetState();
}

class _JobEditSheetState extends State<_JobEditSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasLostFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_refresh);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) _hasLostFocus = true;
    if (mounted) setState(() {});
  }

  String? get _validationError {
    final value = _controller.text.trim();
    if (value.isEmpty) return null;
    switch (widget.config.validationKind) {
      case _JobValidationKind.email:
        final emailPattern = RegExp(
          r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
        );
        return emailPattern.hasMatch(value) ? null : '请输入正确的Email地址';
      case _JobValidationKind.detailAddress:
        final chineseCount = RegExp(r'[\u4E00-\u9FFF]').allMatches(value).length;
        return chineseCount >= 3 ? null : '详细地址不少于3个汉字';
      case _JobValidationKind.phone:
        final mobilePattern = RegExp(r'^1\d{10}$');
        final fixedLinePattern = RegExp(r'^0\d{2,3}-\d{7,8}$');
        return mobilePattern.hasMatch(value) || fixedLinePattern.hasMatch(value)
            ? null
            : '请输入正确的电话号码';
      case _JobValidationKind.none:
        return null;
    }
  }

  String? get _bubbleMessage {
    if (_focusNode.hasFocus &&
        widget.config.validationKind == _JobValidationKind.phone) {
      return '如填写固定电话，格式如：021-XXXXXX';
    }
    return _hasLostFocus ? _validationError : null;
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _controller.text.trim().isNotEmpty && _validationError == null;
    final canDelete = widget.currentValue.isNotEmpty;
    final bubbleMessage = _bubbleMessage;
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF181818)),
                    ),
                  ),
                  BaseText(
                    text: widget.config.label,
                    color: const Color(0xFF181818),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BaseText(
                          text: '当前信息',
                          color: Color(0xFF181818),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            BaseText(
                              text: widget.config.label,
                              color: const Color(0xFF999999),
                              fontSize: 15,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BaseText(
                                text: widget.currentValue.isEmpty
                                    ? ''
                                    : widget.currentValue,
                                color: const Color(0xFF666666),
                                fontSize: 15,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BaseText(
                    text: '如您需要修改${widget.config.label}，请重新填写',
                    color: const Color(0xFFFF7817),
                    fontSize: 14,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 13),
                        child: BaseText(
                          text: widget.config.label,
                          color: const Color(0xFF181818),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              keyboardType: widget.config.keyboardType,
                              style: const TextStyle(
                                color: Color(0xFF181818),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: widget.config.inputHint,
                                hintStyle: const TextStyle(
                                  color: Color(0xFFCBD0D9),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (bubbleMessage != null)
                              _ValidationBubble(message: bubbleMessage),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xFFE8E8E8)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: canDelete
                            ? () => Navigator.pop(
                                  context,
                                  const _JobEditResult.delete(),
                                )
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: canDelete
                                ? const Color(0xFF0075F6)
                                : const Color(0xFFCDD2DB),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: BaseText(
                          text: '删除当前信息',
                          color: canDelete
                              ? const Color(0xFF0075F6)
                              : const Color(0xFFCDD2DB),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () => Navigator.pop(
                                  context,
                                  _JobEditResult.update(_controller.text),
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF0075F6),
                          disabledBackgroundColor: const Color(0xFFCDD2DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const BaseText(
                          text: '修改并确认',
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobFieldConfig {
  const _JobFieldConfig({
    required this.keyName,
    required this.label,
    required this.inputHint,
    required this.pageHint,
    required this.top,
    this.keyboardType = TextInputType.text,
    this.validationKind = _JobValidationKind.none,
  });

  final String keyName;
  final String label;
  final String inputHint;
  final String pageHint;
  final double top;
  final TextInputType keyboardType;
  final _JobValidationKind validationKind;
}

class _JobRegionConfig {
  const _JobRegionConfig({required this.keyName, required this.top});

  final String keyName;
  final double top;
}

enum _JobValidationKind { none, email, phone, detailAddress }

class _ValidationBubble extends StatelessWidget {
  const _ValidationBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('user-job-validation-bubble'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: CustomPaint(
            size: const Size(14, 7),
            painter: _BubbleArrowPainter(),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5454),
            borderRadius: BorderRadius.circular(3),
          ),
          child: BaseText(
            text: message,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF5454));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JobEditResult {
  const _JobEditResult.update(this.value) : delete = false;
  const _JobEditResult.delete()
      : value = '',
        delete = true;

  final String value;
  final bool delete;
}
