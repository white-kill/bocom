import 'package:flutter/cupertino.dart';

class SearchInfoState {


  List<String> titles = [
    '综合',
    '功能',
    '产品',
    '生活',
    '活动',
    '资讯'
  ];


  TextEditingController searchController = TextEditingController();

  SearchInfoState() {
    ///Initialize variables
  }
}
