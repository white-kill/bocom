import 'package:get/get.dart';

import 'ledger_state.dart';

class LedgerLogic extends GetxController {
  final LedgerState state = LedgerState();

  final ledgerTypeList = [
    {'name': '总账本', 'image': 'ledger_type_1', 'selectImage': 'ledger_type_1_select', 'smallImage': 'ledger_type_1_small'},
    {'name': '投资账本', 'image': 'ledger_type_2', 'selectImage': 'ledger_type_2_select', 'smallImage': 'ledger_type_2_small'},
    {'name': '消费账本', 'image': 'ledger_type_3', 'selectImage': 'ledger_type_3_select', 'smallImage': 'ledger_type_3_small'},
    {'name': '薪资账本', 'image': 'ledger_type_4', 'selectImage': 'ledger_type_4_select', 'smallImage': 'ledger_type_4_small'},
  ];

  final ledgerType = 0.obs;
  final ledgerTypeExpanded = false.obs;
  final ledgerTab = 0.obs;

  void toggleLedgerType() {
    ledgerTypeExpanded.toggle();
  }

  void selectLedgerType(int index) {
    ledgerType.value = index;
    ledgerTypeExpanded.value = false;
  }

  void selectLedgerTab(int index) {
    ledgerTab.value = index;
  }

  Future<void> refreshLedger() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state.refreshController.resetNoData();
    state.refreshController.refreshCompleted();
  }

  Future<void> loadMoreLedger() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // 接入分页接口后，根据接口返回的 hasMore 分别调用
    // loadComplete() 或 loadNoData()。
    state.refreshController.loadNoData();
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
