import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

const _secondaryBackground = Color(0xFFF7F7F7);
const _secondaryBlue = Color(0xFF0877E9);
const _secondaryText = Color(0xFF222222);
const _secondaryHint = Color(0xFF9BA2AC);

double _sourceScale(BuildContext context, [double sourceWidth = 1080]) =>
    MediaQuery.sizeOf(context).width / sourceWidth;

String _maskedCardSuffix(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '****0000';
  final suffix =
      digits.length > 4 ? digits.substring(digits.length - 4) : digits;
  return '****$suffix';
}

String _memberBankLabel() {
  if (!Get.isRegistered<BocLogic>()) return '示例收款卡（****0000）';
  final banks = Get.find<BocLogic>().memberInfo.bankList;
  if (banks.isEmpty) return '示例收款卡（****0000）';
  final bank = banks.first;
  final name = bank.bankName.trim().isEmpty ? '交通银行' : bank.bankName.trim();
  return '$name ${bank.cardType.trim().isEmpty ? '借记卡' : bank.cardType.trim()}（${_maskedCardSuffix(bank.bankCard)}）';
}

String _memberName() {
  if (!Get.isRegistered<BocLogic>()) return 'DEMO USER';
  final member = Get.find<BocLogic>().memberInfo;
  if (member.namePinyin.trim().isNotEmpty) {
    return member.namePinyin.trim().toUpperCase();
  }
  if (member.realName.trim().isNotEmpty) return member.realName.trim();
  return 'DEMO USER';
}

