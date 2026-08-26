import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerTrendChart extends StatefulWidget {
  const LedgerTrendChart({
    super.key,
    this.incomeValues = const [],
    this.expenseValues = const [],
    this.dateValues = const [],
    this.title = '近一月收支',
    this.isYearMode = false,
    this.year,
    this.month,
  });

  final List<double> incomeValues;
  final List<double> expenseValues;
  final List<String> dateValues;
  final String title;
  final bool isYearMode;
  final int? year;
  final int? month;

  @override
  State<LedgerTrendChart> createState() => _LedgerTrendChartState();
}

class _LedgerTrendChartState extends State<LedgerTrendChart> {
  static const _incomeColor = Color(0xFF5B9FF2);
  static const _expenseColor = Color(0xFFFF914D);
  late int _selectedIndex;
  bool _showCalendar = false;
  int _selectedCalendarIndex = 11;
  DateTime? _selectedCalendarDate;

  bool get _isCurrentYear =>
      widget.isYearMode && widget.year == DateTime.now().year;

  int get _pointCount => math.max(
        2,
        math.max(
          widget.dateValues.length,
          math.max(widget.incomeValues.length, widget.expenseValues.length),
        ),
      );

  @override
  void initState() {
    super.initState();
    _selectedIndex = _pointCount - 1;
  }

