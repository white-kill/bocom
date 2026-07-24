import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseText extends StatefulWidget {
  const BaseText( {
    super.key,
    required this.text,
    this.color = Colors.black,
    this.textAlign,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.decoration,
    this.scaleMaxLength,
    this.fontSize = 14,
    this.fontFamily,
  });

  /// 文本
  final String text;

  /// 文本颜色
  final Color color;

  final double fontSize;

  /// 文本样式，不设置，默认启用排版类型中的样式
  final TextStyle? style;

  /// 文本对齐方式
  final TextAlign? textAlign;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaleFactor;

  /// 最大行数
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final TextDecoration? decoration;

  /// 如果不为 null ，则文字超过数量就缩放
  final int? scaleMaxLength;

  final String? fontFamily;

  @override
  State<BaseText> createState() => _BaseTextState();
}

class _BaseTextState extends State<BaseText> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TextStyle textSt = TextStyle(
    //     fontFamily: 'cbc',
    //     fontSize: widget.fontSize.sp,
    //     fontWeight: FontWeight.normal,
    //     color: widget.color
    // );
    // 创建基础文本样式
    TextStyle baseStyle = TextStyle(
      fontFamily: widget.fontFamily??'boc',
      fontSize: widget.fontSize.sp,
      fontWeight: FontWeight.normal,
      color: widget.color,
      decoration: widget.decoration,
    );

    // 如果传入了自定义样式，则合并样式
    TextStyle finalStyle;
    if (widget.style != null) {
      // 合并样式，优先使用自定义样式中的属性
      finalStyle = baseStyle.merge(widget.style).copyWith(
        fontFamily: widget.style?.fontFamily ?? 'cbc',
        fontSize: widget.style?.fontSize ?? widget.fontSize.sp,
        fontWeight: widget.style?.fontWeight ?? FontWeight.normal,
        color: widget.style?.color ?? widget.color,
      );
    } else {
      finalStyle = baseStyle;
    }

    return Text(
      widget.text,
      style: finalStyle,
      textAlign: widget.textAlign,
      strutStyle: widget.strutStyle,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow??TextOverflow.ellipsis,
      textScaler: widget.textScaleFactor,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }
}
