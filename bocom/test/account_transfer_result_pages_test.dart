import 'dart:async';
import 'dart:ui' as ui;

import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/pages/tabs/home/transfer/account_transfer/account_transfer_result_pages.dart';
import 'package:bocom/pages/tabs/mine/children/account_asset/account_asset_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  final result = AccountTransferResultData(
    billId: 10020,
    recipientName: '张三',
    recipientAccount: '6217001630076962353',
    recipientBank: '中国建设银行',
    amount: 1,
    payerName: '李四',
    payerAccount: '6222620000002910',
    payerBank: '交通银行',
    transactionTime: DateTime(2026, 8, 12, 11, 29, 52),
    arrivalText: '预计实时到账',
    purpose: '货款',
    serialNumber: '2005000420260812436002307520',
  );

  testWidgets('转账成功页显示真实数据并进入回执页', (tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 956));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GetMaterialApp(
        home: AccountTransferSuccessPage(
          data: result,
          billDetailLoader: (_) async => {
            'billDetail': {
              'transactionTime': '2026-08-12 11:30:00',
              'transactionLogno': 'DETAIL202608121130',
            },
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('¥1.00'), findsOneWidget);
    expect(find.text('张三'), findsOneWidget);
    expect(find.text('中国建设银行(**2353)'), findsOneWidget);
    expect(find.text('设置卡(**2910)为转账默认付款卡'), findsOneWidget);
    expect(find.bySemanticsLabel('通知收款人'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('通知收款人'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('account-transfer-receipt-page')), findsOneWidget);
    expect(find.text('621700****2353'), findsOneWidget);
    expect(find.text('622262****2910'), findsOneWidget);
    expect(find.text('DETAIL202608121130'), findsOneWidget);
    expect(find.text('2026-08-12 11:30:00'), findsOneWidget);
    expect(find.text('人民币壹元整'), findsOneWidget);
    expect(
      find.byKey(const Key('receipt-single-line-serial-body')),
      findsOneWidget,
    );
  });

  testWidgets('转账记录跳转已有页面', (tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 956));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(
            name: Routes.homeTransferRecord,
            page: () => const Scaffold(body: Text('转账记录目标页')),
          ),
        ],
        home: AccountTransferSuccessPage(
          data: result,
          billDetailLoader: (_) async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('转账记录'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('转账记录'));
    await tester.pumpAndSettle();

    expect(find.text('转账记录目标页'), findsOneWidget);
  });

  testWidgets('查询余额进入我的账户左侧Tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(440, 956));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    AppConfig.config.abcLogic = Get.put<BocLogic>(_TestBocLogic());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(440, 956),
        builder: (_, __) => GetMaterialApp(
          home: AccountTransferSuccessPage(
            data: result,
            billDetailLoader: (_) async => null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('查询余额'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('查询余额'));
    await tester.pumpAndSettle();

    final accountPage = tester.widget<AccountAssetPage>(
      find.byType(AccountAssetPage),
    );
    expect(accountPage.initialTabIndex, 0);
    expect(find.text('我的账户'), findsOneWidget);
  });

  testWidgets('回执中间独立滚动且底部切换完整卡号', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: AccountTransferReceiptPage(data: result)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('receipt-fixed-navigation')), findsOneWidget);
    expect(find.byKey(const Key('receipt-fixed-footer')), findsOneWidget);
    expect(find.text('621700****2353'), findsOneWidget);
    expect(find.text('622262****2910'), findsOneWidget);
    expect(find.text('20050004202608124360023075\n20'), findsOneWidget);
    expect(
      find.byKey(const Key('receipt-wrapped-serial-body')),
      findsOneWidget,
    );

    final footerBefore = tester.getTopLeft(
      find.byKey(const Key('receipt-fixed-footer')),
    );
    await tester.drag(
      find.byKey(const Key('receipt-content-scroll-view')),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const Key('receipt-fixed-footer'))),
      footerBefore,
    );

    await tester.tap(find.bySemanticsLabel('隐藏收付款卡号'));
    await tester.pumpAndSettle();
    expect(find.text('6217 0016 3007 6962 353'), findsOneWidget);
    expect(find.text('6222 6200 0000 2910'), findsOneWidget);
    expect(find.text('621700****2353'), findsNothing);
    expect(find.bySemanticsLabel('保存图片'), findsOneWidget);
    expect(find.bySemanticsLabel('通知微信好友'), findsOneWidget);
  });

  testWidgets('流水号达到28位才切换两行底图', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final singleLineSerial = List.filled(27, '0').join();
    final firstWrappedLine = List.filled(26, '0').join();
    final wrappedSerial = '${firstWrappedLine}00';

    await tester.pumpWidget(
      MaterialApp(
        home: AccountTransferReceiptPage(
          data: result.copyWith(serialNumber: singleLineSerial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(singleLineSerial), findsOneWidget);
    expect(
      find.byKey(const Key('receipt-single-line-serial-body')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('receipt-wrapped-serial-body')),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AccountTransferReceiptPage(
          data: result.copyWith(serialNumber: wrappedSerial),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('$firstWrappedLine\n00'), findsOneWidget);
    expect(
      find.byKey(const Key('receipt-wrapped-serial-body')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('receipt-single-line-serial-body')),
      findsNothing,
    );
  });

  final saveResult = AccountTransferResultData(
    billId: 0,
    recipientName: '测试收款人',
    recipientAccount: '0000000000000001',
    recipientBank: '测试收款银行',
    amount: 0.1,
    payerName: '测试付款人',
    payerAccount: '0000000000000002',
    payerBank: '测试付款银行',
    transactionTime: DateTime(2026, 1, 1),
    arrivalText: '预计实时到账',
    purpose: '测试回执',
    serialNumber: 'TEST00000000000000000000000000',
  );

  testWidgets('保存先隐藏底栏并回到顶部，导出完整PNG后显示成功底部弹窗', (tester) async {
    final saveCompleter = Completer<bool>();
    late Completer<void> saveStarted;
    Uint8List? savedBytes;
    tester.view.physicalSize = const Size(383, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: AccountTransferReceiptPage(
          data: saveResult,
          receiptSaver: (bytes) async {
            expect(find.byKey(const Key('receipt-fixed-footer')), findsNothing);
            expect(find.byKey(const Key('receipt-save-result-sheet')),
                findsNothing);
            savedBytes = bytes;
            saveStarted.complete();
            return saveCompleter.future;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scrollFinder = find.byKey(const Key('receipt-content-scroll-view'));
    await tester.drag(scrollFinder, const Offset(0, -350));
    await tester.pumpAndSettle();
    final scrollController =
        tester.widget<SingleChildScrollView>(scrollFinder).controller!;
    expect(scrollController.offset, greaterThan(0));

    await tester.runAsync(() async {
      saveStarted = Completer<void>();
      await tester.tap(find.bySemanticsLabel('保存图片'));
      await tester.pump();
      await saveStarted.future.timeout(const Duration(seconds: 5));
    });
    expect(find.byKey(const Key('receipt-fixed-footer')), findsNothing);
    expect(find.text('保存成功'), findsNothing);
    expect(scrollController.offset, 0);
    expect(savedBytes, isNotNull);
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(savedBytes!);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1206);
      expect(frame.image.height, (1987 * 1206 / 1080).ceil());
      frame.image.dispose();
      codec.dispose();
    });

    saveCompleter.complete(true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('receipt-save-result-sheet')), findsOneWidget);
    expect(find.text('提示'), findsOneWidget);
    expect(find.text('保存成功'), findsOneWidget);
    expect(find.byKey(const Key('receipt-fixed-footer')), findsNothing);
    final overlayRect = tester.getRect(
      find.byKey(const Key('receipt-save-result-overlay')),
    );
    expect(overlayRect.top, 0);
    expect(overlayRect.bottom, 850);
    expect(
      tester
          .widget<Scaffold>(
            find.byKey(const Key('account-transfer-receipt-page')),
          )
          .backgroundColor,
      const Color(0xFFF7F7F7),
    );
    expect(SystemChrome.latestStyle?.statusBarColor, Colors.transparent);
    expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.light);
    final sheetRect =
        tester.getRect(find.byKey(const Key('receipt-save-result-sheet')));
    expect(sheetRect.bottom, 850);
    expect(sheetRect.height, 286);

    await tester.runAsync(() async {
      await tester.tap(find.text('确定'));
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('receipt-save-result-sheet')), findsNothing);
    expect(find.byKey(const Key('receipt-fixed-footer')), findsOneWidget);
    expect(
      tester
          .widget<Scaffold>(
            find.byKey(const Key('account-transfer-receipt-page')),
          )
          .backgroundColor,
      const Color(0xFFF7F7F7),
    );
    expect(find.text('000000****0001'), findsOneWidget);
    expect(find.text('000000****0002'), findsOneWidget);
  });

  for (final throwsError in [false, true]) {
    testWidgets('保存${throwsError ? '异常' : '失败'}后提示失败并可重新保存', (tester) async {
      var attempts = 0;
      late Completer<void> saveStarted;
      tester.view.physicalSize = const Size(383, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        home: AccountTransferReceiptPage(
          data: saveResult,
          receiptSaver: (_) async {
            attempts++;
            saveStarted.complete();
            if (attempts == 1 && throwsError) {
              throw StateError('test save error');
            }
            return attempts > 1;
          },
        ),
      ));
      await tester.pumpAndSettle();

      Future<void> save() async {
        await tester.runAsync(() async {
          saveStarted = Completer<void>();
          await tester.tap(find.bySemanticsLabel('保存图片'));
          await tester.pump();
          await saveStarted.future.timeout(const Duration(seconds: 5));
        });
        await tester.pumpAndSettle();
      }

      await save();
      expect(find.text('保存失败，请重试'), findsOneWidget);
      expect(find.text('保存成功'), findsNothing);
      await tester.runAsync(() async {
        await tester.tap(find.text('确定'));
      });
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('receipt-fixed-footer')), findsOneWidget);

      await save();
      expect(attempts, 2);
      expect(find.text('保存成功'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('确定'));
      });
      await tester.pumpAndSettle();
    });
  }
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
