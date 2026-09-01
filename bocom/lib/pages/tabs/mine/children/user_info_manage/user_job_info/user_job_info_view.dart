import 'package:bocom/config/app_config.dart';
import 'package:bocom/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import 'user_job_info_logic.dart';
import 'user_job_occupation_page.dart';
import 'user_job_region_sheet.dart';

class UserJobInfoPage extends BaseStateless {
  UserJobInfoPage({super.key, UserJobInfoLogic? logic})
      : logic = logic ?? Get.put(_defaultLogic()),
        super(title: '职业及联络信息');

  final UserJobInfoLogic logic;

  static UserJobInfoLogic _defaultLogic() {
    final phone = AppConfig.config.abcLogic.phone();
    return UserJobInfoLogic.fromLocalJson(
      userJobInfoValue(phone),
      currentPhone: phone,
    );
  }

  static const List<_JobFieldConfig> _fields = [
    _JobFieldConfig(
      keyName: UserJobInfoLogic.emailKey,
      label: 'Email地址',
      inputHint: '请输入您的电子邮箱地址',
      pageHint: '',
      keyboardType: TextInputType.emailAddress,
      validationKind: _JobValidationKind.email,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.residencePhoneKey,
      label: '常住电话',
      inputHint: '请输入区号-固定电话或手机号',
      pageHint: '请输入区号-固定电话或手机号',
      keyboardType: TextInputType.phone,
      validationKind: _JobValidationKind.phone,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.residenceDetailKey,
      label: '常住详细地址',
      inputHint: '请输入您的详细地址',
      pageHint: '请输入您的详细地址',
      validationKind: _JobValidationKind.detailAddress,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.familyPhoneKey,
      label: '家庭电话',
      inputHint: '请输入区号-固定电话或手机号',
      pageHint: '请输入区号-固定电话或手机号',
      keyboardType: TextInputType.phone,
      validationKind: _JobValidationKind.phone,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.familyDetailKey,
      label: '家庭详细地址',
      inputHint: '请输入您的详细地址',
      pageHint: '请输入您的详细地址',
      validationKind: _JobValidationKind.detailAddress,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.companyNameKey,
      label: '单位名称',
      inputHint: '请输入您的单位名称',
      pageHint: '请输入您的单位名称',
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.companyPhoneKey,
      label: '单位电话',
      inputHint: '请输入区号-固定电话或手机号',
      pageHint: '请输入区号-固定电话或手机号',
      keyboardType: TextInputType.phone,
      validationKind: _JobValidationKind.phone,
    ),
    _JobFieldConfig(
      keyName: UserJobInfoLogic.companyDetailKey,
      label: '单位详细地址',
      inputHint: '请输入您的详细地址',
      pageHint: '请输入您的详细地址',
      validationKind: _JobValidationKind.detailAddress,
    ),
  ];

