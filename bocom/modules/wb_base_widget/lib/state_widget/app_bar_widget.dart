import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../text_widget/bank_text.dart';

class AppBarWidget extends StatefulWidget {
  final Widget? bodyChild;
  final Widget? titleWidget;
  final String? title;
  final Color? navColor;
  final Color? titleColor;
  final Widget? leftItem;
  final List<Widget>? rightAction;
  final Function? backCallBack;
  final double? lefItemWidth;
  final Color? backColor;
  final Color? background;
  final bool? noBackGround;
  final AppBarController? controller;
  final double navHeight;
  final bool? showBackgroundColor;
  final Function(bool change)? onNotificationNavChange;
  final bool centerTitle;
  final bool resizeToAvoidBottomInset;

  const AppBarWidget({
    super.key,
    required this.bodyChild,
    this.titleWidget,
    this.title,
    this.navColor,
    this.leftItem,
    this.rightAction,
    this.backCallBack,
    this.titleColor,
    this.onNotificationNavChange,
    this.lefItemWidth = 0,
    this.backColor,
    this.background,
    this.noBackGround,
    this.controller,
    this.navHeight = 44,
    this.showBackgroundColor,
    this.centerTitle = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  double _scrollDistance = 0.0;

  double percent(double navHeight) {
    double pix = min(_scrollDistance, widget.navHeight.w) /
        (widget.navHeight.w);
    return _scrollDistance > 0.0 ? pix : 0.0;
  }

  bool isBack() =>
      (Get.currentRoute == '/tabs' || Get.currentRoute == '/login');

  bool isChange = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onController);
  }

  bool showTab = true;

  _onController() {
    if (mounted) {
      if (widget.controller?.type == "changeTabTitle") {
        showTab = widget.controller!.showTab;
        setState(() {});
      }
      if (widget.controller?.type == "changeTagTitle") {
        tagIndex = widget.controller!.tagIndex;
        setState(() {});
      }
    }
  }

  int tagIndex = 0;

  @override
  Widget build(BuildContext context) {
    final navHeight = MediaQuery.of(context).padding.top + widget.navHeight.w;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: _scrollDistance < 0 ? min(_scrollDistance, 0) : 0,
            bottom: 0,
            right: 0,
            child: Scaffold(
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
              body: NotificationListener(
                onNotification: (ScrollUpdateNotification scrollNotification) {
                  // if (widget.noBackGround == false) return false;
                  // print(scrollNotification.depth);

                  final ScrollMetrics metrics = scrollNotification.metrics;
                  if (metrics.axis == Axis.horizontal) {
                    return false;
                  } else {
                    if (scrollNotification.depth == 0) {
                      _scrollDistance = scrollNotification.metrics.pixels;
                      if (_scrollDistance > 20 && !isChange) {
                        isChange = true;
                        widget.onNotificationNavChange?.call(true);
                      }
                      if (_scrollDistance < 5 && isChange) {
                        isChange = false;
                        widget.onNotificationNavChange?.call(false);
                      }
                      if (_scrollDistance < 0) return false;
                      setState(() {});
                    }
                    return false;
                  }
                },
                child: Container(
                  color: widget.background ?? const Color(0xFFF5F5F5),
                  width: 1.sw,
                  height: 1.sh,
                  child: widget.bodyChild!,
                ),
              ),
            ),
          ),
          showTab == false
              ? const SizedBox.shrink()
              : SizedBox(
            height: navHeight,
            child: AppBar(
              elevation: 0,
              title: widget.titleWidget ??
                  BaseText(
                    text: widget.title ?? '',
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: widget.titleColor ?? Colors.white,
                        fontWeight: FontWeight.w600
                    ),),
              centerTitle: widget.centerTitle,
              titleSpacing: 0,
              titleTextStyle:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              leadingWidth: widget.lefItemWidth,
              leading: widget.leftItem ??
                  (isBack()
                      ? const SizedBox.shrink()
                      : InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Icon(Icons.navigate_before,
                            size: 30.h, color: widget.backColor),
                      ),
                      onTap: () => widget.backCallBack == null
                          ? _popThis(context)
                          : widget.backCallBack?.call())),
              actions: widget.rightAction,
              systemOverlayStyle: widget.showBackgroundColor == true &&
                  widget.noBackGround == true
                  ? (_scrollDistance > 20
                  ? SystemUiOverlayStyle.dark
                  : SystemUiOverlayStyle.light)
                  : null,
              backgroundColor:widget.showBackgroundColor ==true? (widget.noBackGround == true
                  ? widget.navColor?.withAlpha(
                  (percent(navHeight) * 255).toInt()) ??
                  Colors.white
                      .withAlpha((percent(navHeight) * 255).toInt())
                  : widget.navColor):Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  /// 返回当前页面
  void _popThis(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.of(context).pop();
    }
  }
}

class AppBarController extends ChangeNotifier {
  String type = '';
  bool showTab = true;

  changeTabTitle(bool show) {
    showTab = show;
    type = 'changeTabTitle';
    notifyListeners();
  }

  int tagIndex = 0;
  changeTagTitle(int index) {
    tagIndex = index;
    type = 'changeTagTitle';
    notifyListeners();
  }
}
