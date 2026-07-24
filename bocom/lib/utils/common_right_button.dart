import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

enum CommonNavButtonType {
  tag,
  image,
  icon,
  text,
}

class CommonNavButtonConfig {
  const CommonNavButtonConfig({
    required this.type,
    this.imgPath,
    this.name,
    this.icon,
    this.color,
    this.onTap,
    this.width,
    this.height,
    this.fontSize,
    this.rightPadding,
    this.leftPadding,
    this.usePng = false,
    this.textStyle,
    this.fontWeight,
    this.alignment,
  });

  final CommonNavButtonType type;
  final String? imgPath;
  final String? name;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? rightPadding;
  final double? leftPadding;
  final bool usePng;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;
  final Alignment? alignment;
}

class CommonNavButtonUtil {
  const CommonNavButtonUtil._();

  static List<Widget> build(List<CommonNavButtonConfig> configs) {
    return configs.map(buildItem).toList();
  }

  static Widget buildItem(CommonNavButtonConfig config) {
    switch (config.type) {
      case CommonNavButtonType.tag:
        return tag(
          imgPath: config.imgPath ?? '',
          name: config.name ?? '',
          color: config.color ?? const Color(0xFF111111),
          onTap: config.onTap,
          imageWidth: config.width,
          imageHeight: config.height,
          fontSize: config.fontSize,
          leftPadding: config.leftPadding,
          rightPadding: config.rightPadding,
          fontWeight: config.fontWeight,
        );
      case CommonNavButtonType.image:
        return image(
          imgPath: config.imgPath ?? '',
          color: config.color,
          onTap: config.onTap,
          width: config.width,
          height: config.height,
          leftPadding: config.leftPadding,
          rightPadding: config.rightPadding,
          usePng: config.usePng,
        );
      case CommonNavButtonType.icon:
        return icon(
          iconData: config.icon ?? Icons.more_horiz,
          color: config.color ?? const Color(0xFF333333),
          onTap: config.onTap,
          size: config.width,
          leftPadding: config.leftPadding,
          rightPadding: config.rightPadding,
        );
      case CommonNavButtonType.text:
        return text(
          text: config.name ?? '',
          textStyle: config.textStyle,
          onTap: config.onTap,
          fontSize: config.fontSize,
          leftPadding: config.leftPadding,
          rightPadding: config.rightPadding,
          alignment: config.alignment ?? Alignment.center,
        );
    }
  }

  static Widget spacer(double width) => SizedBox(width: width);

  /// 上图标（Material Icon）+ 下文字的导航按钮
  static Widget iconTag({
    required IconData iconData,
    required String name,
    Color color = const Color(0xFF111111),
    VoidCallback? onTap,
    double? iconSize,
    double? fontSize,
    double? leftPadding,
    double? rightPadding,
  }) {
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: color, size: iconSize ?? 20.w),
        BaseText(
          text: name,
          color: color,
          fontSize: fontSize ?? 12.sp,
          style: TextStyle(
            color: color,
            fontSize: fontSize ?? 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
    return _wrap(child,
        onTap: onTap, leftPadding: leftPadding, rightPadding: rightPadding);
  }

  static Widget xcxButton({
    VoidCallback? onTap,
    double? width,
    double? height,
    double? leftPadding,
    double? rightPadding,
  }) {
    return image(
      imgPath: 'xcx',
      onTap: onTap,
      width: width ?? 80.w,
      // height: height ?? 20.w,
      leftPadding: leftPadding,
      rightPadding: rightPadding ?? 12.w,
    );
  }

  static Widget tag({
    required String imgPath,
    required String name,
    Color color = const Color(0xFF111111),
    VoidCallback? onTap,
    double? imageWidth,
    double? imageHeight,
    double? fontSize,
    double? leftPadding,
    double? rightPadding,
    FontWeight? fontWeight,
  }) {
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image(
          image: imgPath.png3x,
          width: imageWidth ?? 20.w,
          height: imageHeight ?? 20.w,
          color: color,
        ),
        BaseText(
          text: name,
          color: color,
          fontSize: fontSize ?? 12.sp,
          style: TextStyle(
            color: color,
            fontSize: fontSize ?? 12.sp,
            fontWeight: fontWeight ?? FontWeight.w400,
          ),
        ),
      ],
    );
    return _wrap(child,
        onTap: onTap, leftPadding: leftPadding, rightPadding: rightPadding);
  }

  static Widget image({
    required String imgPath,
    Color? color,
    VoidCallback? onTap,
    double? width,
    double? height,
    double? leftPadding,
    double? rightPadding,
    bool usePng = false,
  }) {
    Widget child = Image(
      image: usePng ? imgPath.png : imgPath.png3x,
      width: width ?? 20.w,
      height: height ?? 20.w,
      color: color,
    );
    return _wrap(child,
        onTap: onTap, leftPadding: leftPadding, rightPadding: rightPadding);
  }

  static Widget icon({
    required IconData iconData,
    Color color = const Color(0xFF333333),
    VoidCallback? onTap,
    double? size,
    double? leftPadding,
    double? rightPadding,
  }) {
    final iconSize = size ?? 24.w;
    return Padding(
      padding: EdgeInsets.only(
        left: leftPadding ?? 0,
        right: rightPadding ?? 12.w,
      ),
      child: IconButton(
        icon: Icon(iconData, color: color, size: iconSize),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }

  static Widget text({
    required String text,
    TextStyle? textStyle,
    VoidCallback? onTap,
    double? fontSize,
    double? leftPadding,
    double? rightPadding,
    Alignment alignment = Alignment.center,
  }) {
    return BaseText(
      text: text,
      style: textStyle ??
          TextStyle(
            color: const Color(0xFF333333),
            fontSize: fontSize ?? 16.sp,
            fontWeight: FontWeight.w500,
          ),
    ).withContainer(
      alignment: alignment,
      padding: EdgeInsets.only(
        left: leftPadding ?? 0,
        right: rightPadding ?? 12.w,
      ),
      onTap: onTap,
    );
  }

  static Widget _wrap(
    Widget child, {
    VoidCallback? onTap,
    double? leftPadding,
    double? rightPadding,
  }) {
    final wrappedChild =
        onTap == null ? child : child.withOnTap(onTap: onTap);
    return wrappedChild.withPadding(
      left: leftPadding ?? 0,
      right: rightPadding ?? 0,
    );
  }
}
