import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../pages/other/fixed_nav/fixed_nav_view.dart';

class CustomButton {
  static Widget rightServiceButton({
    String targetImage = 'home_zxkf',
    String targetTitle = '在线客服',
    Color color = const Color(0xFF333333),
    double size = 24,
    double paddingRight = 8,
    VoidCallback? onPressed, required IconData icon,
  }) {
    return Padding(
        padding: EdgeInsets.only(right: paddingRight),
        child: IconButton(
          icon: Icon(icon, color: color, size: size.w),
          onPressed: () {
            Get.to(() => FixedNavPage(),
                arguments: {
                  'image': targetImage,
                  'title': targetTitle,
                  'navColor': Colors.white,
                  'titleColor': color,
                },
                preventDuplicates: false);
          },
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size.w, height: size.w),
        )
    );
  }

  static Widget rightSearchButton({
    Color color = const Color(0xFF333333),
    double size = 24,
    double paddingRight = 12,
    VoidCallback? onPressed, required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: paddingRight),
      child: IconButton(
        icon: Icon(icon, color: color, size: size.w),
        onPressed: onPressed ?? () => print("点击搜索按钮"),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size.w, height: size.w),
      ),
    );
  }

  /// 4. 右侧更多按钮（三点图标）
  static Widget rightMoreButton({
    Color color = const Color(0xFF333333),
    double size = 24,
    double paddingRight = 12,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: paddingRight),
      child: IconButton(
        icon: Icon(Icons.more_horiz, color: color, size: size.w),
        onPressed: onPressed ??
                () {
              Get.dialog(AlertDialog(
                title: const Text("更多操作"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text("取消")),
                  ],
                ),
              ));
            },
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size.w, height: size.w),
      ),
    );
  }

  /// 5. 自定义文本按钮（右侧文本）
  static Widget rightTextButton({
    required String text,
    TextStyle? textStyle,
    required VoidCallback onPressed,
    double fontSize = 16,
    double paddingRight = 12,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: paddingRight),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(40.w, 40.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        child: Text(
          text,
          style: textStyle ??
              TextStyle(
                color: const Color(0xFF333333),
                fontSize: fontSize.sp,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}