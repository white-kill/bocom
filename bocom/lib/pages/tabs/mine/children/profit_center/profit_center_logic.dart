import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'profit_center_state.dart';

enum ProfitPeriod { day, week, month, year }

enum ProfitChartView { calendar, trend }

class ProfitWeekRange {
  const ProfitWeekRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

class ProfitCenterLogic extends GetxController {
  ProfitCenterLogic({DateTime? now})
      : currentDate = _dateOnly(now ?? DateTime.now()) {
    selectedDate = currentDate.obs;
    calendarAnchor = DateTime(currentDate.year, currentDate.month).obs;
  }

  final ProfitCenterState state = ProfitCenterState();

  var navActionColor = Colors.white.obs;
  var navActionFlag = false.obs;
  var nowDate = "".obs;
  final RxBool amountVisible = true.obs;
  final Rx<ProfitChartView> selectedView = ProfitChartView.calendar.obs;
  final Rx<ProfitPeriod> selectedPeriod = ProfitPeriod.day.obs;
  final DateTime currentDate;
  late final Rx<DateTime> selectedDate;
  late final Rx<DateTime> calendarAnchor;

  String get periodDateText =>
      formatPeriodDate(selectedPeriod.value, selectedDate.value);

  void selectPeriod(ProfitPeriod period) {
    selectedPeriod.value = period;
    calendarAnchor.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
    );
  }

  void selectView(ProfitChartView view) {
    selectedView.value = view;
  }

  void selectCalendarDay(DateTime date) {
    if (_dateOnly(date).isAfter(currentDate)) return;
    selectedDate.value = _dateOnly(date);
    calendarAnchor.value = DateTime(date.year, date.month);
  }

  void selectCalendarWeek(DateTime weekStart) {
    if (_dateOnly(weekStart).isAfter(currentDate)) return;
    selectedDate.value = _dateOnly(weekStart);
  }

  void selectCalendarMonth(int month) {
    final date = DateTime(calendarAnchor.value.year, month);
    if (date.isAfter(DateTime(currentDate.year, currentDate.month))) return;
    selectedDate.value = date;
  }

  void selectCalendarYear(int year) {
    if (year > currentDate.year) return;
    selectedDate.value = DateTime(year);
    calendarAnchor.value = DateTime(year, calendarAnchor.value.month);
  }

  bool canMoveCalendarNext(ProfitPeriod period) {
    if (period == ProfitPeriod.year) return false;
    final anchor = calendarAnchor.value;
    final candidate = period == ProfitPeriod.month
        ? DateTime(anchor.year + 1)
        : DateTime(anchor.year, anchor.month + 1);
    final latest = period == ProfitPeriod.month
        ? DateTime(currentDate.year)
        : DateTime(currentDate.year, currentDate.month);
    return !candidate.isAfter(latest);
  }

  void moveCalendar(ProfitPeriod period, int direction) {
    if (direction > 0 && !canMoveCalendarNext(period)) return;
    final anchor = calendarAnchor.value;
    calendarAnchor.value = period == ProfitPeriod.month
        ? DateTime(anchor.year + direction)
        : DateTime(anchor.year, anchor.month + direction);
  }

  static String formatPeriodDate(ProfitPeriod period, DateTime date) {
    switch (period) {
      case ProfitPeriod.day:
        return DateFormat('yyyy年MM月dd日').format(date);
      case ProfitPeriod.week:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final startText = DateFormat('yyyy年MM.dd').format(weekStart);
        final endPattern = weekStart.year == weekEnd.year
            ? 'MM.dd'
            : 'yyyy年MM.dd';
        return '$startText至${DateFormat(endPattern).format(weekEnd)}';
      case ProfitPeriod.month:
        return DateFormat('yyyy年MM月').format(date);
      case ProfitPeriod.year:
        return DateFormat('yyyy年').format(date);
    }
  }

  static List<DateTime?> buildMonthCalendar(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final leadingDays = firstDay.weekday % DateTime.daysPerWeek;
    final firstCell = firstDay.subtract(Duration(days: leadingDays));
    final lastDay = DateTime(month.year, month.month + 1, 0);

    return List<DateTime?>.generate(42, (index) {
      final date = firstCell.add(Duration(days: index));
      if (date.isAfter(lastDay)) return null;
      return date;
    });
  }

  static List<ProfitWeekRange> buildMonthWeeks(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    var weekStart = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    final weeks = <ProfitWeekRange>[];

    while (!weekStart.isAfter(lastDay)) {
      weeks.add(
        ProfitWeekRange(
          weekStart,
          weekStart.add(const Duration(days: 6)),
        ),
      );
      weekStart = weekStart.add(const Duration(days: 7));
    }
    return weeks;
  }

  static String formatCalendarWeek(ProfitWeekRange week) {
    return '${DateFormat('yyyy-MM-dd').format(week.start)}至'
        '${DateFormat('MM-dd').format(week.end)}';
  }

  static List<int> buildCalendarYears(int currentYear) {
    return List<int>.generate(6, (index) => currentYear - 5 + index);
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void toggleAmountVisible() {
    amountVisible.value = !amountVisible.value;
  }

  @override
  void onInit() {
    super.onInit();
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy年MM月dd日 hh:mm:ss');
    nowDate = formatter.format(now).obs;
  }
}
