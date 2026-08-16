import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ledger_edit_state.dart';

class LedgerEditLogic extends GetxController {
  final LedgerEditState state = LedgerEditState();

  final amountController = TextEditingController();
  final remarkController = TextEditingController();
  final amountFocusNode = FocusNode();
  final remarkFocusNode = FocusNode();

  static const List<String> imageNames = [
    'bg_ledger_edit_1',
    'bg_ledger_edit_2',
  ];

  @override
  void onInit() {
    super.onInit();
    amountController.addListener(_updateInput);
    remarkController.addListener(_updateInput);
    amountFocusNode.addListener(_updateInput);
    remarkFocusNode.addListener(_updateInput);
  }

  // 输入框嵌套在 id=image 的 GetBuilder 中，焦点或文本变化时外层也要
  // 一并刷新，否则 focused/hasText 会一直使用首次构建时的旧值。
  void _updateInput() => update(['image', 'input']);

  void clearAmount() => amountController.clear();

  void back() {
    Get.back();
  }

  void switchImage(int index) {
    if (state.imageIndex == index) return;
    state.imageIndex = index;
    update(['image']);
  }

  @override
  void onClose() {
    amountController
      ..removeListener(_updateInput)
      ..dispose();
    remarkController
      ..removeListener(_updateInput)
      ..dispose();
    amountFocusNode
      ..removeListener(_updateInput)
      ..dispose();
    remarkFocusNode
      ..removeListener(_updateInput)
      ..dispose();
    super.onClose();
  }
}
