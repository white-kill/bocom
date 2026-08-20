import 'package:get/get.dart';

import 'print_confim_state.dart';
import 'print_export_repository.dart';

class PrintConfimLogic extends GetxController {
  PrintConfimLogic({
    required Map<String, dynamic> exportParams,
    PrintExportSubmitter? exportSubmitter,
  })  : exportParams = Map.unmodifiable(exportParams),
        _exportSubmitter = exportSubmitter ?? submitPrintExport;

  final PrintConfimState state = PrintConfimState();
  final Map<String, dynamic> exportParams;
  final PrintExportSubmitter _exportSubmitter;

  final showFullAccount = true.obs;
  final showCertificate = false.obs;
  final showLocation = true.obs;
  final showBalance = true.obs;
  final showOppositeAccount = false.obs;
  final submitting = false.obs;

  String get showType {
    final selected = <String>[
      if (showFullAccount.value) '0',
      if (showCertificate.value) '1',
      if (showLocation.value) '2',
      if (showBalance.value) '3',
      if (showOppositeAccount.value) '4',
    ];
    return selected.join(',');
  }

  bool get isEmailValid {
    final email = state.emailController.text.trim();
    return RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(email);
  }

  Future<PrintExportResult> submit() async {
    if (submitting.value) throw StateError('打印申请正在提交');
    submitting.value = true;
    try {
      final params = <String, dynamic>{
        ...exportParams,
        'email': state.emailController.text.trim(),
        'showType': showType,
      };
      return await _exportSubmitter(params);
    } finally {
      submitting.value = false;
    }
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
