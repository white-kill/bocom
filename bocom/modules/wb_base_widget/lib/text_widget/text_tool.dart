import 'package:flutter/material.dart';

/// TextTool
class TextTool {

  ///文字宽高
  static Size boundingTextSize(String text,
      {
        double fontSize= 16,
        FontWeight fontWeight = FontWeight.normal,
        int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: TextStyle(fontSize: fontSize,fontWeight: fontWeight)),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

}