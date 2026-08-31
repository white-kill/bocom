import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_idcard_info/user_idcard_info_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_idcard_info/user_idcard_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  group('UserIdcardInfoLogic', () {
    test('keeps the first three and last two id-card characters', () {
      expect(
        UserIdcardInfoLogic.maskIdCard('430123456789012311'),
        '430*************11',
      );
    });

    test('uses member city when no local address exists', () {
      final logic = UserIdcardInfoLogic(
        readAddress: () => '',
        writeAddress: (_) {},
      );

      logic.loadLocalAddress();

      expect(logic.addressValue('湖南长沙'), '湖南长沙');
    });

    test('uses an empty address when local address and city are empty', () {
      final logic = UserIdcardInfoLogic(
        readAddress: () => '',
        writeAddress: (_) {},
      );

      logic.loadLocalAddress();

      expect(logic.addressValue(''), '');
    });

    test('loads a saved local address', () {
      final logic = UserIdcardInfoLogic(
        readAddress: () => '湖南长沙',
        writeAddress: (_) {},
      );

      logic.loadLocalAddress();

      expect(logic.addressValue('北京市'), '湖南长沙');
    });

    test('trims, saves, and exposes an edited address', () {
      String? savedAddress;
      final logic = UserIdcardInfoLogic(
        readAddress: () => '',
        writeAddress: (value) => savedAddress = value,
      );
      logic.loadLocalAddress();

      final saved = logic.saveAddress(' 湖南长沙 ');

      expect(saved, isTrue);
      expect(logic.state.address.value, '湖南长沙');
      expect(savedAddress, '湖南长沙');
    });

    test('does not replace the address with a blank edit', () {
      String? savedAddress;
      final logic = UserIdcardInfoLogic(
        readAddress: () => '北京市',
        writeAddress: (value) => savedAddress = value,
      );
      logic.loadLocalAddress();

      final saved = logic.saveAddress('   ');

      expect(saved, isFalse);
      expect(logic.addressValue('上海市'), '北京市');
      expect(savedAddress, isNull);
    });
  });

  testWidgets('long press edits and saves the address', (tester) async {
    String? savedAddress;
    final logic = UserIdcardInfoLogic(
      readAddress: () => '',
      writeAddress: (value) => savedAddress = value,
    );
    logic.loadLocalAddress();
    final bocLogic = Get.put(BocLogic());
    bocLogic.memberInfo.city = '北京市';

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1080, 2400),
        builder: (_, __) =>
            GetMaterialApp(home: UserIdcardInfoPage(logic: logic)),
      ),
    );

    expect(find.text('北京市'), findsOneWidget);
    await tester.longPress(find.byKey(const Key('user-card-manage-address')));
    await tester.pumpAndSettle();

    expect(find.text('修改地址'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), '湖南长沙');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('湖南长沙'), findsOneWidget);
    expect(savedAddress, '湖南长沙');
  });
}
