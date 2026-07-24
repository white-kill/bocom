import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 无样式的 TextField 封装组件
class CleanTextField extends StatelessWidget {
  /// 文本控制器
  final TextEditingController? controller;
  
  /// 文本样式
  final TextStyle? textStyle;
  
  /// 提示文字
  final String? hintText;
  
  /// 提示文字样式
  final TextStyle? hintStyle;
  
  /// 键盘类型
  final TextInputType keyboardType;
  
  /// 是否启用
  final bool enabled;
  
  /// 是否只读
  final bool readOnly;
  
  /// 最大行数
  final int? maxLines;
  
  /// 最小行数
  final int? minLines;
  
  /// 最大长度
  final int? maxLength;
  
  /// 文本对齐方式
  final TextAlign textAlign;
  
  /// 输入格式限制
  final List<TextInputFormatter>? inputFormatters;
  
  /// 文本变化回调
  final ValueChanged<String>? onChanged;
  
  /// 提交回调
  final ValueChanged<String>? onSubmitted;
  
  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChange;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 焦点节点
  final FocusNode? focusNode;
  
  /// 自动焦点
  final bool autofocus;
  
  /// 是否显示光标
  final bool? showCursor;
  
  /// 光标颜色
  final Color? cursorColor;
  
  /// 光标宽度
  final double cursorWidth;
  
  /// 光标高度
  final double? cursorHeight;
  
  /// 内容边距
  final EdgeInsetsGeometry? contentPadding;
  
  /// 是否密码输入
  final bool obscureText;
  
  /// 密码显示字符
  final String obscuringCharacter;
  
  /// 是否使用紧凑模式（移除额外的垂直padding）
  final bool isDense;

  const CleanTextField({
    super.key,
    this.controller,
    this.textStyle,
    this.hintText,
    this.hintStyle,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChange,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.showCursor,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.contentPadding,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextField(
        controller: controller,
        style: textStyle,
        keyboardType: keyboardType,
        enabled: enabled,
        readOnly: readOnly,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        textAlign: textAlign,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        focusNode: focusNode,
        autofocus: autofocus,
        showCursor: showCursor,
        cursorColor: cursorColor,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          contentPadding: contentPadding ?? EdgeInsets.zero,
          isDense: isDense, // 根据参数决定是否使用紧凑模式
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          counterText: '', // 隐藏计数器
        ),
      ),
    );
  }

  /// 普通文本输入框
  factory CleanTextField.text({
    Key? key,
    TextEditingController? controller,
    TextStyle? textStyle,
    String? hintText,
    TextStyle? hintStyle,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChange,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? showCursor,
    Color? cursorColor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    EdgeInsetsGeometry? contentPadding,
    bool isDense = false,
  }) {
    return CleanTextField(
      key: key,
      controller: controller,
      textStyle: textStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      keyboardType: TextInputType.text,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChange: onFocusChange,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      contentPadding: contentPadding,
      isDense: isDense,
    );
  }

  /// 数字输入框
  factory CleanTextField.number({
    Key? key,
    TextEditingController? controller,
    TextStyle? textStyle,
    String? hintText,
    TextStyle? hintStyle,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChange,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? showCursor,
    Color? cursorColor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    EdgeInsetsGeometry? contentPadding,
    bool allowDecimal = true,
  }) {
    return CleanTextField(
      key: key,
      controller: controller,
      textStyle: textStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      keyboardType: allowDecimal 
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign,
      inputFormatters: allowDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChange: onFocusChange,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      contentPadding: contentPadding,
    );
  }

  /// 密码输入框
  /// 密码输入框
  factory CleanTextField.password({
    Key? key,
    TextEditingController? controller,
    TextStyle? textStyle,
    String? hintText,
    TextStyle? hintStyle,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    List<TextInputFormatter>? inputFormatters, // 添加这个参数
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChange,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? showCursor,
    Color? cursorColor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    EdgeInsetsGeometry? contentPadding,
    String obscuringCharacter = '•',
  }) {
    return CleanTextField(
      key: key,
      controller: controller,
      textStyle: textStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      keyboardType: TextInputType.visiblePassword,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign,
      inputFormatters: inputFormatters, // 传递这个参数
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChange: onFocusChange,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      contentPadding: contentPadding,
      obscureText: true,
      obscuringCharacter: obscuringCharacter,
    );
  }

  /// 手机号输入框
  factory CleanTextField.phone({
    Key? key,
    TextEditingController? controller,
    TextStyle? textStyle,
    String? hintText,
    TextStyle? hintStyle,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    TextAlign textAlign = TextAlign.start,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChange,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? showCursor,
    Color? cursorColor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return CleanTextField(
      key: key,
      controller: controller,
      textStyle: textStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: 11,
      textAlign: textAlign,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChange: onFocusChange,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      contentPadding: contentPadding,
    );
  }

  /// 邮箱输入框
  factory CleanTextField.email({
    Key? key,
    TextEditingController? controller,
    TextStyle? textStyle,
    String? hintText,
    TextStyle? hintStyle,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChange,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? showCursor,
    Color? cursorColor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return CleanTextField(
      key: key,
      controller: controller,
      textStyle: textStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChange: onFocusChange,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      contentPadding: contentPadding,
    );
  }

  /// 多行文本输入框
  factory CleanTextField.multiline({
    Key? key,
    TextEditingController? controller,
    TextStyle? textStyle,
    String? hintText,
    TextStyle? hintStyle,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 3,
    int? minLines = 1,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChange,
    VoidCallback? onTap,
    FocusNode? focusNode,
    bool autofocus = false,
    bool? showCursor,
    Color? cursorColor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return CleanTextField(
      key: key,
      controller: controller,
      textStyle: textStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      keyboardType: TextInputType.multiline,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onFocusChange: onFocusChange,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      contentPadding: contentPadding,
    );
  }
}



// 自定义密码输入格式化器
// 自定义密码输入格式化器
class PasswordInputFormatter extends TextInputFormatter {
  final ValueChanged<String>? onTextChanged; // 回调参数
  String _currentText = ''; // 记录当前完整文本
  
  PasswordInputFormatter({this.onTextChanged}); // 构造函数
  
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 根据文本长度变化来判断是增加还是删除
    if (newValue.text.length > oldValue.text.length) {
      // 增加字符：在末尾添加新字符
      _currentText += newValue.text.substring(oldValue.text.length);
    } else if (newValue.text.length < oldValue.text.length) {
      // 删除字符：更新为当前长度
      _currentText = _currentText.substring(0, newValue.text.length);
    } else {
      // 长度相同：可能是光标移动，保持原样
      _currentText = newValue.text;
    }
    
    // 通过回调传出去完整的原文
    onTextChanged?.call(_currentText);

    // 返回替换后的显示文本（用符号替换）
    String maskedText = '•' * _currentText.length;
    
    return TextEditingValue(
      text: maskedText,
      selection: TextSelection.collapsed(offset: maskedText.length),
    );
  }
}