  @override
  void didUpdateWidget(covariant LedgerTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateValues.length != widget.dateValues.length ||
        oldWidget.incomeValues.length != widget.incomeValues.length ||
        oldWidget.expenseValues.length != widget.expenseValues.length) {
      _selectedIndex = _pointCount - 1;
    }
    if (oldWidget.year != widget.year) _selectedCalendarIndex = 11;
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      _selectedCalendarDate = null;
    }
  }

  List<double> _values(List<double> source) {
    final values = source.take(_pointCount).toList();
    return [...values, ...List<double>.filled(_pointCount - values.length, 0)];
  }

  double get _maxY {
    final values = [..._values(widget.incomeValues), ..._values(widget.expenseValues)];
    final max = values.fold<double>(0, (result, value) => value > result ? value : result);
    return max <= 0 ? 5 : max * 1.2;
  }

  // Keep zero slightly above the clipped plot boundary so consecutive zero
  // values still render as a visible, connected line.
  double get _minY => -_maxY * 0.04;

  double _valueToChartY(double value, double plotHeight) =>
      plotHeight * (_maxY - value) / (_maxY - _minY);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.w),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (!_showCalendar || !widget.isYearMode || _isCurrentYear)
                BaseText(text: widget.title, fontSize: 13, color: const Color(0xFF333333)),
              const Spacer(),
              _buildSwitch(),
            ],
          ),
          SizedBox(height: 20.w),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _showCalendar
                ? SizedBox(
                    key: ValueKey(
                      widget.isYearMode ? 'year-calendar' : 'month-calendar',
                    ),
                    height: widget.isYearMode ? 240.w : _monthCalendarHeight(),
                    child: widget.isYearMode
                        ? _buildYearCalendar()
                        : _buildMonthCalendar(),
                  )
                : SizedBox(
                    key: const ValueKey('trend-chart'),
                    height: 170.w,
                    child: LayoutBuilder(
                      builder: (context, constraints) =>
                          _buildChart(constraints.maxWidth),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(double chartWidth) {
    final selectedX = chartWidth * _selectedIndex / (_pointCount - 1);
    final plotHeight = 140.w;
    final incomeY = _valueToChartY(
      _values(widget.incomeValues)[_selectedIndex],
      plotHeight,
    );
    final expenseY = _valueToChartY(
      _values(widget.expenseValues)[_selectedIndex],
      plotHeight,
    );
    final tooltipGap = 12.w;
    final minimumTooltipWidth = 115.w;
    final maximumTooltipOffset = math.max(
      0.0,
      chartWidth - minimumTooltipWidth,
    );
    final showTooltipOnRight = _selectedIndex < _pointCount ~/ 2;
    final tooltipLeft = (selectedX + tooltipGap)
        .clamp(0.0, maximumTooltipOffset)
        .toDouble();
    final tooltipRight = (chartWidth - selectedX + tooltipGap)
        .clamp(0.0, maximumTooltipOffset)
        .toDouble();
    final middleYearIndex = widget.dateValues.length ~/ 2;
    final middleYearX = widget.dateValues.length > 2
        ? chartWidth * middleYearIndex / (_pointCount - 1)
        : 0.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 30.w,
          child: LineChart(
            _chartData(),
            // Monthly and yearly data use very different Y-axis scales. Keep
            // their animation states separate so fl_chart never interpolates
            // yearly values against the previous monthly axis range.
            key: ValueKey(widget.isYearMode),
            duration: const Duration(milliseconds: 250),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          child: SizedBox(
            height: 1.w,
            child: CustomPaint(painter: _HorizontalDashPainter()),
          ),
        ),
        Positioned(
          left: selectedX,
          top: 0,
          bottom: 30.w,
          child: SizedBox(
            width: 1.w,
            child: CustomPaint(painter: _SelectedDashPainter()),
          ),
        ),
        _selectedPoint(
          x: selectedX,
          y: expenseY,
          color: _expenseColor,
        ),
        _selectedPoint(
          x: selectedX,
          y: incomeY,
          color: _incomeColor,
        ),
        Positioned(
          left: showTooltipOnRight ? tooltipLeft : null,
          right: showTooltipOnRight ? null : tooltipRight,
          top: 5.w,
          child: _buildTooltip(),
        ),
        if (widget.isYearMode)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 30.w,
            child: _yearAxisLabels(
              middleIndex: middleYearIndex,
              middleX: middleYearX,
            ),
          )
        else ...[
          Positioned(
            left: 0,
            bottom: 0,
            child: BaseText(
              text: _dateLabel(0),
              fontSize: 13,
              color: const Color(0xFFA6ADB7),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: BaseText(
              text: _endDateLabel(),
              fontSize: 13,
              color: const Color(0xFF222222),
            ),
          ),
        ],
      ],
    );
  }

  Widget _selectedPoint({
    required double x,
    required double y,
    required Color color,
  }) {
    return Positioned(
      left: x - 8.w,
      top: y - 8.w,
      child: Container(
        width: 16.w,
        height: 16.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.38),
              color.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.w),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch() {
    return Container(
      width: 126.w,
      height: 30.w,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showCalendar = false),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !_showCalendar ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18.w),
                ),
                child: BaseText(
                  text: '看走势',
                  fontSize: 12,
                  color: !_showCalendar
                      ? const Color(0xFF1677FF)
                      : const Color(0xFF555555),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showCalendar = true),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _showCalendar ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18.w),
                ),
                child: BaseText(
                  text: '看日历',
                  fontSize: 12,
                  color: _showCalendar
                      ? const Color(0xFF1677FF)
                      : const Color(0xFF555555),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return !widget.isYearMode &&
        widget.year == now.year &&
        widget.month == now.month;
  }

  List<DateTime> _monthCalendarDates() {
    final now = DateTime.now();
    if (_isCurrentMonth) {
      final previousMonth = DateTime(now.year, now.month - 1);
      final maxPreviousDay =
          DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
      final start = DateTime(
        previousMonth.year,
        previousMonth.month,
        math.min(now.day, maxPreviousDay),
      );
      final count = now.difference(start).inDays + 1;
      return List<DateTime>.generate(
        count,
        (index) => start.add(Duration(days: index)),
      );
    }
    final year = widget.year ?? now.year;
    final month = widget.month ?? now.month;
    final dayCount = DateTime(year, month + 1, 0).day;
    return List<DateTime>.generate(
      dayCount,
      (index) => DateTime(year, month, index + 1),
    );
  }

  int _monthCalendarRowCount() {
    final dates = _monthCalendarDates();
    final leading = dates.first.weekday % 7;
    return ((leading + dates.length) / 7).ceil();
  }

  double _monthCalendarHeight() =>
      (28 + _monthCalendarRowCount() * 60 + 70).w;

  Widget _buildMonthCalendar() {
    final dates = _monthCalendarDates();
    final valuesByDay = <String, _CalendarDayData>{};
    final dataCount = math.min(
      dates.length,
      math.max(
        widget.dateValues.length,
        math.max(widget.incomeValues.length, widget.expenseValues.length),
      ),
    );
    for (var index = 0; index < dataCount; index++) {
      final rawDate = index < widget.dateValues.length ? widget.dateValues[index] : '';
      final date = _dateFromValue(rawDate) ?? dates[index];
      valuesByDay[_dayKey(date)] = _CalendarDayData(
        date: date,
        income: index < widget.incomeValues.length ? widget.incomeValues[index] : 0,
        expense: index < widget.expenseValues.length ? widget.expenseValues[index] : 0,
      );
    }
    final entries = dates
        .map(
          (date) => valuesByDay[_dayKey(date)] ??
              _CalendarDayData(date: date, income: 0, expense: 0),
        )
        .toList();
    final selectedDate = _selectedCalendarDate ?? entries.last.date;
    final selected = entries.firstWhere(
      (entry) => DateUtils.isSameDay(entry.date, selectedDate),
      orElse: () => entries.last,
    );
    final leading = dates.first.weekday % 7;
    final slots = <_CalendarDayData?>[
      ...List<_CalendarDayData?>.filled(leading, null),
      ...entries,
    ];

    return Column(
      children: [
        Row(
          children: const ['日', '一', '二', '三', '四', '五', '六']
              .map(
                (text) => Expanded(
                  child: Center(
                    child: BaseText(
                      text: text,
                      fontSize: 13,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 8.w),
        SizedBox(
          height: (_monthCalendarRowCount() * 60).w,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 60.w,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemBuilder: (_, index) {
              final entry = slots[index];
              return entry == null
                  ? const SizedBox.shrink()
                  : _buildCalendarDay(entry);
            },
          ),
        ),
        const Spacer(),
        _buildDayDescription(selected),
      ],
    );
  }

  DateTime? _dateFromValue(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
    final match = RegExp(r'(\d{4})[-/年](\d{1,2})[-/月](\d{1,2})')
        .firstMatch(value);
    final year = int.tryParse(match?.group(1) ?? '');
    final month = int.tryParse(match?.group(2) ?? '');
    final day = int.tryParse(match?.group(3) ?? '');
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  String _dayKey(DateTime value) =>
      '${_monthKey(value)}-${value.day.toString().padLeft(2, '0')}';

  Widget _buildCalendarDay(_CalendarDayData data) {
    final selected = DateUtils.isSameDay(
      data.date,
      _selectedCalendarDate ?? _monthCalendarDates().last,
    );
    final hasData = data.income > 0 || data.expense > 0;
    final background = selected
        ? const Color(0xFF0877F9)
        : hasData
            ? data.income > data.expense
                ? const Color(0xFFE6F2FF)
                : const Color(0xFFFFF0E7)
            : Colors.transparent;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedCalendarDate = data.date),
      child: Column(
        children: [
          SizedBox(
            height: 12.w,
            child: data.date.day == 1
                ? BaseText(
                    text: '${data.date.month}月',
                    fontSize: 9,
                    color: const Color(0xFF444444),
                  )
                : null,
          ),
          Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: BaseText(
              text: '${data.date.day}',
              fontSize: 13,
              color: selected ? Colors.white : const Color(0xFF555555),
            ),
          ),
          if (hasData)
            BaseText(
              text: _calendarAmount(
                data.expense > data.income ? data.expense : data.income,
              ),
              fontSize: 9,
              color: data.expense > data.income
                  ? const Color(0xFFFF7A18)
                  : const Color(0xFF5B9FF2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildDayDescription(_CalendarDayData data) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText(
              text: _dayKey(data.date),
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
            SizedBox(height: 8.w),
            Row(
              children: [
                _calendarLegend(const Color(0xFFFF914D), '支出', data.expense),
                SizedBox(width: 15.w),
                _calendarLegend(const Color(0xFF5B9FF2), '收入', data.income),
              ],
            ),
          ],
        ),
      );

  Widget _buildYearCalendar() {
    final months = _calendarMonths();
    final valuesByMonth = <String, _CalendarMonthData>{};
    final dataCount = math.min(
      12,
      math.max(
        widget.dateValues.length,
        math.max(widget.incomeValues.length, widget.expenseValues.length),
      ),
    );
    for (var index = 0; index < dataCount; index++) {
      final date = index < widget.dateValues.length ? widget.dateValues[index] : '';
      final target = _yearMonthFromDate(date) ?? months[index];
      valuesByMonth[_monthKey(target)] = _CalendarMonthData(
        date: target,
        income: index < widget.incomeValues.length ? widget.incomeValues[index] : 0,
        expense: index < widget.expenseValues.length ? widget.expenseValues[index] : 0,
      );
    }
    final entries = months
        .map(
          (date) => valuesByMonth[_monthKey(date)] ??
              _CalendarMonthData(date: date, income: 0, expense: 0),
        )
        .toList();
    final selected = entries[_selectedCalendarIndex.clamp(0, 11).toInt()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isCurrentYear)
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: BaseText(
              text: '${widget.year ?? DateTime.now().year}年',
              fontSize: 13,
              color: const Color(0xFF333333),
            ),
          ),
        SizedBox(
          height: 160.w,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 3.w,
              crossAxisSpacing: 0.w,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (_, index) => _buildCalendarMonth(
              index: index,
              data: entries[index],
            ),
          ),
        ),
        const Spacer(),
        _buildCalendarDescription(selected),
      ],
    );
  }

  List<DateTime> _calendarMonths() {
    if (_isCurrentYear) {
      final now = DateTime.now();
      return List<DateTime>.generate(
        12,
        (index) => DateTime(now.year, now.month - 11 + index),
      );
    }
    final year = widget.year ?? DateTime.now().year;
    return List<DateTime>.generate(12, (index) => DateTime(year, index + 1));
  }

  DateTime? _yearMonthFromDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateTime(parsed.year, parsed.month);
    final match = RegExp(r'(\d{4})[-/年](\d{1,2})').firstMatch(value);
    final year = int.tryParse(match?.group(1) ?? '');
    final month = int.tryParse(match?.group(2) ?? '');
    if (year == null || month == null || month < 1 || month > 12) return null;
    return DateTime(year, month);
  }

  String _monthKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}';

  Widget _buildCalendarMonth({
    required int index,
    required _CalendarMonthData data,
  }) {
    final selected = index == _selectedCalendarIndex;
    final hasData = data.income > 0 || data.expense > 0;
    final incomeWins = data.income > data.expense;
    final background = selected
        ? const Color(0xFF0877F9)
        : hasData
            ? incomeWins
                ? const Color(0xFFE6F2FF)
                : const Color(0xFFFFF0E7)
            : Colors.transparent;


    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedCalendarIndex = index),
      child: Column(
        children: [
          if (_isCurrentYear)
            SizedBox(
              height: 18.w,
              child: data.date.month == 1
                  ? Padding(
                      padding: EdgeInsets.only(top: 1.w, bottom: 5.w),
                      child: BaseText(
                        text: '${data.date.year}年',
                        fontSize: 10,
                        color: const Color(0xFF666666),
                      ),
                    )
                  : null,
            ),
          Container(
            width: 32.w,
            height: 32.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: BaseText(
              text: '${data.date.month}月',
              fontSize: 13,
              color: selected ? Colors.white : const Color(0xFF555555),
            ),
          ),
          if (hasData) ...[
            SizedBox(height: 2.w),
            if (data.expense > 0)
              BaseText(
                text: _calendarAmount(data.expense),
                fontSize: 10,
                color: const Color(0xFFFF7A18),
                maxLines: 1,
              ),
            if (data.income > 0)
              BaseText(
                text: _calendarAmount(data.income),
                fontSize: 10,
                color: const Color(0xFF5B9FF2),
                maxLines: 1,
              ),
          ],
        ],
      ),
    );
  }

  String _calendarAmount(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(2);
    return value.toStringAsFixed(2);
  }

  Widget _buildCalendarDescription(_CalendarMonthData data) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText(
              text: _monthKey(data.date),
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
            SizedBox(height: 8.w),
            Row(
              children: [
                _calendarLegend(const Color(0xFFFF914D), '支出', data.expense),
                SizedBox(width: 15.w),
                _calendarLegend(const Color(0xFF5B9FF2), '收入', data.income),
              ],
            ),
          ],
        ),
      );

  Widget _calendarLegend(Color color, String label, double value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.w),
          BaseText(text: label, fontSize: 13, color: const Color(0xFF999999)),
          SizedBox(width: 5.w),
          BaseText(
            text: value.toStringAsFixed(2),
            fontSize: 13,
            color: const Color(0xFF333333),
          ),
        ],
      );

  Widget _buildTooltip() {
    final income = _values(widget.incomeValues)[_selectedIndex];
    final expense = _values(widget.expenseValues)[_selectedIndex];
    final dateText = _selectedIndex < widget.dateValues.length
        ? widget.dateValues[_selectedIndex]
        : '';
    return Container(
      key: const Key('ledger-trend-tooltip'),
      constraints: BoxConstraints(minWidth: 115.w),
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.w),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseText(
            text: dateText,
            fontSize: 12,
            color: const Color(0xFF929292),
          ),
          SizedBox(height: 8.w),
          _tooltipRow(_incomeColor, '收入', income),
          SizedBox(height: 8.w),
          _tooltipRow(_expenseColor, '支出', expense),
        ],
      ),
    );
  }

  Widget _tooltipRow(Color color, String label, double value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 9.w, height: 9.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 5.w),
          BaseText(text: '$label ${value.toStringAsFixed(2)}', fontSize: 12, color: const Color(0xFF666666)),
        ],
      );

  String _dateLabel(int index) {
    if (index >= widget.dateValues.length) return '';
    final value = widget.dateValues[index];
    return value.length >= 10 ? value.substring(5, 10) : value;
  }

  Widget _yearStartLabel() {
    final date = _yearMonthAt(0);
    if (date == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText(
          text: '${date.month}月',
          fontSize: 13,
          color: const Color(0xFFA6ADB7),
        ),
        BaseText(
          text: '${date.year}',
          fontSize: 13,
          color: const Color(0xFFA6ADB7),
        ),
      ],
    );
  }

  Widget _yearAxisLabels({
    required int middleIndex,
    required double middleX,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 5.w,
          child: _yearStartLabel(),
        ),
        if (!_isCurrentYear && widget.dateValues.length > 2)
          Positioned(
            left: middleX,
            top: 5.w,
            child: FractionalTranslation(
              translation: const Offset(-0.5, 0),
              child: BaseText(
                text: _yearMonthLabel(middleIndex),
                fontSize: 13,
                color: const Color(0xFF222222),
              ),
            ),
          ),
        Positioned(
          right: 0,
          top: 5.w,
          child: BaseText(
            text: _yearMonthLabel(widget.dateValues.length - 1),
            fontSize: 13,
            color: const Color(0xFF222222),
          ),
        ),
      ],
    );
  }

  String _yearMonthLabel(int index) {
    final date = _yearMonthAt(index);
    return date == null ? '' : '${date.month}月';
  }

  DateTime? _yearMonthAt(int index) {
    if (index < 0 || index >= widget.dateValues.length) return null;
    return _yearMonthFromDate(widget.dateValues[index]);
  }

  String _endDateLabel() {
    if (widget.dateValues.isEmpty) return '';
    final value = widget.dateValues.last;
    final date = DateTime.tryParse(value);
    final today = date != null && DateUtils.isSameDay(date, DateTime.now());
    return '${today ? '今天' : ''}${_dateLabel(widget.dateValues.length - 1)}';
  }

  LineChartData _chartData() {
    return LineChartData(
      minX: 0,
      maxX: (_pointCount - 1).toDouble(),
      minY: _minY,
      maxY: _maxY,
      // Data and axis bounds are animated independently by fl_chart. Clipping
      // keeps intermediate frames inside the plot if the scale changes a lot.
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _maxY / 5,
        getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFD9E0E8), strokeWidth: 1, dashArray: [3, 3]),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false, reservedSize: 30.w),
        ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) =>
              List<LineTooltipItem?>.filled(spots.length, null),
        ),
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions || response?.lineBarSpots == null) return;
          setState(() => _selectedIndex = response!.lineBarSpots!.first.spotIndex);
        },
        getTouchedSpotIndicator: (bar, indexes) => indexes
            .map(
              (_) => const TouchedSpotIndicatorData(
                FlLine(color: Colors.transparent),
                FlDotData(show: false),
              ),
            )
            .toList(),
      ),
      lineBarsData: [
        _lineData(_values(widget.incomeValues), _incomeColor),
        _lineData(_values(widget.expenseValues), _expenseColor),
      ],
    );
  }

  LineChartBarData _lineData(List<double> values, Color color) => LineChartBarData(
        spots: List.generate(values.length, (index) => FlSpot(index.toDouble(), values[index])),
        isCurved: false,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
}

class _CalendarMonthData {
  const _CalendarMonthData({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final double income;
  final double expense;
}

class _CalendarDayData {
  const _CalendarDayData({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final double income;
  final double expense;
}

class _SelectedDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF287CFF)
      ..strokeWidth = 1;
    const dashHeight = 5.0;
    const dashSpace = 4.0;
    double y = 0;
    while (y < size.height) {
      final dashEnd = (y + dashHeight).clamp(0, size.height).toDouble();
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset.zero.translate(0, dashEnd),
        paint,
      );
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HorizontalDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9E0E8)
      ..strokeWidth = 1;
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      final dashEnd = (x + dashWidth).clamp(0, size.width).toDouble();
      canvas.drawLine(Offset(x, 0), Offset(dashEnd, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
