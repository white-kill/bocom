import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class PrintBillCustomPeriodResult {
  const PrintBillCustomPeriodResult({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}

class PrintBillCustomPeriodSheet extends StatefulWidget {
  const PrintBillCustomPeriodSheet({
    super.key,
    required this.initialStart,
    required this.initialEnd,
  });

  final DateTime initialStart;
  final DateTime initialEnd;

  static Future<PrintBillCustomPeriodResult?> show(
    BuildContext context, {
    required DateTime initialStart,
    required DateTime initialEnd,
  }) =>
      showModalBottomSheet<PrintBillCustomPeriodResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => PrintBillCustomPeriodSheet(
          initialStart: initialStart,
          initialEnd: initialEnd,
        ),
      );

  @override
  State<PrintBillCustomPeriodSheet> createState() =>
      _PrintBillCustomPeriodSheetState();
}

class _PrintBillCustomPeriodSheetState
    extends State<PrintBillCustomPeriodSheet> {
  static const _blue = Color(0xFF0075F6);
  static const _yearCount = 20;

  late final int _firstYear;
  late final int _lastYear;
  bool _editingEnd = false;

  late int _startYear;
  late int _startMonth;
  late int _startDay;
  late int _endYear;
  late int _endMonth;
  late int _endDay;

  late final FixedExtentScrollController _startYearController;
  late final FixedExtentScrollController _startMonthController;
  late final FixedExtentScrollController _startDayController;
  late final FixedExtentScrollController _endYearController;
  late final FixedExtentScrollController _endMonthController;
  late final FixedExtentScrollController _endDayController;

  List<int> get _years =>
      List<int>.generate(_yearCount, (index) => _firstYear + index);

  DateTime get _start => DateTime(_startYear, _startMonth, _startDay);
  DateTime get _end => DateTime(_endYear, _endMonth, _endDay);

  bool get _rangeInvalid => _end.difference(_start).inDays > 731;

  @override
  void initState() {
    super.initState();
    final now = _dateOnly(DateTime.now());
    _lastYear = now.year;
    _firstYear = _lastYear - _yearCount + 1;

    final initialStart = _clampToToday(_dateOnly(widget.initialStart));
    final initialEnd = _clampToToday(_dateOnly(widget.initialEnd));
    final safeEnd =
        initialEnd.isBefore(initialStart) ? initialStart : initialEnd;

    _startYear = initialStart.year;
    _startMonth = initialStart.month;
    _startDay = initialStart.day;
    _endYear = safeEnd.year;
    _endMonth = safeEnd.month;
    _endDay = safeEnd.day;

    _startYearController = _yearControllerFor(_startYear);
    _startMonthController =
        FixedExtentScrollController(initialItem: _startMonth - 1);
    _startDayController =
        FixedExtentScrollController(initialItem: _startDay - 1);
    _endYearController = _yearControllerFor(_endYear);
    _endMonthController =
        FixedExtentScrollController(initialItem: _endMonth - 1);
    _endDayController = FixedExtentScrollController(initialItem: _endDay - 1);
  }

  FixedExtentScrollController _yearControllerFor(int year) =>
      FixedExtentScrollController(initialItem: year - _firstYear);

  @override
  void dispose() {
    _startYearController.dispose();
    _startMonthController.dispose();
    _startDayController.dispose();
    _endYearController.dispose();
    _endMonthController.dispose();
    _endDayController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _clampToToday(DateTime date) {
    final now = _dateOnly(DateTime.now());
    return date.isAfter(now) ? now : date;
  }

  int _maxMonth(int year) => year == _lastYear ? DateTime.now().month : 12;

  int _maxDay(int year, int month) {
    final calendarMax = DateTime(year, month + 1, 0).day;
    final now = DateTime.now();
    return year == now.year && month == now.month ? now.day : calendarMax;
  }

  List<int> _months(int year) =>
      List<int>.generate(_maxMonth(year), (index) => index + 1);

  List<int> _days(int year, int month) =>
      List<int>.generate(_maxDay(year, month), (index) => index + 1);

  String _dateText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _setRangeDate(int year, int month, int day) {
    final safeMonth = month.clamp(1, _maxMonth(year)).toInt();
    final safeDay = day.clamp(1, _maxDay(year, safeMonth)).toInt();
    final value = DateTime(year, safeMonth, safeDay);
    setState(() {
      if (_editingEnd) {
        final start = _start;
        final end = value.isBefore(start) ? start : value;
        _endYear = end.year;
        _endMonth = end.month;
        _endDay = end.day;
      } else {
        final end = _end;
        final start = value.isAfter(end) ? end : value;
        _startYear = start.year;
        _startMonth = start.month;
        _startDay = start.day;
      }
    });
    _repairRangeControllers();
  }

  void _selectRangeYear(int index) {
    final value = _years[index];
    final current = _editingEnd ? _end : _start;
    _setRangeDate(value, current.month, current.day);
  }

  void _repairRangeControllers() {
    final date = _editingEnd ? _end : _start;
    final yearController =
        _editingEnd ? _endYearController : _startYearController;
    final monthController =
        _editingEnd ? _endMonthController : _startMonthController;
    final dayController = _editingEnd ? _endDayController : _startDayController;
    if (yearController.hasClients &&
        yearController.selectedItem != date.year - _firstYear) {
      yearController.jumpToItem(date.year - _firstYear);
    }
    if (monthController.hasClients &&
        monthController.selectedItem != date.month - 1) {
      monthController.jumpToItem(date.month - 1);
    }
    if (dayController.hasClients &&
        dayController.selectedItem != date.day - 1) {
      dayController.jumpToItem(date.day - 1);
    }
  }

  void _selectCurrentDate() {
    final now = _dateOnly(DateTime.now());
    _setRangeDate(now.year, now.month, now.day);
  }

  void _confirm() {
    if (_rangeInvalid) return;
    Navigator.of(context).pop(
      PrintBillCustomPeriodResult(start: _start, end: _end),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 470.w + bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
      ),
      child: Column(
        children: [
          _header(),
          Divider(height: 1, thickness: 0.5.w, color: const Color(0xFFE8E8E8)),
          _rangeTip(),
          SizedBox(
            height: 10.w,
          ),
          _summary(),
          _currentShortcut(),
          SizedBox(
            height: 20.w,
          ),
          Expanded(child: _pickerArea()),
          SizedBox(height: bottom),
        ],
      ),
    );
  }

  Widget _header() => SizedBox(
        height: 56.w,
        child: Row(
          children: [
            SizedBox(
              width: 55.w,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, size: 24.w),
              ),
            ),
            const Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BaseText(
                      text: '选择时间',
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    )
                  ],
                )
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _rangeInvalid ? null : _confirm,
              child: SizedBox(
                width: 68.w,
                child: Center(
                  child: BaseText(
                    text: '确定',
                    fontSize: 15,
                    color: _rangeInvalid ? const Color(0xFFD5D9DF) : _blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _rangeTip() => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.w),
        color: const Color(0xFFFFF1E6),
        child: const BaseText(
          text: '一次查询的跨度不能超过2年',
          fontSize: 14,
          color: Color(0xFFFF7A18),
        ),
      );

  Widget _summary() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
        child: Row(
          children: [
            Expanded(child: _rangeButton(_start, false)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: const BaseText(
                text: '至',
                fontSize: 16,
                color: Color(0xFF8B95A5),
              ),
            ),
            Expanded(child: _rangeButton(_end, true)),
          ],
        ),
      );

  Widget _rangeErrorTip() => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: -4.w,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 9.w,
                height: 9.w,
                color: const Color(0xFFFF565C),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.w),
            color: const Color(0xFFFF565C),
            child: const BaseText(
              text: '一次查询的跨度不能超过2年',
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      );

  Widget _currentShortcut() {
    return SizedBox(
      height: 36.w,
      width: 1.sw,
      child: Padding(
        padding: EdgeInsets.only(top: 2.w),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (_rangeInvalid)
              Padding(
                padding: EdgeInsets.only(top: 4.w),
                child: _rangeErrorTip(),
              ),
            Positioned(
              right: 14.w,
              top: 4.w,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _selectCurrentDate,
                child: Container(
                  width: 50.w,
                  height: 25.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: const BaseText(
                    text: '今日',
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangeButton(DateTime date, bool end) => GestureDetector(
        onTap: () => setState(() => _editingEnd = end),
        child: Container(
          height: 32.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _editingEnd == end
                ? const Color(0xFFE5F2FF)
                : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: BaseText(
            text: _dateText(date),
            fontSize: 15,
            color: _editingEnd == end ? _blue : const Color(0xFF333333),
          ),
        ),
      );

  Widget _pickerArea() {
    final date = _editingEnd ? _end : _start;
    return Row(
      children: [
        Expanded(
          child: _flatPicker(
            controller: _editingEnd ? _endYearController : _startYearController,
            items: _years,
            selected: date.year,
            suffix: '年',
            onChanged: _selectRangeYear,
          ),
        ),
        Expanded(
          child: _flatPicker(
            controller:
                _editingEnd ? _endMonthController : _startMonthController,
            items: _months(date.year),
            selected: date.month,
            suffix: '月',
            onChanged: (index) => _setRangeDate(date.year, index + 1, date.day),
          ),
        ),
        Expanded(
          child: _flatPicker(
            controller: _editingEnd ? _endDayController : _startDayController,
            items: _days(date.year, date.month),
            selected: date.day,
            suffix: '日',
            onChanged: (index) =>
                _setRangeDate(date.year, date.month, index + 1),
          ),
        ),
      ],
    );
  }

  Widget _flatPicker({
    required FixedExtentScrollController controller,
    required List<int> items,
    required int selected,
    required String suffix,
    required ValueChanged<int> onChanged,
  }) =>
      Stack(
        children: [
          Positioned.fill(
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 47.w,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: 100,
              perspective: 0.0001,
              squeeze: 1,
              overAndUnderCenterOpacity: 1,
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: items.length,
                builder: (_, index) => Center(
                  child: BaseText(
                    text: '${items[index]}$suffix',
                    fontSize: items[index] == selected ? 19 : 17,
                    color: items[index] == selected
                        ? _blue
                        : const Color(0xFF9AA5B5),
                    fontWeight: items[index] == selected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: IgnorePointer(
              child: Container(
                height: 47.w,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: const Color(0xFFE8E8E8),
                      width: 0.5.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
