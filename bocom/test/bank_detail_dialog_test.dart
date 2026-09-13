import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/pages/tabs/mine/children/account_asset/bank_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

void main() {
  testWidgets('账号详情右侧三行文字使用参考图灰色', (tester) async {
    tester.view.physicalSize = const Size(375, 750);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppConfig.config.abcLogic = BocLogic();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: BankDetailDialog(),
          ),
        ),
      ),
    );

    final values = tester.widgetList<BaseText>(
      find.descendant(
        of: find.byType(BankDetailDialog),
        matching: find.byType(BaseText),
      ),
    );
    expect(values, hasLength(3));
    expect(
      values.map((value) => value.color),
      everyElement(const Color(0xFF6A6A6A)),
    );
  });

  testWidgets('账号复制提示显示在页面上方', (tester) async {
    tester.view.physicalSize = const Size(375, 750);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: BankDetailCopiedToast(),
            ),
          ),
        ),
      ),
    );

    final toastTop = tester.getTopLeft(
      find.byKey(const Key('bank-detail-copied-toast')),
    );
    final toastSize = tester.getSize(
      find.byKey(const Key('bank-detail-copied-toast')),
    );
    expect(toastTop.dy, closeTo(129, 0.1));
    expect(toastTop.dy, lessThan(750 / 2));
    expect(toastSize, const Size(100, 36));
  });
}