class _TransferHeader extends StatelessWidget implements PreferredSizeWidget {
  const _TransferHeader({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _secondaryBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 52,
      leadingWidth: 58,
      leading: Semantics(
        button: true,
        label: '返回',
        child: IconButton(
          onPressed: Get.back,
          icon: Image.asset(
            'assets/images/home_credit_card_back.png',
            width: 40,
            height: 40,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111111),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LightPage extends StatelessWidget {
  const _LightPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _secondaryBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: child,
    );
  }
}

Future<String?> _showChoiceSheet(
  BuildContext context, {
  required String title,
  required List<String> choices,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...choices.map(
              (choice) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(choice),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(sheetContext).pop(choice),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// 单笔资金转入页
// 说明：当前页面是活页面，导航、卡片选择、金额输入和按钮状态均由 Flutter 原生绘制。
class SingleFundsTransferPage extends StatefulWidget {
  const SingleFundsTransferPage({super.key});

  @override
  State<SingleFundsTransferPage> createState() =>
      _SingleFundsTransferPageState();
}

class _SingleFundsTransferPageState extends State<SingleFundsTransferPage> {
  final _amountController = TextEditingController();
  String? _receiver;
  String? _payer;

  bool get _canContinue =>
      _receiver != null &&
      _payer != null &&
      (double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_refresh);
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _chooseReceiver() async {
    final result = await _showChoiceSheet(
      context,
      title: '选择收款卡',
      choices: [_memberBankLabel()],
    );
    if (result != null && mounted) setState(() => _receiver = result);
  }

  Future<void> _choosePayer() async {
    if (_receiver == null) return;
    final result = await _showChoiceSheet(
      context,
      title: '选择付款卡',
      choices: const ['示例付款卡（****0000）'],
    );
    if (result != null && mounted) setState(() => _payer = result);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _sourceScale(context);
    return _LightPage(
      child: Scaffold(
        backgroundColor: _secondaryBackground,
        appBar: const _TransferHeader(title: '资金转入'),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
              38 * scale, 20 * scale, 38 * scale, 44 * scale),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _FundsCard(
              scale: scale,
              title: '收款卡',
              value: _receiver,
              hint: '请选择收款卡',
              enabled: true,
              showChevron: true,
              onTap: _chooseReceiver,
            ),
            SizedBox(height: 32 * scale),
            _FundsCard(
              scale: scale,
              title: '付款卡',
              value: _payer,
              hint: '请选择付款卡',
              enabled: _receiver != null,
              showChevron: false,
              onTap: _choosePayer,
            ),
            SizedBox(height: 32 * scale),
            Container(
              height: 300 * scale,
              padding: EdgeInsets.fromLTRB(
                  52 * scale, 42 * scale, 52 * scale, 24 * scale),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24 * scale)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('转账金额',
                      style: TextStyle(
                          fontSize: 46 * scale, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Row(
                    children: [
                      Text('¥',
                          style: TextStyle(
                              fontSize: 68 * scale,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: TextField(
                          key: const Key('single-funds-amount-field'),
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,9}(\.\d{0,2})?'))
                          ],
                          style: TextStyle(
                              fontSize: 55 * scale,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration.collapsed(
                            hintText: '免手续费',
                            hintStyle: TextStyle(
                                color: const Color(0xFFD4D8DE),
                                fontSize: 43 * scale),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32 * scale),
            _PrimaryButton(
              key: const Key('single-funds-next-button'),
              scale: scale,
              label: '下一步',
              enabled: _canContinue,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('资金转入信息已填写')),
              ),
            ),
            SizedBox(height: 76 * scale),
            const _FundsTransferTips(),
          ],
        ),
      ),
    );
  }
}

class _FundsCard extends StatelessWidget {
  const _FundsCard({
    required this.scale,
    required this.title,
    required this.value,
    required this.hint,
    required this.enabled,
    required this.showChevron,
    required this.onTap,
  });

  final double scale;
  final String title;
  final String? value;
  final String hint;
  final bool enabled;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: title,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          height: 286 * scale,
          padding: EdgeInsets.fromLTRB(
              52 * scale, 40 * scale, 46 * scale, 32 * scale),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24 * scale)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 46 * scale, fontWeight: FontWeight.w600)),
              const Spacer(),
              Row(
                children: [
                  Opacity(
                    opacity: enabled ? 1 : .12,
                    child: Image.asset(
                      'assets/images/account_transfer/icons/bank_of_communications.png',
                      width: 62 * scale,
                      height: 62 * scale,
                    ),
                  ),
                  SizedBox(width: 24 * scale),
                  Expanded(
                    child: Text(
                      value ?? hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: value == null ? _secondaryHint : _secondaryText,
                        fontSize: 42 * scale,
                      ),
                    ),
                  ),
                  if (showChevron) Icon(Icons.chevron_right, size: 48 * scale),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {super.key,
      required this.scale,
      required this.label,
      required this.enabled,
      required this.onTap});

  final double scale;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: SizedBox(
        height: 112 * scale,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _secondaryBlue,
            disabledBackgroundColor: const Color(0xFFCDD3DC),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22 * scale)),
          ),
          child: Text(label,
              style: TextStyle(color: Colors.white, fontSize: 47 * scale)),
        ),
      ),
    );
  }
}

class _FundsTransferTips extends StatelessWidget {
  const _FundsTransferTips();

  @override
  Widget build(BuildContext context) {
    const style =
        TextStyle(color: Color(0xFF929292), fontSize: 14, height: 1.65);
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('温馨提示：',
            style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        Text('1. 收款卡与付款卡须为本人同名账户。', style: style),
        Text('2. 转入额度以付款卡发卡行与银联渠道的可用限额为准。', style: style),
        Text('3. 请妥善保管卡号、密码和短信验证码，谨防诈骗。', style: style),
      ],
    );
  }
}

// 定期转入计划页
// 说明：当前页面使用不含导航栏的内容切图，页面导航由 Flutter 单独绘制，操作区使用透明热区。
class PeriodicTransferPlanPage extends StatelessWidget {
  const PeriodicTransferPlanPage({super.key});

  static const _sourceWidth = 1080.0;
  static const _sourceHeight = 2172.0;
  static const _asset =
      'assets/images/transfer_secondary/periodic_transfer_plan_body.png';

  void _showPending(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label功能待接入')));
  }

