import 'package:get/get.dart';

import 'print_confim_state.dart';

class PrintConfimLogic extends GetxController {
  final PrintConfimState state = PrintConfimState();

  final showFullAccount = true.obs;
  final showCertificate = false.obs;
  final showLocation = true.obs;
  final showBalance = true.obs;
  final showOppositeAccount = false.obs;

  bool get isEmailValid {
    final email = state.emailController.text.trim();
    return RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(email);
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }
}
