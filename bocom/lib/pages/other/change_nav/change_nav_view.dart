import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../../component/right_widget.dart';
import 'change_nav_logic.dart';
import 'change_nav_state.dart';

class ChangeNavPage extends BaseStateless {
  ChangeNavPage({super.key})
      : super(title: Get.arguments?['title'] ?? '无title参数');

  final ChangeNavLogic logic = Get.put(ChangeNavLogic());
  final ChangeNavState state = Get.find<ChangeNavLogic>().state;

  @override
  bool get isChangeNav => true;

  @override

  bool get noBackGround1 =>Get.arguments?['noBackGround1']??true;


  @override
  Color? get navColor => Get.arguments?['navColor'] ??Colors.white;


  @override
  List<Widget>? get rightAction => Get.arguments?['rightWidget'] ?? [];

  @override
  Widget? get leftItem => Get.arguments?['leftWidget'] ??InkWell(
        child: Obx(() => Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Icon(
                Icons.navigate_before,
                size: 30.h,
                color: logic.navActionColor.value,
              ),
            )),
        onTap: () => Get.back(),
      );

  @override
  Widget? get titleWidget => Obx(
        () => BaseText(
            text: title ?? '',
            fontSize: 18.sp,
            color: logic.navActionColor.value),
      );

  @override
  Function(bool change)? get onNotificationNavChange => (v) {
        logic.navActionColor.value = v
            ? Get.arguments['changeTitleColor'] ?? const Color(0xFF111111)
            : Get.arguments['defTitleColor'] ?? const Color(0xFF111111);
      };

  @override
  Widget initBody(BuildContext context) {
    final List<Widget> imageOverlay =
        (Get.arguments?['imageOverlay'] as List<Widget>?) ?? const [];

    return ListView(
      padding: EdgeInsets.only(top: Get.arguments['top']??0),
      children: [
        if (logic.state.assetsImagePath != '')
          _buildImageWithOverlay(
            Image(
              image: logic.state.assetsImagePath.png3x,
              fit: BoxFit.fitWidth,
              width: 1.sw,
            ),
            imageOverlay,
          )
        else if (logic.state.fullImagePath != "")
          _buildImageWithOverlay(
            Image(
              image: AssetImage(logic.state.fullImagePath),
              fit: BoxFit.fitWidth,
              width: 1.sw,
            ),
            imageOverlay,
          ),
        if (logic.state.assetsImagePathList.isNotEmpty)
          buildImageList(),
      ],
    );
  }

  Widget _buildImageWithOverlay(Widget image, List<Widget> overlay) {
    if (overlay.isEmpty) return image;
    return Stack(
      children: [
        image,
        ...overlay,
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
