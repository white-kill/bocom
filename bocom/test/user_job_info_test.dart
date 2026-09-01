import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_job_info/user_job_info_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_job_info/user_job_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

void main() {
  tearDown(Get.reset);

  test('local snapshot saves form values but excludes residence phone', () {
    final logic = UserJobInfoLogic(
      initialValues: const {
        UserJobInfoLogic.emailKey: 'user@example.com',
        UserJobInfoLogic.residencePhoneKey: '13900000000',
        UserJobInfoLogic.residenceRegionKey: '湖南省·长沙市·岳麓区',
        UserJobInfoLogic.familyPhoneKey: '0731-88888888',
        UserJobInfoLogic.occupationKey: '金融业务人员',
      },
      initialSameAsResidence: true,
    );

    final snapshot = logic.localSnapshot();

    expect(snapshot['values'], {
      UserJobInfoLogic.emailKey: 'user@example.com',
      UserJobInfoLogic.residenceRegionKey: '湖南省·长沙市·岳麓区',
      UserJobInfoLogic.familyPhoneKey: '0731-88888888',
      UserJobInfoLogic.occupationKey: '金融业务人员',
    });
    expect(snapshot['sameAsResidence'], isTrue);
  });

  test('restored job info always uses current member phone', () {
    final logic = UserJobInfoLogic.fromLocalSnapshot(
      const {
        'values': {
          UserJobInfoLogic.emailKey: 'user@example.com',
          UserJobInfoLogic.residencePhoneKey: 'old-phone',
          UserJobInfoLogic.familyPhoneKey: '0731-88888888',
        },
        'sameAsResidence': true,
      },
      currentPhone: '18800001111',
    );

    expect(logic.valueOf(UserJobInfoLogic.emailKey), 'user@example.com');
    expect(logic.valueOf(UserJobInfoLogic.residencePhoneKey), '18800001111');
    expect(logic.valueOf(UserJobInfoLogic.familyPhoneKey), '0731-88888888');
    expect(logic.sameAsResidence, isTrue);
  });

  test('locally restored contact fields are masked for initial display', () {
    final logic = UserJobInfoLogic.fromLocalSnapshot(
      const {
        'values': {
          UserJobInfoLogic.emailKey: 'abcdef@qq.com',
          UserJobInfoLogic.familyPhoneKey: '13812345678',
          UserJobInfoLogic.companyPhoneKey: '073188888888',
          UserJobInfoLogic.companyNameKey: '湖南联通有限公司',
        },
      },
      currentPhone: '18800001111',
    );

    expect(logic.displayValue(UserJobInfoLogic.emailKey), 'abc***@qq.com');
    expect(logic.displayValue(UserJobInfoLogic.familyPhoneKey), '138****5678');
    expect(
      logic.displayValue(UserJobInfoLogic.companyPhoneKey),
      '073*****8888',
    );
    expect(logic.displayValue(UserJobInfoLogic.companyNameKey), '湖南**有限**');
    expect(
      logic.displayValue(UserJobInfoLogic.residencePhoneKey),
      '18800001111',
    );
  });

  test('editing a restored field displays the new value in full', () {
    final logic = UserJobInfoLogic.fromLocalSnapshot(
      const {
        'values': {UserJobInfoLogic.emailKey: 'abcdef@qq.com'},
      },
      currentPhone: '18800001111',
    );

    expect(logic.displayValue(UserJobInfoLogic.emailKey), 'abc***@qq.com');
    logic.updateField(UserJobInfoLogic.emailKey, 'newmail@example.com');
    expect(
      logic.displayValue(UserJobInfoLogic.emailKey),
      'newmail@example.com',
    );
  });

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

  test('same residence keeps family contact information synchronized', () {
    final logic = UserJobInfoLogic(
      initialValues: const {
        UserJobInfoLogic.familyPhoneKey: '13800000000',
        UserJobInfoLogic.familyRegionKey: '广东省·广州市·天河区',
        UserJobInfoLogic.familyDetailKey: '体育西路一号',
      },
    );

    logic.setSameAsResidence(true);
    logic.updateField(UserJobInfoLogic.residencePhoneKey, '13900000000');
    logic.updateRegion(
      UserJobInfoLogic.residenceRegionKey,
      const ['湖南省', '长沙市', '岳麓区'],
    );
    logic.updateField(UserJobInfoLogic.residenceDetailKey, '岳麓大道一号');

    expect(logic.displayValue(UserJobInfoLogic.familyPhoneKey), '13900000000');
    expect(
      logic.displayValue(UserJobInfoLogic.familyRegionKey),
      '湖南省·长沙市·岳麓区',
    );
    expect(logic.displayValue(UserJobInfoLogic.familyDetailKey), '岳麓大道一号');

    logic.setSameAsResidence(false);
    expect(logic.displayValue(UserJobInfoLogic.familyPhoneKey), '13800000000');
    expect(
      logic.displayValue(UserJobInfoLogic.familyRegionKey),
      '广东省·广州市·天河区',
    );
  });

  test('company fields are hidden only for empty student and unemployed jobs',
      () {
    final logic = UserJobInfoLogic();

    expect(logic.showsCompanyFields, isFalse);
    logic.selectOccupation('学生');
    expect(logic.showsCompanyFields, isFalse);
    logic.selectOccupation('无业');
    expect(logic.showsCompanyFields, isFalse);
    logic.selectOccupation('工人');
    expect(logic.showsCompanyFields, isTrue);
    logic.selectOccupation('金融业务人员');
    expect(logic.showsCompanyFields, isTrue);
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
    expect(value.maxLines, isNull);
    expect(value.overflow, TextOverflow.visible);
  });

  testWidgets('native form scrolls while bottom actions stay fixed',
      (tester) async {
    final logic = UserJobInfoLogic(
      initialValues: const {
        UserJobInfoLogic.residenceRegionKey:
            '新疆维吾尔自治区·伊犁哈萨克自治州·察布查尔锡伯自治县',
      },
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    expect(find.byKey(const Key('user-job-form-scroll')), findsOneWidget);
    expect(find.byKey(const Key('user-job-bottom-actions')), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(
      tester.getSize(
        find.byKey(const Key('user-job-same-residence-track')),
      ),
      const Size(52, 30),
    );
    expect(find.text('单位名称'), findsNothing);
    expect(find.text('单位电话'), findsNothing);
    expect(find.text('单位地址'), findsNothing);
    expect(find.text('常住详细地址'), findsNothing);
    expect(find.text('家庭详细地址'), findsNothing);

    final region = tester.widget<BaseText>(
      find.byKey(const Key('user-job-residence-region-value')),
    );
    expect(region.maxLines, isNull);
    expect(region.overflow, TextOverflow.visible);

    final bottomBefore = tester.getTopLeft(
      find.byKey(const Key('user-job-bottom-actions')),
    );
    await tester.drag(
      find.byKey(const Key('user-job-form-scroll')),
      const Offset(0, -300),
    );
    await tester.pump();
    final bottomAfter = tester.getTopLeft(
      find.byKey(const Key('user-job-bottom-actions')),
    );
    expect(bottomAfter, bottomBefore);
  });

  testWidgets('worker occupation returns directly and reveals company fields',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('user-job-occupation')),
      300,
      scrollable: find.byKey(const Key('user-job-form-scroll')),
    );
    await tester.tap(find.byKey(const Key('user-job-occupation')));
    await tester.pumpAndSettle();
    expect(find.text('请选择职业类别'), findsOneWidget);
    await tester.tap(find.text('工人'));
    await tester.pumpAndSettle();

    expect(logic.valueOf(UserJobInfoLogic.occupationKey), '工人');
    await tester.scrollUntilVisible(
      find.text('单位地址'),
      250,
      scrollable: find.byKey(const Key('user-job-form-scroll')),
    );
    expect(find.text('单位名称'), findsOneWidget);
    expect(find.text('单位电话'), findsOneWidget);
    expect(find.text('单位地址'), findsOneWidget);
  });

  testWidgets('occupation pages use the project back button', (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('user-job-occupation')),
      300,
      scrollable: find.byKey(const Key('user-job-form-scroll')),
    );
    await tester.tap(find.byKey(const Key('user-job-occupation')));
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.leading, isNotNull);
    expect(find.byKey(const Key('user-job-occupation-back')), findsOneWidget);
  });

  testWidgets('secondary occupation returns only the final category',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('user-job-occupation')),
      300,
      scrollable: find.byKey(const Key('user-job-form-scroll')),
    );
    await tester.tap(find.byKey(const Key('user-job-occupation')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('专业技术人员'));
    await tester.pumpAndSettle();
    expect(find.text('请选择二级子类别'), findsOneWidget);
    await tester.tap(find.text('金融业务人员'));
    await tester.pumpAndSettle();

    expect(logic.valueOf(UserJobInfoLogic.occupationKey), '金融业务人员');
  });

  testWidgets('retired occupation requires confirmation before returning',
      (tester) async {
    final logic = UserJobInfoLogic();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserJobInfoPage(logic: logic)),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('user-job-occupation')),
      300,
      scrollable: find.byKey(const Key('user-job-form-scroll')),
    );
    await tester.tap(find.byKey(const Key('user-job-occupation')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('离退休人员'),
      300,
      scrollable: find.byKey(
        const Key('user-job-occupation-list-请选择职业类别'),
      ),
    );
    await tester.tap(find.text('离退休人员'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('user-job-retired-confirm-sheet')),
        findsOneWidget);
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(logic.valueOf(UserJobInfoLogic.occupationKey), '离退休人员');
  });
}
