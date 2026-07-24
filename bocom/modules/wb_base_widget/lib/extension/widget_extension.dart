import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wb_base_widget/extension/string_extension.dart';

import '../component/wb_loading_widget.dart';
import '../text_widget/bank_text.dart';

///判空
extension WbObject on Object? {
  bool get isNullOrEmpty {
    if (this == null) return true;
    if (this is String) {
      return this == '';
    }
    if (this is List) {
      return (this as List).isEmpty;
    }
    return false;
  }

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  bool get isNull => this == null;

  bool get isNotNull => this != null;
}

///图片
const String _assetImageDir = 'assets/images/';

/// 资源操作
extension AssetsStringExtension on String {
  AssetImage get jpg3x => AssetImage('$_assetImageDir$this@3x.jpg');

  AssetImage get jpg => AssetImage('$_assetImageDir$this.png');

  AssetImage get png3x => AssetImage('$_assetImageDir$this@3x.png');

  AssetImage get png => AssetImage('$_assetImageDir$this.png');

  AssetImage get gif => AssetImage('$_assetImageDir$this.gif');

  String get imgPath => '$_assetImageDir$this';
}



extension CustomWidgetExtensions on Widget {


  Widget withPadding({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
    double all = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
          left: all == 0 ? left : all,
          right: all == 0 ? right : all,
          top: all == 0 ? top : all,
          bottom: all == 0 ? bottom : all),
      child: this,
    );
  }

  Widget expanded({int flex = 1, Function()? onTap}) {
    return Expanded(
      flex: flex,
      child: withOnTap(onTap: onTap),
    );
  }

  Widget sw({double scale = 0.8}){
    return Transform.scale(
      scale: 0.8,
      child: this,
    );
  }

  Widget withContainer(
      {double? width,
      double? height,
      Color? color,
      AlignmentGeometry? alignment,
      BoxConstraints? constraints,
      EdgeInsetsGeometry? padding,
      EdgeInsetsGeometry? margin,
      Decoration? decoration,
      Matrix4? transform,
      AlignmentGeometry? transformAlignment,
      Clip clipBehavior = Clip.none,
      Function()? onTap}) {
    return Container(
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: this,
    ).withOnTap(onTap: onTap);
  }

  Widget withSizedBox({double? width, double? height, Function()? onTap}) {
    return SizedBox(
      width: width,
      height: height,
      child: this,
    ).withOnTap(onTap: onTap);
  }

  Widget withOnTap({required onTap}) => InkWell(onTap: onTap, child: this);

  Widget get screenSizedBox => SizedBox(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        child: this,
      );
}
