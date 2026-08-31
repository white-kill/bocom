import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/abc_config/boc_logic.dart';
import 'config/app_config.dart';
import 'config/model/member_info_model.dart';
import 'main/app_plugin.dart';
import 'pages/tabs/home/feature_pages/home_static_feature_pages.dart';
import 'pages/tabs/home/home_view.dart';
import 'pages/tabs/mine/children/account_asset/account_secondary_pages.dart';
import 'routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final logic = Get.put<BocLogic>(_DemoBocLogic());
  AppConfig.config.abcLogic = logic;
  logic.memberInfo = _demoMemberInfo();
  runApp(const _SecondaryPagesDemoApp());
}

class _SecondaryPagesDemoApp extends StatelessWidget {
  const _SecondaryPagesDemoApp();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 240),
      getPages: AppPages.routes,
      builder: (context, child) => appBuilder(context, child),
      home: const _SecondaryPagesMenu(),
    );
  }
}

class _SecondaryPagesMenu extends StatelessWidget {
  const _SecondaryPagesMenu();

  static final List<(String, Widget Function())> _pages = [
    ('首页入口点击验收', () => HomePage()),
    ('活动中心', () => const HomeActivityCenterPage()),
    ('城市专区', () => const HomeCityZonePage()),
    ('全部理财产品', () => const HomePreferredProductsPage()),
    ('交行福利季', () => const HomeWelfareSeasonPage()),
    ('一站式授信', () => const HomeOneStopCreditPage()),
    ('养老专区', () => const HomePensionZonePage()),
    ('交薪通专区', () => const HomeSalaryZonePage()),
    ('领券中心', () => const HomeCouponCenterPage()),
    ('资金转入', () => const AccountFundsTransferPage()),
    ('所属网点弹窗', () => const _OutletDialogDemoPage()),
    ('银行卡挂失', () => const AccountLossPage()),
    ('更多功能', () => const AccountMoreFunctionsPage()),
    ('申请账户', () => const AccountApplicationPage()),
    ('激活银行卡', () => const AccountActivationPage()),
    ('账户解绑', () => const AccountUnbindPage()),
    ('账户排序', () => const AccountSortPage()),
    ('安心付Pro', () => const AccountFamilyPayPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页二级页验收')),
      body: ListView.separated(
        itemCount: _pages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) => ListTile(
          key: ValueKey('secondary-page-$index'),
          title: Text(_pages[index].$1),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.to(_pages[index].$2),
        ),
      ),
    );
  }
}

class _OutletDialogDemoPage extends StatefulWidget {
  const _OutletDialogDemoPage();

  @override
  State<_OutletDialogDemoPage> createState() => _OutletDialogDemoPageState();
}

class _OutletDialogDemoPageState extends State<_OutletDialogDemoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showAccountOutletDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('所属网点')),
      body: Center(
        child: FilledButton(
          onPressed: () => showAccountOutletDialog(context),
          child: const Text('查看所属网点'),
        ),
      ),
    );
  }
}

MemberInfoModel _demoMemberInfo() {
  final bank = MemberInfoBankList()
    ..bankName = '交通银行'
    ..bankCard = '6222601234568431'
    ..realName = '李晓明'
    ..openOutlets = '合肥长江中路支行';
  return MemberInfoModel()
    ..realName = '李晓明'
    ..phone = '13866665555'
    ..city = '合肥'
    ..bankId = '301290000123'
    ..branchBelongs = '合肥长江中路支行'
    ..bankList = [bank];
}

class _DemoBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
