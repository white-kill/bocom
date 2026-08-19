import 'package:bocom/pages/other/scan/scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('扫描线单向下移后直接重置到顶部', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(home: ScanPage(enableCamera: false)),
    );

    final initialTop = tester
        .getTopLeft(
          find.byKey(const Key('animated-scan-line')),
        )
        .dy;
    await tester.pump(const Duration(milliseconds: 2200));
    final nearBottomTop = tester
        .getTopLeft(
          find.byKey(const Key('animated-scan-line')),
        )
        .dy;
    await tester.pump(const Duration(milliseconds: 300));
    final resetTop = tester
        .getTopLeft(
          find.byKey(const Key('animated-scan-line')),
        )
        .dy;

    expect(nearBottomTop, greaterThan(initialTop + 400));
    expect(resetTop, lessThan(initialTop + 100));
    expect(find.text('请扫描二维码/条形码'), findsOneWidget);
    expect(find.bySemanticsLabel('照亮'), findsOneWidget);
    expect(find.bySemanticsLabel('相册'), findsOneWidget);
  });

  testWidgets('返回按钮可退出扫码页', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Get.to<void>(
              () => const ScanPage(enableCamera: false),
            ),
            child: const Text('打开扫码'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开扫码'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ScanPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('返回'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ScanPage), findsNothing);
  });
}
