import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'boc_logic.dart';

class AccountCityBuilder extends StatelessWidget {
  const AccountCityBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, String city) builder;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BocLogic>()) {
      return builder(context, '--');
    }

    return GetBuilder<BocLogic>(
      id: 'updateUI',
      builder: (logic) {
        final city = logic.memberInfo.city.trim();
        return builder(context, city.isEmpty ? '--' : city);
      },
    );
  }
}
