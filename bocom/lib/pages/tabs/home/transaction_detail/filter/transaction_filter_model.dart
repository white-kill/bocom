import '../transaction_detail_model.dart';

enum TransactionDateFilterMode { month, year, custom }

enum TransactionQuickRange {
  currentMonth,
  recentWeek,
  recentMonth,
  recentThreeMonths,
  recentYear,
  custom,
}

extension TransactionQuickRangeText on TransactionQuickRange {
  String get label => switch (this) {
        TransactionQuickRange.currentMonth => '本月',
        TransactionQuickRange.recentWeek => '近一周',
        TransactionQuickRange.recentMonth => '近一个月',
        TransactionQuickRange.recentThreeMonths => '近三个月',
        TransactionQuickRange.recentYear => '近一年',
        TransactionQuickRange.custom => '自定义',
      };
}

class TransactionFilterSelection {
  const TransactionFilterSelection.month(this.month)
      : mode = TransactionDateFilterMode.month,
        year = null,
        startDate = null,
        endDate = null;

  const TransactionFilterSelection.year(this.year)
      : mode = TransactionDateFilterMode.year,
        month = null,
        startDate = null,
        endDate = null;

  const TransactionFilterSelection.custom({
    required this.startDate,
    required this.endDate,
  })  : mode = TransactionDateFilterMode.custom,
        month = null,
        year = null;

  final TransactionDateFilterMode mode;
  final DateTime? month;
  final int? year;
  final DateTime? startDate;
  final DateTime? endDate;

  String get toolbarLabel => switch (mode) {
        TransactionDateFilterMode.month =>
          '${month!.year}-${month!.month.toString().padLeft(2, '0')}',
        TransactionDateFilterMode.year => year.toString(),
        TransactionDateFilterMode.custom =>
          '${_toolbarDate(startDate!)}-${_toolbarDate(endDate!)}',
      };

  static String _toolbarDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

enum TransactionDateValidationError { startAfterEnd, overTwoYears }

class TransactionDateRules {
  const TransactionDateRules._();

  static TransactionDateValidationError? validate(
    DateTime start,
    DateTime end,
  ) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    if (normalizedStart.isAfter(normalizedEnd)) {
      return TransactionDateValidationError.startAfterEnd;
    }

    final twoYearsLater = DateTime(
      normalizedStart.year + 2,
      normalizedStart.month,
      normalizedStart.day,
    );
    if (normalizedEnd.isAfter(twoYearsLater)) {
      return TransactionDateValidationError.overTwoYears;
    }
    return null;
  }

  static bool containsFutureDate(DateTime start, DateTime end, DateTime today) {
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return start.isAfter(endOfToday) || end.isAfter(endOfToday);
  }
}

class TransactionFilterResult {
  const TransactionFilterResult({
    required this.toolbarLabel,
    required this.count,
    required this.income,
    required this.expense,
    required this.records,
    this.selection,
    this.quickRange,
    this.showSummary = true,
  });

  final String toolbarLabel;
  final int count;
  final double income;
  final double expense;
  final List<TransactionRecord> records;
  final TransactionFilterSelection? selection;
  final TransactionQuickRange? quickRange;
  final bool showSummary;
}