  @override
  Widget build(BuildContext context) {
    return _LightPage(
      child: Scaffold(
        backgroundColor: _secondaryBackground,
        appBar: const _TransferHeader(title: '定期转入计划'),
        body: SafeArea(
          top: false,
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _sourceWidth,
                height: _sourceHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(_asset, fit: BoxFit.fill),
                    ),
                    _ImageHotspot(
                      label: '签约卡管理',
                      left: 760,
                      top: 0,
                      width: 300,
                      height: 125,
                      scale: 1,
                      onTap: () => _showPending(context, '签约卡管理'),
                    ),
                    _ImageHotspot(
                      label: '添加计划',
                      left: 0,
                      top: 2000,
                      width: 1080,
                      height: 172,
                      scale: 1,
                      onTap: () => _showPending(context, '添加计划'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 预约转账页
// 说明：当前页面使用包含沉浸式导航的两张内容切图，固定导航仅在滚动后出现，菜单操作由 Flutter 热区承载。
class AppointmentTransferPage extends StatefulWidget {
  const AppointmentTransferPage({super.key});

  @override
  State<AppointmentTransferPage> createState() =>
      _AppointmentTransferPageState();
}

class _AppointmentTransferPageState extends State<AppointmentTransferPage> {
  static const _sourceWidth = 1080.0;
  static const _headerHeight = 1707.0;
  static const _tipsHeight = 1013.0;
  final _scrollController = ScrollController();
  bool _showPinnedHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final threshold =
        210 * (MediaQuery.maybeSizeOf(context)?.width ?? 1080) / _sourceWidth;
    final next = _scrollController.offset >= threshold;
    if (next != _showPinnedHeader && mounted) {
      setState(() => _showPinnedHeader = next);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _openPlan(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label计划待接入')));
  }

  @override
  Widget build(BuildContext context) {
    final statusHeight = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _showPinnedHeader ? Brightness.dark : Brightness.light,
        statusBarBrightness:
            _showPinnedHeader ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _secondaryBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _secondaryBackground,
        body: LayoutBuilder(
          builder: (_, constraints) {
            final scale = constraints.maxWidth / _sourceWidth;
            return Stack(
              children: [
                SingleChildScrollView(
                  key: const Key('appointment-transfer-scroll'),
                  controller: _scrollController,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: (_headerHeight + _tipsHeight) * scale,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: _headerHeight * scale,
                          child: Image.asset(
                            'assets/images/transfer_secondary/appointment_transfer_header.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: _headerHeight * scale,
                          height: _tipsHeight * scale,
                          child: Image.asset(
                            'assets/images/transfer_secondary/appointment_transfer_tips.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        _ImageHotspot(
                          label: '返回',
                          left: 25,
                          top: 85,
                          width: 120,
                          height: 125,
                          scale: scale,
                          onTap: Get.back,
                        ),
                        _ImageHotspot(
                          label: '客服',
                          left: 935,
                          top: 85,
                          width: 120,
                          height: 125,
                          scale: scale,
                          onTap: () => Get.toNamed(Routes.customerService),
                        ),
                        ..._planHotspots(scale),
                      ],
                    ),
                  ),
                ),
                if (_showPinnedHeader)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: statusHeight + 52,
                    child: ColoredBox(
                      color: _secondaryBackground,
                      child: Padding(
                        padding: EdgeInsets.only(top: statusHeight),
                        child: const _AppointmentPinnedHeader(),
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

  List<Widget> _planHotspots(double scale) {
    const labels = ['给父母', '付房租', '给TA', '还车贷', '还房贷', '自定义'];
    const positions = [
      [45.0, 1180.0],
      [315.0, 1180.0],
      [585.0, 1180.0],
      [830.0, 1180.0],
      [45.0, 1430.0],
      [315.0, 1430.0],
    ];
    return List<Widget>.generate(labels.length, (index) {
      return _ImageHotspot(
        label: labels[index],
        left: positions[index][0],
        top: positions[index][1],
        width: 230,
        height: 220,
        scale: scale,
        onTap: () => _openPlan(labels[index]),
      );
    });
  }
}

class _AppointmentPinnedHeader extends StatelessWidget {
  const _AppointmentPinnedHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              '预约转账',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              label: '返回',
              child: IconButton(
                onPressed: Get.back,
                icon: Image.asset(
                  'assets/images/home_credit_card_back.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Semantics(
                button: true,
                label: '客服',
                child: IconButton(
                  onPressed: () => Get.toNamed(Routes.customerService),
                  icon: Image.asset(
                    'assets/images/nav_right_kf.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageHotspot extends StatelessWidget {
  const _ImageHotspot({
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
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
      ),
    );
  }
}

class TransferLimitData {
  const TransferLimitData({
    this.actualSingle = '--',
    this.actualDaily = '--',
    this.actualDailyCount = '--',
    this.actualAnnual = '--',
    this.customSingle = '--',
    this.customDaily = '--',
    this.customDailyCount = '--',
    this.customAnnual = '--',
    this.offCounterSingle = '--',
    this.offCounterDaily = '--',
    this.offCounterAnnual = '--',
  });

  final String actualSingle;
  final String actualDaily;
  final String actualDailyCount;
  final String actualAnnual;
  final String customSingle;
  final String customDaily;
  final String customDailyCount;
  final String customAnnual;
  final String offCounterSingle;
  final String offCounterDaily;
  final String offCounterAnnual;
}

// 查询手机转账限额页
// 说明：当前页面是动态账户页，账户与额度均由运行时模型传入，参考截图不作为账户数据源。
class TransferLimitPage extends StatelessWidget {
  const TransferLimitPage({super.key, this.data = const TransferLimitData()});

  final TransferLimitData data;

  @override
  Widget build(BuildContext context) {
    final scale = _sourceScale(context);
    return _LightPage(
      child: Scaffold(
        backgroundColor: _secondaryBackground,
        appBar: const _TransferHeader(title: '查询手机转账限额'),
        body: ListView(
          key: const Key('transfer-limit-scroll'),
          padding: EdgeInsets.fromLTRB(
              30 * scale, 22 * scale, 30 * scale, 52 * scale),
          children: [
            _AccountSummaryCard(scale: scale),
            SizedBox(height: 28 * scale),
            _LimitSection(
              scale: scale,
              title: '实际转账限额',
              description: '实际转账限额为您设置的转账限额与非柜面转出限额的较小值。',
              rows: [
                _LimitRowData(
                    '单笔限额', data.actualSingle, '单笔转账可用限额 ${data.actualSingle}'),
                _LimitRowData(
                    '每日限额', data.actualDaily, '剩余可用 ${data.actualDaily}'),
                _LimitRowData('每日笔数', data.actualDailyCount,
                    '剩余可用 ${data.actualDailyCount}'),
                _LimitRowData(
                    '年度限额', data.actualAnnual, '剩余可用 ${data.actualAnnual}'),
              ],
            ),
            SizedBox(height: 28 * scale),
            _LimitSection(
              scale: scale,
              title: '您设置的转账限额',
              action: '修改限额',
              description: '按照手机银行规则，可分别设置单笔、每日及年度限额。',
              rows: [
                _LimitRowData('单笔限额', data.customSingle),
                _LimitRowData('每日限额', data.customDaily),
                _LimitRowData('每日笔数', data.customDailyCount),
                _LimitRowData('年度限额', data.customAnnual),
              ],
            ),
            SizedBox(height: 28 * scale),
            _LimitSection(
              scale: scale,
              title: '非柜面转出限额',
              action: '申请调整',
              rows: [
                _LimitRowData('单笔限额', data.offCounterSingle),
                _LimitRowData('每日限额', data.offCounterDaily),
                _LimitRowData('年度限额', data.offCounterAnnual),
              ],
            ),
            SizedBox(height: 42 * scale),
            Text('温馨提示',
                style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 38 * scale,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 18 * scale),
            Text(
              '1. 向本人交通银行账户转账不受自设限额控制，但受非柜面转出限额控制。\n'
              '2. 非柜面转出限额是指通过手机银行、网上银行、自助设备、POS机等非柜面渠道的转出总限额。',
              style: TextStyle(
                  color: const Color(0xFF939393),
                  fontSize: 31 * scale,
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112 * scale,
      padding: EdgeInsets.symmetric(horizontal: 32 * scale),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18 * scale)),
      child: Row(
        children: [
          Image.asset(
              'assets/images/account_transfer/icons/bank_of_communications.png',
              width: 58 * scale,
              height: 58 * scale),
          SizedBox(width: 22 * scale),
          Expanded(
            child: Text(_memberBankLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 39 * scale)),
          ),
        ],
      ),
    );
  }
}

class _LimitRowData {
  const _LimitRowData(this.label, this.value, [this.detail]);
  final String label;
  final String value;
  final String? detail;
}

class _LimitSection extends StatelessWidget {
  const _LimitSection(
      {required this.scale,
      required this.title,
      required this.rows,
      this.description,
      this.action});

  final double scale;
  final String title;
  final String? description;
  final String? action;
  final List<_LimitRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(32 * scale, 30 * scale, 32 * scale, 12 * scale),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18 * scale)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 42 * scale, fontWeight: FontWeight.w600))),
              if (action != null)
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$action功能待接入'))),
                  child: Text(action!,
                      style: TextStyle(
                          color: _secondaryBlue, fontSize: 33 * scale)),
                ),
            ],
          ),
          if (description != null) ...[
            SizedBox(height: 14 * scale),
            Text(description!,
                style: TextStyle(
                    color: const Color(0xFF929292),
                    fontSize: 31 * scale,
                    height: 1.45)),
          ],
          SizedBox(height: 14 * scale),
          ...rows.map((row) => _LimitRow(row: row, scale: scale)),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.row, required this.scale});
  final _LimitRowData row;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(minHeight: (row.detail == null ? 94 : 132) * scale),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          Expanded(
              child: Text(row.label, style: TextStyle(fontSize: 37 * scale))),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(row.value, style: TextStyle(fontSize: 37 * scale)),
              if (row.detail != null) ...[
                SizedBox(height: 5 * scale),
                Text(row.detail!,
                    style: TextStyle(
                        color: const Color(0xFF929292), fontSize: 29 * scale)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// 跨境支付通页
// 说明：当前页面是活页面，表单、选择器、协议勾选及动态汇款人信息均由 Flutter 原生绘制。
class CrossBorderPaymentPage extends StatefulWidget {
  const CrossBorderPaymentPage({super.key});

  @override
  State<CrossBorderPaymentPage> createState() => _CrossBorderPaymentPageState();
}

class _CrossBorderPaymentPageState extends State<CrossBorderPaymentPage> {
  final _recipientNameController = TextEditingController();
  final _recipientAccountController = TextEditingController();
  final _provinceController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _postscriptController = TextEditingController();
  bool _useAccount = true;
  bool _agreed = false;
  String? _recipientBank;
  String? _remitAccount;
  String? _tradeNote;

  bool get _canContinue =>
      _recipientBank != null &&
      _recipientNameController.text.trim().isNotEmpty &&
      _recipientAccountController.text.trim().isNotEmpty &&
      _remitAccount != null &&
      (double.tryParse(_amountController.text) ?? 0) > 0 &&
      _agreed;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _recipientNameController,
      _recipientAccountController,
      _provinceController,
      _addressController,
      _amountController,
      _postscriptController
    ]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in [
      _recipientNameController,
      _recipientAccountController,
      _provinceController,
      _addressController,
      _amountController,
      _postscriptController
    ]) {
      controller.removeListener(_refresh);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _chooseBank() async {
    final result = await _showChoiceSheet(
      context,
      title: '选择收款行',
      choices: const ['示例银行（中国香港）', '其他银行'],
    );
    if (result != null && mounted) setState(() => _recipientBank = result);
  }

  Future<void> _chooseRemitAccount() async {
    final result = await _showChoiceSheet(context,
        title: '选择汇款账户', choices: [_memberBankLabel()]);
    if (result != null && mounted) setState(() => _remitAccount = result);
  }

  Future<void> _chooseTradeNote() async {
    final result = await _showChoiceSheet(
      context,
      title: '选择交易附言',
      choices: const ['生活费', '教育费', '其他'],
    );
    if (result != null && mounted) setState(() => _tradeNote = result);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _sourceScale(context, 1320);
    return _LightPage(
      child: Scaffold(
        backgroundColor: _secondaryBackground,
        appBar: const _TransferHeader(title: '跨境支付通'),
        body: ListView(
          key: const Key('cross-border-payment-scroll'),
          padding: EdgeInsets.fromLTRB(
              45 * scale, 16 * scale, 45 * scale, 55 * scale),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _SectionTitle('收款行信息', scale: scale),
            _CrossCard(
              scale: scale,
              children: [
                _CountryBadge(scale: scale),
                _CrossChoiceRow(
                    label: '收款行',
                    value: _recipientBank,
                    hint: '请选择',
                    scale: scale,
                    onTap: _chooseBank),
              ],
            ),
            _SectionTitle('收款人信息', scale: scale),
            _CrossCard(
              scale: scale,
              children: [
                _IdentificationSegment(
                  scale: scale,
                  useAccount: _useAccount,
                  onChanged: (value) => setState(() => _useAccount = value),
                ),
                _CrossInputRow(
                    label: '收款人姓名',
                    hint: '请输入',
                    controller: _recipientNameController,
                    scale: scale),
                _CrossInputRow(
                  label: _useAccount ? '收款账户' : '手机号',
                  hint: '请输入',
                  controller: _recipientAccountController,
                  scale: scale,
                  keyboardType:
                      _useAccount ? TextInputType.text : TextInputType.phone,
                ),
                _CrossChoiceRow(
                    label: '所在国家/地区',
                    value: 'HKG',
                    hint: '',
                    scale: scale,
                    onTap: () {}),
              ],
            ),
            _SectionTitle('汇款人信息', scale: scale),
            _CrossCard(
              scale: scale,
              children: [
                _CrossReadOnlyRow(
                    label: '汇款人姓名', value: _memberName(), scale: scale),
                _CrossChoiceRow(
                    label: '所在国家/地区',
                    value: 'CHN',
                    hint: '',
                    scale: scale,
                    onTap: () {}),
                _CrossInputRow(
                    label: '所在省/市/州',
                    hint: '请输入',
                    controller: _provinceController,
                    scale: scale),
                _CrossInputRow(
                    label: '详细地址',
                    hint: '请输入',
                    controller: _addressController,
                    scale: scale),
              ],
            ),
            _SectionTitle('资金信息', scale: scale, action: '选择到账币种'),
            _CrossCard(
              scale: scale,
              children: [
                _CrossChoiceRow(
                    label: '汇款账户',
                    value: _remitAccount,
                    hint: '请选择',
                    scale: scale,
                    onTap: _chooseRemitAccount),
                _CrossReadOnlyRow(label: '汇款币种', value: 'CNY', scale: scale),
                _CrossInputRow(
                  key: const Key('cross-border-amount-field'),
                  label: '汇款金额',
                  hint: '请输入',
                  controller: _amountController,
                  scale: scale,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  trailing: '限额查询',
                ),
                _CrossChoiceRow(
                    label: '交易附言',
                    value: _tradeNote,
                    hint: '请选择',
                    scale: scale,
                    onTap: _chooseTradeNote),
                _CrossInputRow(
                    label: '汇款附言',
                    hint: '请输入',
                    controller: _postscriptController,
                    scale: scale),
              ],
            ),
            SizedBox(height: 48 * scale),
            Semantics(
              checked: _agreed,
              label: '同意汇款服务协议',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: _agreed,
                        onChanged: (value) =>
                            setState(() => _agreed = value ?? false),
                        activeColor: _secondaryBlue),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12 * scale),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                                color: _secondaryHint,
                                fontSize: 37 * scale,
                                height: 1.35),
                            children: const [
                              TextSpan(text: '同意并接受 '),
                              TextSpan(
                                  text: '《交通银行个人电子渠道汇款服务协议》',
                                  style: TextStyle(color: _secondaryBlue)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24 * scale),
            _PrimaryButton(
              key: const Key('cross-border-next-button'),
              scale: scale,
              label: '下一步',
              enabled: _canContinue,
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('跨境汇款信息已填写'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, {required this.scale, this.action});
  final String label;
  final double scale;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 34 * scale, 0, 20 * scale),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: const Color(0xFF909090),
                      fontSize: 47 * scale,
                      fontWeight: FontWeight.w600))),
          if (action != null)
            Text(action!,
                style: TextStyle(color: _secondaryBlue, fontSize: 37 * scale)),
        ],
      ),
    );
  }
}

class _CrossCard extends StatelessWidget {
  const _CrossCard({required this.scale, required this.children});
  final double scale;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 34 * scale),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(28 * scale)),
      child: Column(children: children),
    );
  }
}

class _CountryBadge extends StatelessWidget {
  const _CountryBadge({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28 * scale),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 550 * scale,
          height: 106 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F1FE),
            border: Border.all(color: const Color(0xFF4D9AFF), width: 1),
            borderRadius: BorderRadius.circular(18 * scale),
          ),
          child: Text('HKG-中国香港',
              style: TextStyle(
                  color: _secondaryBlue,
                  fontSize: 40 * scale,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _CrossChoiceRow extends StatelessWidget {
  const _CrossChoiceRow(
      {required this.label,
      required this.value,
      required this.hint,
      required this.scale,
      required this.onTap});
  final String label;
  final String? value;
  final String hint;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CrossRowShell(
      scale: scale,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                  width: 325 * scale,
                  child: Text(label, style: TextStyle(fontSize: 39 * scale))),
              Expanded(
                child: Text(value ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: value == null
                            ? const Color(0xFFD0D6DF)
                            : _secondaryText,
                        fontSize: 38 * scale)),
              ),
              Icon(Icons.chevron_right, size: 44 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrossReadOnlyRow extends StatelessWidget {
  const _CrossReadOnlyRow(
      {required this.label, required this.value, required this.scale});
  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _CrossRowShell(
      scale: scale,
      child: Row(
        children: [
          SizedBox(
              width: 325 * scale,
              child: Text(label, style: TextStyle(fontSize: 39 * scale))),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 38 * scale))),
        ],
      ),
    );
  }
}

class _CrossInputRow extends StatelessWidget {
  const _CrossInputRow(
      {super.key,
      required this.label,
      required this.hint,
      required this.controller,
      required this.scale,
      this.keyboardType,
      this.trailing});
  final String label;
  final String hint;
  final TextEditingController controller;
  final double scale;
  final TextInputType? keyboardType;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return _CrossRowShell(
      scale: scale,
      child: Row(
        children: [
          SizedBox(
              width: 325 * scale,
              child: Text(label, style: TextStyle(fontSize: 39 * scale))),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: 38 * scale),
              decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: const Color(0xFFD0D6DF), fontSize: 38 * scale)),
            ),
          ),
          if (trailing != null)
            Text(trailing!,
                style: TextStyle(color: _secondaryBlue, fontSize: 35 * scale)),
        ],
      ),
    );
  }
}

