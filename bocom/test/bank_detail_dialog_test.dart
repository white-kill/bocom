import 'package:bocom/pages/tabs/mine/children/account_asset/bank_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(toastSize, const Size(110, 40));
  });
}
