import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';

import '../../../../component/auth_sm.dart';
import '../../../../component/indicator_loading.dart';
import '../../../../component/password_keyboard_sheet.dart';
import 'account_transfer_result_pages.dart';

const _blue = Color(0xFF0875E8);
const _pageBackground = Color(0xFFF5F6F8);

enum _RequestState { loading, loaded, error }

// 全部收款人页
// 说明：导航、搜索、动态分组列表和底部操作均使用原生 Flutter 绘制，截图仅用于尺寸与颜色校准。
class AccountTransferRecipientsPage extends StatefulWidget {
  const AccountTransferRecipientsPage({
    super.key,
    this.contactsLoader,
  });

  final Future<List<ContactsModel>> Function()? contactsLoader;

  @override
  State<AccountTransferRecipientsPage> createState() =>
      _AccountTransferRecipientsPageState();
}

class _AccountTransferRecipientsPageState
    extends State<AccountTransferRecipientsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<ContactsModel> _contacts = const [];
  Map<String, double> _sectionOffsets = const {};
  _RequestState _requestState = _RequestState.loading;
  String? _activeSection;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
    _scrollController.addListener(_updateActiveSection);
    _loadContacts();
  }

  @override
  void didUpdateWidget(covariant AccountTransferRecipientsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contactsLoader != widget.contactsLoader) _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _requestState = _RequestState.loading);
    try {
      final contacts = List<ContactsModel>.of(
        await (widget.contactsLoader?.call() ?? _fetchContacts()),
      );
      contacts.sort((a, b) => _sortKey(a.name).compareTo(_sortKey(b.name)));
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _requestState = _RequestState.loaded;
      });
    } catch (_) {
      if (mounted) setState(() => _requestState = _RequestState.error);
    }
  }

  Future<List<ContactsModel>> _fetchContacts() async {
    final response = await Http.get(Apis.contactsList, isLoading: false);
    final items = _extractList(response);
    return items
        .whereType<Map>()
        .map((item) => ContactsModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: true);
  }

  void _refresh() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() => _activeSection = null);
  }

  List<ContactsModel> get _visibleContacts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _contacts;
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          contact.bankName.toLowerCase().contains(query) ||
          contact.bankCard.contains(query) ||
          contact.phone.contains(query);
    }).toList(growable: false);
  }

  Map<String, List<ContactsModel>> get _groupedContacts {
    final groups = <String, List<ContactsModel>>{};
    for (final contact in _visibleContacts) {
      groups.putIfAbsent(_initialFor(contact.name), () => []).add(contact);
    }
    return groups;
  }

  String _sortKey(String value) => PinyinHelper.getPinyinE(value).toUpperCase();

  String _initialFor(String value) {
    final pinyin = _sortKey(value).trim();
    if (pinyin.isEmpty) return '#';
    final initial = pinyin[0];
    return RegExp(r'[A-Z]').hasMatch(initial) ? initial : '#';
  }

  void _updateActiveSection() {
    if (_sectionOffsets.isEmpty) return;
    final position = _scrollController.offset + 8;
    var current = _sectionOffsets.keys.first;
    for (final entry in _sectionOffsets.entries) {
      if (entry.value <= position) current = entry.key;
    }
    if (current != _activeSection && mounted) {
      setState(() => _activeSection = current);
    }
  }

  void _scrollToSection(String section) {
    final offset = _sectionOffsets[section];
    if (offset == null || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
    setState(() => _activeSection = section);
  }

  Future<void> _addRecipient() async {
    final contact = await Get.to<ContactsModel>(() => const AddRecipientPage());
    if (contact == null || !mounted) return;
    final contacts = [..._contacts, contact]
      ..sort((a, b) => _sortKey(a.name).compareTo(_sortKey(b.name)));
    setState(() {
      _contacts = contacts;
      _activeSection = null;
    });
  }

  Future<void> _editRecipient(ContactsModel original) async {
    final updated = await Get.to<ContactsModel>(
      () => AddRecipientPage(initialRecipient: original),
    );
    if (updated == null || !mounted) return;
    final contacts = [..._contacts];
    final index = contacts.indexOf(original);
    if (index < 0) return;
    contacts[index] = updated;
    contacts.sort((a, b) => _sortKey(a.name).compareTo(_sortKey(b.name)));
    setState(() {
      _contacts = contacts;
      _activeSection = null;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_refresh);
    _scrollController.removeListener(_updateActiveSection);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LightSystemUi(
      child: Scaffold(
        key: const Key('all-recipients-scaffold'),
        backgroundColor: _pageBackground,
        body: LayoutBuilder(
          builder: (_, constraints) {
            final scale = constraints.maxWidth / 1080;
            return Column(
              children: [
                _RecipientsHeader(
                  scale: scale,
                  searchController: _searchController,
                ),
                Expanded(child: _buildContactsBody(scale)),
              ],
            );
          },
        ),
        bottomNavigationBar: _AddRecipientBottomBar(
          scale: MediaQuery.sizeOf(context).width / 1080,
          onTap: _addRecipient,
        ),
      ),
    );
  }

  Widget _buildContactsBody(double scale) {
    switch (_requestState) {
      case _RequestState.loading:
        return const _LoadingState(label: '正在加载收款人');
      case _RequestState.error:
        return _ErrorState(label: '收款人加载失败', onRetry: _loadContacts);
      case _RequestState.loaded:
        final groups = _groupedContacts;
        if (groups.isEmpty) {
          return _EmptyState(
            label:
                _searchController.text.trim().isEmpty ? '暂无收款人' : '未找到匹配的收款人',
          );
        }
        var offset = 0.0;
        final offsets = <String, double>{};
        final children = <Widget>[];
        for (final entry in groups.entries) {
          offsets[entry.key] = offset;
          children.add(_SectionHeader(label: entry.key, scale: scale));
          offset += 80 * scale;
          for (final contact in entry.value) {
            children.add(
              _LiveRecipientTile(
                contact: contact,
                scale: scale,
                onTap: () => Get.back(result: contact),
                onEdit: () => _editRecipient(contact),
              ),
            );
            offset += 193 * scale;
          }
        }
        _sectionOffsets = offsets;
        _activeSection ??= groups.keys.first;
        return Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: children,
            ),
            Positioned(
              top: 8 * scale,
              right: 0,
              bottom: 8 * scale,
              width: 66 * scale,
              child: _AlphabetRail(
                sections: groups.keys.toList(growable: false),
                activeSection: _activeSection,
                onSelect: _scrollToSection,
                scale: scale,
              ),
            ),
          ],
        );
    }
  }
}

