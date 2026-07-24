import 'package:flutter/material.dart';
import 'verification_box_cursor.dart';

/// 输入框样式
enum VerificationBoxItemType {
  /// 下划线
  underline,

  /// 盒子
  box,
}

/// 光标位置
enum CursorPosition {
  /// 居左
  left,

  /// 居中
  center,
}

/// 单个输入框
class VerificationBoxItem extends StatelessWidget {
  const VerificationBoxItem({
    Key? key,
    required this.itemWidth,
    this.data = '',
    this.textStyle,
    this.type = VerificationBoxItemType.box,
    this.decoration,
    this.borderRadius = 5.0,
    this.borderWidth = 2.0,
    this.borderColor,
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth = 2,
    this.cursorIndent = 5,
    this.cursorEndIndent = 5,
    this.cursorPosition = CursorPosition.left,
    this.obscureText,
    this.index = 0,
  }) : super(key: key);

  final String data;
  final VerificationBoxItemType type;
  final double borderWidth;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final Decoration? decoration;
  final bool? obscureText;

  final int index;

  /// 是否显示光标
  final bool showCursor;

  /// item宽度, 用来调整光标位置
  final double itemWidth;

  /// 光标位置
  final CursorPosition cursorPosition;

  /// 光标颜色
  final Color? cursorColor;

  /// 光标宽度
  final double cursorWidth;

  /// 光标距离顶部距离
  final double cursorIndent;

  /// 光标距离底部距离
  final double cursorEndIndent;

  @override
  Widget build(BuildContext context) {
    var borderColor = this.borderColor ?? Theme.of(context).dividerColor;
    var text = _buildText();
    Widget _widget;
    if (type == VerificationBoxItemType.box) {
      _widget = _buildBoxDecoration(text, borderColor);
    } else {
      _widget = _buildUnderlineDecoration(text, borderColor);
    }

    double cursorPositionLeft = 0;
    if (cursorPosition == CursorPosition.left) cursorPositionLeft = -itemWidth;

    return Container(
      decoration: decoration,
      child: Stack(
        children: [
          _widget,
          showCursor
              ? Positioned.fill(
              left: cursorPositionLeft,
              child: VerificationBoxCursor(
                color: cursorColor ?? const TextSelectionThemeData().cursorColor,
                width: cursorWidth,
                indent: cursorIndent,
                endIndent: cursorEndIndent,
              ))
              : Container()
        ],
      ),
    );
  }

  /// 绘制盒子类型
  _buildBoxDecoration(Widget child, Color borderColor) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(index == 0?borderRadius:0),
                topRight:  Radius.circular(index ==5?borderRadius:0),
                bottomLeft:  Radius.circular(index == 0?borderRadius:0),
                bottomRight:  Radius.circular(index ==5?borderRadius:0),
              ),
              border: Border.all(color: borderColor, width: borderWidth),),
      child: child,
    );
  }

  /// 绘制下划线类型
  _buildUnderlineDecoration(Widget child, Color borderColor) {
    return Container(
      alignment: Alignment.center,
      decoration: UnderlineTabIndicator(
          borderSide: BorderSide(width: borderWidth, color: borderColor)),
      child: child,
    );
  }

  /// 文本
  _buildText() {
    return Text((obscureText == true && data != '')?'●':data, style: textStyle);
  }
}
