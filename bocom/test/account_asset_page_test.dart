import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/config/app_config.dart';
import 'package:bocom/pages/tabs/mine/children/account_asset/account_asset_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/state_widget/app_bar_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('我的账户顶部与页面使用同一背景色', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    AppConfig.config.abcLogic = Get.put<BocLogic>(_TestBocLogic());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => GetMaterialApp(
          home: AccountAssetPage(initialTabIndex: 0),
        ),
      ),
    );
    await tester.pump();

    final navigationShell = tester.widget<AppBarWidget>(
      find.byType(AppBarWidget),
    );
    expect(navigationShell.background, const Color(0xFFF7F7F7));
  });

  testWidgets('我的账户明细清单进入PDF导出页面', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    AppConfig.config.abcLogic = Get.put<BocLogic>(_TestBocLogic());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => GetMaterialApp(
          getPages: [
            GetPage(
              name: Routes.printPage,
              page: () => const Scaffold(body: Text('PDF导出页面')),
            ),
          ],
          home: AccountAssetPage(initialTabIndex: 0),
        ),
      ),
    );
    await tester.pump();

    final detailListHotspot = find.byKey(
      const Key('account-detail-list-hotspot'),
    );
    final detector = tester.widget<GestureDetector>(detailListHotspot);
    detector.onTap?.call();
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.printPage);
    expect(find.text('PDF导出页面'), findsOneWidget);
  });
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
