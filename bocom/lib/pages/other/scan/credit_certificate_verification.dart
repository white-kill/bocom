import 'dart:io';

import 'package:bocom/config/app_config.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:bocom/utils/sp_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'credit_certificate_pdf_view.dart';

typedef CreditCertificateLoader = Future<CreditCertificateVerificationResult>
    Function(String creNo);

class CreditCertificateQrPayload {
  const CreditCertificateQrPayload({
    required this.creNo,
    required this.voucherNumber,
  });

  final String creNo;
  final String voucherNumber;

  static CreditCertificateQrPayload? tryParse(String rawValue) {
    final fields = <String, String>{};
    for (final segment in rawValue.trim().split('|')) {
      final separator = segment.indexOf(':');
      if (separator <= 0 || separator == segment.length - 1) continue;
      fields[segment.substring(0, separator).trim()] =
          segment.substring(separator + 1).trim();
    }

    final creNo = fields['creNo'] ?? '';
    final voucherNumber = fields['voucherNumber'] ?? '';
    if (fields['channelId'] != 'credit_certificate' ||
        fields['creType'] != '00' ||
        creNo.isEmpty ||
        voucherNumber.isEmpty) {
      return null;
    }
    return CreditCertificateQrPayload(
      creNo: creNo,
      voucherNumber: voucherNumber,
    );
  }
}

class CreditCertificateVerificationResult {
  const CreditCertificateVerificationResult({
    required this.certificateNumber,
    required this.customerName,
    required this.establishmentDate,
    required this.pdfUri,
  });

  final String certificateNumber;
  final String customerName;
  final String establishmentDate;
  final Uri pdfUri;

  factory CreditCertificateVerificationResult.fromResponse(
    Map<String, dynamic> response, {
    required String fallbackCertificateNumber,
  }) {
    final source = _unwrapData(response);
    final certificateNumber = _readString(
          source,
          const ['creNo', 'orderId', 'certificateNumber', 'certificateNo'],
        ) ??
        fallbackCertificateNumber;
    final customerName = _readString(
      source,
      const ['customerName', 'custName', 'realName', 'name'],
    );
    final establishmentDate = _readString(
      source,
      const [
        'establishmentDate',
        'establishDate',
        'openDate',
        'openTime',
        'createTime',
      ],
    );
    final pdfValue = _readString(
      source,
      const [
        'pdfUrl',
        'pdfURL',
        'pdfPath',
        'fileUrl',
        'electronicUrl',
        'downloadUrl',
      ],
    );

    if (pdfValue == null) {
      throw const FormatException('未获取到证明电子版地址');
    }
    if (customerName == null || establishmentDate == null) {
      throw const FormatException('资信证明验真结果不完整');
    }

    final pdfUri = _resolvePdfUri(pdfValue);
    if ((pdfUri.scheme != 'http' && pdfUri.scheme != 'https') ||
        pdfUri.host.isEmpty) {
      throw const FormatException('资信证明 PDF 地址无效');
    }

    return CreditCertificateVerificationResult(
      certificateNumber: certificateNumber,
      customerName: customerName,
      establishmentDate: establishmentDate,
      pdfUri: pdfUri,
    );
  }

  static Map<String, dynamic> _unwrapData(Map<String, dynamic> response) {
    var current = response;
    for (var depth = 0; depth < 3; depth++) {
      final nested = current['data'];
      if (nested is! Map) break;
      current = Map<String, dynamic>.from(nested);
    }
    return current;
  }

