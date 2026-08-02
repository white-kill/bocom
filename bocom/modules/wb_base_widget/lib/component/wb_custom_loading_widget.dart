import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WbCustomLoadingWidget extends StatelessWidget {
  const WbCustomLoadingWidget({super.key, required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(
        image: image,
        width: 90.w,
        height: 45.w,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }
}
