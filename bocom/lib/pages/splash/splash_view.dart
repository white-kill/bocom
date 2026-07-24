import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';

import 'splash_logic.dart';
import 'splash_state.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);

  final SplashLogic logic = Get.put(SplashLogic());
  final SplashState state = Get.find<SplashLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
        child: Image(
      image: 'background'.png,
      width: 1.sw,
      height: 1.sh,
      fit: BoxFit.cover,
    ));
  }
}
