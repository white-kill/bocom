import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/state_widget/app_bar_widget.dart';
import 'package:wb_base_widget/state_widget/widget_comfig.dart';

import '../text_widget/bank_text.dart';

abstract class BaseStateful extends StatefulWidget {
  final String? title;

  const BaseStateful({super.key, this.title = ""});

  @override
  BaseState<BaseStateful> createState();
}

abstract class BaseState<T extends BaseStateful> extends State<T>
    with StateWidgetConfig, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => isWantKeepAlive;

  @override
  void initState() {
    super.initState();
    initDefaultState();
  }

  ///dispose
  @override
  void dispose() {
    super.dispose();
    initDefaultDispose();
  }

  bool isBack() =>
      (Get.currentRoute == '/tabs' || Get.currentRoute == '/login');

  ///build
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isChangeNav
        ? AppBarWidget(
      bodyChild: initBody(context),
      title: widget.title,
      titleWidget: titleWidget,
      navColor: navColor,
      leftItem: leftItem,
      rightAction: rightAction,
      lefItemWidth: lefItemWidth,
      onNotificationNavChange: onNotificationNavChange,
      backColor: backColor,
      background: background,
      noBackGround: noBackGround1,
      titleColor: titleColor,
      controller: appBarController,
      navHeight: navHeight,
      showBackgroundColor: showBackgroundColor,
    )
        : Scaffold(
      resizeToAvoidBottomInset: bottomInset,
      backgroundColor: Colors.white,
      appBar: isShowAppBar == false
          ? null
          : PreferredSize(
        preferredSize: Size.fromHeight(navHeight.w), // 设置高度
        child: AppBar(
          title: titleWidget ??
              BaseText(
                text: widget.title ?? '',
                style: TextStyle(
                    fontSize: 18.sp,
                    color: titleColor ?? Colors.black,
                    fontWeight: FontWeight.w600),
              ),
          backgroundColor: navColor ?? Colors.white,
          elevation: 0,
          centerTitle: true,
          titleSpacing: 0,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18.sw),
          leadingWidth: lefItemWidth,
          leading: leftItem ??
              (isBack()
                  ? const SizedBox.shrink()
                  : InkWell(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: Icon(
                      Icons.navigate_before,
                      size: 30.h,
                      color: backColor,
                    ),
                  ),
                  onTap: () => backCallBack == null
                      ? _popThis(context)
                      : backCallBack?.call())),
          actions: rightAction,
        ),
      ),
      body: Container(
        color: background ?? const Color(0xFFF5F5F5),
        width: 1.sw,
        height: 1.sh,
        child: initBody(context),
      ),
    );
  }

  ///界面构建
  Widget initBody(BuildContext context);

  Widget refreshWidget({child}) {
    return SmartRefresher(
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      controller: refreshController!,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("上拉加载更多");
          } else if (mode == LoadStatus.loading) {
            body = Row(
              children: [
                const CupertinoActivityIndicator(),
                const Text("加载中..."),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text("加载失败，点击重试");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("释放加载更多");
          } else {
            body = const Text("没有更多数据了");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: child,
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