  static const List<_JobRegionConfig> _regionFields = [
    _JobRegionConfig(
      keyName: UserJobInfoLogic.residenceRegionKey,
      label: '常住地址',
      required: true,
    ),
    _JobRegionConfig(
      keyName: UserJobInfoLogic.familyRegionKey,
      label: '家庭地址',
    ),
    _JobRegionConfig(
      keyName: UserJobInfoLogic.companyRegionKey,
      label: '单位地址',
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
            currentValue: logic.displayValue(config.keyName),
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

  Future<void> _selectOccupation(BuildContext context) async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const UserJobOccupationPage()),
    );
    if (selected != null) logic.selectOccupation(selected);
  }

  @override
  Color? get navColor => const Color(0xFFFFFFFF);

  @override
  List<Widget>? get rightAction => [];

  @override
  Widget initBody(BuildContext context) {
    final fields = {for (final field in _fields) field.keyName: field};
    final regions = {
      for (final region in _regionFields) region.keyName: region,
    };
    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const Key('user-job-form-scroll'),
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            children: [
              const _SectionGap(),
              _nativeFieldRow(context, fields[UserJobInfoLogic.emailKey]!),
              _nativeFieldRow(
                context,
                fields[UserJobInfoLogic.residencePhoneKey]!,
                required: true,
              ),
              _nativeRegionRow(
                context,
                regions[UserJobInfoLogic.residenceRegionKey]!,
              ),
              _nativeFieldRow(
                context,
                fields[UserJobInfoLogic.residenceDetailKey]!,
                allowWrap: true,
              ),
              const _SectionGap(),
              Obx(() {
                final disabled = logic.sameAsResidence;
                return Column(
                  children: [
                    _nativeFieldRow(
                      context,
                      fields[UserJobInfoLogic.familyPhoneKey]!,
                      disabled: disabled,
                    ),
                    _nativeRegionRow(
                      context,
                      regions[UserJobInfoLogic.familyRegionKey]!,
                      disabled: disabled,
                    ),
                    _nativeFieldRow(
                      context,
                      fields[UserJobInfoLogic.familyDetailKey]!,
                      allowWrap: true,
                      disabled: disabled,
                    ),
                  ],
                );
              }),
              _sameResidenceRow(),
              const _SectionGap(),
              Obx(() {
                final occupation =
                    logic.displayValue(UserJobInfoLogic.occupationKey);
                return Column(
                  children: [
                    _NativeFormRow(
                      key: const Key('user-job-occupation'),
                      label: '职业',
                      valueKey: const Key('user-job-occupation-value'),
                      value: occupation.isEmpty ? '请选择职业类别' : occupation,
                      required: true,
                      valueColor: occupation.isEmpty
                          ? const Color(0xFFB7BCC5)
                          : const Color(0xFF181818),
                      showArrow: true,
                      onTap: () => _selectOccupation(context),
                    ),
                    if (logic.showsCompanyFields) ...[
                      _nativeFieldRow(
                        context,
                        fields[UserJobInfoLogic.companyNameKey]!,
                      ),
                      _nativeFieldRow(
                        context,
                        fields[UserJobInfoLogic.companyPhoneKey]!,
                      ),
                      _nativeRegionRow(
                        context,
                        regions[UserJobInfoLogic.companyRegionKey]!,
                      ),
                      _nativeFieldRow(
                        context,
                        fields[UserJobInfoLogic.companyDetailKey]!,
                        allowWrap: true,
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
        _bottomActions(),
      ],
    );
  }

  Widget _nativeFieldRow(
    BuildContext context,
    _JobFieldConfig config, {
    bool required = false,
    bool allowWrap = false,
    bool disabled = false,
  }) {
    final widgetKey = config.keyName.replaceAll('_', '-');
    return Obx(() {
      final value = logic.displayValue(config.keyName);
      return _NativeFormRow(
        key: Key('user-job-$widgetKey'),
        label: config.validationKind == _JobValidationKind.detailAddress
            ? ''
            : config.label,
        valueKey: Key('user-job-$widgetKey-value'),
        value: value.isEmpty ? config.pageHint : value,
        required: required,
        enabled: !disabled,
        showArrow: false,
        allowWrap: allowWrap,
        valueColor: value.isEmpty
            ? const Color(0xFFB7BCC5)
            : disabled
                ? const Color(0xFF777777)
                : const Color(0xFF181818),
        onTap: disabled ? null : () => _editField(context, config),
      );
    });
  }

  Widget _nativeRegionRow(
    BuildContext context,
    _JobRegionConfig config, {
    bool disabled = false,
  }) {
    final widgetKey = config.keyName.replaceAll('_', '-');
    return Obx(() {
      final value = logic.displayValue(config.keyName);
      return _NativeFormRow(
        key: Key('user-job-$widgetKey'),
        label: config.label,
        valueKey: Key('user-job-$widgetKey-value'),
        value: value.isEmpty ? '请选择省、市、区（县）' : value,
        required: config.required,
        enabled: !disabled,
        showArrow: true,
        allowWrap: true,
        valueColor: value.isEmpty
            ? const Color(0xFFB7BCC5)
            : disabled
                ? const Color(0xFF777777)
                : const Color(0xFF181818),
        onTap: disabled ? null : () => _selectRegion(context, config),
      );
    });
  }

  Widget _sameResidenceRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => _JobSameResidenceSwitch(
              key: const Key('user-job-same-residence'),
              value: logic.sameAsResidence,
              onChanged: logic.setSameAsResidence,
            ),
          ),
          const SizedBox(width: 8),
          const BaseText(
            text: '同居住地',
            color: Color(0xFF181818),
            fontSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _bottomActions() {
    return Container(
      key: const Key('user-job-bottom-actions'),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: Get.back,
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
                    onPressed: () async {
                      final phone = AppConfig.config.abcLogic.phone();
                      await saveUserJobInfo(phone, logic.localSnapshotJson());
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF0075F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const BaseText(
                      text: '提交',
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobSameResidenceSwitch extends StatelessWidget {
  const _JobSameResidenceSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        key: const Key('user-job-same-residence-track'),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF0075F6) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: value
                ? const Color(0xFF0075F6)
                : const Color(0xFFBFC4CC),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NativeFormRow extends StatelessWidget {
  const _NativeFormRow({
    super.key,
    required this.label,
    required this.value,
    this.valueKey,
    this.required = false,
    this.enabled = true,
    this.showArrow = false,
    this.allowWrap = false,
    this.valueColor = const Color(0xFF181818),
    this.onTap,
  });

  final String label;
  final String value;
  final Key? valueKey;
  final bool required;
  final bool enabled;
  final bool showArrow;
  final bool allowWrap;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100.w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (required)
                      const BaseText(
                        text: '*',
                        color: Color(0xFFDC1717),
                        fontSize: 16,
                      ),
                    Flexible(
                      child: BaseText(
                        text: label,
                        color: const Color(0xFF181818),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BaseText(
                  key: valueKey,
                  text: value,
                  color: valueColor,
                  fontSize: 16,
                  maxLines: allowWrap ? null : 1,
                  overflow:
                      allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
                  height: 1.45,
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 8),
                Image(
                  image: 'ic_mine_amount_right'.png,
                  width: 8.w,
                  fit: BoxFit.fitWidth,
                  color: const Color(0xFF181818),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionGap extends StatelessWidget {
  const _SectionGap();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 12,
      child: ColoredBox(color: Color(0xFFF5F5F5)),
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
    this.keyboardType = TextInputType.text,
    this.validationKind = _JobValidationKind.none,
  });

  final String keyName;
  final String label;
  final String inputHint;
  final String pageHint;
  final TextInputType keyboardType;
  final _JobValidationKind validationKind;
}

class _JobRegionConfig {
  const _JobRegionConfig({
    required this.keyName,
    required this.label,
    this.required = false,
  });

  final String keyName;
  final String label;
  final bool required;
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
