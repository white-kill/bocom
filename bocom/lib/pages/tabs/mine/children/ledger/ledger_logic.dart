import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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
  final periodMode = 0.obs;
  final selectedPeriod = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final periodPickerVisible = false.obs;
  // 0: 收起，1: 日期，2: 账户，3: 金额筛选
  final waterFilterExpanded = 0.obs;
  final waterLastFilter = 1.obs;
  final waterPeriodLabel = ''.obs;
  final waterAccount = '全部账户'.obs;
  final waterAmountFilter = ''.obs;
  final waterMinAmount = ''.obs;
  final waterMaxAmount = ''.obs;
  final waterAmountInputVersion = 0.obs;

  void toggleLedgerType() {
    waterFilterExpanded.value = 0;
    ledgerTypeExpanded.toggle();
  }

  void selectLedgerType(int index) {
    ledgerType.value = index;
    ledgerTypeExpanded.value = false;
  }

  void selectLedgerTab(int index) {
    waterFilterExpanded.value = 0;
    ledgerTab.value = index;
  }

  void toggleWaterFilter(int index) {
    ledgerTypeExpanded.value = false;
    waterLastFilter.value = index;
    waterFilterExpanded.value = waterFilterExpanded.value == index ? 0 : index;
  }

  void closeWaterFilter() => waterFilterExpanded.value = 0;

  void selectWaterPeriod(String label) {
    waterPeriodLabel.value = label;
    closeWaterFilter();
  }

  void selectWaterAccount(String account) {
    waterAccount.value = account;
    closeWaterFilter();
  }

  void selectWaterAmount(String amount) {
    waterAmountFilter.value = amount;
  }

  void resetWaterAmount() {
    waterAmountFilter.value = '';
    waterMinAmount.value = '';
    waterMaxAmount.value = '';
    waterAmountInputVersion.value++;
  }

  void selectPeriodMode(int index) {
    periodMode.value = index;
  }

  void selectPeriod({required int year, required int month}) {
    waterPeriodLabel.value = '';
    selectedPeriod.value = DateTime(year, month);
  }

  Future<void> refreshLedger(RefreshController refreshController) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    refreshController.resetNoData();
    refreshController.refreshCompleted();
  }

  Future<void> loadMoreLedger(RefreshController refreshController) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // 接入分页接口后，根据接口返回的 hasMore 分别调用
    // loadComplete() 或 loadNoData()。
    refreshController.loadNoData();
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
