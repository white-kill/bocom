import 'package:bocom/pages/other/customer_service/customer_service_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  test('客服页问候语按小时切换', () {
    expect(customerServiceGreetingForHour(0), '上午好');
    expect(customerServiceGreetingForHour(11), '上午好');
    expect(customerServiceGreetingForHour(12), '中午好');
    expect(customerServiceGreetingForHour(13), '下午好');
    expect(customerServiceGreetingForHour(17), '下午好');
    expect(customerServiceGreetingForHour(18), '晚上好');
    expect(customerServiceGreetingForHour(23), '晚上好');
  });

  testWidgets('客服页使用主内容和固定底部切图', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 90, bottom: 72);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const GetMaterialApp(home: CustomerServicePage()),
    );

    expect(find.byKey(const Key('customer-service-scaffold')), findsOneWidget);
    expect(find.byKey(const Key('customer-service-footer')), findsOneWidget);
    final back = tester.getRect(
      find.byKey(const Key('customer-service-back')),
    );
    expect(back.top, closeTo(113, 0.1));
    final footer = tester.getRect(
      find.byKey(const Key('customer-service-footer')),
    );
    expect(footer.height, closeTo(292, 0.1));
    expect(footer.bottom, closeTo(2268, 0.1));
    expect(find.bySemanticsLabel('静音'), findsOneWidget);
    expect(find.bySemanticsLabel('请输入您的问题'), findsOneWidget);
    expect(find.text('请输入您的问题'), findsOneWidget);
  });

  testWidgets('客服页问候语会随时间实时刷新', (tester) async {
    var now = DateTime(2026, 9, 8, 17, 59);

    await tester.pumpWidget(
      GetMaterialApp(home: CustomerServicePage(now: () => now)),
    );

    expect(find.text('下午好!'), findsOneWidget);

    now = DateTime(2026, 9, 8, 18);
    await tester.pump(const Duration(minutes: 1));

    expect(find.text('晚上好!'), findsOneWidget);
    expect(find.text('下午好!'), findsNothing);
  });

  testWidgets('客服页返回按钮可退出页面', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (_) => TextButton(
            onPressed: () => Get.to<void>(
              () => const CustomerServicePage(),
            ),
            child: const Text('打开客服'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开客服'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerServicePage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('返回'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerServicePage), findsNothing);
  });
}
