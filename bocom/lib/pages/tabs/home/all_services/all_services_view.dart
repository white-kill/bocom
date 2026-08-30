import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../mine/children/account_asset/account_asset_view.dart';
import '../../mine/children/profit_center/profit_center_view.dart';
import '../../mine/children/user_info_manage/user_info_manage_view.dart';
import '../transfer/account_transfer/account_transfer_support_pages.dart';

// 全部服务页
// 说明：服务内容使用分类切图，导航、分类联动和已实现服务的跳转热区由 Flutter 绘制。
class AllServicesPage extends StatefulWidget {
  const AllServicesPage({super.key});

  @override
  State<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends State<AllServicesPage> {
  static const double _sourceWidth = 1080;
  static const double _contentSourceWidth = 808;
  static const double _menuSourceWidth = 272;
  static const double _menuItemSourceHeight = 142;
  static const double _menuContentOffsetSource = 16;
  static const double _serviceGridTop = 76;
  static const double _serviceRowExtent = 210;

  static const List<_ServiceSection> _sections = [
    _ServiceSection(
      id: 'recent',
      title: '最近使用',
      assets: ['assets/images/all_services/recent.png'],
      sourceHeights: [671],
      hotspots: [
        _ServiceHotspot('转账', 0, 0, _ServiceDestination.transfer),
        _ServiceHotspot('账户/资产', 0, 1, _ServiceDestination.accountAsset),
        _ServiceHotspot('收支账本', 0, 2, _ServiceDestination.ledger),
        _ServiceHotspot(
          '交易明细',
          1,
          0,
          _ServiceDestination.transactionDetail,
        ),
        _ServiceHotspot('账单', 1, 1, _ServiceDestination.bill),
        _ServiceHotspot('存款', 1, 2, _ServiceDestination.deposit),
      ],
    ),
    _ServiceSection(
      id: 'query',
      title: '查询',
      assets: ['assets/images/all_services/query.png'],
      sourceHeights: [1034],
      hotspots: [
        _ServiceHotspot('账户/资产', 0, 0, _ServiceDestination.accountAsset),
        _ServiceHotspot(
          '交易明细',
          0,
          1,
          _ServiceDestination.transactionDetail,
        ),
        _ServiceHotspot('收支账本', 0, 2, _ServiceDestination.ledger),
        _ServiceHotspot('账单', 1, 0, _ServiceDestination.bill),
        _ServiceHotspot('收益中心', 1, 1, _ServiceDestination.profitCenter),
        _ServiceHotspot('安心付Pro', 3, 1, _ServiceDestination.familyPay),
      ],
    ),
    _ServiceSection(
      id: 'account-management',
      title: '账户管理',
      assets: ['assets/images/all_services/account_management.png'],
      sourceHeights: [394],
      hotspots: [
        _ServiceHotspot(
          '账户申请',
          0,
          0,
          _ServiceDestination.accountApplication,
        ),
        _ServiceHotspot(
          '卡片激活',
          0,
          2,
          _ServiceDestination.accountActivation,
        ),
      ],
    ),
    _ServiceSection(
      id: 'transfer',
      title: '转账',
      assets: ['assets/images/all_services/transfer.png'],
      sourceHeights: [822],
      hotspots: [
        _ServiceHotspot('转账', 0, 0, _ServiceDestination.transfer),
        _ServiceHotspot('账号转账', 0, 1, _ServiceDestination.accountTransfer),
        _ServiceHotspot('手机号转账', 0, 2, _ServiceDestination.phoneTransfer),
        _ServiceHotspot(
          '单笔资金转入',
          1,
          1,
          _ServiceDestination.fundsTransfer,
        ),
        _ServiceHotspot('全部收款人', 2, 0, _ServiceDestination.recipients),
        _ServiceHotspot('转账记录', 2, 1, _ServiceDestination.transferRecord),
      ],
    ),
    _ServiceSection(
      id: 'payment',
      title: '支付',
      assets: ['assets/images/all_services/payment.png'],
      sourceHeights: [823],
      hotspots: [
        _ServiceHotspot('扫一扫', 0, 1, _ServiceDestination.scan),
        _ServiceHotspot('付款码', 0, 2, _ServiceDestination.paymentCode),
      ],
    ),
    _ServiceSection(
      id: 'investment',
      title: '投资理财',
      assets: ['assets/images/all_services/investment.png'],
      sourceHeights: [1876],
      hotspots: [
        _ServiceHotspot('理财', 0, 1, _ServiceDestination.preferredProducts),
        _ServiceHotspot('存款', 1, 0, _ServiceDestination.deposit),
        _ServiceHotspot('活期盈', 2, 0, _ServiceDestination.demandDepositPlus),
        _ServiceHotspot('交薪通', 7, 1, _ServiceDestination.salaryZone),
      ],
    ),
    _ServiceSection(
      id: 'loan',
      title: '贷款',
      assets: ['assets/images/all_services/loan.png'],
      sourceHeights: [1670],
      hotspots: [
        _ServiceHotspot('惠民贷', 2, 0, _ServiceDestination.consumerLoan),
        _ServiceHotspot(
          '综合授信',
          4,
          2,
          _ServiceDestination.oneStopCredit,
        ),
      ],
    ),
    _ServiceSection(
      id: 'credit-card',
      title: '信用卡',
      assets: ['assets/images/all_services/credit_card.png'],
      sourceHeights: [1242],
      hotspots: [
        _ServiceHotspot('信用卡', 0, 0, _ServiceDestination.creditCard),
      ],
    ),
    _ServiceSection(
      id: 'cross-border',
      title: '跨境金融',
      assets: ['assets/images/all_services/cross_border.png'],
      sourceHeights: [1035],
    ),
    _ServiceSection(
      id: 'pension',
      title: '养老金融',
      assets: ['assets/images/all_services/pension.png'],
      sourceHeights: [395],
      hotspots: [
        _ServiceHotspot('养老专区', 0, 0, _ServiceDestination.pensionZone),
      ],
    ),
    _ServiceSection(
      id: 'cloud-bank',
      title: '云上交行',
      assets: ['assets/images/all_services/outlet_1.png'],
      sourceHeights: [403],
    ),
    _ServiceSection(
      id: 'outlet',
      title: '网点服务',
      assets: ['assets/images/all_services/outlet_2.png'],
      sourceHeights: [818],
    ),
    _ServiceSection(
      id: 'life',
      title: '生活服务',
      assets: [
        'assets/images/all_services/life_1.png',
        'assets/images/all_services/life_2.png',
      ],
      sourceHeights: [1316, 1630],
    ),
    _ServiceSection(
      id: 'benefits',
      title: '活动权益',
      assets: ['assets/images/all_services/benefits.png'],
      sourceHeights: [819],
      hotspots: [
        _ServiceHotspot('活动中心', 0, 0, _ServiceDestination.activityCenter),
        _ServiceHotspot('交行福利季', 0, 1, _ServiceDestination.welfareSeason),
        _ServiceHotspot('城市专区', 1, 0, _ServiceDestination.cityZone),
        _ServiceHotspot('领券中心', 1, 1, _ServiceDestination.couponCenter),
      ],
    ),
    _ServiceSection(
      id: 'premium',
      title: '高端服务',
      assets: ['assets/images/all_services/premium.png'],
      sourceHeights: [615],
    ),
    _ServiceSection(
      id: 'tools',
      title: '工具',
      assets: ['assets/images/all_services/tools.png'],
      sourceHeights: [1932],
      hotspots: [
        _ServiceHotspot('个人信息', 0, 1, _ServiceDestination.personalInfo),
        _ServiceHotspot('我的安全', 0, 2, _ServiceDestination.security),
        _ServiceHotspot('资讯', 3, 0, _ServiceDestination.news),
      ],
    ),
  ];

  final ScrollController _menuController = ScrollController();
  final ScrollController _contentController = ScrollController();
  int _selectedIndex = 0;
  int? _programmaticTarget;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_handleContentScroll);
  }

  @override
  void dispose() {
    _contentController
      ..removeListener(_handleContentScroll)
      ..dispose();
    _menuController.dispose();
    super.dispose();
  }

  void _handleContentScroll() {
    if (_programmaticTarget != null || !_contentController.hasClients) return;

    final position = _contentController.position;
    if (position.extentAfter <= 1) {
      _selectMenu(_sections.length - 1);
      return;
    }

    final offset = _contentController.offset + 1;
    var index = 0;
    var sectionStart = 0.0;
    for (var i = 1; i < _sections.length; i++) {
      sectionStart += _sections[i - 1].sourceHeight * _scale;
      if (offset < sectionStart) break;
      index = i;
    }
    _selectMenu(index);
  }

  void _selectMenu(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealMenuItem(index);
    });
  }

  void _revealMenuItem(int index) {
    if (!_menuController.hasClients) return;

    final itemExtent = _menuItemSourceHeight * _scale;
    final itemTop = index * itemExtent;
    final itemBottom = itemTop + itemExtent;
    final position = _menuController.position;
    var target = position.pixels;
    if (itemTop < position.pixels) {
      target = itemTop;
    } else if (itemBottom > position.pixels + position.viewportDimension) {
      target = itemBottom - position.viewportDimension;
    }
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < 0.5) return;
    _menuController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollToSection(int index) async {
    if (!_contentController.hasClients) return;

    var target = 0.0;
    for (var i = 0; i < index; i++) {
      target += _sections[i].sourceHeight * _scale;
    }
    target = target.clamp(
      _contentController.position.minScrollExtent,
      _contentController.position.maxScrollExtent,
    );

    _programmaticTarget = index;
    _selectMenu(index);
    try {
      await _contentController.animateTo(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _programmaticTarget = null;
      if (mounted) _handleContentScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (_, constraints) {
              _scale = constraints.maxWidth / _sourceWidth;
              return Column(
                children: [
                  _AllServicesNavigationBar(
                    onBack: Get.back,
                    onSearch: () => Get.toNamed(Routes.search),
                    onCustomerService: () =>
                        Get.toNamed(Routes.customerService),
                  ),
                  Image.asset(
                    'assets/images/all_services/header.png',
                    key: const Key('all-services-common-header'),
                    width: constraints.maxWidth,
                    fit: BoxFit.fitWidth,
                    gaplessPlayback: true,
                  ),
                  Container(height: 1, color: const Color(0xFFF3F3F3)),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: _menuSourceWidth * _scale,
                          child: _buildMenu(),
                        ),
                        Expanded(child: _buildContent()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFF1F1F1), width: 1),
        ),
      ),
      child: ListView.builder(
        key: const Key('all-services-menu'),
        controller: _menuController,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemExtent: _menuItemSourceHeight * _scale,
        itemCount: _sections.length,
        itemBuilder: (_, index) {
          final section = _sections[index];
          final selected = index == _selectedIndex;
          return Semantics(
            button: true,
            selected: selected,
            label: section.title,
            child: GestureDetector(
              key: Key('all-services-menu-${section.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _scrollToSection(index),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(left: 42 * _scale),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            _menuContentOffsetSource * _scale,
                          ),
                          child: Text(
                            section.title,
                            maxLines: 1,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF0878F9)
                                  : const Color(0xFF595959),
                              fontSize: (selected ? 47 : 44) * _scale,
                              fontWeight:
                                  selected ? FontWeight.w500 : FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      right: 0,
                      top: (_menuItemSourceHeight - 47) * _scale / 2 +
                          _menuContentOffsetSource * _scale,
                      width: 8 * _scale,
                      height: 47 * _scale,
                      child: Image.asset(
                        'assets/images/all_services/selection_indicator.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return ListView.builder(
      key: const Key('all-services-content'),
      controller: _contentController,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemCount: _sections.length,
      itemBuilder: (_, index) {
        final section = _sections[index];
        return SizedBox(
          key: Key('all-services-section-${section.id}'),
          width: _contentSourceWidth * _scale,
          height: section.sourceHeight * _scale,
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    for (var assetIndex = 0;
                        assetIndex < section.assets.length;
                        assetIndex++)
                      Image.asset(
                        section.assets[assetIndex],
                        width: _contentSourceWidth * _scale,
                        height: section.sourceHeights[assetIndex] * _scale,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                  ],
                ),
              ),
              for (final hotspot in section.hotspots)
                _buildServiceHotspot(section, hotspot),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceHotspot(
    _ServiceSection section,
    _ServiceHotspot hotspot,
  ) {
    const columnWidth = _contentSourceWidth / 3;
    return Positioned(
      key: Key('all-services-service-${section.id}-${hotspot.label}'),
      left: hotspot.column * columnWidth * _scale,
      top: (_serviceGridTop + hotspot.row * _serviceRowExtent) * _scale,
      width: columnWidth * _scale,
      height: _serviceRowExtent * _scale,
      child: Semantics(
        button: true,
        label: hotspot.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openService(hotspot.destination),
        ),
      ),
    );
  }

  void _openService(_ServiceDestination destination) {
    switch (destination) {
      case _ServiceDestination.accountAsset:
        Get.to<void>(() => AccountAssetPage(initialTabIndex: 1));
      case _ServiceDestination.profitCenter:
        Get.to<void>(() => ProfitCenterPage());
      case _ServiceDestination.recipients:
        Get.to<void>(() => const AccountTransferRecipientsPage());
      case _ServiceDestination.personalInfo:
        Get.to<void>(() => UserInfoManagePage());
      default:
        Get.toNamed<void>(destination.routeName!);
    }
  }
}

class _AllServicesNavigationBar extends StatelessWidget {
  const _AllServicesNavigationBar({
    required this.onBack,
    required this.onSearch,
    required this.onCustomerService,
  });

  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onCustomerService;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              '全部服务',
              style: TextStyle(
                color: Color(0xFF292929),
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 5,
            top: 0,
            bottom: 0,
            child: _NavigationButton(
              semanticsLabel: '返回',
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 25,
                color: Color(0xFF181818),
              ),
            ),
          ),
          Positioned(
            right: 48,
            top: 0,
            bottom: 0,
            child: _NavigationButton(
              semanticsLabel: '搜索',
              onTap: onSearch,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFF151515),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/home_nav_search_dark.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            right: 3,
            top: 0,
            bottom: 0,
            child: _NavigationButton(
              semanticsLabel: '客服',
              onTap: onCustomerService,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFF151515),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/home_nav_service_dark.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.semanticsLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticsLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(width: 44, child: Center(child: child)),
      ),
    );
  }
}

class _ServiceSection {
  const _ServiceSection({
    required this.id,
    required this.title,
    required this.assets,
    required this.sourceHeights,
    this.hotspots = const [],
  });

  final String id;
  final String title;
  final List<String> assets;
  final List<double> sourceHeights;
  final List<_ServiceHotspot> hotspots;

  double get sourceHeight =>
      sourceHeights.fold(0, (total, height) => total + height);
}

class _ServiceHotspot {
  const _ServiceHotspot(
    this.label,
    this.row,
    this.column,
    this.destination,
  );

  final String label;
  final int row;
  final int column;
  final _ServiceDestination destination;
}

enum _ServiceDestination {
  transfer(Routes.homeTransfer),
  accountAsset(),
  ledger(Routes.ledgerPage),
  transactionDetail(Routes.transactionDetail),
  bill(Routes.comprehensiveBillPage),
  deposit(Routes.homeDeposit),
  profitCenter(),
  familyPay(Routes.accountFamilyPay),
  accountApplication(Routes.accountApplication),
  accountActivation(Routes.accountActivation),
  accountTransfer(Routes.homeAccountTransfer),
  phoneTransfer(Routes.homePhoneTransfer),
  fundsTransfer(Routes.accountFundsTransfer),
  recipients(),
  transferRecord(Routes.homeTransferRecord),
  scan(Routes.scan),
  paymentCode(Routes.homePaymentCode),
  preferredProducts(Routes.homePreferredProducts),
  demandDepositPlus(Routes.homeDemandDepositPlus),
  salaryZone(Routes.homeSalaryZone),
  consumerLoan(Routes.homeConsumerLoan),
  oneStopCredit(Routes.homeOneStopCredit),
  creditCard(Routes.homeCreditCard),
  pensionZone(Routes.homePensionZone),
  activityCenter(Routes.homeActivityCenter),
  welfareSeason(Routes.homeWelfareSeason),
  cityZone(Routes.homeCityZone),
  couponCenter(Routes.homeCouponCenter),
  personalInfo(),
  security(Routes.homeSecurity),
  news(Routes.homeNews);

  const _ServiceDestination([this.routeName]);

  final String? routeName;
}
