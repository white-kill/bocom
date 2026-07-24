import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class PlaceholderSearchWidget extends StatefulWidget {
  final double width;
  final List<String> contentList;
  final Function? onTap;
  final Color? bgColor;
  final Color? textColor;
  final double? textSize;
  final Widget? rightIcon;
  final BoxBorder? border;
  const PlaceholderSearchWidget({
    super.key,
    this.width = 263,
    required this.contentList,
    this.onTap,
    this.bgColor,
    this.textColor,
    this.textSize,
    this.rightIcon,
    this.border
  });

  @override
  State<PlaceholderSearchWidget> createState() =>
      _PlaceholderSearchWidgetState();
}

class _PlaceholderSearchWidgetState extends State<PlaceholderSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width.w,
      height: 34.w,
      decoration: BoxDecoration(
        border:widget.border,
          borderRadius: BorderRadius.all(Radius.circular(20.w)),
          color:widget.bgColor??const Color(0xffEAF2FD)),
      padding: EdgeInsets.only(left: 10.w, right: 12.w),
      child: Row(
        children: [
          Image(
            image: 'ic_search_left'.png3x,
            width: 16.w,
            height: 16.w,
            color: const Color(0xffC8C8C8),
          ),
          Expanded(child: Swiper(
            scrollDirection:Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 5.w),
                child: BaseText(
                  text: widget.contentList[index],
                  fontSize: widget.textSize??12.w,
                  color: widget.textColor??const Color(0xffC8C8C8),),
              );
            },
            itemCount: widget.contentList.length,
            autoplay:widget.contentList.length > 1 ? true : false,
          ).withOnTap(onTap: (){
            if(widget.onTap == null){
              Get.toNamed('/search');
            }else {
              widget.onTap?.call();
            }
          })),
         widget.rightIcon?? Image(
              image: 'ic_search_right'.png3x,
              width: 16.w,
              height: 16.w,
              color: const Color(0xffC8C8C8),)
        ],
      ),
    );
  }
}
