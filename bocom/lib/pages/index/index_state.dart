
import 'package:flutter/cupertino.dart';

import '../tabs/life/life_view.dart';
import '../tabs/home/home_view.dart';
import '../tabs/community/community_view.dart';
import '../tabs/mine/mine_view.dart';
import '../tabs/‌finance‌/‌finance‌_view.dart';


class IndexState {


  /// 页面放到数组中
  /// EssencePageWidget
  /// InheritedWidgetTestContainer
  late List<Widget> pageList;


  ///appTabList
  late List<Map> appBarList;


  /// item
  late List<BottomNavigationBarItem>  item;


  IndexState() {
    ///Initialize variables

    pageList = [
      HomePage(),
      FinancePage(),
      LifePage(),
      CommunityPage(),
      MinePage(),
    ];


    appBarList = const [
      {"title":"首页", "icon":"tabbar",'index':0,'selectColor':0xFF008CFF},
      {"title":"金融", "icon":"tabbar",'index':1,'selectColor':0xFF008CFF},
      {"title":"生活", "icon":"tabbar",'index':2,'selectColor':0xFF008CFF},
      {"title":"社区", "icon":"tabbar",'index':3,'selectColor':0xFF008CFF},
      {"title":"我的", "icon":"tabbar",'index':4,'selectColor':0xFF008CFF},
    ];


  }
}
