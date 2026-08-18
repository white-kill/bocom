import '../../../../../config/dio/network.dart';
import '../../../../../config/net_config/apis.dart';

typedef TransferRecordPageLoader = Future<TransferRecordPageData> Function(
  Map<String, dynamic> params,
);

class TransferRecordPageData {
  const TransferRecordPageData({
    required this.records,
    required this.total,
    required this.pages,
    required this.incomeTotal,
    required this.expensesTotal,
  });

  final List<TransferRecordEntry> records;
  final int total;
  final int pages;
  final double incomeTotal;
  final double expensesTotal;

  factory TransferRecordPageData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final source = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : Map<String, dynamic>.from(json);
    final rawList = source['list'];
    final records = rawList is List
        ? rawList
            .whereType<Map>()
            .map((item) => TransferRecordEntry.tryFromJson(
                  Map<String, dynamic>.from(item),
                ))
            .whereType<TransferRecordEntry>()
            .toList(growable: false)
        : const <TransferRecordEntry>[];
    return TransferRecordPageData(
      records: records,
      total: _int(source['total']) ?? records.length,
      pages: _int(source['pages']) ?? (records.isEmpty ? 0 : 1),
      incomeTotal: _double(source['incomeTotal']) ?? 0,
      expensesTotal: _double(source['expensesTotal']) ?? 0,
    );
  }
}

class TransferRecordEntry {
  const TransferRecordEntry({
    required this.id,
    required this.bankCard,
    required this.amount,
    required this.oppositeName,
    required this.oppositeAccount,
    required this.oppositeBankName,
    this.icon = '',
    required this.excerpt,
    required this.transactionDescription,
    required this.type,
    required this.transactionTime,
    this.accountsTime,
  });

  final int id;
  final String bankCard;
  final double amount;
  final String oppositeName;
  final String oppositeAccount;
  final String oppositeBankName;
  final String icon;
  final String excerpt;
  final String transactionDescription;
  final int type;
  final DateTime transactionTime;
  final DateTime? accountsTime;

  static TransferRecordEntry? tryFromJson(Map<String, dynamic> json) {
    final transactionTime = _dateTime(json['transactionTime'] ?? json['day']);
    if (transactionTime == null) return null;
    final type = _int(json['type']) ?? 2;
    var amount = _double(json['amount']) ?? 0;
    if (type == 2 && amount > 0) amount = -amount;
    if (type == 1 && amount < 0) amount = amount.abs();
    return TransferRecordEntry(
      id: _int(json['id']) ?? 0,
      bankCard: _text(json['bankCard']),
      amount: amount,
      oppositeName: _text(json['oppositeName']),
      oppositeAccount: _text(json['oppositeAccount']),
      oppositeBankName: _text(json['oppositeBankName']),
      icon: _text(json['icon']),
      excerpt: _text(json['excerpt']),
      transactionDescription: _text(json['transactionDescription']),
      type: type,
      transactionTime: transactionTime,
      accountsTime: _dateTime(json['accountsTime']),
    );
  }
}

Future<TransferRecordPageData> loadTransferRecordPage(
  Map<String, dynamic> params,
) async {
  final response = await Http.post(
    Apis.transferPage,
    data: params,
    isLoading: false,
  );
  if (response is! Map) {
    throw const FormatException('转账记录接口返回格式错误');
  }
  return TransferRecordPageData.fromJson(
    Map<String, dynamic>.from(response),
  );
}

String _text(dynamic value) => value?.toString().trim() ?? '';

int? _int(dynamic value) => switch (value) {
      int number => number,
      num number => number.toInt(),
      String text => int.tryParse(text.trim()),
      _ => null,
    };

double? _double(dynamic value) => switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text.replaceAll(',', '').trim()),
      _ => null,
    };

DateTime? _dateTime(dynamic value) {
  final text = _text(value);
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}
