import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWidget({
    super.key,
    this.hintText = '请输入',
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.hintStyle,
    this.style,
    this.inputFormatters,
    this.enabled,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: widget.textAlign,
      maxLines: 1,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      style: widget.style ?? TextStyle(fontSize: 14.sp),
      inputFormatters: widget.inputFormatters,
      enabled:widget.enabled,
      decoration: normalDecoration(widget.hintText, widget.hintStyle),
    );
  }

  InputDecoration normalDecoration(String hintText, TextStyle? hintStyle) {
    return InputDecoration(
      hintText: hintText,
      hintStyle:
          hintStyle ?? TextStyle(fontSize: 14.sp, color: Color(0xff7F7F7F)),
      filled: true,
      fillColor: Colors.transparent,
      focusedBorder: _inputBorder(),
      disabledBorder: _inputBorder(),
      errorBorder: _inputBorder(),
      focusedErrorBorder: _inputBorder(),
      enabledBorder: _inputBorder(),
      border: _inputBorder(),
      contentPadding: const EdgeInsets.all(0),
    );
  }

  InputBorder _inputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(width: 0, color: Colors.transparent),
    );
  }
}
