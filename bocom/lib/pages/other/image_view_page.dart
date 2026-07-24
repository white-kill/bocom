import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';


class ImageViewPage extends StatelessWidget {
  const ImageViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    String imageName = Get.arguments?['image'] ?? '';
    return GestureDetector(
      onTap: () => Get.back(),
      child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Image(
            image: imageName.png3x,
            fit: BoxFit.fitWidth,
          )
        ]
      )
    );
  }
}

