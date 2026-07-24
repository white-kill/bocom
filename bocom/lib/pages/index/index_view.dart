import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index_logic.dart';
import 'index_state.dart';

class IndexPage extends StatelessWidget {
  IndexPage({Key? key}) : super(key: key);

  final IndexLogic logic = Get.put(IndexLogic());
  final IndexState state = Get.find<IndexLogic>().state;

  @override
  Widget build(BuildContext context) {

    return GetBuilder(builder: (IndexLogic c) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F5),
        body: IndexedStack(
          index: logic.taBarIdx.value,
          children: state.pageList,
        ),
        bottomNavigationBar: c.showTabBar?logic.navigationBar():null,
      );
    },id: 'updateTabBar',);
  }
}
