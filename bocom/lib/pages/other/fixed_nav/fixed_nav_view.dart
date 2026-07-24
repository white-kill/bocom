import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import '../../component/right_widget.dart';
import 'fixed_nav_logic.dart';
import 'fixed_nav_state.dart';

class FixedNavPage extends BaseStateless {
  FixedNavPage({super.key})
      : super(title: Get.arguments?['title'] ?? '无title参数');

  final FixedNavLogic logic = Get.put(FixedNavLogic());
  final FixedNavState state = Get.find<FixedNavLogic>().state;

  @override
  Color? get navColor => Get.arguments?['navColor'] ?? Colors.white;

  @override
  Color? get titleColor =>
      Get.arguments?['titleColor'] ?? const Color(0xFF333333);

  @override
  Color? get background => Get.arguments?['background'];

  @override
  Color? get backColor =>
      Get.arguments?['backColor'] ??
      Get.arguments?['titleColor'] ??
      const Color(0xFF333333);

  @override
  List<Widget>? get rightAction => Get.arguments?['rightWidget'] ?? [];

  @override
  bool get centerTitle => Get.arguments?['centerTitle'] ?? true;

  @override
  double? get lefItemWidth =>Get.arguments?['lefItemWidth'];

  @override
  Widget? get titleWidget => Get.arguments?['titleWidget'];

  @override
  Widget initBody(BuildContext context) {
    final Widget? bodyChild = Get.arguments?['bodyChild'];
    if (bodyChild != null) {
      return bodyChild;
    }
    return ListView(
      padding: EdgeInsets.only(top: (Get.arguments?['top'] ?? 0).toDouble()),
      children: [
        Get.arguments?['topWidget'] ??const SizedBox.shrink(),
        if (logic.state.assetsImagePath != '')
          Image(
            image: logic.state.assetsImagePath.png3x,
            fit: BoxFit.fitWidth,
            width: 1.sw,
          ),
        if (logic.state.assetsImagePathList.isNotEmpty)
          buildImageList(),
      ],
    );
  }


  buildImageList() {
    List<Widget> images = [];
    for (String assets in logic.state.assetsImagePathList!) {
      images.add(Image(
        image: assets.png3x,
        fit: BoxFit.fitWidth,
        width: 1.sw,
      ));
    }
    return Column(
      children: images,
    );
  }
}
