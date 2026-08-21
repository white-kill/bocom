import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/state_widget/widget_comfig.dart';

import '../text_widget/bank_text.dart';
import 'app_bar_widget.dart';

abstract class BaseStateless extends StatelessWidget  with StateWidgetConfig {

  final String? title;
  ///构造函数
  const BaseStateless({super.key, this.title,});

  bool isBack() => (Get.currentRoute == '/tabs'|| Get.currentRoute == '/login');

  ///build
  @override
  Widget build(BuildContext context) {
    return isChangeNav?AppBarWidget(
      bodyChild: initBody(context),
      title: title,
      titleWidget: titleWidget,
      navColor: navColor,
      leftItem: leftItem,
      rightAction: rightAction,
      onNotificationNavChange: onNotificationNavChange,
      lefItemWidth: lefItemWidth,
      backColor: backColor,
      background: background,
      noBackGround: noBackGround1,
      titleColor: titleColor,
      controller: appBarController,
      navHeight: navHeight,
      showBackgroundColor: showBackgroundColor,
      centerTitle: centerTitle,
      resizeToAvoidBottomInset: bottomInset,
      keepBodyPositionOnOverscroll: keepBodyPositionOnOverscroll,
    ):Scaffold(
      resizeToAvoidBottomInset: bottomInset,
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomNav,
      appBar: isShowAppBar == false ? null : PreferredSize(
        preferredSize: Size.fromHeight(navHeight.w), // 设置高度
        child: AppBar(
          title:titleWidget??BaseText(
            text: title??'',
            style: TextStyle(
                fontSize: 18.sp,
                color:  titleColor ?? Colors.black,
                fontWeight: FontWeight.w600
            ),),
          backgroundColor:  navColor ?? Colors.white,
          elevation: 0,
          centerTitle: centerTitle,
          titleSpacing: 0,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.sw),
          leadingWidth:lefItemWidth,
          leading: leftItem??(isBack()?const SizedBox.shrink():InkWell(
              child: Icon(Icons.navigate_before,size: 30.h,color: backColor,),
              onTap: ()  => backCallBack == null ?_popThis(context): backCallBack?.call()
          )),
          actions:rightAction,
        ),
      ),
      body:Container(
        color: background??const Color(0xFFF5F5F5),
        width: 1.sw,
        height: 1.sh,
        child: initBody(context),
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


  Widget refreshWidget({child,RefreshController? controller,Widget? noDataWidget }){
    return SmartRefresher(
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      controller: controller??refreshController!,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("上拉加载更多");
          } else if (mode == LoadStatus.loading) {
            body = const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(radius: 8,),
                SizedBox(width: 6,),
                Text("正在加载...",style: TextStyle(
                    fontSize: 13
                ),),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text("加载失败，点击重试");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("释放加载更多");
          } else {
            body = noDataWidget?? const Text('没有更多数据了',maxLines: 10,);
          }
          return SizedBox(
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
  ///界面构建
  Widget initBody(BuildContext context);


}


