import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/abc_config/boc_logic.dart';
import '../../../../config/model/member_info_model.dart';
import '../../../../routes/app_pages.dart';

const double _depositSourceWidth = 1080;
const double _depositSourceHeight = 2701;

// 我的存款页
// 说明：页面按参考图原生绘制；账户尾号、人民币总额和账户存款金额来自当前登录账户，导航随首屏滚动并在滚出后固定。
class HomeMyDepositPage extends StatefulWidget {
  const HomeMyDepositPage({super.key});

  @override
  State<HomeMyDepositPage> createState() => _HomeMyDepositPageState();
}

class _HomeMyDepositPageState extends State<HomeMyDepositPage> {
  late final ScrollController _scrollController;
  int _selectedAccountIndex = 0;
  bool _showPinnedNavigation = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false)
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final scale = MediaQuery.sizeOf(context).width / _depositSourceWidth;
    final shouldShow = _scrollController.offset >= 216 * scale;
    if (shouldShow == _showPinnedNavigation) return;
    setState(() => _showPinnedNavigation = shouldShow);
  }

  Future<void> _selectAccount(List<MemberInfoBankList> accounts) async {
    if (accounts.length < 2) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Text(
                '切换币种 | 账户',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            for (var index = 0; index < accounts.length; index++)
              ListTile(
                key: Key('my-deposit-account-option-$index'),
                title: Text(_accountTitle(accounts[index])),
                trailing: index == _selectedAccountIndex
                    ? const Icon(Icons.check_rounded, color: Color(0xFF1687ED))
                    : null,
                onTap: () => Navigator.of(context).pop(index),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedAccountIndex = selected);
  }

  @override
  Widget build(BuildContext context) {
    const systemStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Color(0xFFF7F7F7),
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemStyle,
      child: Scaffold(
        key: const Key('home-my-deposit-page'),
        backgroundColor: const Color(0xFFF7F7F7),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final scale = constraints.maxWidth / _depositSourceWidth;
                  return SingleChildScrollView(
                    key: const Key('home-my-deposit-scroll-view'),
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: _depositSourceHeight * scale,
                      child: Get.isRegistered<BocLogic>()
                          ? GetBuilder<BocLogic>(
                              id: 'updateUI',
                              builder: (logic) => _DepositCanvas(
                                scale: scale,
                                logic: logic,
                                selectedAccountIndex: _selectedAccountIndex,
                                onSelectAccount: _selectAccount,
                              ),
                            )
                          : _DepositCanvas(
                              scale: scale,
                              logic: null,
                              selectedAccountIndex: _selectedAccountIndex,
                              onSelectAccount: _selectAccount,
                            ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: IgnorePointer(
                ignoring: !_showPinnedNavigation,
                child: AnimatedOpacity(
                  key: const Key('home-my-deposit-pinned-navigation'),
                  opacity: _showPinnedNavigation ? 1 : 0,
                  duration: const Duration(milliseconds: 140),
                  child: const _DepositPinnedNavigation(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositCanvas extends StatelessWidget {
  const _DepositCanvas({
    required this.scale,
    required this.logic,
    required this.selectedAccountIndex,
    required this.onSelectAccount,
  });

  final double scale;
  final BocLogic? logic;
  final int selectedAccountIndex;
  final ValueChanged<List<MemberInfoBankList>> onSelectAccount;

  List<MemberInfoBankList> get _accounts =>
      logic?.memberInfo.bankList ?? const [];

  MemberInfoBankList? get _selectedAccount {
    if (_accounts.isEmpty) return null;
    return _accounts[math.min(selectedAccountIndex, _accounts.length - 1)];
  }

  double get _rmbTotal {
    if (_accounts.isEmpty) return logic?.memberInfo.accountBalance ?? 0;
    final total = _accounts.fold<double>(
      0,
      (value, account) => value + account.accountBalance,
    );
    if (total == 0 && (logic?.memberInfo.accountBalance ?? 0) != 0) {
      return logic!.memberInfo.accountBalance;
    }
    return total;
  }

  double get _selectedAmount {
    final account = _selectedAccount;
    if (account != null) return account.accountBalance;
    return logic?.memberInfo.accountBalance ?? 0;
  }

  String _money(double value) => NumberFormat('#,##0.00').format(value);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFFF7F7F7)),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 760 * scale,
          child: CustomPaint(painter: _DepositHeaderPainter()),
        ),
        _scaledPosition(
          left: 43,
          top: 113,
          width: 84,
          height: 84,
          child: Semantics(
            button: true,
            label: '返回',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: Get.back,
              child: Image.asset('assets/images/nav_back_light.png'),
            ),
          ),
        ),
        _scaledPosition(
          left: 958,
          top: 113,
          width: 84,
          height: 84,
          child: _ServiceButton(scale: scale),
        ),
        _scaledPosition(
          left: 280,
          top: 121,
          width: 520,
          height: 72,
          child: Center(
            child: _text(
              '我的存款',
              fontSize: 58,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _scaledText(
          key: const Key('my-deposit-rmb-label'),
          text: '总金额(人民币)',
          left: 102,
          top: 269,
          width: 410,
          height: 60,
          fontSize: 43,
          color: const Color(0x99FFFFFF),
        ),
        _scaledText(
          key: const Key('my-deposit-rmb-total'),
          text: _money(_rmbTotal),
          left: 102,
          top: 337,
          width: 350,
          height: 78,
          fontSize: 67,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        _scaledText(
          text: '总金额(外币折算)',
          left: 596,
          top: 269,
          width: 420,
          height: 60,
          fontSize: 43,
          color: const Color(0x99FFFFFF),
        ),
        _scaledText(
          key: const Key('my-deposit-foreign-total'),
          text: '0.00',
          left: 596,
          top: 337,
          width: 350,
          height: 78,
          fontSize: 67,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        _scaledPosition(
          left: 539,
          top: 294,
          width: 2,
          height: 86,
          child: const ColoredBox(color: Color(0x36FFFFFF)),
        ),
        _scaledPosition(
          left: 42,
          top: 454,
          width: 996,
          height: 316,
          child: CustomPaint(painter: _DepositAccountCardPainter()),
        ),
        _scaledPosition(
          left: 96,
          top: 496,
          width: 56,
          height: 56,
          child: const CustomPaint(painter: _CurrencyStackPainter()),
        ),
        _scaledText(
          key: const Key('my-deposit-account-title'),
          text: _accountTitle(_selectedAccount),
          left: 155,
          top: 490,
          width: 490,
          height: 70,
          fontSize: 42,
          color: const Color(0xFF555555),
        ),
        _scaledPosition(
          left: 662,
          top: 468,
          width: 376,
          height: 96,
          child: Semantics(
            button: true,
            label: '切换币种和账户',
            child: GestureDetector(
              key: const Key('my-deposit-account-switch'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelectAccount(_accounts),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: _text(
                      '切换币种 | 账户',
                      fontSize: 40,
                      color: const Color(0xFF315A80),
                    ),
                  ),
                  SizedBox(width: 14 * scale),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 47 * scale,
                    color: const Color(0xFF315A80),
                  ),
                ],
              ),
            ),
          ),
        ),
        _scaledText(
          text: '存款金额',
          left: 101,
          top: 600,
          width: 360,
          height: 65,
          fontSize: 43,
          color: const Color(0xFF888888),
        ),
        _scaledText(
          key: const Key('my-deposit-account-amount'),
          text: _money(_selectedAmount),
          left: 101,
          top: 650,
          width: 390,
          height: 92,
          fontSize: 72,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111111),
        ),
        _actionCard(context),
        _emptyHoldings(context),
        _tips(),
      ],
    );
  }

  Widget _actionCard(BuildContext context) {
    final actions = [
      _DepositAction(
        label: '交易明细',
        assetPath: 'assets/images/home_my_deposit_transaction.png',
        onTap: () => Get.toNamed(Routes.transactionDetail),
      ),
      const _DepositAction(
        label: '我的预约',
        assetPath: 'assets/images/home_my_deposit_appointment.png',
      ),
      const _DepositAction(
        label: '我的收藏',
        assetPath: 'assets/images/home_my_deposit_favorite.png',
      ),
      const _DepositAction(
        label: '我的预购',
        assetPath: 'assets/images/home_my_deposit_purchase.png',
      ),
    ];

    return _scaledPosition(
      left: 42,
      top: 803,
      width: 996,
      height: 239,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28 * scale),
        ),
        child: Row(
          children: [
            for (final action in actions)
              Expanded(
                child: Semantics(
                  button: true,
                  label: action.label,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: action.onTap ?? () {},
                    child: Column(
                      children: [
                        SizedBox(height: 38 * scale),
                        SizedBox(
                          width: 105 * scale,
                          height: 108 * scale,
                          child: Image.asset(
                            action.assetPath,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                        SizedBox(height: 5 * scale),
                        _text(
                          action.label,
                          fontSize: 42,
                          color: const Color(0xFF171717),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyHoldings(BuildContext context) {
    return _scaledPosition(
      left: 42,
      top: 1077,
      width: 996,
      height: 931,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28 * scale),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 372 * scale,
              top: 283 * scale,
              width: 252 * scale,
              height: 236 * scale,
              child: Image.asset(
                'assets/images/ic_common_empty.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 551 * scale,
              height: 70 * scale,
              child: Center(
                child: _text(
                  '您暂无产品持仓',
                  fontSize: 44,
                  color: const Color(0xFF565656),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 620 * scale,
              height: 70 * scale,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 42 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF515151),
                    ),
                    children: const [
                      TextSpan(text: '点击查看'),
                      TextSpan(
                        text: '全部存款产品',
                        style: TextStyle(color: Color(0xFF0088EB)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 255 * scale,
              right: 255 * scale,
              top: 615 * scale,
              height: 82 * scale,
              child: Semantics(
                button: true,
                label: '查看全部存款产品',
                child: GestureDetector(
                  key: const Key('my-deposit-all-products'),
                  behavior: HitTestBehavior.opaque,
                  onTap: Get.back,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tips() {
    const body = '1、每日数据处理期间，存款总额与实际总额可能会有短暂偏差，\n'
        '完成处理后将恢复正常。\n'
        '2、本页面总金额（人民币及外币折算）为您本人已添加银行卡、\n'
        '存单存折的存款产品总额，不含已添加的儿童卡的存款产品总\n'
        '额。\n'
        '3、本页面“交易明细”中暂不支持存单存折交易明细查询，您可通\n'
        '过“我的账户”页面选择所需查询的存单存折，点击“交易明细”进行\n'
        '查询。';

    return Stack(
      children: [
        _scaledText(
          text: '温馨提示：',
          left: 43,
          top: 2050,
          width: 450,
          height: 68,
          fontSize: 43,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8A8A8A),
        ),
        _scaledPosition(
          left: 43,
          top: 2120,
          width: 994,
          height: 520,
          child: Text(
            body,
            style: TextStyle(
              color: const Color(0xFF929292),
              fontSize: 35 * scale,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _text(
    String value, {
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: fontSize * scale,
        fontWeight: fontWeight,
        height: 1.08,
      ),
    );
  }

  Widget _scaledText({
    Key? key,
    required String text,
    required double left,
    required double top,
    required double width,
    required double height,
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return _scaledPosition(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          key: key,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: fontSize * scale,
            fontWeight: fontWeight,
            height: 1.08,
          ),
        ),
      ),
    );
  }

  Widget _scaledPosition({
    required double left,
    required double top,
    required double width,
    required double height,
    required Widget child,
  }) {
    return Positioned(
      left: left * scale,
      top: top * scale,
      width: width * scale,
      height: height * scale,
      child: child,
    );
  }
}

String _accountTitle(MemberInfoBankList? account) {
  if (account == null) return '人民币 | I类账户';
  final digits = account.bankCard.replaceAll(RegExp(r'\D'), '');
  final suffix = digits.isEmpty
      ? ''
      : digits.length <= 4
          ? digits
          : digits.substring(digits.length - 4);
  final rawType = account.cardType.trim();
  final accountType = rawType.contains('类账户') ? rawType : 'II类账户';
  return '人民币 | $accountType${suffix.isEmpty ? '' : '(**$suffix)'}';
}

class _DepositAction {
  const _DepositAction({
    required this.label,
    required this.assetPath,
    this.onTap,
  });

  final String label;
  final String assetPath;
  final VoidCallback? onTap;
}

class _ServiceButton extends StatelessWidget {
  const _ServiceButton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '客服',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(Routes.customerService),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0x2C286CB5),
            borderRadius: BorderRadius.circular(26 * scale),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/home_nav_service_light.png',
              width: 51 * scale,
              height: 51 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

class _DepositPinnedNavigation extends StatelessWidget {
  const _DepositPinnedNavigation();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Material(
      color: const Color(0xFF397FEA),
      child: SizedBox(
        width: double.infinity,
        height: statusBarHeight + 48,
        child: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                '我的存款',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Positioned(
                left: 8,
                top: 4,
                bottom: 4,
                child: Semantics(
                  button: true,
                  label: '返回',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: Get.back,
                    child: Image.asset('assets/images/nav_back_light.png'),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 5,
                bottom: 5,
                child: _ServiceButton(
                  scale: MediaQuery.sizeOf(context).width / _depositSourceWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepositHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF166DEA), Color(0xFF76C4FA)],
          stops: [0, 1],
        ).createShader(rect),
    );

    final backRibbon = Path()
      ..moveTo(size.width * .53, size.height * .12)
      ..cubicTo(
        size.width * .76,
        size.height * .16,
        size.width * .83,
        size.height * .27,
        size.width,
        size.height * .31,
      )
      ..lineTo(size.width, size.height * .48)
      ..cubicTo(
        size.width * .84,
        size.height * .41,
        size.width * .71,
        size.height * .36,
        size.width * .53,
        size.height * .12,
      )
      ..close();
    canvas.drawPath(backRibbon, Paint()..color = const Color(0x112069DA));

    final glow =
        Rect.fromLTWH(0, size.height * .46, size.width, size.height * .54);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x001C78EC), Color(0xD8F7F7F7)],
        ).createShader(glow),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DepositAccountCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * .028),
    );
    canvas.drawRRect(outer, Paint()..color = Colors.white);

    final rightTab = Path()
      ..moveTo(size.width * .58, size.height * .04)
      ..lineTo(size.width * .97, size.height * .04)
      ..quadraticBezierTo(
          size.width, size.height * .04, size.width, size.height * .15)
      ..lineTo(size.width, size.height * .36)
      ..lineTo(size.width * .69, size.height * .36)
      ..cubicTo(
        size.width * .65,
        size.height * .36,
        size.width * .64,
        size.height * .28,
        size.width * .62,
        size.height * .21,
      )
      ..close();
    final tabBounds = rightTab.getBounds();
    canvas.drawPath(
      rightTab,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFDDF2FF), Color(0xFFF2FFF8)],
        ).createShader(tabBounds),
    );

    final leftHeader = Path()
      ..moveTo(0, size.height * .12)
      ..quadraticBezierTo(0, 0, size.width * .04, 0)
      ..lineTo(size.width * .59, 0)
      ..lineTo(size.width * .65, size.height * .34)
      ..lineTo(0, size.height * .34)
      ..close();
    canvas.drawPath(
      leftHeader,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xEBF8FAFF)],
        ).createShader(leftHeader.getBounds()),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurrencyStackPainter extends CustomPainter {
  const _CurrencyStackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * .18;
    final width = size.width * .64;
    final ovalHeight = size.height * .22;
    final bodyTop = size.height * .22;
    final bodyBottom = size.height * .79;
    final blue = Paint()..color = const Color(0xFF26A5F5);
    final highlight = Paint()
      ..color = const Color(0xFF8AD7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .055;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, bodyTop, left + width, bodyBottom),
        Radius.circular(size.width * .08),
      ),
      blue,
    );
    canvas.drawOval(
      Rect.fromLTWH(left, size.height * .12, width, ovalHeight),
      Paint()..color = const Color(0xFF5CC2FB),
    );
    canvas.drawArc(
      Rect.fromLTWH(left, size.height * .31, width, ovalHeight),
      0,
      math.pi,
      false,
      highlight,
    );
    canvas.drawArc(
      Rect.fromLTWH(left, size.height * .50, width, ovalHeight),
      0,
      math.pi,
      false,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
