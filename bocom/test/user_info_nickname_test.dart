import 'dart:math';

import 'package:bocom/pages/tabs/mine/children/user_info/nickname_edit_view.dart';
import 'package:bocom/pages/tabs/mine/children/user_info/user_info_logic.dart';
import 'package:bocom/pages/tabs/mine/children/user_info_manage/user_info_manage_logic.dart';
import 'package:bocom/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

void main() {
  group('UserInfoManageLogic identity masking', () {
    test('keeps the first three and last two id-card characters', () {
      expect(
        UserInfoManageLogic.maskIdCard('500123456789012311'),
        '500*************11',
      );
    });

    test('returns a placeholder when id card is unavailable', () {
      expect(UserInfoManageLogic.maskIdCard(''), '--');
    });
  });

  group('UserInfoLogic nickname persistence', () {
    test('generates and persists a nickname when local value is missing', () {
      String? persisted;
      final logic = UserInfoLogic(
        readNickname: () => '',
        writeNickname: (value) => persisted = value,
        random: Random(7),
      );

      logic.loadNickname();

      expect(logic.state.nickname.value, matches(r'^用户\d{7}[A-Za-z]{3}$'));
      expect(persisted, logic.state.nickname.value);
    });

    test('uses the persisted nickname without replacing it', () {
      String? persisted;
      final logic = UserInfoLogic(
        readNickname: () => '用户7548005rwG',
        writeNickname: (value) => persisted = value,
      );

      logic.loadNickname();

      expect(logic.state.nickname.value, '用户7548005rwG');
      expect(persisted, isNull);
    });

    test('trims and saves a non-empty edited nickname', () {
      String? persisted;
      final logic = UserInfoLogic(
        readNickname: () => '旧昵称',
        writeNickname: (value) => persisted = value,
      );
      logic.loadNickname();

      final saved = logic.saveNickname('  新昵称  ');

      expect(saved, isTrue);
      expect(logic.state.nickname.value, '新昵称');
      expect(persisted, '新昵称');
    });

    test('does not save a blank nickname', () {
      String? persisted;
      final logic = UserInfoLogic(
        readNickname: () => '旧昵称',
        writeNickname: (value) => persisted = value,
      );
      logic.loadNickname();

      final saved = logic.saveNickname('   ');

      expect(saved, isFalse);
      expect(logic.state.nickname.value, '旧昵称');
      expect(persisted, isNull);
    });
  });

  testWidgets('nickname editor shows customer service action and opens it',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const NicknameEditPage(initialNickname: '用户7548005rwG'),
        getPages: [
          GetPage<void>(
            name: Routes.customerService,
            page: () => const Scaffold(
              body: BaseText(text: '客服页面'),
            ),
          ),
        ],
      ),
    );

    expect(find.bySemanticsLabel('客服'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('客服'));
    await tester.pumpAndSettle();

    expect(find.text('客服页面'), findsOneWidget);
  });
}