class _RecipientsHeader extends StatelessWidget {
  const _RecipientsHeader({
    required this.scale,
    required this.searchController,
  });

  final double scale;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('all-recipients-header'),
      height: 325 * scale,
      child: ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: 24 * scale,
              top: 80 * scale,
              width: 120 * scale,
              height: 120 * scale,
              child: Semantics(
                button: true,
                label: '返回',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: Get.back,
                  child: Center(
                    child: Image.asset(
                      'assets/images/nav_back_white.png',
                      width: 21 * scale,
                      height: 40 * scale,
                      color: const Color(0xFF181818),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 95 * scale,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Text(
                  '全部收款人',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF181818),
                    fontSize: 52 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 38 * scale,
              right: 38 * scale,
              top: 217 * scale,
              height: 88 * scale,
              child: TextField(
                key: const Key('all-recipients-search'),
                controller: searchController,
                cursorColor: _blue,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 41 * scale,
                ),
                decoration: InputDecoration(
                  hintText: '收款人/银行/手机号/卡号',
                  hintStyle: TextStyle(
                    color: const Color(0xFF999B9F),
                    fontSize: 41 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF989DA6),
                    size: 43 * scale,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 90 * scale,
                    minHeight: 88 * scale,
                  ),
                  contentPadding: EdgeInsets.only(
                    right: 30 * scale,
                    bottom: 2 * scale,
                  ),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(44 * scale),
                    borderSide: BorderSide(
                      color: const Color(0xFFAEB1B7),
                      width: 2 * scale,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(44 * scale),
                    borderSide: BorderSide(color: _blue, width: 2 * scale),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRecipientBottomBar extends StatelessWidget {
  const _AddRecipientBottomBar({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '添加收款人',
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            key: const Key('add-recipient-bottom-bar'),
            height: 124 * scale,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFE9ECEF),
                  width: 2 * scale,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 56 * scale,
                  color: const Color(0xFF333333),
                ),
                SizedBox(width: 12 * scale),
                Text(
                  '添加收款人',
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 50 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddRecipientPage extends StatefulWidget {
  const AddRecipientPage({
    super.key,
    this.bankLoader,
    this.initialRecipient,
  });

  final Future<List<RecipientBank>> Function()? bankLoader;
  final ContactsModel? initialRecipient;

  @override
  State<AddRecipientPage> createState() => _AddRecipientPageState();
}

class _AddRecipientPageState extends State<AddRecipientPage> {
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _bankController = TextEditingController();
  final _locationController = TextEditingController();
  final _branchController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty &&
      _accountController.text.trim().isNotEmpty &&
      _bankController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRecipient;
    if (initial != null) {
      _nameController.text = initial.name;
      _accountController.text = initial.bankCard;
      _bankController.text = initial.bankName;
      _phoneController.text = initial.phone;
    }
    for (final controller in [
      _nameController,
      _accountController,
      _bankController
    ]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  Future<void> _selectBank() async {
    final bank = await Get.to<String>(
      () => RecipientBankPage(bankLoader: widget.bankLoader),
    );
    if (bank != null) _bankController.text = bank;
  }

  Future<void> _scanCard() async {
    final number = await Get.to<String>(() => const BankCardScannerPage());
    if (number != null) _accountController.text = number;
  }

  Future<void> _editOptionalValue(
    String title,
    TextEditingController controller,
  ) async {
    final value = await Get.dialog<String>(
      _OptionalValueDialog(
        title: title,
        initialValue: controller.text,
      ),
    );
    if (value != null) controller.text = value;
  }

  void _complete() {
    if (!_canContinue) {
      final message = _nameController.text.trim().isEmpty
          ? '请输入收款户名'
          : _accountController.text.trim().isEmpty
              ? '请输入银行卡号'
              : '请选择银行';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    final initial = widget.initialRecipient;
    final contact = ContactsModel()
      ..name = _nameController.text.trim()
      ..bankName = _bankController.text.trim()
      ..bankCard = _accountController.text.trim()
      ..phone = _phoneController.text.trim()
      ..bankId = initial?.bankId ?? ''
      ..icon = initial?.icon ?? '';
    Get.back(result: contact);
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _accountController,
      _bankController
    ]) {
      controller.removeListener(_refresh);
    }
    for (final controller in [
      _nameController,
      _accountController,
      _bankController,
      _locationController,
      _branchController,
      _phoneController,
      _noteController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LightSystemUi(
      child: Scaffold(
        key: const Key('add-recipient-scaffold'),
        backgroundColor: const Color(0xFFF7F7F7),
        body: LayoutBuilder(
          builder: (_, constraints) {
            final scale = constraints.maxWidth / 1080;
            return ListView(
              padding: EdgeInsets.zero,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _AddRecipientHeader(
                  scale: scale,
                  title: widget.initialRecipient == null ? '添加收款人' : '编辑收款人',
                ),
                ColoredBox(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _LabeledInputRow(
                        scale: scale,
                        label: '户名',
                        hint: '请输入收款户名',
                        controller: _nameController,
                      ),
                      _LabeledInputRow(
                        scale: scale,
                        label: '账号',
                        hint: '请输入银行卡号',
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        suffix: Tooltip(
                          message: '扫描银行卡',
                          child: InkWell(
                            onTap: _scanCard,
                            child: SizedBox(
                              width: 78 * scale,
                              height: 132.8 * scale,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/account_transfer/icons/card_scan.png',
                                  width: 41 * scale,
                                  height: 40 * scale,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _LabeledInputRow(
                        scale: scale,
                        label: '开户行',
                        hint: '选择银行',
                        controller: _bankController,
                        readOnly: true,
                        onTap: _selectBank,
                        suffix: _AddRecipientChevron(scale: scale),
                      ),
                      _LabeledInputRow(
                        scale: scale,
                        label: '开户地',
                        hint: '可不选',
                        controller: _locationController,
                        readOnly: true,
                        onTap: () => _editOptionalValue(
                          '开户地',
                          _locationController,
                        ),
                        suffix: _AddRecipientChevron(scale: scale),
                      ),
                      _LabeledInputRow(
                        scale: scale,
                        label: '开户网点',
                        hint: '可不选',
                        controller: _branchController,
                        readOnly: true,
                        onTap: () => _editOptionalValue(
                          '开户网点',
                          _branchController,
                        ),
                        suffix: _AddRecipientChevron(scale: scale),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  key: const Key('add-recipient-group-gap'),
                  height: 44 * scale,
                ),
                ColoredBox(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _LabeledInputRow(
                        scale: scale,
                        rowHeight: 132,
                        label: '手机号',
                        hint: '选填',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      _LabeledInputRow(
                        scale: scale,
                        rowHeight: 132,
                        label: '备注',
                        hint: '15个汉字内(选填)',
                        controller: _noteController,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    43 * scale,
                    87 * scale,
                    43 * scale,
                    40 * scale,
                  ),
                  child: SizedBox(
                    key: const Key('add-recipient-next-button'),
                    height: 127 * scale,
                    child: ElevatedButton(
                      onPressed: _complete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF016AE9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18 * scale),
                        ),
                      ),
                      child: Text(
                        '下一步',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AddRecipientHeader extends StatelessWidget {
  const _AddRecipientHeader({required this.scale, required this.title});

  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('add-recipient-header'),
      height: 196 * scale,
      child: ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: 24 * scale,
              top: 80 * scale,
              width: 120 * scale,
              height: 100 * scale,
              child: Tooltip(
                message: '返回',
                child: Semantics(
                  button: true,
                  label: '返回',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: Get.back,
                    child: Center(
                      child: Image.asset(
                        'assets/images/nav_back_white.png',
                        width: 21 * scale,
                        height: 40 * scale,
                        color: const Color(0xFF181818),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 95 * scale,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF181818),
                    fontSize: 52 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRecipientChevron extends StatelessWidget {
  const _AddRecipientChevron({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78 * scale,
      height: 132.8 * scale,
      child: Center(
        child: Image.asset(
          'assets/images/account_transfer/icons/row_chevron.png',
          width: 20 * scale,
          height: 38 * scale,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class _OptionalValueDialog extends StatefulWidget {
  const _OptionalValueDialog({
    required this.title,
    required this.initialValue,
  });

  final String title;
  final String initialValue;

  @override
  State<_OptionalValueDialog> createState() => _OptionalValueDialogState();
}

class _OptionalValueDialogState extends State<_OptionalValueDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: '请输入${widget.title}'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

class RecipientBank {
  const RecipientBank({
    required this.name,
    this.icon = '',
    this.asset = '',
    this.initial = '',
  });

  final String name;
  final String icon;
  final String asset;
  final String initial;
}

// Logo 切图均来自 1080×2340 真实页面，裁剪框为 x=31、w=84、h=84，
// 首个 y=480，后续按 132 像素行高递增。
const _mockRecipientBanks = <RecipientBank>[
  RecipientBank(
    name: '交通银行',
    asset: 'assets/images/account_transfer/banks/bank_communications.jpg',
    initial: 'J',
  ),
  RecipientBank(
    name: '中国工商银行',
    asset: 'assets/images/account_transfer/banks/bank_icbc.jpg',
    initial: 'G',
  ),
  RecipientBank(
    name: '中国农业银行',
    asset: 'assets/images/account_transfer/banks/bank_agricultural.jpg',
    initial: 'N',
  ),
  RecipientBank(
    name: '中国银行',
    asset: 'assets/images/account_transfer/banks/bank_china.jpg',
    initial: 'Z',
  ),
  RecipientBank(
    name: '中国建设银行',
    asset: 'assets/images/account_transfer/banks/bank_construction.jpg',
    initial: 'J',
  ),
  RecipientBank(
    name: '中国邮政储蓄银行',
    asset: 'assets/images/account_transfer/banks/bank_postal.jpg',
    initial: 'Y',
  ),
  RecipientBank(
    name: '招商银行',
    asset: 'assets/images/account_transfer/banks/bank_merchants.jpg',
    initial: 'Z',
  ),
  RecipientBank(
    name: '中信银行',
    asset: 'assets/images/account_transfer/banks/bank_citic.jpg',
    initial: 'Z',
  ),
  RecipientBank(
    name: '中国民生银行',
    asset: 'assets/images/account_transfer/banks/bank_minsheng.jpg',
    initial: 'M',
  ),
  RecipientBank(
    name: '兴业银行',
    asset: 'assets/images/account_transfer/banks/bank_industrial.jpg',
    initial: 'X',
  ),
  RecipientBank(
    name: '浦发银行',
    asset: 'assets/images/account_transfer/banks/bank_spdb.jpg',
    initial: 'P',
  ),
  RecipientBank(
    name: '中国光大银行',
    asset: 'assets/images/account_transfer/banks/bank_everbright.jpg',
    initial: 'G',
  ),
  RecipientBank(
    name: '平安银行',
    asset: 'assets/images/account_transfer/banks/bank_pingan.jpg',
    initial: 'P',
  ),
  RecipientBank(
    name: '华夏银行',
    asset: 'assets/images/account_transfer/banks/bank_huaxia.jpg',
    initial: 'H',
  ),
];

// 收款银行页
// 说明：页面使用原生 Flutter 绘制，银行 Logo 从真实页面截图裁切，导航由页面固定绘制。
class RecipientBankPage extends StatefulWidget {
  const RecipientBankPage({
    super.key,
    this.bankLoader,
  });

  final Future<List<RecipientBank>> Function()? bankLoader;

  @override
  State<RecipientBankPage> createState() => _RecipientBankPageState();
}

class _RecipientBankPageState extends State<RecipientBankPage> {
  static const _referenceWidth = 1080.0;
  static const _alphabet = [
    '热',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'W',
    'X',
    'Y',
    'Z',
  ];

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<RecipientBank> _banks = const [];
  Map<String, double> _sectionOffsets = const {};
  _RequestState _requestState = _RequestState.loading;
  String? _activeSection;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
    _scrollController.addListener(_updateActiveSection);
    if (widget.bankLoader == null) {
      _banks = _mockRecipientBanks;
      _requestState = _RequestState.loaded;
      _activeSection = '热';
    } else {
      _loadBanks();
    }
  }

  @override
  void didUpdateWidget(covariant RecipientBankPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bankLoader != widget.bankLoader) _loadBanks();
  }

  Future<void> _loadBanks() async {
    if (widget.bankLoader == null) {
      setState(() {
        _banks = _mockRecipientBanks;
        _requestState = _RequestState.loaded;
        _activeSection = '热';
      });
      return;
    }
    setState(() => _requestState = _RequestState.loading);
    try {
      final banks = List<RecipientBank>.of(
        await widget.bankLoader!.call(),
      );
      banks.sort((a, b) => _sortKey(a.name).compareTo(_sortKey(b.name)));
      if (!mounted) return;
      setState(() {
        _banks = banks;
        _requestState = _RequestState.loaded;
      });
    } catch (_) {
      if (mounted) setState(() => _requestState = _RequestState.error);
    }
  }

  void _refresh() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    setState(() => _activeSection = null);
  }

  List<RecipientBank> get _visibleBanks {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _banks;
    return _banks
        .where(
          (bank) =>
              bank.name.toLowerCase().contains(query) ||
              _sortKey(bank.name).toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Map<String, List<RecipientBank>> get _groupedBanks {
    final groups = <String, List<RecipientBank>>{};
    for (final bank in _visibleBanks) {
      final initial = bank.initial.isEmpty
          ? _initialFor(bank.name)
          : bank.initial.toUpperCase();
      groups.putIfAbsent(initial, () => []).add(bank);
    }
    final entries = groups.entries.toList(growable: false)
      ..sort((a, b) {
        final aIndex = _alphabet.indexOf(a.key);
        final bIndex = _alphabet.indexOf(b.key);
        return (aIndex < 0 ? _alphabet.length : aIndex)
            .compareTo(bIndex < 0 ? _alphabet.length : bIndex);
      });
    return Map.fromEntries(entries);
  }

  String _sortKey(String value) => PinyinHelper.getPinyinE(value).toUpperCase();

  String _initialFor(String value) {
    final pinyin = _sortKey(value).trim();
    if (pinyin.isEmpty) return '#';
    final initial = pinyin[0];
    return RegExp(r'[A-Z]').hasMatch(initial) ? initial : '#';
  }

  void _updateActiveSection() {
    if (_sectionOffsets.isEmpty) return;
    final position = _scrollController.offset + 8;
    var current = _sectionOffsets.keys.first;
    for (final entry in _sectionOffsets.entries) {
      if (entry.value <= position) current = entry.key;
    }
    if (current != _activeSection && mounted) {
      setState(() => _activeSection = current);
    }
  }

  void _scrollToSection(String section) {
    var offset = _sectionOffsets[section];
    if (offset == null) {
      final start = _alphabet.indexOf(section);
      for (var index = start + 1; index < _alphabet.length; index++) {
        offset = _sectionOffsets[_alphabet[index]];
        if (offset != null) break;
      }
    }
    if (offset == null || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
    setState(() => _activeSection = section);
  }

  @override
  void dispose() {
    _searchController.removeListener(_refresh);
    _scrollController.removeListener(_updateActiveSection);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LightSystemUi(
      child: Scaffold(
        key: const Key('recipient-bank-scaffold'),
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (_, constraints) {
              final scale = constraints.maxWidth / _referenceWidth;
              return Column(
                children: [
                  _RecipientBankHeader(
                    scale: scale,
                    searchController: _searchController,
                  ),
                  Expanded(child: _buildBanksBody(scale)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBanksBody(double scale) {
    switch (_requestState) {
      case _RequestState.loading:
        return const _LoadingState(label: '正在加载银行');
      case _RequestState.error:
        return _ErrorState(label: '银行列表加载失败', onRetry: _loadBanks);
      case _RequestState.loaded:
        if (_visibleBanks.isEmpty) return const _EmptyState(label: '未找到匹配的银行');
        final filtering = _searchController.text.trim().isNotEmpty;
        final groups = _groupedBanks;
        final sections = <String, List<RecipientBank>>{};
        if (!filtering) {
          sections['热'] = _banks.take(14).toList(growable: false);
        }
        sections.addAll(groups);

        var offset = 0.0;
        final offsets = <String, double>{};
        final children = <Widget>[];
        for (final entry in sections.entries) {
          offsets[entry.key] = offset;
          children.add(
            _BankSectionHeader(
              label: entry.key == '热' ? '热门银行' : entry.key,
              scale: scale,
            ),
          );
          offset += 95 * scale;
          for (final bank in entry.value) {
            children.add(
              _LiveBankTile(
                bank: bank,
                scale: scale,
                onTap: () => Get.back(result: bank.name),
              ),
            );
            offset += 132 * scale;
          }
        }
        _sectionOffsets = offsets;
        _activeSection ??= filtering ? sections.keys.first : '热';
        return Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: children,
            ),
            if (!filtering)
              Positioned(
                top: 158 * scale,
                right: 0,
                width: 56 * scale,
                child: _BankAlphabetRail(
                  sections: _alphabet,
                  activeSection: _activeSection,
                  onSelect: _scrollToSection,
                  scale: scale,
                ),
              ),
          ],
        );
    }
  }
}

// 扫描银行卡页
// 说明：扫描界面为原生实时相机页，预览画面保持相机原始宽高比并在扫描框内居中裁剪。
class BankCardScannerPage extends StatefulWidget {
  const BankCardScannerPage({super.key});

  @override
  State<BankCardScannerPage> createState() => _BankCardScannerPageState();
}

class _BankCardScannerPageState extends State<BankCardScannerPage> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) return;
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _cameraController = controller);
    } catch (_) {
      // The framed fallback remains usable when the emulator has no camera.
    }
  }

  Future<void> _capture() async {
    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      try {
        await controller.takePicture();
      } catch (_) {}
    }
    if (!mounted) return;
    Get.back();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: const Key('bank-card-scanner-scaffold'),
        backgroundColor: const Color(0xFF646464),
        body: LayoutBuilder(
          builder: (_, constraints) {
            final widthScale = constraints.maxWidth / 1080;
            final heightScale = constraints.maxHeight / 2340;
            final captureSize = 207 * widthScale;
            return Stack(
              key: const Key('bank-card-scanner'),
              children: [
                Positioned(
                  top: 740 * heightScale,
                  left: 45 * widthScale,
                  right: 45 * widthScale,
                  height: 638 * heightScale,
                  child: ClipRect(
                    key: const Key('bank-card-camera-preview'),
                    child: _cameraController?.value.isInitialized == true
                        ? _AspectCorrectCameraPreview(
                            controller: _cameraController!,
                          )
                        : const ColoredBox(color: Color(0xFF303234)),
                  ),
                ),
                Positioned(
                  left: 37 * widthScale,
                  right: 37 * widthScale,
                  top: 732 * heightScale,
                  height: 654 * heightScale,
                  child: IgnorePointer(
                    child: CustomPaint(
                      key: const Key('bank-card-scan-corners'),
                      painter: _ScannerCornerPainter(
                        horizontalLeg: 75 * widthScale,
                        verticalLeg: 75 * heightScale,
                        thickness: 9 * widthScale,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 106 * heightScale,
                  width: 128 * widthScale,
                  height: 125 * heightScale,
                  child: Semantics(
                    button: true,
                    label: '返回',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: Get.back,
                      child: Center(
                        child: Image.asset(
                          'assets/images/nav_back_white.png',
                          width: 28 * widthScale,
                          height: 51 * heightScale,
                          color: Colors.white,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 129 * heightScale,
                  left: 0,
                  right: 0,
                  child: Text(
                    '扫描银行卡',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 57 * widthScale,
                    ),
                  ),
                ),
                Positioned(
                  top: 616 * heightScale,
                  left: 30 * widthScale,
                  right: 30 * widthScale,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50 * widthScale,
                        fontWeight: FontWeight.w600,
                      ),
                      children: const [
                        TextSpan(text: '请将银行卡'),
                        TextSpan(
                          text: '正面(卡号面)',
                          style: TextStyle(color: Color(0xFFFB5655)),
                        ),
                        TextSpan(text: '放置框内并拍摄'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  top: 1913 * heightScale,
                  left: (constraints.maxWidth - captureSize) / 2,
                  width: captureSize,
                  height: captureSize,
                  child: Semantics(
                    button: true,
                    label: '拍摄银行卡',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _capture,
                      child: Container(
                        key: const Key('bank-card-capture-button'),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Container(
                          margin: EdgeInsets.all(13 * widthScale),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF646464),
                              width: 4 * widthScale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  const _ScannerCornerPainter({
    required this.horizontalLeg,
    required this.verticalLeg,
    required this.thickness,
  });

  final double horizontalLeg;
  final double verticalLeg;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3388ED);
    final right = size.width - thickness;
    final bottom = size.height - thickness;

    canvas
      ..drawRect(Rect.fromLTWH(0, 0, horizontalLeg, thickness), paint)
      ..drawRect(Rect.fromLTWH(0, 0, thickness, verticalLeg), paint)
      ..drawRect(
        Rect.fromLTWH(size.width - horizontalLeg, 0, horizontalLeg, thickness),
        paint,
      )
      ..drawRect(Rect.fromLTWH(right, 0, thickness, verticalLeg), paint)
      ..drawRect(Rect.fromLTWH(0, bottom, horizontalLeg, thickness), paint)
      ..drawRect(
        Rect.fromLTWH(0, size.height - verticalLeg, thickness, verticalLeg),
        paint,
      )
      ..drawRect(
        Rect.fromLTWH(
          size.width - horizontalLeg,
          bottom,
          horizontalLeg,
          thickness,
        ),
        paint,
      )
      ..drawRect(
        Rect.fromLTWH(
          right,
          size.height - verticalLeg,
          thickness,
          verticalLeg,
        ),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _ScannerCornerPainter oldDelegate) {
    return horizontalLeg != oldDelegate.horizontalLeg ||
        verticalLeg != oldDelegate.verticalLeg ||
        thickness != oldDelegate.thickness;
  }
}

class _AspectCorrectCameraPreview extends StatelessWidget {
  const _AspectCorrectCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const ColoredBox(color: Color(0xFF303234));
    }

    // Camera preview sizes are reported in the sensor's landscape orientation.
    // The scanner is portrait, so swap the axes before applying a cover crop.
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: CameraPreview(controller),
      ),
    );
  }
}

class AccountTransferConfirmationPage extends StatefulWidget {
  const AccountTransferConfirmationPage({
    super.key,
    required this.recipient,
    required this.amount,
    required this.description,
    required this.arrivalTime,
    this.passwordVerificationLauncher,
    this.smsVerificationLauncher,
  });

  final ContactsModel recipient;
  final String amount;
  final String description;
  final String arrivalTime;
  final PasswordVerificationLauncher? passwordVerificationLauncher;
  final SmsVerificationLauncher? smsVerificationLauncher;

  @override
  State<AccountTransferConfirmationPage> createState() =>
      _AccountTransferConfirmationPageState();
}

class _AccountTransferConfirmationPageState
    extends State<AccountTransferConfirmationPage> {
  bool _isSubmitting = false;

  String get _memberPhone {
    try {
      return AppConfig.config.abcLogic.memberInfo.phone;
    } catch (_) {
      return '';
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final transferContext = AuthSmTransferContext(
        payeeName: widget.recipient.name.trim(),
        cardLast4: _cardLastFour(widget.recipient.bankCard),
        amountDisplay: widget.amount.replaceAll(',', '').trim(),
      );
      final verified = await (widget.smsVerificationLauncher?.call(
            context,
            _memberPhone,
            transferContext,
          ) ??
          showSmsVerificationCode(
            context,
            phone: _memberPhone,
            transferContext: transferContext,
          ));
      if (!mounted || verified != true) return;
      final transaction = TransactionPasswordContext(
        payeeName: widget.recipient.name.trim(),
        amountDisplay: widget.amount,
        bankName: widget.recipient.bankName.trim(),
        accountNumber: widget.recipient.bankCard.trim(),
      );
      final passwordVerified = await (widget.passwordVerificationLauncher?.call(
            context,
            transaction,
          ) ??
          PasswordKeyboardSheet.showForVerification(
            context,
            transaction: transaction,
          ));
      if (!mounted || passwordVerified != true) return;
      await BocomLoading.run<void>(
        context,
        () => Future<void>.delayed(const Duration(milliseconds: 550)),
        alignment: const Alignment(0, -0.22),
      );
      if (!mounted) return;
      final transactionTime = DateTime.now();
      final result = AccountTransferResultData.fromTransfer(
        billId: transactionTime.millisecondsSinceEpoch,
        recipientName: widget.recipient.name.trim(),
        recipientAccount: widget.recipient.bankCard.trim(),
        recipientBank: widget.recipient.bankName.trim(),
        amount: num.parse(widget.amount.replaceAll(',', '').trim()).toDouble(),
        transactionTime: transactionTime,
        arrivalText: widget.arrivalTime,
        purpose: widget.description.trim(),
      );
      Get.off<int>(
        () => AccountTransferSuccessPage(
          data: result,
          billDetailLoader: (_) async => null,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('转账提交失败，请稍后重试')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _cardLastFour(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return digits;
    return digits.substring(digits.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return _LightSystemUi(
      child: Scaffold(
        backgroundColor: _pageBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            tooltip: '返回',
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          ),
          title: const Text('确认转账信息', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        _ConfirmationRow(
                          label: '收款人',
                          value: widget.recipient.name,
                        ),
                        _ConfirmationRow(
                          label: '收款账号',
                          value: widget.recipient.bankCard,
                        ),
                        _ConfirmationRow(
                          label: '收款银行',
                          value: widget.recipient.bankName,
                        ),
                        _ConfirmationRow(
                          label: '到账时间',
                          value: widget.arrivalTime,
                        ),
                        if (widget.description.isNotEmpty)
                          _ConfirmationRow(
                            label: '转账说明',
                            value: widget.description,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        const Text(
                          '转账金额',
                          style: TextStyle(color: Color(0xFF666666)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '¥ ${widget.amount}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '手续费 0元',
                          style: TextStyle(color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '确认转账',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> showArrivalTimeSheet(
  BuildContext context,
  String selected,
) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black45,
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: _ArrivalTimeSheet.heightFactor,
      child: _ArrivalTimeSheet(
        selected: selected,
        onClose: () => Navigator.of(sheetContext).pop(),
        onSelected: (value) => Navigator.of(sheetContext).pop(value),
      ),
    ),
  );
}

// 更换到账时间弹层
// 说明：弹层为原生动态选择面板，高度按参考图占屏比例计算，不使用页面切图。
class _ArrivalTimeSheet extends StatelessWidget {
  const _ArrivalTimeSheet({
    required this.selected,
    required this.onClose,
    required this.onSelected,
  });

  static const heightFactor = (1280 - 478) / 1280;
  static const _referenceWidth = 588.0;
  static const _values = [
    '预计实时到账',
    '预计2小时后到账',
    '预计次日到账',
  ];

  final String selected;
  final VoidCallback onClose;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _referenceWidth;
        final headerHeight = 80 * scale;
        final rowHeight = 67 * scale;
        final horizontalPadding = 22 * scale;
        return Material(
          key: const Key('arrival-time-sheet'),
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18 * scale),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        '更换到账时间',
                        style: TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6 * scale,
                      top: 0,
                      bottom: 0,
                      child: Semantics(
                        button: true,
                        label: '关闭',
                        child: IconButton(
                          tooltip: '关闭',
                          onPressed: onClose,
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF222222),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (final value in _values)
                Semantics(
                  button: true,
                  selected: value == selected,
                  label: value,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onSelected(value),
                    child: Container(
                      height: rowHeight,
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (value == selected)
                            const Icon(
                              Icons.check,
                              color: _blue,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showTransferLimitSheet(
  BuildContext context, {
  VoidCallback? onQuery,
  VoidCallback? onModify,
  VoidCallback? onCollapse,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black45,
    builder: (sheetContext) => _TransferLimitSheet(
      onClose: () => Navigator.of(sheetContext).pop(),
      onQuery: onQuery ?? () {},
      onModify: onModify ?? () {},
      onCollapse: onCollapse ?? () {},
    ),
  );
}

// 限额说明弹层
// 说明：弹层为静态说明内容，使用裁掉主页和状态栏的内容图，交互热区由 Flutter 单独绘制。
class _TransferLimitSheet extends StatelessWidget {
  const _TransferLimitSheet({
    required this.onClose,
    required this.onQuery,
    required this.onModify,
    required this.onCollapse,
  });

  static const _sourceWidth = 588.0;
  static const _sourceHeight = 1125.0;
  static const _asset =
      'assets/images/account_transfer/limit_sheet/limit_sheet_expanded.png';

  final VoidCallback onClose;
  final VoidCallback onQuery;
  final VoidCallback onModify;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _sourceWidth;
        final height = _sourceHeight * scale;
        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(_asset, fit: BoxFit.fill),
              ),
              _LimitSheetHotspot(
                label: '关闭',
                left: 0,
                top: 0,
                width: 72,
                height: 76,
                scale: scale,
                onTap: onClose,
              ),
              _LimitSheetHotspot(
                label: '查询限额',
                left: 16,
                top: 248,
                width: 276,
                height: 92,
                scale: scale,
                onTap: onQuery,
              ),
              _LimitSheetHotspot(
                label: '修改限额',
                left: 296,
                top: 248,
                width: 276,
                height: 92,
                scale: scale,
                onTap: onModify,
              ),
              _LimitSheetHotspot(
                label: '收起验证方式说明',
                left: 470,
                top: 370,
                width: 108,
                height: 70,
                scale: scale,
                onTap: onCollapse,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LimitSheetHotspot extends StatelessWidget {
  const _LimitSheetHotspot({
    required this.label,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double left;
  final double top;
  final double width;
  final double height;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left * scale,
      top: top * scale,
      width: width * scale,
      height: height * scale,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child:
                Text(label, style: const TextStyle(color: Color(0xFF666666))),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF222222), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Color(0xFF888888))),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.label, required this.onRetry});

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              color: Color(0xFF999999), size: 38),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Color(0xFF777777))),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('重新加载')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, color: Color(0xFFB7BBC2), size: 44),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Color(0xFF999999))),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.scale});

  final String label;
  final double? scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: scale == null ? null : Key('recipient-section-$label'),
      height: scale == null ? 34 : 80 * scale!,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: scale == null ? 16 : 40 * scale!),
      color: scale == null ? const Color(0xFFF5F6F8) : const Color(0xFFF7F7F7),
      child: Text(
        label,
        style: TextStyle(
          color:
              scale == null ? const Color(0xFF8A9099) : const Color(0xFF222222),
          fontSize: scale == null ? 14 : 38 * scale!,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _LiveRecipientTile extends StatelessWidget {
  const _LiveRecipientTile({
    required this.contact,
    required this.scale,
    required this.onTap,
    required this.onEdit,
  });

  final ContactsModel contact;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final digits = contact.bankCard.replaceAll(RegExp(r'\D'), '');
    final suffix =
        digits.length > 4 ? digits.substring(digits.length - 4) : digits;
    final detail = contact.bankCard.isEmpty
        ? contact.bankName
        : '${contact.bankName} 借记卡 (**$suffix)';
    return Semantics(
      button: true,
      label: '收款人${contact.name}',
      explicitChildNodes: true,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            key: Key('recipient-row-${contact.bankCard}'),
            height: 193 * scale,
            child: Row(
              children: [
                SizedBox(width: 40 * scale),
                _RecipientBankIcon(contact: contact, size: 66 * scale),
                SizedBox(width: 31 * scale),
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
                          fontSize: 42 * scale,
                          height: 1.12,
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF929497),
                          fontSize: 35 * scale,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  container: true,
                  button: true,
                  label: '编辑${contact.name}',
                  child: ExcludeSemantics(
                    child: InkWell(
                      onTap: onEdit,
                      child: SizedBox(
                        width: 150 * scale,
                        height: 193 * scale,
                        child: Center(
                          child: Text(
                            '编辑',
                            style: TextStyle(
                              color: _blue,
                              fontSize: 42 * scale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 25 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipientBankIcon extends StatelessWidget {
  const _RecipientBankIcon({required this.contact, required this.size});

  final ContactsModel contact;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (contact.icon.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: contact.icon,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if (contact.bankName.contains('交通银行')) {
      return Image.asset(
        'assets/images/account_transfer/icons/bank_of_communications.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    if (contact.bankName.contains('中国银行')) {
      return Image.asset(
        'assets/images/account_transfer/icons/bank_of_china.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Icon(
        Icons.account_balance,
        color: const Color(0xFF0B6DB9),
        size: size * .8,
      ),
    );
  }
}

class _RecipientBankHeader extends StatelessWidget {
  const _RecipientBankHeader({
    required this.scale,
    required this.searchController,
  });

  final double scale;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('recipient-bank-header'),
      height: 270 * scale,
      child: ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              left: 24 * scale,
              top: 0,
              width: 120 * scale,
              height: 126 * scale,
              child: Semantics(
                button: true,
                label: '返回',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: Get.back,
                  child: Center(
                    child: Image.asset(
                      'assets/images/nav_back_white.png',
                      width: 21 * scale,
                      height: 38 * scale,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 145 * scale,
              right: 145 * scale,
              top: 0,
              height: 126 * scale,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    '收款银行',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF111111),
                      fontSize: 53 * scale,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 38 * scale,
              right: 38 * scale,
              top: 149 * scale,
              height: 86 * scale,
              child: TextField(
                key: const Key('recipient-bank-search'),
                controller: searchController,
                cursorColor: _blue,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 43 * scale,
                  height: 1,
                ),
                decoration: InputDecoration(
                  hintText: '请输入银行名称',
                  hintStyle: TextStyle(
                    color: const Color(0xFF9299A6),
                    fontSize: 43 * scale,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF9299A6),
                    size: 47 * scale,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 91 * scale,
                    minHeight: 86 * scale,
                  ),
                  contentPadding: EdgeInsets.only(
                    right: 28 * scale,
                    bottom: 2 * scale,
                  ),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(44 * scale),
                    borderSide: BorderSide(
                      color: const Color(0xFFB7BBC3),
                      width: 2 * scale,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(44 * scale),
                    borderSide: BorderSide(color: _blue, width: 2 * scale),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankSectionHeader extends StatelessWidget {
  const _BankSectionHeader({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('recipient-bank-section-$label'),
      height: 95 * scale,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 43 * scale),
      color: Colors.white,
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF8C95A3),
          fontSize: 42 * scale,
          fontWeight: FontWeight.w400,
          height: 1,
        ),
      ),
    );
  }
}

class _LiveBankTile extends StatelessWidget {
  const _LiveBankTile({
    required this.bank,
    required this.scale,
    required this.onTap,
  });

  final RecipientBank bank;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: bank.name,
      child: InkWell(
        onTap: onTap,
        child: Container(
          key: Key('recipient-bank-row-${bank.name}'),
          height: 132 * scale,
          padding: EdgeInsets.only(left: 31 * scale, right: 40 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE7E7E7),
                width: 1 * scale,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 84 * scale,
                height: 84 * scale,
                child: bank.asset.isNotEmpty
                    ? Image.asset(bank.asset, fit: BoxFit.fill)
                    : bank.icon.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: bank.icon,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => _BankLogoFallback(
                              scale: scale,
                            ),
                          )
                        : _BankLogoFallback(scale: scale),
              ),
              SizedBox(width: 19 * scale),
              Expanded(
                child: Text(
                  bank.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 48 * scale,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankLogoFallback extends StatelessWidget {
  const _BankLogoFallback({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.account_balance,
      color: const Color(0xFF0B6DB9),
      size: 58 * scale,
    );
  }
}

class _BankAlphabetRail extends StatelessWidget {
  const _BankAlphabetRail({
    required this.sections,
    required this.activeSection,
    required this.onSelect,
    required this.scale,
  });

  final List<String> sections;
  final String? activeSection;
  final ValueChanged<String> onSelect;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final itemExtent = 52 * scale;

    void selectAt(double dy) {
      final index = (dy / itemExtent).floor().clamp(0, sections.length - 1);
      onSelect(sections[index]);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => selectAt(details.localPosition.dy),
      onVerticalDragUpdate: (details) => selectAt(details.localPosition.dy),
      child: SizedBox(
        key: const Key('recipient-bank-alphabet-rail'),
        height: itemExtent * sections.length,
        child: Column(
          children: sections
              .map(
                (section) => SizedBox(
                  key: Key('recipient-bank-alphabet-$section'),
                  width: itemExtent,
                  height: itemExtent,
                  child: Center(
                    child: Container(
                      width: 50 * scale,
                      height: 50 * scale,
                      alignment: Alignment.center,
                      decoration: section == activeSection
                          ? const BoxDecoration(
                              color: _blue,
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Text(
                        section,
                        style: TextStyle(
                          color: section == activeSection
                              ? Colors.white
                              : const Color(0xFF3E4652),
                          fontSize: 33 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _AlphabetRail extends StatelessWidget {
  const _AlphabetRail({
    required this.sections,
    required this.activeSection,
    required this.onSelect,
    this.scale,
  });

  final List<String> sections;
  final String? activeSection;
  final ValueChanged<String> onSelect;
  final double? scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final itemExtent = scale == null ? 22.0 : 50 * scale!;
        final railHeight = itemExtent * sections.length;
        final railTop = (constraints.maxHeight - railHeight) / 2;

        void selectAt(double dy) {
          if (sections.isEmpty) return;
          final index = ((dy - railTop) / itemExtent)
              .floor()
              .clamp(0, sections.length - 1);
          onSelect(sections[index]);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => selectAt(details.localPosition.dy),
          onVerticalDragUpdate: (details) => selectAt(details.localPosition.dy),
          child: Center(
            child: SizedBox(
              key: scale == null
                  ? null
                  : const Key('recipient-alphabet-rail-items'),
              height: railHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sections
                    .map(
                      (section) => Container(
                        key: scale == null
                            ? null
                            : Key('recipient-alphabet-item-$section'),
                        width: itemExtent,
                        height: itemExtent,
                        alignment: Alignment.center,
                        decoration: section == activeSection
                            ? const BoxDecoration(
                                color: _blue,
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Text(
                          section,
                          style: TextStyle(
                            color: section == activeSection
                                ? Colors.white
                                : const Color(0xFF3E4652),
                            fontSize: scale == null ? 11 : 31 * scale!,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LabeledInputRow extends StatelessWidget {
  const _LabeledInputRow({
    required this.scale,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.showDivider = true,
    this.rowHeight = 132.8,
  });

  final double scale;
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final bool showDivider;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('add-recipient-row-$label'),
      height: rowHeight * scale,
      margin: EdgeInsets.symmetric(horizontal: 43 * scale),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: const Color(0xFFF0F1F3),
                  width: 2 * scale,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 246 * scale,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF292929),
                fontSize: 48 * scale,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                color: const Color(0xFF292929),
                fontSize: 44 * scale,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xFFD1D5DC),
                  fontSize: 44 * scale,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

class _LightSystemUi extends StatelessWidget {
  const _LightSystemUi({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

List<dynamic> _extractList(dynamic response) {
  if (response is List) return response;
  if (response is! Map) return const [];
  for (final key in const ['list', 'records', 'rows', 'data']) {
    final value = response[key];
    if (value is List) return value;
    if (value is Map) {
      final nested = _extractList(value);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}
