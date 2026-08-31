import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_job_info/user_job_info_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_job_info/user_job_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

void main() {
  tearDown(Get.reset);

  test('job info fields can be changed and deleted', () {
    final logic = UserJobInfoLogic(
      initialValues: const {UserJobInfoLogic.emailKey: 'old@example.com'},
    );

    logic.updateField(UserJobInfoLogic.emailKey, ' new@example.com ');
    expect(logic.valueOf(UserJobInfoLogic.emailKey), 'new@example.com');

    logic.deleteField(UserJobInfoLogic.emailKey);
    expect(logic.valueOf(UserJobInfoLogic.emailKey), '');
  });

  test('job region values use middle dots and remain independent', () {
    final logic = UserJobInfoLogic();

    logic.updateRegion(
      UserJobInfoLogic.residenceRegionKey,
      const ['湖南省', '长沙市', '岳麓区'],
    );
    logic.updateRegion(
      UserJobInfoLogic.familyRegionKey,
      const ['广东省', '广州市', '天河区'],
    );

    expect(
      logic.valueOf(UserJobInfoLogic.residenceRegionKey),
      '湖南省·长沙市·岳麓区',
    );
    expect(
      logic.valueOf(UserJobInfoLogic.familyRegionKey),
      '广东省·广州市·天河区',
    );
    expect(logic.valueOf(UserJobInfoLogic.companyRegionKey), '');
  });

  testWidgets('email editor changes the positioned value', (tester) async {
    final logic = UserJobInfoLogic(
      initialValues: const {UserJobInfoLogic.emailKey: '754***@QQ.COM'},
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-email')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('user-job-edit-sheet')), findsOneWidget);
    expect(find.text('如您需要修改Email地址，请重新填写'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'new@example.com');
    await tester.tap(find.text('修改并确认'));
    await tester.pumpAndSettle();

    final value = tester.widget<BaseText>(
      find.byKey(const Key('user-job-email-value')),
    );
    expect(value.text, 'new@example.com');
    expect(value.color, const Color(0xFF181818));
    expect(value.maxLines, 1);
    expect(value.overflow, TextOverflow.ellipsis);
  });

  testWidgets('residence detail uses its own dynamic editor labels',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-residence-detail')));
    await tester.pumpAndSettle();

    expect(find.text('常住详细地址'), findsWidgets);
    expect(find.text('如您需要修改常住详细地址，请重新填写'), findsOneWidget);
    expect(find.text('请输入您的详细地址'), findsOneWidget);
  });

  testWidgets('delete current information clears the field', (tester) async {
    final logic = UserJobInfoLogic(
      initialValues: const {UserJobInfoLogic.emailKey: '754***@QQ.COM'},
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-email')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除当前信息'));
    await tester.pumpAndSettle();

    expect(logic.valueOf(UserJobInfoLogic.emailKey), '');
  });

  testWidgets('invalid email shows an error bubble after losing focus',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-email')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '4646464');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.text('请输入正确的Email地址'), findsOneWidget);
    expect(find.byKey(const Key('user-job-validation-bubble')), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const Key('user-job-validation-bubble')))
          .dx,
      tester.getTopLeft(find.byType(TextField)).dx,
    );
    final submit = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, '修改并确认'),
    );
    expect(submit.onPressed, isNull);
  });

  testWidgets('short detail address shows an error bubble after losing focus',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-residence-detail')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'go g nin');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.text('详细地址不少于3个汉字'), findsOneWidget);
  });

  testWidgets('phone editor shows fixed-line format tip when focused',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-residence-phone')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(find.text('如填写固定电话，格式如：021-XXXXXX'), findsOneWidget);
  });

  testWidgets('detail address is saved only after second confirmation',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-residence-detail')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '岳麓大道一号');
    await tester.tap(find.text('修改并确认'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('user-job-address-confirm-sheet')),
        findsOneWidget);
    expect(logic.valueOf(UserJobInfoLogic.residenceDetailKey), '');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(
      logic.valueOf(UserJobInfoLogic.residenceDetailKey),
      '岳麓大道一号',
    );
  });

  testWidgets('region picker selects province city district and fills page',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.tap(find.byKey(const Key('user-job-residence-region')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('user-job-region-sheet')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('湖南省'),
      500,
      scrollable: find.byKey(const Key('user-job-province-list')),
    );
    await tester.tap(find.text('湖南省'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('长沙市'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('岳麓区'));
    await tester.pumpAndSettle();

    final value = tester.widget<BaseText>(
      find.byKey(const Key('user-job-residence-region-value')),
    );
    expect(value.text, '湖南省·长沙市·岳麓区');
    expect(value.maxLines, 1);
    expect(value.overflow, TextOverflow.ellipsis);
  });
}
