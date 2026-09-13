import 'package:bocom/pages/other/scan/credit_certificate_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  test('只接受资信证明固定二维码协议', () {
    final payload = CreditCertificateQrPayload.tryParse(
      'channelId:credit_certificate|creType:00|'
      'creNo:CERT-DEMO-0000|voucherNumber:VOUCHER-DEMO-0000',
    );

    expect(payload?.creNo, 'CERT-DEMO-0000');
    expect(payload?.voucherNumber, 'VOUCHER-DEMO-0000');
    expect(
      CreditCertificateQrPayload.tryParse(
        'channelId:unrelated|creType:00|'
        'creNo:CERT-DEMO-0000|voucherNumber:VOUCHER-DEMO-0000',
      ),
      isNull,
    );
    expect(
      CreditCertificateQrPayload.tryParse(
        'channelId:credit_certificate|creType:00|creNo:CERT-DEMO-0000',
      ),
      isNull,
    );
  });

  test('扫码后仅使用协议中的证明编号请求验真', () async {
    String? requestedCreNo;
    final expected = CreditCertificateVerificationResult(
      certificateNumber: 'CERT-DEMO-0000',
      customerName: '示例用户',
      establishmentDate: '2026-01-01 00:00:00',
      pdfUri: Uri.parse('https://example.invalid/certificate.pdf'),
    );

    final result = await verifyCreditCertificateQr(
      'channelId:credit_certificate|creType:00|'
      'creNo:CERT-DEMO-0000|voucherNumber:VOUCHER-DEMO-0000',
      loader: (creNo) async {
        requestedCreNo = creNo;
        return expected;
      },
    );

    expect(requestedCreNo, 'CERT-DEMO-0000');
    expect(result, same(expected));
  });

  test('验真结果兼容接口字段并校验 PDF 地址', () {
    final result = CreditCertificateVerificationResult.fromResponse(
      {
        'orderId': 'CERT-DEMO-0000',
        'custName': '示例用户',
        'openDate': '2026-01-01 00:00:00',
        'pdfUrl': 'https://example.invalid/certificate.pdf',
      },
      fallbackCertificateNumber: 'CERT-FALLBACK',
    );

    expect(result.certificateNumber, 'CERT-DEMO-0000');
    expect(result.customerName, '示例用户');
    expect(result.establishmentDate, '2026-01-01 00:00:00');
    expect(result.pdfUri.scheme, 'https');

    expect(
      () => CreditCertificateVerificationResult.fromResponse(
        {
          'custName': '示例用户',
          'openDate': '2026-01-01 00:00:00',
          'pdfUrl': 'file:///tmp/certificate.pdf',
        },
        fallbackCertificateNumber: 'CERT-FALLBACK',
      ),
      throwsFormatException,
    );
  });

  testWidgets('验真结果页展示动态数据并把 PDF 交给外部打开', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Uri? launchedUri;
    final result = CreditCertificateVerificationResult(
      certificateNumber: 'CERT-DEMO-0000',
      customerName: '示例用户',
      establishmentDate: '2026-01-01 00:00:00',
      pdfUri: Uri.parse('https://example.invalid/certificate.pdf'),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: CreditCertificateVerificationPage(
          result: result,
          pdfLauncher: (uri) async {
            launchedUri = uri;
            return true;
          },
        ),
      ),
    );

    expect(find.text('资信证明二维码验证'), findsOneWidget);
    expect(find.text('CERT-DEMO-0000'), findsOneWidget);
    expect(find.text('示例用户'), findsOneWidget);
    expect(find.text('2026-01-01 00:00:00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-credit-certificate-pdf')));
    await tester.pump();

    expect(launchedUri, Uri.parse('https://example.invalid/certificate.pdf'));
  });
}
