import 'package:get/get.dart';

import 'user_info_manage_state.dart';

class UserInfoManageLogic extends GetxController {
  final UserInfoManageState state = UserInfoManageState();

  @override
  void onInit() {
    super.onInit();
  }

  static String maskIdCard(String value) {
    final idCard = value.trim();
    if (idCard.isEmpty) return '--';
    if (idCard.length <= 5) return idCard;

    final stars = List.filled(idCard.length - 5, '*').join();
    final suffix = idCard.substring(idCard.length - 2);
    return '${idCard.substring(0, 3)}$stars$suffix';
  }
}
