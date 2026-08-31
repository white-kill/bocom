import 'dart:async';

import 'package:bocom/config/model/contacts_model.dart';
import 'package:bocom/pages/component/indicator_loading.dart';
import 'package:bocom/pages/tabs/home/transfer/account_transfer/account_transfer_support_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('全部收款人显示所有数据并生成动态分组和索引', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final first = ContactsModel()
      ..name = '安安'
      ..bankName = '中国建设银行'
      ..bankCard = '6222000012345678'
      ..phone = '13113113113';
    final second = ContactsModel()
      ..name = '张三'
      ..bankName = '交通银行'
      ..bankCard = '6217000012342910';

    await tester.pumpWidget(
      GetMaterialApp(
        home: AccountTransferRecipientsPage(
          contactsLoader: () async => [second, first],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('安安'), findsOneWidget);
    expect(find.text('张三'), findsOneWidget);
    expect(find.text('中国建设银行 借记卡 (**5678)'), findsOneWidget);
    expect(find.text('A'), findsWidgets);
    expect(find.text('Z'), findsWidgets);
    expect(find.text('S'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('all-recipients-header'))).height,
      closeTo(325, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const Key('recipient-section-A'))).height,
      closeTo(80, 0.1),
    );
    expect(
      tester
          .getSize(
            find.byKey(const Key('recipient-row-6222000012345678')),
          )
          .height,
      closeTo(193, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const Key('add-recipient-bottom-bar'))).height,
      closeTo(124, 0.1),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('recipient-alphabet-rail-items')))
          .height,
      closeTo(100, 0.1),
    );
    final aIndex = tester.getCenter(
      find.byKey(const Key('recipient-alphabet-item-A')),
    );
    final zIndex = tester.getCenter(
      find.byKey(const Key('recipient-alphabet-item-Z')),
    );
    expect(zIndex.dy - aIndex.dy, closeTo(50, 0.1));

    await tester.tap(find.bySemanticsLabel('编辑安安'));
    await tester.pumpAndSettle();
    expect(find.text('编辑收款人'), findsOneWidget);
    expect(find.widgetWithText(TextField, '安安'), findsOneWidget);
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('all-recipients-search')),
      '13113113113',
    );
    await tester.pump();
    expect(find.text('安安'), findsOneWidget);
    expect(find.text('张三'), findsNothing);
    expect(find.text('A'), findsWidgets);
    expect(find.text('Z'), findsNothing);

    await tester.tap(find.bySemanticsLabel('添加收款人'));
    await tester.pumpAndSettle();
    expect(find.byType(AddRecipientPage), findsOneWidget);
    expect(find.byTooltip('扫描银行卡'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('add-recipient-header'))).height,
      closeTo(196, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const Key('add-recipient-row-户名'))).height,
      closeTo(132.8, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const Key('add-recipient-group-gap'))).height,
      closeTo(44, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const Key('add-recipient-row-手机号'))).height,
      closeTo(132, 0.1),
    );
    final nextButton = tester.getRect(
      find.byKey(const Key('add-recipient-next-button')),
    );
    expect(nextButton.left, closeTo(43, 0.1));
    expect(nextButton.top, closeTo(1255, 0.1));
    expect(nextButton.width, closeTo(994, 0.1));
    expect(nextButton.height, closeTo(127, 0.1));
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '下一步'))
          .onPressed,
      isNotNull,
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('add-recipient-row-开户地')),
        matching: find.byType(TextField),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('收款人页区分加载、空态和失败重试', (tester) async {
    final completer = Completer<List<ContactsModel>>();
    await tester.pumpWidget(
      GetMaterialApp(
        home: AccountTransferRecipientsPage(
          contactsLoader: () => completer.future,
        ),
      ),
    );

    expect(find.text('正在加载收款人'), findsOneWidget);
    expect(find.text('S'), findsNothing);
    completer.complete(const []);
    await tester.pumpAndSettle();
    expect(find.text('暂无收款人'), findsOneWidget);

    await tester.pumpWidget(
      GetMaterialApp(
        home: AccountTransferRecipientsPage(
          contactsLoader: () async => throw Exception('network'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('收款人加载失败'), findsOneWidget);
    expect(find.text('重新加载'), findsOneWidget);
  });

  testWidgets('银行页使用加载器数据而不是固定截图银行', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: RecipientBankPage(
          bankLoader: () async => const [
            RecipientBank(name: '测试甲银行'),
            RecipientBank(name: '测试乙银行'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('测试甲银行'), findsWidgets);
    expect(find.text('测试乙银行'), findsWidgets);
    expect(find.text('交通银行'), findsNothing);
  });

  testWidgets('银行页加载态使用转账小圆弧', (tester) async {
    final completer = Completer<List<RecipientBank>>();
    await tester.pumpWidget(
      GetMaterialApp(
        home: RecipientBankPage(bankLoader: () => completer.future),
      ),
    );

    expect(find.byType(BocomArcLoadingIndicator), findsOneWidget);
    expect(find.text('正在加载银行'), findsNothing);

    completer.complete(const [RecipientBank(name: '交通银行')]);
    await tester.pumpAndSettle();
    expect(find.byType(BocomArcLoadingIndicator), findsNothing);
  });

  testWidgets('银行页按接口数据保持参考图比例', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        home: RecipientBankPage(
          bankLoader: () async => const [
            RecipientBank(name: '交通银行', initial: 'J', hot: true),
            RecipientBank(name: '华夏银行', initial: 'H'),
            RecipientBank(name: '中国民生银行', initial: 'Z'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('收款银行'), findsOneWidget);
    expect(find.text('热门银行'), findsOneWidget);
    expect(find.text('交通银行'), findsWidgets);
    expect(find.text('华夏银行'), findsWidgets);
    expect(
      tester.getSize(find.byKey(const Key('recipient-bank-header'))).height,
      closeTo(270, 0.1),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('recipient-bank-section-热门银行')))
          .height,
      closeTo(95, 0.1),
    );
    expect(
      tester
          .getSize(
            find.byKey(const Key('recipient-bank-row-交通银行')).first,
          )
          .height,
      closeTo(132, 0.1),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('recipient-bank-alphabet-rail')))
          .height,
      closeTo(1196, 0.1),
    );

    await tester.enterText(
      find.byKey(const Key('recipient-bank-search')),
      '民生',
    );
    await tester.pump();
    expect(find.text('中国民生银行'), findsOneWidget);
    expect(find.text('交通银行'), findsNothing);
    expect(find.byKey(const Key('recipient-bank-alphabet-rail')), findsNothing);
  });

  test('银行接口字段兼容名称、图标和首字母', () {
    final bank = RecipientBank.fromJson({
      'id': 1,
      'bankName': '中国建设银行',
      'bankLogo': 'https://example.com/ccb.png',
      'firstLetter': 'J',
      'hot': 1,
    });

    expect(bank.id, 1);
    expect(bank.name, '中国建设银行');
    expect(bank.icon, 'https://example.com/ccb.png');
    expect(bank.initial, 'J');
    expect(bank.hot, isTrue);
    expect(
      bank.asset,
      'assets/images/account_transfer/banks/bank_construction.jpg',
    );
  });

  test('银行列表解析真实响应并保留接口顺序和热门列表', () {
    final catalog = RecipientBankCatalog.fromResponse({
      'code': 200,
      'data': {
        'bankList': [
          {
            'id': 25,
            'name': '鞍山银行',
            'initial': 'A',
            'icon': 'http://example.com/ascb.png',
            'hot': 0,
          },
          {
            'id': 5,
            'name': '交通银行',
            'initial': 'J',
            'icon': 'http://example.com/comm.png',
            'hot': 1,
          },
          {
            'id': 1,
            'name': '中国建设银行',
            'initial': 'Z',
            'icon': 'http://example.com/ccb.png',
            'hot': 0,
          },
        ],
        'hotList': [
          {
            'id': 5,
            'name': '交通银行',
            'initial': 'J',
            'icon': 'http://example.com/comm.png',
            'hot': 1,
          },
        ],
      },
    });

    expect(
      catalog.banks.map((bank) => bank.name),
      ['鞍山银行', '交通银行', '中国建设银行'],
    );
    expect(catalog.banks.last.initial, 'Z');
    expect(catalog.hotBanks.map((bank) => bank.name), ['交通银行']);
  });

  testWidgets('扫描银行卡页按设计比例绘制四角框并在拍摄后返回', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Get.to<void>(
                () => const BankCardScannerPage(),
              ),
              child: const Text('打开扫描页'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开扫描页'));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(
      find.byKey(const Key('bank-card-scanner-scaffold')),
    );
    expect(scaffold.backgroundColor, const Color(0xFF646464));
    final frameRect = tester.getRect(
      find.byKey(const Key('bank-card-scan-corners')),
    );
    expect(frameRect.left, closeTo(37, 0.1));
    expect(frameRect.top, closeTo(732, 0.1));
    expect(frameRect.width, closeTo(1006, 0.1));
    expect(frameRect.height, closeTo(654, 0.1));

    await tester.tap(find.bySemanticsLabel('返回'));
    await tester.pumpAndSettle();
    expect(find.byType(BankCardScannerPage), findsNothing);

    await tester.tap(find.text('打开扫描页'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('拍摄银行卡'));
    await tester.pumpAndSettle();
    expect(find.byType(BankCardScannerPage), findsNothing);
  });

  testWidgets('到账时间和限额面板可打开关闭', (tester) async {
    var queryTaps = 0;
    var modifyTaps = 0;
    var collapseTaps = 0;
    String? arrivalResult;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                TextButton(
                  onPressed: () async {
                    arrivalResult = await showArrivalTimeSheet(
                      context,
                      '预计实时到账',
                    );
                  },
                  child: const Text('到账时间'),
                ),
                TextButton(
                  onPressed: () => showTransferLimitSheet(
                    context,
                    onQuery: () => queryTaps++,
                    onModify: () => modifyTaps++,
                    onCollapse: () => collapseTaps++,
                  ),
                  child: const Text('限额'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('到账时间'));
    await tester.pumpAndSettle();
    final sheetSize = tester.getSize(
      find.byKey(const Key('arrival-time-sheet')),
    );
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      sheetSize.height,
      closeTo(viewportHeight * ((1280 - 478) / 1280), 0.1),
    );
    expect(find.bySemanticsLabel('预计2小时后到账'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('预计2小时后到账'));
    await tester.pumpAndSettle();
    expect(arrivalResult, '预计2小时后到账');

    await tester.tap(find.text('限额'));
    await tester.pumpAndSettle();
    expect(
      find.image(
        const AssetImage(
          'assets/images/account_transfer/limit_sheet/limit_sheet_expanded.png',
        ),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('关闭'), findsOneWidget);
    expect(find.bySemanticsLabel('查询限额'), findsOneWidget);
    expect(find.bySemanticsLabel('修改限额'), findsOneWidget);
    expect(find.bySemanticsLabel('收起验证方式说明'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('查询限额'));
    await tester.tap(find.bySemanticsLabel('修改限额'));
    await tester.tap(find.bySemanticsLabel('收起验证方式说明'));
    expect(queryTaps, 1);
    expect(modifyTaps, 1);
    expect(collapseTaps, 1);
    await tester.tap(find.bySemanticsLabel('关闭'));
    await tester.pumpAndSettle();
  });

  testWidgets('确认转账完成校验后显示 loading 并直接进入结果页', (tester) async {
    final recipient = ContactsModel()
      ..name = ' 张三 '
      ..bankCard = ' 6222000012341234 '
      ..bankName = ' 中国工商银行 ';
    await tester.pumpWidget(
      GetMaterialApp(
        home: AccountTransferConfirmationPage(
          recipient: recipient,
          amount: '1,500.25',
          description: ' 货款 ',
          arrivalTime: '预计2小时后到账',
          passwordVerificationLauncher: (_, __) async => true,
          smsVerificationLauncher: (_, __, ___) async => true,
        ),
      ),
    );

    await tester.tap(find.text('确认转账'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('transfer-loading-indicator')), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('account-transfer-success-page')),
      findsOneWidget,
    );
    expect(find.text('张三'), findsOneWidget);
    expect(find.text('中国工商银行(**1234)'), findsOneWidget);
  });
}
