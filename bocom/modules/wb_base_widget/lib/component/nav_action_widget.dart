import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:popup_menu/popup_menu.dart';

class NavActionWidget extends StatefulWidget {
  final String? image;
  final String? title;
  final Color? color;
  final double? left;
  final double? right;
  final bool showTitle;
  final Function? onTap;
  final Function? onTapItem;
  final String? routesName;

  const NavActionWidget({
    super.key,
    this.image,
    this.title,
    this.color,
    this.left,
    this.right,
    this.routesName,
    this.showTitle = true,
    this.onTap,
    this.onTapItem,
  });

  @override
  State<NavActionWidget> createState() => _NavActionWidgetState();
}

class _NavActionWidgetState extends State<NavActionWidget> {

late PopupMenu menu;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //widget.onpress!();
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: (widget.left ?? 0), right: widget.right ?? 16.w),
          child: Container(
            height: 34.w,
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: widget.image!.png3x,
                  width: 20.w,
                  height: 20.w,
                  color: widget.color ?? Colors.black,
                ),
                widget.showTitle? BaseText(
                  text: widget.title ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: widget.color ?? Colors.black87,
                    fontWeight: FontWeight.normal,
                  ),
                ):const SizedBox.shrink(),
              ],
            ).withOnTap(onTap: () {
              widget.onTap?.call();
              if (widget.routesName != null) {
                Get.toNamed(widget.routesName!);
                return;
              }
              if (widget.title == '更多') {
                scalePoint(context);
              }
            }),
          ),
        ));
  }

void scalePoint(BuildContext context) {
  SmartDialog.showAttach(
    targetContext: context,
    targetBuilder: (targetOffset, targetSize) {
      return Offset(targetOffset.dx,
          targetOffset.dy - 10.w);
    },
    maskColor: Colors.transparent,
    alignment: Alignment.bottomCenter,
    animationType: SmartAnimationType.scale,
    builder: (_) {
      return SizedBox(
        width:  120.w,
        child: Stack(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 15,right: 10),
            width:  120.w,
            decoration:  BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w), // 圆角（可选）
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // 阴影颜色
                  spreadRadius: 0, // 阴影扩散范围
                  blurRadius: 5, // 阴影模糊程度
                  offset: Offset(1, 1), // 阴影偏移量 (x, y)
                ),
              ],
            ),
            alignment: Alignment.center,
            child:
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 7.w,),
                        Image(
                          image: 'xiaoxi'.png3x,
                          width: 16.w,
                          height: 16.w,
                          color: Colors.black,
                        ).withPadding(
                          left: 0.w,
                          right: 8.w,
                        ),
                        SizedBox(width: 8.w,),
                        BaseText(
                          text: '消息',
                          color: Colors.black,
                        )
                      ],
                    )
                        .withContainer(
                        height: 45.w, alignment: Alignment.centerLeft)
                        .withOnTap(onTap: () {
                      SmartDialog.dismiss();
                      widget.onTapItem?.call('消息');
                      //TODO: 跳转消息
                    }),
                    Container(
                      width: 80.w,
                      height: 0.5.w,
                      color: Color(0xffdedede),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 7.w,),
                        Image(
                          image: 'kefu'.png3x,
                          width: 16.w,
                          height: 16.w,
                          color: Colors.black,
                        ).withPadding(
                          left: 0.w,
                          right: 8.w,
                        ),
                        SizedBox(width: 8.w,),
                        BaseText(
                          text: '客服',
                          color: Colors.black,
                        )
                      ],
                    )
                        .withContainer(
                        height: 45.w, alignment: Alignment.centerLeft)
                        .withOnTap(onTap: () {
                      SmartDialog.dismiss();
                      widget.onTapItem?.call('客服');
                      //TODO: 跳转消息
                    }),

                    Container(
                      width: 80.w,
                      height: 0.5.w,
                      color: Color(0xffdedede),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 7.w,),
                        Image(
                          image: 'banben'.png3x,
                          width: 16.w,
                          height: 16.w,
                          color: Colors.black,
                        ).withPadding(
                          left: 2.w,
                          right: 8.w,
                        ),
                        SizedBox(width: 8.w,),
                        BaseText(
                          text: '版本',
                          color: Colors.black,
                        ),
                      ],
                    ).withContainer(
                        height: 45.w, alignment: Alignment.centerLeft),
                  ],
                ).withPadding(left: 10.w).withOnTap(onTap: () {
                  SmartDialog.dismiss();
                  widget.onTapItem?.call('版本');
                  //TODO: 跳转版本
                }),
          ),
        ]),
      );
    },
  );
}
}
