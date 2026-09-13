import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wb_base_widget/state_widget/app_bar_widget.dart';

void main() {
  testWidgets('沉浸导航覆盖上一页状态栏底色，滚动后仍保持透明系统栏', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    final controller = ScrollController();
    addTearDown(controller.dispose);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.white),
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 750),
        builder: (_, __) => MaterialApp(
          home: AppBarWidget(
            noBackGround: true,
            showBackgroundColor: true,
            navColor: Colors.white,
            leftItem: const SizedBox.shrink(),
            titleWidget: const Text('搜索'),
            bodyChild: ListView(
              controller: controller,
              padding: EdgeInsets.zero,
              children: const [
                SizedBox(
                  key: Key('immersive-background'),
                  height: 1600,
                  child: ColoredBox(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        tester.getTopLeft(find.byKey(const Key('immersive-background'))).dy, 0);
    expect(tester.getTopLeft(find.text('搜索')).dy, greaterThanOrEqualTo(44));
    expect(SystemChrome.latestStyle?.statusBarColor, Colors.transparent);
    expect(SystemChrome.latestStyle?.systemStatusBarContrastEnforced, false);
    expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.light);
    expect(tester.widget<AppBar>(find.byType(AppBar)).backgroundColor?.a, 0);

    controller.jumpTo(100);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(AppBar)).dy, 0);
    expect(tester.getSize(find.byType(AppBar)).height, 88);
    expect(tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        Colors.white);
    expect(SystemChrome.latestStyle?.statusBarColor, Colors.transparent);
    expect(SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.dark);
  });
}
