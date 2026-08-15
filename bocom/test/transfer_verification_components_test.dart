import 'dart:async';

import 'package:bocom/pages/component/auth_sm.dart';
import 'package:bocom/pages/component/indicator_loading.dart';
import 'package:bocom/pages/component/password_keyboard_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('短信验证码使用系统电话键盘并按参考图显示输入数字', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmsVerificationCodeSheet(
            phone: '13800138958',
            codeSender: () async => '428799',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final input = tester.widget<TextField>(
      find.byKey(const Key('sms-verification-input')),
    );
    expect(input.keyboardType, TextInputType.phone);
    expect(find.text('已发送至尾号(**8958)的手机'), findsOneWidget);
    expect(find.text('5分钟内有效'), findsOneWidget);
    expect(find.text('收不到短信?'), findsOneWidget);
    expect(
      tester
          .widget<Container>(find.byKey(const Key('sms-code-box-0')))
          .decoration,
      isA<BoxDecoration>(),
    );

    await tester.enterText(
      find.byKey(const Key('sms-verification-input')),
      '4287',
    );
    await tester.pump();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    final activeDecoration = tester
        .widget<Container>(find.byKey(const Key('sms-code-box-4')))
        .decoration as BoxDecoration;
    expect(activeDecoration.border, isNotNull);
  });

  testWidgets('交易密码动态显示业务文字且输入后仅显示圆点', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: PasswordKeyboardSheet(
              transaction: TransactionPasswordContext(
                payeeName: '沈光德',
                amountDisplay: '10.00',
                bankName: '中国建设银行',
                accountNumber: '6217001630076962353',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('转给 沈光德 10.00'), findsOneWidget);
    expect(find.text('中国建设银行 6217 0016 3007 6962 353'), findsOneWidget);
    expect(find.byKey(const Key('password-dot-0')), findsNothing);

    await tester.tap(find.bySemanticsLabel('安全键盘6'));
    await tester.tap(find.bySemanticsLabel('安全键盘7'));
    await tester.pump();

    expect(find.byKey(const Key('password-dot-0')), findsOneWidget);
    expect(find.byKey(const Key('password-dot-1')), findsOneWidget);
    expect(find.text('6'), findsNothing);
    expect(find.text('7'), findsNothing);
  });

  testWidgets('任意六位短信验证码输入完成后直接通过', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showSmsVerificationCode(
                  context,
                  phone: '13800138958',
                  codeSender: () async => '428799',
                );
              },
              child: const Text('短信验证'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('短信验证'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('sms-verification-input')),
      '000000',
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byKey(const Key('sms-verification-sheet')), findsNothing);
  });

  testWidgets('任意六位交易密码输入完成后直接通过且不调用内容校验', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    bool? result;
    var verifierCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await PasswordKeyboardSheet.showForVerification(
                  context,
                  transaction: const TransactionPasswordContext(
                    payeeName: '测试收款人',
                    amountDisplay: '0.01',
                    bankName: '中国建设银行',
                    accountNumber: '6217001630076962353',
                  ),
                  passwordVerifier: (_) async {
                    verifierCalled = true;
                    return false;
                  },
                );
              },
              child: const Text('密码验证'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('密码验证'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    for (var index = 0; index < 6; index++) {
      await tester.tap(find.bySemanticsLabel('安全键盘6'));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 400));

    expect(result, isTrue);
    expect(verifierCalled, isFalse);
    expect(find.byKey(const Key('password-keyboard-sheet')), findsNothing);
  });

  testWidgets('转账Loading随异步任务显示和关闭', (tester) async {
    final completer = Completer<int>();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => BocomLoading.run(
                context,
                () => completer.future,
              ),
              child: const Text('开始'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('开始'));
    await tester.pump();
    expect(find.byKey(const Key('transfer-loading-indicator')), findsOneWidget);
    expect(find.byType(BocomArcLoadingIndicator), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('transfer-loading-indicator'))),
      const Size.square(22),
    );

    completer.complete(1);
    await tester.pump();
    expect(find.byKey(const Key('transfer-loading-indicator')), findsNothing);
  });
}
