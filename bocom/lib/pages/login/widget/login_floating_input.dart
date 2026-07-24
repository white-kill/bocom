import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 登录页浮动占位符输入框：未聚焦时占位居中，聚焦或有内容时占位上移缩小。
class LoginFloatingInput extends StatefulWidget {
  const LoginFloatingInput({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  static const Color _fillColor = Color(0xFFF5F5F5);
  static const Color _fillHighColor = Color(0xFFEDEDED);
  static const Color _labelColor = Color(0xFF999999);
  static const Color _labelHighColor = Color(0xFF828384);

  @override
  State<LoginFloatingInput> createState() => _LoginFloatingInputState();
}

class _LoginFloatingInputState extends State<LoginFloatingInput> {
  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeInOut;

  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  bool get _floated =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusOrTextChange);
    widget.controller.addListener(_onFocusOrTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusOrTextChange);
    widget.controller.removeListener(_onFocusOrTextChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusOrTextChange() {
    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final collapsedHeight = 52.h;
    final expandedHeight = 68.h;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        height: _floated ? expandedHeight : collapsedHeight,
        decoration: BoxDecoration(
          color: _floated ? LoginFloatingInput._fillHighColor : LoginFloatingInput._fillColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            AnimatedAlign(
              duration: _duration,
              curve: _curve,
              alignment:
                  _floated ? Alignment.topLeft : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  top: _floated ? 10.h : 0,
                  right: 16.w,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: _duration,
                  curve: _curve,
                  style: TextStyle(
                    fontSize: _floated ? 12.sp : 16.sp,
                    color: _floated ? LoginFloatingInput._labelHighColor : LoginFloatingInput._labelColor,
                    height: 1.2,
                  ),
                  child: Text(
                    widget.label,
                    maxLines: _floated ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              top: _floated ? 35.h : 0,
              bottom: _floated ? 8.h : 0,
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onSubmitted,
                cursorColor: const Color(0xFF1860F0),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  height: 1.25,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
