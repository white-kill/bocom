import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/state_less_widget.dart';

import 'tips_page_logic.dart';
import 'tips_page_state.dart';

class TipsPagePage extends BaseStateless {
  TipsPagePage({Key? key}) : super(key: key,title: Get.arguments?['title'] ?? '无title参数');

  final TipsPageLogic logic = Get.put(TipsPageLogic());
  final TipsPageState state = Get.find<TipsPageLogic>().state;


  @override
  Color? get background => Colors.white;

  @override
  Widget initBody(BuildContext context) {
    return Container();
  }
}
