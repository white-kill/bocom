import 'package:get/get.dart';

import '‌finance‌_state.dart';

class FinanceLogic extends GetxController {
  final FinanceState state = FinanceState();

  final selectedCategoryIndex = 0.obs;

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }
}
