import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_base_info/user_base_info_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_base_info/user_base_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  group('UserBaseInfoLogic local values', () {
    test('uses masked defaults when no local values exist', () {
      final logic = UserBaseInfoLogic(
        readDate: () => '',
        readPinyin: () => '',
        writeDate: (_) {},
        writePinyin: (_) {},
      );

      logic.loadLocalValues();

      expect(logic.state.date.value, '****.**.**');
      expect(logic.state.pinyin.value, '***KAN');
    });

    test('loads date and pinyin from local values', () {
      final logic = UserBaseInfoLogic(
        readDate: () => '1990.01.02',
        readPinyin: () => 'ZHANG SAN',
        writeDate: (_) {},
        writePinyin: (_) {},
      );

      logic.loadLocalValues();

      expect(logic.state.date.value, '1990.01.02');
      expect(logic.state.pinyin.value, 'ZHANG SAN');
    });

    test('trims, saves, and exposes edited values', () {
      String? savedDate;
      String? savedPinyin;
      final logic = UserBaseInfoLogic(
        readDate: () => '',
        readPinyin: () => '',
        writeDate: (value) => savedDate = value,
        writePinyin: (value) => savedPinyin = value,
      );
      logic.loadLocalValues();

      expect(logic.saveDate(' 2000.08.30 '), isTrue);
      expect(logic.savePinyin(' LI SI '), isTrue);
      expect(logic.state.date.value, '2000.08.30');
      expect(logic.state.pinyin.value, 'LI SI');
      expect(savedDate, '2000.08.30');
      expect(savedPinyin, 'LI SI');
    });

    test('does not replace values with blank edits', () {
      var writes = 0;
      final logic = UserBaseInfoLogic(
        readDate: () => '1990.01.02',
        readPinyin: () => 'ZHANG SAN',
        writeDate: (_) => writes++,
        writePinyin: (_) => writes++,
      );
      logic.loadLocalValues();

      expect(logic.saveDate('   '), isFalse);
      expect(logic.savePinyin(''), isFalse);
      expect(logic.state.date.value, '1990.01.02');
      expect(logic.state.pinyin.value, 'ZHANG SAN');
      expect(writes, 0);
    });
  });

  testWidgets('long press edits and saves date', (tester) async {
    String? savedDate;
    final logic = UserBaseInfoLogic(
      readDate: () => '',
      readPinyin: () => '',
      writeDate: (value) => savedDate = value,
      writePinyin: (_) {},
    );
    logic.loadLocalValues();
    Get.put(BocLogic());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserBaseInfoPage(logic: logic)),
      ),
    );

    expect(find.text('****.**.**'), findsOneWidget);
    await tester.longPress(find.byKey(const Key('user-info-manage-date')));
    await tester.pumpAndSettle();

    expect(find.text('修改出生日期'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), '2000.08.30');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('2000.08.30'), findsOneWidget);
    expect(savedDate, '2000.08.30');
  });
}
