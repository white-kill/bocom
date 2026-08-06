class TransactionAdvancedFilterValue {
  const TransactionAdvancedFilterValue({
    this.direction,
    this.commonType,
    this.amountRange,
    this.channel,
    this.bank,
    this.accountName = '',
    this.accountNumber = '',
    this.summary = '',
  });

  final String? direction;
  final String? commonType;
  final String? amountRange;
  final String? channel;
  final String? bank;
  final String accountName;
  final String accountNumber;
  final String summary;

  bool get isEmpty =>
      direction == null &&
      commonType == null &&
      amountRange == null &&
      channel == null &&
      bank == null &&
      accountName.trim().isEmpty &&
      accountNumber.trim().isEmpty &&
      summary.trim().isEmpty;

  TransactionAdvancedFilterValue copyWith({
    String? direction,
    String? commonType,
    String? amountRange,
    String? channel,
    String? bank,
    String? accountName,
    String? accountNumber,
    String? summary,
  }) {
    return TransactionAdvancedFilterValue(
      direction: direction ?? this.direction,
      commonType: commonType ?? this.commonType,
      amountRange: amountRange ?? this.amountRange,
      channel: channel ?? this.channel,
      bank: bank ?? this.bank,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      summary: summary ?? this.summary,
    );
  }
}
