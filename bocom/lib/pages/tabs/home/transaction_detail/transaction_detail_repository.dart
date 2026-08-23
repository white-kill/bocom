import '../../../../config/dio/network.dart';
import '../../../../config/net_config/apis.dart';
import 'filter/transaction_advanced_filter_model.dart';
import 'transaction_detail_model.dart';

typedef TransactionBillPageLoader = Future<TransactionBillPage> Function(
  Map<String, dynamic> params,
);
typedef TransactionBillDetailLoader = Future<TransactionBillDetail> Function(
  int billId,
);

class TransactionBillQuery {
  const TransactionBillQuery._();

  static Map<String, dynamic> build({
    required int pageNum,
    required TransactionAdvancedFilterValue filter,
    DateTime? beginTime,
    DateTime? endTime,
  }) {
    final params = <String, dynamic>{
      'pageNum': pageNum,
      'pageSize': 10,
      'orderSort': '1',
    };
    if (beginTime != null) params['beginTime'] = _formatDate(beginTime);
    if (endTime != null) params['endTime'] = _formatDate(endTime);

    switch (filter.direction) {
      case '全部收入':
        params['type'] = 1;
      case '全部支出':
        params['type'] = 2;
    }
    _putText(params, 'keyWord', filter.commonType);
    _appendAmount(params, filter);
    _putText(params, 'transactionChannel', filter.channel);

    final bankName = filter.bank == '自定义' ? filter.customBankName : filter.bank;
    _putText(params, 'oppositeBankName', bankName);
    _putText(params, 'oppositeName', filter.accountName);
    _putText(params, 'oppositeAccount', filter.accountNumber);
    _putText(params, 'excerpt', filter.summary);
    return params;
  }

  static void _appendAmount(
    Map<String, dynamic> params,
    TransactionAdvancedFilterValue filter,
  ) {
    switch (filter.amountRange) {
      case '1百以下':
        params['maxAmount'] = 100;
      case '1百-1千':
        params
          ..['minAmount'] = 100
          ..['maxAmount'] = 1000;
      case '1千-5千':
        params
          ..['minAmount'] = 1000
          ..['maxAmount'] = 5000;
      case '5千-1万':
        params
          ..['minAmount'] = 5000
          ..['maxAmount'] = 10000;
      case '1万-5万':
        params
          ..['minAmount'] = 10000
          ..['maxAmount'] = 50000;
      case '5万以上':
        params['minAmount'] = 50000;
      case '自定义':
        final minAmount = num.tryParse(filter.minAmount.trim());
        final maxAmount = num.tryParse(filter.maxAmount.trim());
        if (minAmount != null) params['minAmount'] = minAmount;
        if (maxAmount != null) params['maxAmount'] = maxAmount;
    }
  }

  static void _putText(
    Map<String, dynamic> params,
    String key,
    String? value,
  ) {
    final text = value?.trim() ?? '';
    if (text.isNotEmpty) params[key] = text;
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class TransactionBillPage {
  const TransactionBillPage({
    required this.entries,
    required this.total,
    required this.pages,
    required this.incomeTotal,
    required this.expensesTotal,
  });

  final List<TransactionBillEntry> entries;
  final int total;
  final int pages;
  final double incomeTotal;
  final double expensesTotal;

  factory TransactionBillPage.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'];
    final source =
        nestedData is Map ? Map<String, dynamic>.from(nestedData) : json;
    final rawList = source['list'];
    final entries = rawList is List
        ? rawList
            .whereType<Map>()
            .map((item) => TransactionBillEntry.tryFromJson(
                  Map<String, dynamic>.from(item),
                ))
            .whereType<TransactionBillEntry>()
            .toList(growable: false)
        : const <TransactionBillEntry>[];
    return TransactionBillPage(
      entries: entries,
      total: _int(source['total']) ?? entries.length,
      pages: _int(source['pages']) ?? (entries.isEmpty ? 0 : 1),
      incomeTotal: _double(source['incomeTotal']) ?? 0,
      expensesTotal: _double(source['expensesTotal']) ?? 0,
    );
  }

  static int? _int(dynamic value) => switch (value) {
        int number => number,
        num number => number.toInt(),
        String text => int.tryParse(text),
        _ => null,
      };

  static double? _double(dynamic value) => switch (value) {
        num number => number.toDouble(),
        String text => double.tryParse(text.replaceAll(',', '')),
        _ => null,
      };
}

class TransactionBillEntry {
  const TransactionBillEntry({
    required this.id,
    required this.record,
    this.detail,
    this.monthIncomeTotal,
    this.monthExpensesTotal,
  });

