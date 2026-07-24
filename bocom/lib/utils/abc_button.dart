import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class AbcButton extends StatefulWidget {
  final String title;
  final double? width;
  final double? height;
  final Color? bgColor;
  final Color titleColor;
  final double radius;
  final double fontSize;
  final BoxBorder? border;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final void Function()? onTap;

  const AbcButton({
    super.key,
    required this.title,
    this.width,
    this.height,
    this.bgColor,
    this.titleColor = Colors.white,
    this.onTap,
    this.border,
    this.radius = 0,
    this.fontSize = 14,
    this.margin,
    this.borderRadius
  });

  @override
  State<AbcButton> createState() => _AbcButtonState();
}

class _AbcButtonState extends State<AbcButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: widget.width??1.sw,
        height: widget.height??42.w,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.bgColor??const Color(0xff2D70ED),
          border: widget.border,
          borderRadius:widget.borderRadius?? BorderRadius.all(Radius.circular(widget.radius)),
        ),
        alignment: Alignment.center,
        child: BaseText(
          text: widget.title,
          color: widget.titleColor,
          fontSize: widget.fontSize.sp,
        ),
      ),
    );
  }
}
