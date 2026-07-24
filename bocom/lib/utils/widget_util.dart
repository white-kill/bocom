import 'package:bocom/utils/screen_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';

BoxDecoration decorationImage(String imageName,{BoxFit? fit}) {
  return BoxDecoration(
    image: DecorationImage(
      image: imageName.png3x,
      fit: fit??BoxFit.fitWidth,
    ),
  );
}

BoxDecoration decorationRadius(
  double radius, {
  Color color = Colors.white,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: color,
  );
}

BoxDecoration decorationOnlyRadius({
  Color color = Colors.white,
  double topRight = 0,
  double topLeft = 0,
  double bottomRight = 0,
  double bottomLeft = 0,
  BoxBorder? border,
  double? radius,
}) {
  return BoxDecoration(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(radius??topRight),
        topLeft: Radius.circular(radius??topLeft),
        bottomRight: Radius.circular(radius??bottomRight),
        bottomLeft: Radius.circular(radius??bottomLeft),
      ),
      border: border,
      color: color);
}

InputDecoration normalDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    border: InputBorder.none,
  );
}

///设置横线
class HorizontalLine extends StatelessWidget {
  final double dashedWidth;
  final double dashedHeight;
  final Color color;
  final double edgeSize;

  const HorizontalLine(
      {super.key,
      this.dashedHeight = 1,
      this.dashedWidth = double.infinity,
      this.color = const Color(0xfff6f6f6),
      this.edgeSize = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: edgeSize, right: edgeSize),
      child: Container(width: dashedWidth, height: dashedHeight, color: color),
    );
  }
}

Widget bottomWidget(child, {double height = 40, Color? color}) {
  return Container(
    color: color,
    padding: EdgeInsets.only(
      top: 15,
      bottom: 15 + bottomBarHeight,
      left: 15,
      right: 15,
    ),
    child: child,
  );
}

Widget netImage({
  required String url,
  BoxFit fit = BoxFit.cover,
  double width = double.infinity,
  double height = double.infinity,
  double radius = 0
}) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    child: CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: url,
      fit: fit,
      placeholder: (_,__){
        return Container(
          alignment: Alignment.center,
          width: 45.h,
          height: 45.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.0.w,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
      errorWidget: (context, url, error) =>Container(
        decoration: decorationOnlyRadius(
            color: Colors.white,
            radius: 4.w
        ),
      ),
    ),
  );
}

void changeKeyboardType(BuildContext context, FocusNode focusNode) {
  FocusScopeNode focusScopeNode = FocusScope.of(context);
  if (!focusScopeNode.hasPrimaryFocus && focusScopeNode.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  Future.delayed(const Duration(microseconds: 100), () {
    focusNode.requestFocus();
  });
}
