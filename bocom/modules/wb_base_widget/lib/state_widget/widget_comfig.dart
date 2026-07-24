import 'package:flutter/material.dart';

import 'app_bar_widget.dart';

typedef BodyWidgetBuilder = Widget Function(BuildContext context);

mixin StateWidgetConfig {

  Function? get backCallBack => null;

  Widget? get titleWidget => null;

  Widget? get bottomNav => null;

  Widget? get leftItem => null;

  double? get lefItemWidth => null;

  double get navHeight => 44;

  List<Widget>? get rightAction => null;

  bool get enablePullUp => true;

  bool get enablePullDown => true;

  Color? get navColor => null;

  Color? get titleColor => null;

  bool get bottomInset => true;

  Color? get background => null;

  Color? get backColor =>  Colors.black;

  bool get isShowAppBar => true;

  bool get isWantKeepAlive => false;

  bool get isChangeNav => false;

  bool get centerTitle => true;

  bool get noBackGround1 => true;

  bool get showBackgroundColor => true;

  Function(bool change)? get onNotificationNavChange => null;

  dynamic get refreshController => null;

  AppBarController? get appBarController => null;


  void onRefresh() {}

  void onLoading() {}

  ///界面进入
  void initDefaultState() {}

  ///界面销毁
  void initDefaultDispose() {}



}