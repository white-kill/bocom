import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import 'account_transfer/account_transfer_support_pages.dart';

// 转账页
// 说明：当前页面使用裁掉系统状态栏、保留页面导航栏的参考图；常用收款人示例已覆盖并改为接口数据。
class HomeTransferPage extends StatefulWidget {
  const HomeTransferPage({
    super.key,
    this.contactsLoader,
  });

  static const double _sourceWidth = 1206;
  static const double _sourceHeight = 2445;
  static const String _assetPath = 'assets/images/home_transfer_page.png';

  final Future<List<ContactsModel>> Function()? contactsLoader;

  @override
  State<HomeTransferPage> createState() => _HomeTransferPageState();
}

class _HomeTransferPageState extends State<HomeTransferPage> {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8F8F8),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: _TransferPageBody(
            contacts: _contacts,
            isLoading: _isLoading,
            hasError: _hasError,
            onRetry: _loadContacts,
            contactsLoader: widget.contactsLoader,
          ),
        ),
      ),
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
  });

  final List<ContactsModel> contacts;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final Future<List<ContactsModel>> Function()? contactsLoader;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final scale = constraints.maxWidth / HomeTransferPage._sourceWidth;
        final rowCount =
            isLoading || hasError || contacts.isEmpty ? 1 : contacts.length;
        final dynamicCardHeight = (150 + rowCount * 217 + 24) * scale;
        final requiredHeight = 1180 * scale + dynamicCardHeight + 48 * scale;
        final pageHeight = requiredHeight < constraints.maxHeight
            ? constraints.maxHeight
            : requiredHeight;
        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            height: pageHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 1180 * scale,
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
                  right: 28 * scale,
                  top: 565 * scale,
                  width: 290 * scale,
                  height: 245 * scale,
                  child: Semantics(
                    button: true,
                    label: '全部收款人',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.to(
                        () => AccountTransferRecipientsPage(
                          contactsLoader: contactsLoader,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18 * scale,
                  top: 0,
                  width: 145 * scale,
                  height: 135 * scale,
                  child: Semantics(
                    button: true,
                    label: '返回',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: Get.back,
                    ),
                  ),
                ),
                Positioned(
                  right: 18 * scale,
                  top: 0,
                  width: 145 * scale,
                  height: 135 * scale,
                  child: Semantics(
                    button: true,
                    label: '客服',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(Routes.customerService),
                    ),
                  ),
                ),
                Positioned(
                  left: 44 * scale,
                  top: 180 * scale,
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
                  left: 44 * scale,
                  top: 790 * scale,
                  width: 282 * scale,
                  height: 210 * scale,
                  child: Semantics(
                    button: true,
                    label: '转账记录',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(Routes.homeTransferRecord),
                    ),
                  ),
                ),
                Positioned(
                  left: 50 * scale,
                  right: 50 * scale,
                  top: 1180 * scale,
                  height: dynamicCardHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28 * scale),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 150 * scale,
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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.to(
                                    () => AccountTransferRecipientsPage(
                                      contactsLoader: contactsLoader,
                                    ),
                                  ),
                                  child: Text(
                                    '全部',
                                    style: TextStyle(
                                      color: const Color(0xFF0875E8),
                                      fontSize: 42 * scale,
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
              height: 217 * scale,
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
          arguments: contact,
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
                      '${contact.bankName} 借记卡（**$_cardSuffix）',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF999999),
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
