import 'package:get/get.dart';

import 'community_state.dart';

class CommunityLogic extends GetxController {
  final CommunityState state = CommunityState();

  final selectedCategoryIndex = 1.obs;

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }
}
