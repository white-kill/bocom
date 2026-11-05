import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

import '../../../../routes/app_pages.dart';
import 'account_transfer/home_account_transfer_view.dart';
import 'account_transfer/account_transfer_support_pages.dart';

// 转账页
// 说明：当前页面使用裁掉系统状态栏、保留页面导航栏的参考图；常用收款人示例已覆盖并改为接口数据。
class HomeTransferPage extends BaseStateless {
  const HomeTransferPage({
    super.key,
    this.contactsLoader,
  }) : super(title: '转账');

  static const double _sourceWidth = 1206;
  static const double _sourceHeight = 2445;
  static const String _assetPath = 'assets/images/home_transfer_page.png';

  final Future<List<ContactsModel>> Function()? contactsLoader;

  @override
  bool get isChangeNav => true;

  @override
  Color? get navColor => const Color(0xFFF8F8F8);

  @override
  Color? get background => const Color(0xFFF8F8F8);

  @override
  Color? get titleColor => const Color(0xFF181818);

  @override
  double? get lefItemWidth => 56.w;

  @override
  Widget? get leftItem => Row(
        children: [
          SizedBox(width: 15.w),
          Semantics(
            button: true,
            label: '返回',
            child: SizedBox(
              width: 30.w,
              height: 30.w,
              child: Center(
                child: Image(
                  image: 'nav_back_light_white'.png,
                  width: 29.5.w,
                  height: 29.5.w,
                  fit: BoxFit.contain,
                ),
              ),
            ).withOnTap(onTap: () => Get.back()),
          ),
        ],
      );

  @override
  List<Widget>? get rightAction => [
        Semantics(
          button: true,
          label: '客服',
          child: SizedBox(
            width: 30.w,
            height: 30.w,
            child: Center(
              child: Image(
                image: 'nav_kf_light_white'.png,
                width: 29.w,
                height: 29.w,
                fit: BoxFit.contain,
              ),
            ),
          ).withOnTap(onTap: () => Get.toNamed(Routes.customerService)),
        ),
        SizedBox(width: 15.w),
      ];

  @override
  Widget initBody(BuildContext context) {
    return _HomeTransferBody(
      contactsLoader: contactsLoader,
      topInset: MediaQuery.paddingOf(context).top + navHeight.w,
    );
  }
}

class _HomeTransferBody extends StatefulWidget {
  const _HomeTransferBody({
    this.contactsLoader,
    required this.topInset,
  });

  final Future<List<ContactsModel>> Function()? contactsLoader;
  final double topInset;

  @override
  State<_HomeTransferBody> createState() => _HomeTransferBodyState();
}

