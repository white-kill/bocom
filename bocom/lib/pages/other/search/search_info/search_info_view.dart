import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/component/text_field_widget.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../../../../utils/color_util.dart';
import 'search_info_logic.dart';
import 'search_info_state.dart';

class SearchInfoPage extends BaseStateless {
  SearchInfoPage({Key? key}) : super(key: key);

  final SearchInfoLogic logic = Get.put(SearchInfoLogic());
  final SearchInfoState state = Get.find<SearchInfoLogic>().state;

  @override
  Widget? get titleWidget => Container(
        width: 1.sw,
        height: 32.w,
        margin: EdgeInsets.only(right: 15.w),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5.w, color: Color(0xffdfdfdf)),
            borderRadius: BorderRadius.all(Radius.circular(4.w))),
        child: Row(
          children: [
            Image(
              image: 'home_search_left'.png3x,
              width: 18.w,
              height: 18.w,
            ).withPadding(left: 10.w, right: 6.w),
            Container(width: 0.5, height: 18.w, color: Color(0xffdfdfdf)),
            SizedBox(
              width: 6.w,
            ),
            TextFieldWidget(
              hintText: '输入搜索词',
              controller: state.searchController,
            ).expanded(),
            SizedBox(
              width: 8.w,
            ),
            Container(
              width: 42.w,
              height: 26.w,
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                color: Color(0xffdfdfdf),
                borderRadius: BorderRadius.all(Radius.circular(4.w)),
              ),
              alignment: Alignment.center,
              child: BaseText(text: '搜索'),
            )
          ],
        ),
      );

  @override
  Color? get navColor => Color(0xFFF5F5F5);

  @override
  Widget initBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        Container(
          width: 1.sw,
          height: 42.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: state.titles.map((String name) {
              int index = state.titles.indexOf(name);
              return Obx(() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BaseText(
                        text: name,
                        style: TextStyle(
                            color: logic.selectTitle.value == index
                                ? BColors.mainColor
                                : Color(0xff666666),
                            fontSize:
                                logic.selectTitle.value == index ? 15 : 14),
                      ),
                      SizedBox(
                        height: 4.w,
                      ),
                      Container(
                        width: 16.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                            color: logic.selectTitle.value == index
                                ? BColors.mainColor
                                : Color(0xFFF5F5F5),
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.w))),
                      )
                    ],
                  ).withOnTap(onTap: () {
                    logic.selectTitle.value = index;
                  }));
            }).toList(),
          ),
        ),
        Image(
                image: logic.title.contains('流水')
                    ? 'ls_search_top'.png3x
                    : 'nd_search_top'.png3x)
            .withOnTap(onTap: () {
              logic.jumpPage();
        }),

        Image(
            image: logic.title.contains('流水')
                ? 'ls_search'.png3x
                : 'nd_search'.png3x),
      ],
    );
  }
}
