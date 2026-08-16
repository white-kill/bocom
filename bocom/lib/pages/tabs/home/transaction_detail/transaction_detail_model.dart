class TransactionRecord {
  const TransactionRecord({
    required this.title,
    required this.channel,
    required this.occurredAt,
    required this.amount,
    required this.balance,
  });

  final String title;
  final String channel;
  final DateTime occurredAt;
  final double amount;
  final double balance;

  bool get isIncome => amount > 0;
}

class TransactionMonthSection {
  const TransactionMonthSection({
    required this.year,
    required this.month,
    required this.records,
    this.serverIncome,
    this.serverExpense,
  });

  final int year;
  final int month;
  final List<TransactionRecord> records;
  final double? serverIncome;
  final double? serverExpense;

  String get monthKey => '$year-${month.toString().padLeft(2, '0')}';

  double get income =>
      serverIncome ??
      records
          .where((record) => record.amount > 0)
          .fold(0, (sum, record) => sum + record.amount);

  double get expense =>
      serverExpense ??
      records
          .where((record) => record.amount < 0)
          .fold(0, (sum, record) => sum + record.amount.abs());
}
