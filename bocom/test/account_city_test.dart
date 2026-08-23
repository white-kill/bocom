import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/pages/tabs/life/life_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('生活页显示账号城市并保留原字体样式', (tester) async {
    final accountLogic = Get.put<BocLogic>(_TestBocLogic());
    accountLogic.memberInfo.city = '广州';

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (_, __) => GetMaterialApp(home: LifePage()),
      ),
    );
    await tester.pump();

    final cityFinder = find.byKey(const Key('life-city-label'));
    expect(find.text('广州'), findsOneWidget);

    final cityText = tester.widget<Text>(cityFinder);
    expect(cityText.style?.fontSize, 17.sp);
    expect(cityText.style?.fontWeight, FontWeight.w400);

    accountLogic.memberInfo.city = '深圳';
    accountLogic.update(['updateUI']);
    await tester.pump();

    expect(find.text('深圳'), findsOneWidget);
    expect(find.text('广州'), findsNothing);
  });
}

class _TestBocLogic extends BocLogic {
  @override
  Future<void> memberInfoData() async {}
}