  static String? _readString(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static Uri _resolvePdfUri(String value) {
    final uri = Uri.parse(value);
    if (uri.hasScheme) return uri;
    final baseUrl = AppConfig.config.netConfig.baseUrl ?? '';
    return Uri.parse(baseUrl).resolveUri(uri);
  }
}

Future<CreditCertificateVerificationResult> loadCreditCertificateVerification(
  String creNo,
) async {
  // 该接口包含证明编号、姓名与 PDF 地址，使用独立客户端避免被全局
  // LogInterceptor 写入调试日志。
  final netConfig = AppConfig.config.netConfig;
  final client = Dio(
    BaseOptions(
      baseUrl: netConfig.baseUrl ?? '',
      connectTimeout: Duration(milliseconds: netConfig.connectTimeout),
      sendTimeout: Duration(milliseconds: netConfig.sendTimeout),
      receiveTimeout: Duration(milliseconds: netConfig.receiveTimeout),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: token,
        'client_type': 'APP',
        'banktype': '5',
        'BANKTYPE': '5',
        'login_device': Platform.isIOS ? '1' : '2',
      },
    ),
  );
  final response = await client.get<dynamic>(
    Apis.creditCertificateVerify,
    queryParameters: {'creNo': creNo},
  );
  final envelope = response.data;
  if (envelope is! Map) {
    throw const FormatException('资信证明验真接口返回格式错误');
  }
  final body = Map<String, dynamic>.from(envelope);
  if (body.containsKey('code') && body['code'].toString() != '200') {
    throw const FormatException('资信证明验真失败');
  }
  return CreditCertificateVerificationResult.fromResponse(
    body,
    fallbackCertificateNumber: creNo,
  );
}

Future<CreditCertificateVerificationResult> verifyCreditCertificateQr(
  String rawValue, {
  CreditCertificateLoader loader = loadCreditCertificateVerification,
}) async {
  final payload = CreditCertificateQrPayload.tryParse(rawValue);
  if (payload == null) {
    throw const FormatException('不是可识别的资信证明二维码');
  }
  return loader(payload.creNo);
}

// 资信证明二维码验证页
// 说明：页面使用接口返回的证明编号、客户姓名、开立日期和 PDF 地址原生绘制，不保留参考图中的个人信息。
class CreditCertificateVerificationPage extends StatefulWidget {
  const CreditCertificateVerificationPage({
    required this.result,
    super.key,
  });

  final CreditCertificateVerificationResult result;

  @override
  State<CreditCertificateVerificationPage> createState() =>
      _CreditCertificateVerificationPageState();
}

class _CreditCertificateVerificationPageState
    extends State<CreditCertificateVerificationPage> {
  void _openPdf() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CreditCertificatePdfPage(
          pdfUri: widget.result.pdfUri,
        ),
      ),
    );
  }

  void _finish() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7F7F7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('credit-certificate-verification-page'),
        backgroundColor: const Color(0xFFF7F7F7),
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: MediaQuery.paddingOf(context).top,
              child: const ColoredBox(color: Colors.white),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _VerificationNavigation(onFinish: _finish),
                  _VerificationRow(
                    label: '证明编号',
                    value: widget.result.certificateNumber,
                    valueKey: const Key('credit-certificate-number'),
                  ),
                  _VerificationRow(
                    label: '客户姓名',
                    value: widget.result.customerName,
                    valueKey: const Key('credit-certificate-customer-name'),
                  ),
                  _VerificationRow(
                    label: '开立日期',
                    value: widget.result.establishmentDate,
                    valueKey:
                        const Key('credit-certificate-establishment-date'),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: Semantics(
                            button: true,
                            label: '查看此证明电子版',
                            child: FilledButton(
                              key: const Key('open-credit-certificate-pdf'),
                              onPressed: _openPdf,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0B70F0),
                                disabledBackgroundColor:
                                    const Color(0xFF0B70F0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: const Text(
                                '查看此证明电子版',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationNavigation extends StatelessWidget {
  const _VerificationNavigation({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              '资信证明二维码验证',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Semantics(
                button: true,
                label: '返回',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: SizedBox(
                    width: 54,
                    child: Center(
                      child: Image.asset(
                        'assets/images/scan/back.png',
                        width: 9,
                        height: 17,
                        color: const Color(0xFF111111),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Semantics(
                button: true,
                label: '完成',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onFinish,
                  child: const SizedBox(
                    width: 64,
                    child: Center(
                      child: Text(
                        '完成',
                        style: TextStyle(
                          color: Color(0xFF0878DA),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              key: valueKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
