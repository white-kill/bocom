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
  final double height;
  final double radius;
  const PlaceholderSearchWidget({
    super.key,
    this.width = 263,
    this.height = 30,
    required this.contentList,
    this.onTap,
    this.bgColor,
    this.textColor,
    this.textSize,
    this.rightIcon,
    this.border,
    this.radius = 15,
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
      height: widget.height.w,
      decoration: BoxDecoration(
        border:widget.border,
          borderRadius: BorderRadius.all(Radius.circular(widget.radius.w)),
          color:widget.bgColor??Colors.white),
      padding: EdgeInsets.only(left: 10.w, right: 2.w),
      margin: EdgeInsets.only(bottom: 10.w),
      child: Row(
        children: [
          Image(
            image: 'ic_search_left'.png3x,
            width: 14.w,
            height: 14.w,
            color: widget.textColor??const Color(0xffC8C8C8),
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
         widget.rightIcon?? Container(
           width: 38.w,
           height: 25.w,
           alignment: Alignment.center,
           decoration: BoxDecoration(
             color: Color(0xffffffff),
             borderRadius: BorderRadius.all(Radius.circular(9.w)),
           ),
           child: Container(
             width: 17.w,
             height: 17.w,
             child: Row(
               children: [
                 Image(
                   image: 'home_search_left'.png3x,
                   width: 17.w,
                   height: 17.w,
                   color: Color(0xff333333),
                 ),
               ],
             ),
           ),
         )
        ],
      ),
    );
  }
}
