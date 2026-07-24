import 'package:get/get.dart';

import '../../../utils/sp_util.dart';
import 'search_state.dart';

class SearchLogic extends GetxController {
  final SearchState state = SearchState();

  @override
  void onInit() {
    super.onInit();
    state.nameList = searchHistoryValue.split(',');
  }
}
