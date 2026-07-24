import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateTimePicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final ValueChanged<DateTime>? onDateTimeChanged;
  final DateTimePickerNotifier? dateTimePickerNotifier;
  final bool showText;
  final bool showDay;
  final bool showMonth;
  final int lastYear;
  /// 可选：精确最小日期（优先级高于 lastYear）。
  /// 同时限制年/月/日的下边界，不再只按年截断。
  final DateTime? minimumDate;
  /// 可选：精确最大日期（优先级高于默认今天）。
  /// 同时限制年/月/日的上边界。
  final DateTime? maximumDate;
  const DateTimePicker({
    super.key,
    this.initialDateTime,
    this.onDateTimeChanged,
    this.dateTimePickerNotifier,
    this.showText = true,
    this.showDay = true,
    this.showMonth = true,
    this.lastYear = 1,
    this.minimumDate,
    this.maximumDate,
  });

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  final DateTime _currentDate = DateTime.now();
  int _startYear = 2025;
  int get _endYear => widget.maximumDate?.year ?? _currentDate.year;

  bool showDay = true;

  @override
  void initState() {
    super.initState();

    showDay = widget.showDay;
    final initialDate = widget.initialDateTime ?? _currentDate;
    _selectedYear = initialDate.year;
    _selectedMonth = initialDate.month;
    _selectedDay = initialDate.day;

    _startYear = widget.minimumDate != null
        ? widget.minimumDate!.year
        : _currentDate.year - widget.lastYear;

    final initMonths = _buildMonthList(_selectedYear);
    final initDays = _buildDayList(_selectedYear, _selectedMonth);
    final initMonthIdx =
        initMonths.contains(_selectedMonth) ? initMonths.indexOf(_selectedMonth) : 0;
    final initDayIdx =
        initDays.contains(_selectedDay) ? initDays.indexOf(_selectedDay) : 0;

    _yearController =
        FixedExtentScrollController(initialItem: _selectedYear - _startYear);
    _monthController = FixedExtentScrollController(initialItem: initMonthIdx);
    _dayController = FixedExtentScrollController(initialItem: initDayIdx);

    widget.dateTimePickerNotifier?.addListener(_onController);

  }
  _onController() {
    if (mounted) {
      if (widget.dateTimePickerNotifier?.type == "jumpTime") {
        jumpToDate(widget.dateTimePickerNotifier?.jTime??DateTime.now());
      }
      if (widget.dateTimePickerNotifier?.type == "changeTimeType") {
        showDay = widget.dateTimePickerNotifier!.showDay;
        setState(() {});
      }
    }
  }


  void jumpToDate(DateTime date) {
    final years = getYears();
    final yearIndex = years.indexOf(date.year);
    if (yearIndex != -1) {
      _yearController.jumpToItem(yearIndex);
      _selectedYear = date.year;
    }

    final months = getMonths();
    final monthIndex = months.indexOf(date.month);
    if (monthIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _monthController.jumpToItem(monthIndex);
      });
      _selectedMonth = date.month;
    }

    final days = getDays();
    final dayIndex = days.indexOf(date.day);
    if (dayIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dayController.jumpToItem(dayIndex);
      });
      _selectedDay = date.day;
    }

    _notifyDateTimeChanged();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  List<int> getYears() {
    return List.generate(
        _endYear - _startYear + 1, (index) => _startYear + index);
  }

  List<int> _buildMonthList(int year) {
    final minMonth =
        (widget.minimumDate != null && year == widget.minimumDate!.year)
            ? widget.minimumDate!.month
            : 1;
    final maxMonth = widget.maximumDate != null &&
            year == widget.maximumDate!.year
        ? widget.maximumDate!.month
        : (widget.maximumDate == null && year == _currentDate.year
            ? _currentDate.month
            : 12);
    return List.generate(maxMonth - minMonth + 1, (i) => minMonth + i);
  }

  List<int> _buildDayList(int year, int month) {
    final minDay = (widget.minimumDate != null &&
            year == widget.minimumDate!.year &&
            month == widget.minimumDate!.month)
        ? widget.minimumDate!.day
        : 1;
    final maxDay = widget.maximumDate != null &&
            year == widget.maximumDate!.year &&
            month == widget.maximumDate!.month
        ? widget.maximumDate!.day
        : (widget.maximumDate == null &&
                year == _currentDate.year &&
                month == _currentDate.month
            ? _currentDate.day
            : DateTime(year, month + 1, 0).day);
    return List.generate(maxDay - minDay + 1, (i) => minDay + i);
  }

  List<int> getMonths() => _buildMonthList(_selectedYear);
  List<int> getDays() => _buildDayList(_selectedYear, _selectedMonth);

  /// index 为当前 getMonths()/getDays() 列表内的位置（非固定 1 起步偏移）。
  int _monthControllerIndex() {
    final months = getMonths();
    final idx = months.indexOf(_selectedMonth);
    return idx < 0 ? 0 : idx;
  }

  int _dayControllerIndex() {
    final days = getDays();
    final idx = days.indexOf(_selectedDay);
    return idx < 0 ? 0 : idx;
  }

  void _jumpMonthController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monthController.hasClients) {
        _monthController.jumpToItem(_monthControllerIndex());
      }
    });
  }

  void _jumpDayController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dayController.hasClients) {
        _dayController.jumpToItem(_dayControllerIndex());
      }
    });
  }

  void _onYearSelected(int index) {
    setState(() {
      _selectedYear = getYears()[index];

      // 月份修正：不在新列表内则跳到最近边界
      final months = getMonths();
      if (!months.contains(_selectedMonth)) {
        _selectedMonth =
            _selectedMonth < months.first ? months.first : months.last;
      }
      _jumpMonthController();

      // 日期修正：不在新列表内则跳到最近边界
      final days = getDays();
      if (!days.contains(_selectedDay)) {
        _selectedDay = _selectedDay < days.first ? days.first : days.last;
      }
      _jumpDayController();
    });
    _notifyDateTimeChanged();
  }

  void _onMonthSelected(int index) {
    setState(() {
      _selectedMonth = getMonths()[index];

      // 日期修正
      final days = getDays();
      if (!days.contains(_selectedDay)) {
        _selectedDay = _selectedDay < days.first ? days.first : days.last;
      }
      _jumpDayController();
    });
    _notifyDateTimeChanged();
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDay = getDays()[index];
    });
    _notifyDateTimeChanged();
  }

  void _notifyDateTimeChanged() {
    if (widget.onDateTimeChanged != null) {
      widget.onDateTimeChanged!(
          DateTime(_selectedYear, _selectedMonth, _selectedDay));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _yearController,
            itemExtent: 42.w,
            onSelectedItemChanged: _onYearSelected,
            // selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
            //   capStartEdge: false,
            //   capEndEdge: false,
            // ),
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.w, color: const Color(0xFFE7E7E7)),
                  bottom: BorderSide(
                      width: 1.w, color: const Color(0xFFE7E7E7)), // 下边框
                ),
              ),
            ),
            children: getYears().map((year) {
              return Center(
                child: Text(
                  widget.showText?'$year年':year.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // 月选择器
       widget.showMonth? Expanded(
          child: CupertinoPicker(
            scrollController: _monthController,
            itemExtent: 42.w,
            onSelectedItemChanged: _onMonthSelected,
            // selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
            //   capStartEdge: false,
            //   capEndEdge: false,
            // ),
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.w, color: const Color(0xFFE7E7E7)),
                  bottom: BorderSide(
                      width: 1.w, color: const Color(0xFFE7E7E7)), // 下边框
                ),
              ),
            ),
            children: getMonths().map((month) {
              return Center(
                child: Text(
                  widget.showText?'$month月':month.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ):const SizedBox.shrink(),
        // 日选择器
        showDay? Expanded(
          child: CupertinoPicker(
            scrollController: _dayController,
            itemExtent: 42.w,
            onSelectedItemChanged: _onDaySelected,
            // selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
            //   capStartEdge: false,
            //   capEndEdge: false,
            // ),
            selectionOverlay: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.w, color: const Color(0xFFE7E7E7)),
                  bottom: BorderSide(
                      width: 1.w, color: const Color(0xFFE7E7E7)), // 下边框
                ),
              ),
            ),
            children: getDays().map((day) {
              return Center(
                child: Text(
                  widget.showText?'$day日':day.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ):const SizedBox.shrink(),
      ],
    );
  }
}


class DateTimePickerNotifier extends ChangeNotifier {

  String type = '';

  DateTime? jTime;
  jumpTime(DateTime t) {
    type = 'jumpTime';
    jTime = t;
    notifyListeners();
  }

  bool showDay = true;
  changeTimeType(bool show){
    type = 'changeTimeType';
    showDay = show;
    notifyListeners();
  }

}

