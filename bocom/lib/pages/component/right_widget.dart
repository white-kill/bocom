import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class RightWidget {

 static List<Widget> widget1(){
    return [
      SizedBox(
        width: 10.w,
      ),
      Image(
        width: 37.w,
        height: 37.w,
        image: 'home_right_khfw'.png3x,
      ),
      SizedBox(
        width: 12.w,
      ),
      Image(
          width: 22.w,
          height: 22.w,
          image: 'right_tag1'.png3x,),
      SizedBox(
        width: 16.w,
      ),
    ];
  }

  static Widget rightTag({String imgPath = '',String name = ''}){
   return Column(
      children: [
        Image(
          image: imgPath.png3x,
          width: 20.w,
          height: 20.w,
          color: Color(0xff111111),
        ),
        BaseText(
          text: name,
          fontSize: 12.sp,
          color: Color(0xff111111),
        )
      ],
    );
  }

 static Widget rightImage({String imgPath = ''}){
   return Image(
     image: imgPath.png3x,
     width: 20.w,
     height: 20.w,
     color: Color(0xff111111),
   );
 }

}