  final int id;
  final TransactionRecord record;
  final TransactionBillDetail? detail;
  final double? monthIncomeTotal;
  final double? monthExpensesTotal;

  static TransactionBillEntry? tryFromJson(Map<String, dynamic> json) {
    final rawDetail = json['billDetail'];
    final detail = rawDetail is Map
        ? Map<String, dynamic>.from(rawDetail)
        : const <String, dynamic>{};
    final occurredAt = _dateTime(
      json['day'] ??
          json['transactionTime'] ??
          detail['transactionTime'] ??
          detail['accountsTime'],
    );
    if (occurredAt == null) return null;

    final type = _text(json['type']).isNotEmpty
        ? _text(json['type'])
        : _text(detail['type']);
    var amount = _number(json['amount']) ?? _number(detail['amount']) ?? 0;
    if (type == '2' && amount > 0) amount = -amount;
    if (type == '1' && amount < 0) amount = amount.abs();

    return TransactionBillEntry(
      id: TransactionBillPage._int(json['id']) ??
          TransactionBillPage._int(detail['id']) ??
          0,
      record: TransactionRecord(
        title: _firstText([
          json['oppositeName'],
          detail['oppositeName'],
          json['excerpt'],
          detail['excerpt'],
        ], fallback: '交易'),
        channel: _firstText([
          json['merchantBranch'],
          json['transactionChannel'],
          detail['merchantBranch'],
          detail['transactionChannel'],
          detail['transactionCategory'],
        ]),
        occurredAt: occurredAt,
        amount: amount,
        balance: _number(json['accountBalance']) ??
            _number(detail['accountBalance']) ??
            0,
      ),
      detail: detail.isEmpty ? null : TransactionBillDetail.fromJson(json),
      monthIncomeTotal: _number(json['monthIncomeTotal']),
      monthExpensesTotal: _number(json['monthExpensesTotal']),
    );
  }

