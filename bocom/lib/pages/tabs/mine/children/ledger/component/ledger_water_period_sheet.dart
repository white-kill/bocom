import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerWaterPeriodResult {
  const LedgerWaterPeriodResult({
    required this.mode,
    required this.start,
    required this.end,
  });

  final int mode;
  final DateTime start;
  final DateTime end;
}

class LedgerWaterPeriodSheet extends StatefulWidget {
  const LedgerWaterPeriodSheet({super.key, required this.initialDate});

  final DateTime initialDate;

  static Future<LedgerWaterPeriodResult?> show(
    BuildContext context, {
    required DateTime initialDate,
  }) =>
      showModalBottomSheet<LedgerWaterPeriodResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => LedgerWaterPeriodSheet(initialDate: initialDate),
      );

  @override
  State<LedgerWaterPeriodSheet> createState() =>
      _LedgerWaterPeriodSheetState();
}

class _LedgerWaterPeriodSheetState extends State<LedgerWaterPeriodSheet> {
  static const _blue = Color(0xFF0075F6);
  static const _yearCount = 20;

  late final int _firstYear;
  late final int _lastYear;
  int _mode = 0;
  bool _editingEnd = false;

  late int _monthYear;
  late int _month;
  late int _year;
  late DateTime _start;
  late DateTime _end;

  late final FixedExtentScrollController _monthYearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _startYearController;
  late final FixedExtentScrollController _startMonthController;
  late final FixedExtentScrollController _startDayController;
  late final FixedExtentScrollController _endYearController;
  late final FixedExtentScrollController _endMonthController;
  late final FixedExtentScrollController _endDayController;

  List<int> get _years =>
      List<int>.generate(_yearCount, (index) => _firstYear + index);

  bool get _rangeInvalid =>
      _mode == 2 && _end.difference(_start).inDays > 731;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _lastYear = now.year;
    _firstYear = _lastYear - _yearCount + 1;
    _monthYear = widget.initialDate.year.clamp(_firstYear, _lastYear).toInt();
    _month = widget.initialDate.month.clamp(1, _maxMonth(_monthYear)).toInt();
    _year = _monthYear;
    _start = DateTime(_monthYear, _month, 1);
    _end = now;

