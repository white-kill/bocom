import 'package:bocom/pages/other/search/search_results_view.dart';
import 'package:bocom/pages/other/search/search_view.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('搜索流水打印进入结果页，交易明细进入列表', (tester) async {
    tester.view.physicalSize = const Size(432, 900);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(Get.reset);

    final memberLogic = Get.put<BocLogic>(_TestBocLogic());
    memberLogic.memberInfo.city = '杭州';

    await tester.pumpWidget(
      GetMaterialApp(
        home: const SearchPage(),
        getPages: [
          GetPage(
            name: Routes.transactionDetail,
            page: () => const Scaffold(body: Text('转账交易明细列表')),
          ),
        ],
      ),
    );

    expect(find.text('杭州'), findsOneWidget);
    expect(find.text('流水打印'), findsOneWidget);
    final landingHeader = tester.getRect(
      find.byKey(const Key('search-shared-header')),
    );
    expect(
      tester.getSize(find.byKey(const Key('search-history-flow-print'))).width,
      closeTo(91.2, 0.1),
    );

    memberLogic.memberInfo.city = '苏州';
    memberLogic.update(['updateUI']);
    await tester.pump();
    expect(find.text('苏州'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('search-input')),
      '流水打印',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byType(SearchResultsPage), findsOneWidget);
    final resultHeader = tester.getRect(
      find.byKey(const Key('search-shared-header')),
    );
    expect(resultHeader.top, closeTo(landingHeader.top, 0.1));
    expect(resultHeader.height, closeTo(landingHeader.height, 0.1));
    expect(find.text('苏州'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('苏州')).style?.fontSize,
      closeTo(17.9, 0.1),
    );
    expect(find.bySemanticsLabel('交易明细'), findsOneWidget);

    await tester.tap(find.byKey(const Key('search-results-cancel')));
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('历史搜索：流水打印'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchResultsPage), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('search-result-transaction-detail')),
    );
    await tester.pumpAndSettle();

    expect(find.text('转账交易明细列表'), findsOneWidget);
  });
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
