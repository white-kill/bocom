import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

import '../routes/app_pages.dart';

class ScalePointWidget extends StatefulWidget {
  final double? width;
  final double? left;
  final double? dx;
  final double? dy;
  final Widget? content;
  final Color icColor;
  final double icSize;
  final String? text;
  final String? image;
  final ChangeScalePointController? controller;

  const ScalePointWidget({
    super.key,
    this.width,
    this.left,
    this.content,
    this.controller,
    this.icColor = Colors.black,
    this.icSize = 24,
    this.dx,
    this.dy,
    this.text,
    this.image,
  });

  @override
  State<ScalePointWidget> createState() => _ScalePointWidgetState();
}

class _ScalePointWidgetState extends State<ScalePointWidget> {
  Color color1 = Colors.white;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onController);
  }

  _onController() {
    if (mounted) {
      if (widget.controller?.type == "changeColor") {
        color1 = widget.controller!.newColor;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => scalePoint(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: widget.image == null
                    ? 'right_more'.png3x
                    : (widget.image ?? '').png3x,
                width: widget.icSize.w,
                height: widget.icSize.w,
                color: widget.icColor,
              ),
              widget.text == null
                  ? const SizedBox.shrink()
                  : BaseText(text: widget.text ?? '')
            ],
          ),
        ),
      );
    });
  }

  void scalePoint(BuildContext context) {
    SmartDialog.showAttach(
      targetContext: context,
      targetBuilder: (targetOffset, targetSize) {
        return Offset(targetOffset.dx - (widget.dx ?? 0),
            targetOffset.dy - (widget.dy ?? 0));
      },
      alignment: Alignment.bottomCenter,
      animationType: SmartAnimationType.scale,
      builder: (_) {
        return SizedBox(
          width: widget.width ?? 100.w,
          child: Stack(children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: widget.left ?? 50.w),
              child: Container(
                width: 14.w,
                height: 14.w,
                color: Colors.white,
                transform: Matrix4.rotationZ(pi / 4),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 7),
              width: widget.width ?? 150.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              alignment: Alignment.center,
              child: widget.content ??
                  Column(
                    children: [
                      Row(
                        children: [
                          Image(
                            image: 'ic_nav_scan'.png3x,
                            width: 24.w,
                            height: 24.w,
                          ).withPadding(
                            left: 2.w,
                            right: 8.w,
                          ),
                          BaseText(
                            text: '扫一扫',
                            color: Colors.black,
                          ),
                        ],
                      ).withContainer(
                        onTap: () {
                          SmartDialog.dismiss();
                        },
                        height: 39.w,
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        width: 110.w,
                        height: 0.5.w,
                        color: Color(0xffdedede),
                      ),
                      Row(
                        children: [
                          Image(
                            image: 'ic_fhome_1_1'.png3x,
                            width: 24.w,
                            height: 24.w,
                          ).withPadding(
                            left: 2.w,
                            right: 8.w,
                          ),
                          BaseText(
                            text: '收款',
                            color: Colors.black,
                          ),
                        ],
                      ).withContainer(
                        onTap: () {
                          SmartDialog.dismiss();
                        },
                        height: 39.w,
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        width: 110.w,
                        height: 0.5.w,
                        color: Color(0xffdedede),
                      ),
                      Row(
                        children: [
                          Image(
                            image: 'ic_fk'.png3x,
                            width: 24.w,
                            height: 24.w,
                          ).withPadding(
                            left: 2.w,
                            right: 8.w,
                          ),
                          BaseText(
                            text: '付款',
                            color: Colors.black,
                          ),
                        ],
                      ).withContainer(
                        onTap: () {
                          SmartDialog.dismiss();
                        },
                        height: 39.w,
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        width: 110.w,
                        height: 0.5.w,
                        color: Color(0xffdedede),
                      ),
                      Row(
                        children: [
                          Image(
                            image: 'ic_bbqh'.png3x,
                            width: 24.w,
                            height: 24.w,
                          ).withPadding(
                            left: 2.w,
                            right: 8.w,
                          ),
                          BaseText(
                            text: '版本切换',
                            color: Colors.black,
                          ),
                        ],
                      ).withContainer(
                          height: 39.w, alignment: Alignment.centerLeft),
                    ],
                  ).withPadding(left: 10.w).withOnTap(onTap: () {
                    SmartDialog.dismiss();

                  }),
            ),
          ]),
        );
      },
    );
  }
}

class ChangeScalePointController extends ChangeNotifier {
  String type = '';
  Color newColor = Colors.black;

  upDataColor(Color color) {
    type = 'changeColor';
    newColor = color;
    notifyListeners();
  }
}
