import 'package:flutter/material.dart';

import '../account_transfer/home_account_transfer_view.dart';

// 手机号转账页
// 说明：当前页面是无接口的原生表单，参考截图仅用于校准导航、卡片、输入框和滚动状态。
class HomePhoneTransferPage extends StatelessWidget {
  const HomePhoneTransferPage({
    super.key,
    this.onNext,
  });

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return HomeAccountTransferPage(
      pageKind: TransferPageKind.phone,
      onPhoneNext: onNext,
    );
  }
}
