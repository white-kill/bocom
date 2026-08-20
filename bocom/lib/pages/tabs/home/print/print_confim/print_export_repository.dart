import '../../../../../config/dio/network.dart';
import '../../../../../config/net_config/apis.dart';

typedef PrintExportSubmitter = Future<PrintExportResult> Function(
  Map<String, dynamic> params,
);
typedef PrintRecordPageLoader = Future<PrintRecordPageData> Function(
  int pageNum,
  int pageSize,
);

class PrintExportResult {
  const PrintExportResult({
    required this.email,
    required this.code,
    this.id,
    this.name = '',
    this.orderId = '',
    this.bankCard = '',
    this.status = '',
    this.currency = '',
    this.detailType = '',
    this.beginTime = '',
    this.endTime = '',
    this.amountRange = '',
    this.method = '',
    this.fileUrl = '',
    this.pdfUrl = '',
    this.createTime = '',
  });

  final int? id;
  final String name;
  final String orderId;
  final String bankCard;
  final String status;
  final String currency;
  final String detailType;
  final String beginTime;
  final String endTime;
  final String amountRange;
  final String method;
  final String email;
  final String code;
  final String fileUrl;
  final String pdfUrl;
  final String createTime;

  factory PrintExportResult.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'];
    final source = nestedData is Map
        ? Map<String, dynamic>.from(nestedData)
        : json;
    return PrintExportResult(
      id: _int(source['id']),
      name: _text(source['name']),
      orderId: _text(source['orderId']),
      bankCard: _text(source['bankCard']),
      status: _text(source['status']),
      currency: _text(source['currency']),
      detailType: _text(source['detailType']),
      beginTime: _text(source['beginTime']),
      endTime: _text(source['endTime']),
      amountRange: _text(source['amountRange']),
      method: _text(source['method']),
      email: _text(source['email']),
      code: _code(source['code']),
      fileUrl: _text(source['fileUrl']),
      pdfUrl: _text(source['pdfUrl']),
      createTime: _text(source['createTime']),
    );
  }

  static String _text(dynamic value) => value?.toString().trim() ?? '';

  static String _code(dynamic value) {
    final code = _text(value);
    return code.isEmpty ? '' : code.padLeft(6, '0');
  }

  static int? _int(dynamic value) => switch (value) {
        int number => number,
        num number => number.toInt(),
        String text => int.tryParse(text),
        _ => null,
      };
}

class PrintExportRecord {
  const PrintExportRecord({
    required this.id,
    required this.bankCard,
    required this.dateTimeRange,
    required this.status,
    required this.fileUrl,
    required this.createTime,
    required this.detail,
  });

  final int id;
  final String bankCard;
  final String dateTimeRange;
  final String status;
  final String fileUrl;
  final String createTime;
  final PrintExportResult detail;

  factory PrintExportRecord.fromJson(Map<String, dynamic> json) {
    final rawDetail = json['detail'];
    final detail = rawDetail is Map
        ? PrintExportResult.fromJson(Map<String, dynamic>.from(rawDetail))
        : PrintExportResult.fromJson(json);
    return PrintExportRecord(
      id: PrintExportResult._int(json['id']) ?? detail.id ?? 0,
      bankCard: PrintExportResult._text(json['bankCard']).isNotEmpty
          ? PrintExportResult._text(json['bankCard'])
          : detail.bankCard,
      dateTimeRange: PrintExportResult._text(json['dateTimeRange']),
      status: PrintExportResult._text(json['status']).isNotEmpty
          ? PrintExportResult._text(json['status'])
          : detail.status,
      fileUrl: PrintExportResult._text(json['fileUrl']).isNotEmpty
          ? PrintExportResult._text(json['fileUrl'])
          : detail.fileUrl,
      createTime: PrintExportResult._text(json['createTime']).isNotEmpty
          ? PrintExportResult._text(json['createTime'])
          : detail.createTime,
      detail: detail,
    );
  }
}

class PrintRecordPageData {
  const PrintRecordPageData({
    required this.records,
    required this.total,
    required this.pages,
  });

  final List<PrintExportRecord> records;
  final int total;
  final int pages;

  factory PrintRecordPageData.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'];
    final source = nestedData is Map
        ? Map<String, dynamic>.from(nestedData)
        : json;
    final rawList = source['list'];
    final records = rawList is List
        ? rawList
            .whereType<Map>()
            .map((item) => PrintExportRecord.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false)
        : const <PrintExportRecord>[];
    return PrintRecordPageData(
      records: records,
      total: PrintExportResult._int(source['total']) ?? records.length,
      pages: PrintExportResult._int(source['pages']) ??
          (records.isEmpty ? 0 : 1),
    );
  }
}

Future<PrintExportResult> submitPrintExport(
  Map<String, dynamic> params,
) async {
  print(params);
  final response = await Http.post(
    Apis.print,
    data: params,
    isLoading: false,
  );
  if (response is! Map) {
    throw const FormatException('打印申请接口返回格式错误');
  }
  return PrintExportResult.fromJson(Map<String, dynamic>.from(response));
}

Future<PrintRecordPageData> loadPrintRecordPage(
  int pageNum,
  int pageSize,
) async {
  final response = await Http.get(
    Apis.applyPageList,
    queryParameters: {
      'pageNum': pageNum,
      'pageSize': pageSize,
    },
    isLoading: false,
  );
  if (response is! Map) {
    throw const FormatException('打印申请记录接口返回格式错误');
  }
  return PrintRecordPageData.fromJson(Map<String, dynamic>.from(response));
}
