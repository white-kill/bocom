class TransactionAdvancedFilterValue {
  const TransactionAdvancedFilterValue({
    this.direction,
    this.commonType,
    this.amountRange,
    this.minAmount = '',
    this.maxAmount = '',
    this.channel,
    this.bank,
    this.customBankName = '',
    this.accountName = '',
    this.accountNumber = '',
    this.summary = '',
  });

  final String? direction;
  final String? commonType;
  final String? amountRange;
  final String minAmount;
  final String maxAmount;
  final String? channel;
  final String? bank;
  final String customBankName;
  final String accountName;
  final String accountNumber;
  final String summary;

  bool get isEmpty =>
      direction == null &&
      commonType == null &&
      amountRange == null &&
      minAmount.trim().isEmpty &&
      maxAmount.trim().isEmpty &&
      channel == null &&
      bank == null &&
      customBankName.trim().isEmpty &&
      accountName.trim().isEmpty &&
      accountNumber.trim().isEmpty &&
      summary.trim().isEmpty;

  TransactionAdvancedFilterValue copyWith({
    String? direction,
    String? commonType,
    String? amountRange,
    String? minAmount,
    String? maxAmount,
    String? channel,
    String? bank,
    String? customBankName,
    String? accountName,
    String? accountNumber,
    String? summary,
  }) {
    return TransactionAdvancedFilterValue(
      direction: direction ?? this.direction,
      commonType: commonType ?? this.commonType,
      amountRange: amountRange ?? this.amountRange,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      channel: channel ?? this.channel,
      bank: bank ?? this.bank,
      customBankName: customBankName ?? this.customBankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      summary: summary ?? this.summary,
    );
  }
}