class _CrossRowShell extends StatelessWidget {
  const _CrossRowShell({required this.scale, required this.child});
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112 * scale,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8)))),
      child: child,
    );
  }
}

class _IdentificationSegment extends StatelessWidget {
  const _IdentificationSegment(
      {required this.scale, required this.useAccount, required this.onChanged});
  final double scale;
  final bool useAccount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _CrossRowShell(
      scale: scale,
      child: Row(
        children: [
          Expanded(
              child: Text('收款识别方式', style: TextStyle(fontSize: 39 * scale))),
          _SegmentButton(
              label: '账号账户',
              selected: useAccount,
              scale: scale,
              onTap: () => onChanged(true)),
          SizedBox(width: 18 * scale),
          _SegmentButton(
              label: '手机号',
              selected: !useAccount,
              scale: scale,
              onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton(
      {required this.label,
      required this.selected,
      required this.scale,
      required this.onTap});
  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Container(
          height: 66 * scale,
          padding: EdgeInsets.symmetric(horizontal: 26 * scale),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF3FF) : Colors.white,
            border: Border.all(
                color: selected ? _secondaryBlue : const Color(0xFFCDD2D9),
                width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? _secondaryBlue : _secondaryText,
                  fontSize: 34 * scale)),
        ),
      ),
    );
  }
}