class _HomeTransferBodyState extends State<_HomeTransferBody> {
  List<ContactsModel> _contacts = const [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final contacts =
          await (widget.contactsLoader?.call() ?? _fetchContacts());
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<List<ContactsModel>> _fetchContacts() async {
    final response = await Http.get(Apis.contactsList, isLoading: false);
    final items = _extractItems(response);
    return items
        .whereType<Map>()
        .map(
          (item) => ContactsModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  List<dynamic> _extractItems(dynamic response) {
    if (response is List) return response;
    if (response is! Map) return const [];
    for (final key in const ['list', 'records', 'rows', 'data']) {
      final value = response[key];
      if (value is List) return value;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return _TransferPageBody(
      contacts: _contacts,
      isLoading: _isLoading,
      hasError: _hasError,
      onRetry: _loadContacts,
      contactsLoader: widget.contactsLoader,
      topInset: widget.topInset,
    );
  }
}

class _TransferPageBody extends StatelessWidget {
  const _TransferPageBody({
    required this.contacts,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.contactsLoader,
    required this.topInset,
  });

  final List<ContactsModel> contacts;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final Future<List<ContactsModel>> Function()? contactsLoader;
  final double topInset;

  static const double _contactCardTop = 1080;
  static const double _contactHeaderHeight = 158;
  static const double _contactRowHeight = 217;
  static const double _contactCardBottomPadding = 58;



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final scale = constraints.maxWidth / HomeTransferPage._sourceWidth;
        final rowCount =
            isLoading || hasError || contacts.isEmpty ? 1 : contacts.length;
        final dynamicCardHeight = (_contactHeaderHeight +
                rowCount * _contactRowHeight +
                _contactCardBottomPadding) *
            scale;
        final requiredHeight =
            (_contactCardTop + 48) * scale + dynamicCardHeight;
        final pageHeight = requiredHeight < constraints.maxHeight
            ? constraints.maxHeight
            : requiredHeight;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: topInset),
            child: SizedBox(
              width: constraints.maxWidth,
              height: pageHeight,
              child: Stack(
                children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: _contactCardTop * scale,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: HomeTransferPage._sourceHeight * scale,
                      maxHeight: HomeTransferPage._sourceHeight * scale,
                      child: Image.asset(
                        HomeTransferPage._assetPath,
                        width: constraints.maxWidth,
                        height: HomeTransferPage._sourceHeight * scale,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 44 * scale,
                  top: 45 * scale,
                  width: 370 * scale,
                  height: 355 * scale,
                  child: Semantics(
                    button: true,
                    label: '账号转账',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(Routes.homeAccountTransfer),
                    ),
                  ),
                ),
                Positioned(
                  left: 414 * scale,
                  top: 45 * scale,
                  width: 370 * scale,
                  height: 355 * scale,
                  child: Semantics(
                    key: const ValueKey('home_phone_transfer_hotspot'),
                    button: true,
                    label: '手机号转账',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(Routes.homePhoneTransfer),
                    ),
                  ),
                ),
                Positioned(
                  left: 784 * scale,
                  top: 45 * scale,
                  width: 378 * scale,
                  height: 355 * scale,
                  child: Semantics(
                    key: const ValueKey(
                      'home_credit_card_repayment_hotspot',
                    ),
                    button: true,
                    label: '信用卡还款',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(Routes.creditCardRepayment),
                    ),
                  ),
                ),
                Positioned(
                  left: 44 * scale,
                  top: 405 * scale,
                  width: 558 * scale,
                  height: 145 * scale,
                  child: Semantics(
                    key: const ValueKey('home_transfer_record_hotspot'),
                    button: true,
                    label: '转账记录',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(Routes.homeTransferRecord),
                    ),
                  ),
                ),
                Positioned(
                  left: 602 * scale,
                  right: 44 * scale,
                  top: 405 * scale,
                  height: 145 * scale,
                  child: Semantics(
                    key: const ValueKey('home_transfer_settings_hotspot'),
                    button: true,
                    label: '转账设置',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(Routes.transferSettings),
                    ),
                  ),
                ),
                Positioned(
                  left: 44 * scale,
                  right: 44 * scale,
                  top: 650 * scale,
                  height: 250 * scale,
                  child: _TransferQuickActions(
                    scale: scale,
                    contactsLoader: contactsLoader,
                  ),
                ),
                Positioned(
                  left: 44 * scale,
                  right: 44 * scale,
                  top: _contactCardTop * scale,
                  height: dynamicCardHeight,
                  child: DecoratedBox(
                    key: const ValueKey('home_transfer_contacts_card'),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28 * scale),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: _contactHeaderHeight * scale,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 42 * scale),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '常用收款人',
                                    style: TextStyle(
                                      fontSize: 52 * scale,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  label: '全部常用收款人',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => Get.to(
                                      () => AccountTransferRecipientsPage(
                                        contactsLoader: contactsLoader,
                                      ),
                                    ),
                                    child: Container(
                                      key: const ValueKey(
                                        'home_transfer_contacts_all_button',
                                      ),
                                      width: 230 * scale,
                                      height: 104 * scale,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F7F7),
                                        borderRadius:
                                            BorderRadius.circular(52 * scale),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/account_transfer/icons/recipient_contact.png',
                                            width: 42 * scale,
                                            height: 42 * scale,
                                            fit: BoxFit.contain,
                                          ),
                                          SizedBox(width: 18 * scale),
                                          Text(
                                            '全部',
                                            style: TextStyle(
                                              color: const Color(0xFF333333),
                                              fontSize: 42 * scale,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: _buildContacts(scale)),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContacts(double scale) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 34 * scale,
          height: 34 * scale,
          child: const CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    if (hasError) {
      return Center(
        child: TextButton(
          onPressed: onRetry,
          child: Text('加载失败，点击重试', style: TextStyle(fontSize: 34 * scale)),
        ),
      );
    }
    if (contacts.isEmpty) {
      return Center(
        child: Text(
          '暂无常用收款人',
          style:
              TextStyle(color: const Color(0xFF999999), fontSize: 36 * scale),
        ),
      );
    }
    return Column(
      children: contacts
          .map(
            (contact) => SizedBox(
              height: _contactRowHeight * scale,
              child: _FrequentPayeeRow(contact: contact, scale: scale),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FrequentPayeeRow extends StatelessWidget {
  const _FrequentPayeeRow({
    required this.contact,
    required this.scale,
  });

  final ContactsModel contact;
  final double scale;

  String get _cardSuffix {
    final digits = contact.bankCard.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;
    return digits.substring(digits.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '常用收款人${contact.name}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(
          Routes.homeAccountTransfer,
          arguments: AccountTransferRouteArguments.quickRecipient(contact),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 42 * scale, right: 32 * scale),
          child: Row(
            children: [
              ClipOval(
                child: contact.icon.isEmpty
                    ? _BankIconFallback(scale: scale)
                    : CachedNetworkImage(
                        imageUrl: contact.icon,
                        width: 66 * scale,
                        height: 66 * scale,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _BankIconFallback(scale: scale),
                        errorWidget: (_, __, ___) =>
                            _BankIconFallback(scale: scale),
                      ),
              ),
              SizedBox(width: 28 * scale),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 48 * scale,
                        fontWeight: FontWeight.w400,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      '${contact.bankName} 借记卡(**$_cardSuffix)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF8C98A8),
                        fontSize: 41 * scale,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankIconFallback extends StatelessWidget {
  const _BankIconFallback({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66 * scale,
      height: 66 * scale,
      child: ColoredBox(
        color: const Color(0xFF0B6DB9),
        child: Center(
          child: Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 38 * scale,
          ),
        ),
      ),
    );
  }
}

class _TransferQuickActions extends StatefulWidget {
  const _TransferQuickActions({
    required this.scale,
    required this.contactsLoader,
  });

  final double scale;

  final Future<List<ContactsModel>> Function()? contactsLoader;

  @override
  State<_TransferQuickActions> createState() => _TransferQuickActionsState();
}

class _TransferQuickActionsState extends State<_TransferQuickActions> {
  late final PageController _pageController = PageController(
    viewportFraction: 1 / 5,
  );
  double _scrollProgress = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _TransferQuickAction(
        key: const ValueKey('home_appointment_transfer_hotspot'),
        label: '预约转账',
        assetPath: 'assets/images/ic_home_transfer_1.png',
        onTap: () => Get.toNamed(Routes.appointmentTransfer),
      ),
      _TransferQuickAction(
        key: const ValueKey('home_single_funds_transfer_hotspot'),
        label: '单笔转入',
        assetPath: 'assets/images/ic_home_transfer_2.png',
        onTap: () => Get.toNamed(Routes.singleFundsTransfer),
      ),
      _TransferQuickAction(
        key: const ValueKey('home_periodic_transfer_hotspot'),
        label: '定期转入',
        assetPath: 'assets/images/ic_home_transfer_3.png',
        onTap: () => Get.toNamed(Routes.periodicTransferPlan),
      ),
      _TransferQuickAction(
        key: const ValueKey('home_transfer_all_recipients_hotspot'),
        label: '全部收款人',
        assetPath: 'assets/images/ic_home_transfer_4.png',
        onTap: () => Get.to(
          () => AccountTransferRecipientsPage(
            contactsLoader: widget.contactsLoader,
          ),
        ),
      ),
      _TransferQuickAction(
        key: const ValueKey('home_transfer_limit_hotspot'),
        label: '转账限额',
        assetPath: 'assets/images/ic_home_transfer_5.png',
        onTap: () => Get.toNamed(Routes.transferLimit),
      ),
      _TransferQuickAction(
        key: const ValueKey('home_cross_border_payment_hotspot'),
        label: '跨境支付通',
        assetPath: 'assets/images/ic_home_transfer_6.png',
        onTap: () => Get.toNamed(Routes.crossBorderPayment),
      ),
    ];
    final scale = widget.scale;

    return Column(
      key: const Key('home-transfer-quick-actions'),
      children: [
        SizedBox(
          height: 205 * scale,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final maxScrollExtent = notification.metrics.maxScrollExtent;
              final progress = maxScrollExtent <= 0
                  ? 0.0
                  : (notification.metrics.pixels / maxScrollExtent)
                      .clamp(0.0, 1.0);
              if (progress != _scrollProgress) {
                setState(() => _scrollProgress = progress);
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              padEnds: false,
              physics: const PageScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              itemCount: actions.length,
              itemBuilder: (_, index) => _TransferQuickActionButton(
                action: actions[index],
                scale: scale,
              ),
            ),
          ),
        ),
        _TransferQuickActionsIndicator(
          progress: _scrollProgress,
          scale: scale,
        ),
      ],
    );
  }
}

class _TransferQuickAction {
  const _TransferQuickAction({
    required this.key,
    required this.label,
    required this.assetPath,
    required this.onTap,
  });

  final Key key;
  final String label;
  final String assetPath;
  final VoidCallback onTap;
}

class _TransferQuickActionButton extends StatelessWidget {
  const _TransferQuickActionButton({
    required this.action,
    required this.scale,
  });

  final _TransferQuickAction action;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: action.key,
      button: true,
      label: action.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action.onTap,
        child: Padding(
          padding: EdgeInsets.only(top: 28 * scale),
          child: Column(
            children: [
              SizedBox(
                width: 76 * scale,
                height: 76 * scale,
                child: Image.asset(action.assetPath, fit: BoxFit.contain),
              ),
              SizedBox(height: 15 * scale),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: const Color(0xFF252525),
                  fontSize: 38 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferQuickActionsIndicator extends StatelessWidget {
  const _TransferQuickActionsIndicator({
    required this.progress,
    required this.scale,
  });

  final double progress;
  final double scale;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 66.0;
    const thumbWidth = 24.0;
    const height = 8.0;

    return Container(
      width: trackWidth * scale,
      height: height * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF0),
        borderRadius: BorderRadius.circular(height * scale / 2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: (trackWidth - thumbWidth) * scale * progress,
            child: Container(
              width: thumbWidth * scale,
              height: height * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFBFC5CF),
                borderRadius: BorderRadius.circular(height * scale / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