    _monthYearController = _yearControllerFor(_monthYear);
    _monthController = FixedExtentScrollController(initialItem: _month - 1);
    _yearController = _yearControllerFor(_year);
    _startYearController = _yearControllerFor(_start.year);
    _startMonthController = FixedExtentScrollController(initialItem: _start.month - 1);
    _startDayController = FixedExtentScrollController(initialItem: _start.day - 1);
    _endYearController = _yearControllerFor(_end.year);
    _endMonthController = FixedExtentScrollController(initialItem: _end.month - 1);
    _endDayController = FixedExtentScrollController(initialItem: _end.day - 1);
  }

  FixedExtentScrollController _yearControllerFor(int year) =>
      FixedExtentScrollController(initialItem: year - _firstYear);

  @override
  void dispose() {
    _monthYearController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _startYearController.dispose();
    _startMonthController.dispose();
    _startDayController.dispose();
    _endYearController.dispose();
    _endMonthController.dispose();
    _endDayController.dispose();
    super.dispose();
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

  String _dateText(DateTime date, {bool showDay = true}) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return showDay ? '${date.year}-$month-$day' : '${date.year}-$month';
  }

  void _selectMonthYear(int index) {
    setState(() {
      _monthYear = _years[index];
      final maxMonth = _maxMonth(_monthYear);
      if (_month > maxMonth) {
        _month = maxMonth;
        _monthController.jumpToItem(_month - 1);
      }
    });
  }

  void _selectRangeYear(int index) {
    final value = _years[index];
    final current = _editingEnd ? _end : _start;
    _setRangeDate(value, current.month, current.day);
  }

  void _setRangeDate(int year, int month, int day) {
    final safeMonth = month.clamp(1, _maxMonth(year)).toInt();
    final safeDay = day.clamp(1, _maxDay(year, safeMonth)).toInt();
    final value = DateTime(year, safeMonth, safeDay);
    setState(() {
      if (_editingEnd) {
        _end = value.isBefore(_start) ? _start : value;
      } else {
        _start = value.isAfter(_end) ? _end : value;
      }
    });
    _repairRangeControllers();
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
    if (monthController.hasClients && monthController.selectedItem != date.month - 1) {
      monthController.jumpToItem(date.month - 1);
    }
    if (dayController.hasClients && dayController.selectedItem != date.day - 1) {
      dayController.jumpToItem(date.day - 1);
    }
  }

  void _confirm() {
    if (_rangeInvalid) return;
    final start = _mode == 0
        ? DateTime(_monthYear, _month)
        : _mode == 1
            ? DateTime(_year)
            : _start;
    final end = _mode == 0
        ? DateTime(_monthYear, _month + 1, 0)
        : _mode == 1
            ? DateTime(_year, 12, 31)
            : _end;
    Navigator.of(context).pop(
      LedgerWaterPeriodResult(mode: _mode, start: start, end: end),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 410.w + bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
      ),
      child: Column(
        children: [
          _header(),
          Divider(height: 1, thickness: 0.5.w, color: const Color(0xFFE8E8E8)),
          if (_mode == 2) _rangeTip(),
          _summary(),
          _currentShortcut(),
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
            ...List.generate(3, (index) {
              const names = ['月度', '年度', '自定义'];
              final selected = _mode == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() {
                    _mode = index;
                    _editingEnd = false;
                  }),
                  child: Container(
                    height: 32.w,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFE5F2FF) : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: BaseText(
                      text: names[index],
                      fontSize: 16,
                      color: selected ? _blue : const Color(0xFF333333),
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _rangeInvalid ? null : _confirm,
              child: SizedBox(
                width: 68.w,
                child: Center(
                  child: BaseText(
                    text: '确定',
                    fontSize: 17,
                    color: _rangeInvalid
                        ? const Color(0xFFD5D9DF)
                        : _blue,
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

  Widget _summary() {
    if (_mode == 2) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
        child: Column(
          children: [
            Row(
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
          ],
        ),
      );
    }
    final text = _mode == 0 ? '$_monthYear-${_month.toString().padLeft(2, '0')}' : '$_year';
    return Container(
      height: 32.w,
      margin: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 8.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F2FF),
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: BaseText(text: text, fontSize: 16, color: _blue),
    );
  }

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
    final isCustom = _mode == 2;
    final text = _mode == 0
        ? '当月'
        : _mode == 1
            ? '今年'
            : '今日';

    return Container(
      height: 36.w,
      width: 1.sw,
      child: Padding(
        padding: EdgeInsets.only(top: 2.w),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (isCustom && _rangeInvalid)
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
                    color: isCustom
                        ? const Color(0xFFF7F7F7)
                        : const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: BaseText(
                    text: text,
                    fontSize: 14,
                    color: isCustom ? const Color(0xFF333333) : _blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCurrentDate() {
    final now = DateTime.now();
    if (_mode == 0) {
      setState(() {
        _monthYear = now.year;
        _month = now.month;
      });
      _monthYearController.jumpToItem(now.year - _firstYear);
      _monthController.jumpToItem(now.month - 1);
      return;
    }
    if (_mode == 1) {
      setState(() => _year = now.year);
      _yearController.jumpToItem(now.year - _firstYear);
      return;
    }
    _setRangeDate(now.year, now.month, now.day);
  }

  Widget _rangeButton(DateTime date, bool end) => GestureDetector(
        onTap: () => setState(() => _editingEnd = end),
        child: Container(
          height: 32.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _editingEnd == end ? const Color(0xFFE5F2FF) : const Color(0xFFF7F7F7),
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
    if (_mode == 0) {
      return Row(
        children: [
          Expanded(
            child: _flatPicker(
              controller: _monthYearController,
              items: _years,
              selected: _monthYear,
              suffix: '年',
              onChanged: _selectMonthYear,
            ),
          ),
          Expanded(
            child: _flatPicker(
              controller: _monthController,
              items: _months(_monthYear),
              selected: _month,
              suffix: '月',
              onChanged: (index) => setState(() => _month = index + 1),
            ),
          ),
        ],
      );
    }
    if (_mode == 1) {
      return _flatPicker(
        controller: _yearController,
        items: _years,
        selected: _year,
        suffix: '年',
        onChanged: (index) => setState(() => _year = _years[index]),
      );
    }

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
            controller: _editingEnd ? _endMonthController : _startMonthController,
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
            onChanged: (index) => _setRangeDate(date.year, date.month, index + 1),
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
                    color: items[index] == selected ? _blue : const Color(0xFF9AA5B5),
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