  static String _firstText(
    Iterable<dynamic> values, {
    String fallback = '',
  }) {
    for (final value in values) {
      final text = _text(value);
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static String _text(dynamic value) => value?.toString().trim() ?? '';

  static double? _number(dynamic value) => switch (value) {
        num number => number.toDouble(),
        String text => double.tryParse(text.replaceAll(',', '').trim()),
        _ => null,
      };

  static DateTime? _dateTime(dynamic value) {
    final text = _text(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(
        text.replaceFirst('/', '-').replaceFirst('/', '-'));
  }
}

enum TransactionBillDetailKind {
  onlinePayment,
  transferRemittance,
  unknown;

  factory TransactionBillDetailKind.fromExcerpt(String excerpt) {
    return switch (excerpt.trim()) {
      '网上支付' => TransactionBillDetailKind.onlinePayment,
      '转账汇款' => TransactionBillDetailKind.transferRemittance,
      _ => TransactionBillDetailKind.unknown,
    };
  }
}

class TransactionBillDetail {
  const TransactionBillDetail({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.balance,
    required this.bankCard,
    required this.transactionTime,
    required this.transactionChannel,
    required this.transactionCategory,
    required this.transactionDescription,
    required this.oppositeName,
    required this.oppositeAccount,
    required this.oppositeBankName,
    required this.postscriptno,
    required this.transactionLogno,
    required this.excerpt,
  });

  final int id;
  final String merchantName;
  final double amount;
  final double balance;
  final String bankCard;
  final DateTime? transactionTime;
  final String transactionChannel;
  final String transactionCategory;
  final String transactionDescription;
  final String oppositeName;
  final String oppositeAccount;
  final String oppositeBankName;
  final String postscriptno;
  final String transactionLogno;
  final String excerpt;

  TransactionBillDetailKind get kind =>
      TransactionBillDetailKind.fromExcerpt(excerpt);

  String get displayName {
    final values = kind == TransactionBillDetailKind.transferRemittance
        ? [oppositeName, merchantName, excerpt]
        : [merchantName, oppositeName, excerpt];
    return _firstText(values, fallback: '交易');
  }

  factory TransactionBillDetail.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'];
    final source = nestedData is Map
        ? Map<String, dynamic>.from(nestedData)
        : Map<String, dynamic>.from(json);
    final rawDetail = source['billDetail'];
    final detail = rawDetail is Map
        ? Map<String, dynamic>.from(rawDetail)
        : const <String, dynamic>{};
    final type = _firstText([source['type'], detail['type']]);
    var amount = _number(source['amount']) ?? _number(detail['amount']) ?? 0;
    if (type == '2' && amount > 0) amount = -amount;
    if (type == '1' && amount < 0) amount = amount.abs();

    final excerpt = _firstText([
      detail['excerpt'],
      source['excerpt'],
      detail['transactionScene'],
      detail['scene'],
    ]);
    final oppositeName = _firstText([
      detail['oppositeName'],
      source['oppositeName'],
    ]);
    final merchantName = _firstText([
      detail['merchantName'],
      source['merchantName'],
    ]);
    return TransactionBillDetail(
      id: _int(source['id']) ?? _int(detail['id']) ?? 0,
      merchantName: merchantName.isNotEmpty
          ? merchantName
          : TransactionBillDetailKind.fromExcerpt(excerpt) ==
                  TransactionBillDetailKind.transferRemittance
              ? ''
              : oppositeName,
      amount: amount,
      balance: _number(source['accountBalance']) ??
          _number(detail['accountBalance']) ??
          0,
      bankCard: _firstText([
        detail['bankCard'],
        source['bankCard'],
        detail['account'],
      ]),
      transactionTime: _dateTime(
        detail['transactionTime'] ??
            source['transactionTime'] ??
            source['day'] ??
            detail['accountsTime'],
      ),
      transactionChannel: _firstText([
        detail['transactionChannel'],
        source['transactionChannel'],
        detail['merchantBranch'],
        source['merchantBranch'],
        detail['paymentChannel'],
      ]),
      transactionCategory: _firstText([
        detail['transactionCategory'],
        source['transactionCategory'],
        detail['transactionType'],
        source['transactionType'],
        detail['billType'],
      ]),
      transactionDescription: _firstText([
        detail['transactionDescription'],
        source['transactionDescription'],
      ]),
      oppositeName: oppositeName,
      oppositeAccount: _firstText([
        detail['oppositeAccount'],
        source['oppositeAccount'],
      ]),
      oppositeBankName: _firstText([
        detail['oppositeBankName'],
        source['oppositeBankName'],
      ]),
      postscriptno: _firstText([
        detail['postscriptno'],
        source['postscriptno'],
        detail['orderNumber'],
        detail['orderNo'],
        detail['orderId'],
        detail['certificateNo'],
        source['orderNumber'],
      ]),
      transactionLogno: _firstText([
        detail['transactionLogno'],
        source['transactionLogno'],
        detail['transactionSerialNumber'],
        detail['serialNumber'],
        detail['flowNo'],
      ]),
      excerpt: excerpt,
    );
  }

  factory TransactionBillDetail.fromRecord(TransactionRecord record) =>
      TransactionBillDetail(
        id: 0,
        merchantName: record.title,
        amount: record.amount,
        balance: record.balance,
        bankCard: '',
        transactionTime: record.occurredAt,
        transactionChannel: record.channel,
        transactionCategory: '',
        transactionDescription: '',
        oppositeName: '',
        oppositeAccount: '',
        oppositeBankName: '',
        postscriptno: '',
        transactionLogno: '',
        excerpt: '',
      );

  static String _firstText(
    Iterable<dynamic> values, {
    String fallback = '',
  }) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static int? _int(dynamic value) => switch (value) {
        int number => number,
        num number => number.toInt(),
        String text => int.tryParse(text.trim()),
        _ => null,
      };

  static double? _number(dynamic value) => switch (value) {
        num number => number.toDouble(),
        String text => double.tryParse(text.replaceAll(',', '').trim()),
        _ => null,
      };

  static DateTime? _dateTime(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }
}

Future<TransactionBillPage> loadTransactionBillPage(
  Map<String, dynamic> params,
) async {
  final response = await Http.post(
    Apis.billPage,
    data: params,
    isLoading: false,
  );
  if (response is! Map) {
    throw const FormatException('交易明细接口返回格式错误');
  }
  return TransactionBillPage.fromJson(Map<String, dynamic>.from(response));
}

Future<TransactionBillDetail> loadTransactionBillDetail(int billId) async {
  final response = await Http.post(
    '${Apis.billDetail}/$billId',
    isLoading: false,
  );
  if (response is! Map) {
    throw const FormatException('单笔账单详情接口返回格式错误');
  }
  return TransactionBillDetail.fromJson(
    Map<String, dynamic>.from(response),
  );
}
