import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'transaction_filter_model.dart';

// 交易明细日期筛选底部面板
// 说明：月度、年度和自定义日期共用同一份状态；自定义范围在本组件内完成顺序及两年跨度校验。
class TransactionDateFilterSheet extends StatefulWidget {
  const TransactionDateFilterSheet({
    required this.initialMode,
    required this.today,
    this.initialSelection,
    super.key,
  });

  final TransactionDateFilterMode initialMode;
  final TransactionFilterSelection? initialSelection;
  final DateTime today;

  static Future<TransactionFilterSelection?> show(
    BuildContext context, {
    TransactionDateFilterMode initialMode = TransactionDateFilterMode.custom,
    TransactionFilterSelection? initialSelection,
    DateTime? today,
  }) {
    return showModalBottomSheet<TransactionFilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.43),
      builder: (_) => TransactionDateFilterSheet(
        initialMode: initialMode,
        initialSelection: initialSelection,
        today: today ?? DateTime.now(),
      ),
    );
  }

  @override
  State<TransactionDateFilterSheet> createState() =>
      _TransactionDateFilterSheetState();
}

class _TransactionDateFilterSheetState
    extends State<TransactionDateFilterSheet> {
  static const int _firstYear = 2021;
  static const int _lastYear = 2028;

  late TransactionDateFilterMode _mode;
  late DateTime _selectedMonth;
  late int _selectedYear;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _editingStartDate = true;

  late final FixedExtentScrollController _monthYearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _customYearController;
  late final FixedExtentScrollController _customMonthController;
  late final FixedExtentScrollController _customDayController;

  DateTime get _today => DateTime(
        widget.today.year,
        widget.today.month,
        widget.today.day,
      );

  DateTime get _editingDate => _editingStartDate ? _startDate : _endDate;

  TransactionDateValidationError? get _validationError =>
      TransactionDateRules.validate(_startDate, _endDate);

  @override
  void initState() {
    super.initState();
    _mode = widget.initialSelection?.mode ?? widget.initialMode;
    _selectedMonth =
        widget.initialSelection?.month ?? DateTime(_today.year, _today.month);
    _selectedYear = widget.initialSelection?.year ?? _today.year;
    _startDate = widget.initialSelection?.startDate ??
        DateTime(_today.year, _today.month, 1);
    _endDate = widget.initialSelection?.endDate ?? _today;

    _monthYearController = FixedExtentScrollController(
      initialItem: _yearIndex(_selectedMonth.year),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth.month - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: _yearIndex(_selectedYear),
    );
    _customYearController = FixedExtentScrollController(
      initialItem: _yearIndex(_editingDate.year),
    );
    _customMonthController = FixedExtentScrollController(
      initialItem: _editingDate.month - 1,
    );
    _customDayController = FixedExtentScrollController(
      initialItem: _editingDate.day - 1,
    );
  }

  @override
  void dispose() {
    _monthYearController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _customYearController.dispose();
    _customMonthController.dispose();
    _customDayController.dispose();
    super.dispose();
  }

  int _yearIndex(int year) =>
      year.clamp(_firstYear, _lastYear).toInt() - _firstYear;

  List<int> get _years => [
        for (var year = _firstYear; year <= _lastYear; year++) year,
      ];

  List<int> get _months => [for (var month = 1; month <= 12; month++) month];

  List<int> get _historicalYears =>
      _years.where((year) => year <= _today.year).toList(growable: false);

  List<int> get _historicalMonths => [
        for (var month = 1;
            month <= (_selectedMonth.year == _today.year ? _today.month : 12);
            month++)
          month,
      ];

  List<int> _daysFor(DateTime date) => [
        for (var day = 1;
            day <= DateTime(date.year, date.month + 1, 0).day;
            day++)
          day,
      ];

  void _changeMode(TransactionDateFilterMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
  }

  void _selectCustomEndpoint(bool start) {
    if (_editingStartDate == start) return;
    setState(() => _editingStartDate = start);
    _syncCustomControllers();
  }

  void _syncCustomControllers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final date = _editingDate;
      if (_customYearController.hasClients) {
        _customYearController.jumpToItem(_yearIndex(date.year));
      }
      if (_customMonthController.hasClients) {
        _customMonthController.jumpToItem(date.month - 1);
      }
      if (_customDayController.hasClients) {
        _customDayController.jumpToItem(date.day - 1);
      }
    });
  }

  void _updateCustomDate({int? year, int? month, int? day}) {
    final current = _editingDate;
    final newYear = year ?? current.year;
    final newMonth = month ?? current.month;
    final maximumDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = (day ?? current.day).clamp(1, maximumDay).toInt();
    final next = DateTime(newYear, newMonth, newDay);
    setState(() {
      if (_editingStartDate) {
        _startDate = next;
      } else {
        _endDate = next;
      }
    });
    if (newDay != current.day && day == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_customDayController.hasClients) {
          _customDayController.jumpToItem(newDay - 1);
        }
      });
    }
  }

  void _useToday() {
    if (_mode == TransactionDateFilterMode.month) {
      setState(() => _selectedMonth = DateTime(_today.year, _today.month));
      _monthYearController.jumpToItem(_yearIndex(_today.year));
      _monthController.jumpToItem(_today.month - 1);
      return;
    }
    if (_mode == TransactionDateFilterMode.year) {
      setState(() => _selectedYear = _today.year);
      _yearController.jumpToItem(_yearIndex(_today.year));
      return;
    }
    setState(() {
      if (_editingStartDate) {
        _startDate = _today;
      } else {
        _endDate = _today;
      }
    });
    _syncCustomControllers();
  }

  void _confirm() {
    if (_mode == TransactionDateFilterMode.custom && _validationError != null) {
      return;
    }
    final result = switch (_mode) {
      TransactionDateFilterMode.month =>
        TransactionFilterSelection.month(_selectedMonth),
      TransactionDateFilterMode.year =>
        TransactionFilterSelection.year(_selectedYear),
      TransactionDateFilterMode.custom => TransactionFilterSelection.custom(
          startDate: _startDate,
          endDate: _endDate,
        ),
    };
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final custom = _mode == TransactionDateFilterMode.custom;
    final error = _validationError;
    final confirmEnabled = !custom || error == null;
    // 参考图 1080×2340：自定义面板高约 1225px，月度/年度约 1098px。
    final sheetHeight =
        (custom ? 425.w : 381.w) + MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: sheetHeight,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(11.w)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _FilterSheetHeader(
                mode: _mode,
                confirmEnabled: confirmEnabled,
                onClose: () => Navigator.of(context).pop(),
                onModeChanged: _changeMode,
                onConfirm: _confirm,
              ),
              Container(height: 0.5.w, color: const Color(0xFFE8E8E8)),
              if (custom)
                Container(
                  key: const ValueKey('custom_date_range_tip'),
                  alignment: Alignment.centerLeft,
                  height: 44.w,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  color: const Color(0xFFFEF3EC),
                  child: Text(
                    '一次查询的跨度不能超过2年',
                    style: TextStyle(
                      color: const Color(0xFFFF8A26),
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              Expanded(
                child: switch (_mode) {
                  TransactionDateFilterMode.month => _buildMonthPicker(),
                  TransactionDateFilterMode.year => _buildYearPicker(),
                  TransactionDateFilterMode.custom => _buildCustomPicker(error),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthPicker() {
    final current = _selectedMonth.year == _today.year &&
        _selectedMonth.month == _today.month;
    return Column(
      children: [
        _SelectedValueArea(
          text:
              '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
          quickText: '当月',
          quickSelected: current,
          onQuickTap: _useToday,
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TransactionFilterWheel(
                  controller: _monthYearController,
                  values: _historicalYears,
                  selectedValue: _selectedMonth.year,
                  onChanged: (year) {
                    final month = year == _today.year
                        ? _selectedMonth.month.clamp(1, _today.month).toInt()
                        : _selectedMonth.month;
                    setState(
                      () => _selectedMonth = DateTime(year, month),
                    );
                    if (_monthController.hasClients &&
                        _monthController.selectedItem >=
                            _historicalMonths.length) {
                      _monthController.jumpToItem(month - 1);
                    }
                  },
                ),
              ),
              Expanded(
                child: TransactionFilterWheel(
                  controller: _monthController,
                  values: _historicalMonths,
                  selectedValue: _selectedMonth.month,
                  formatter: (value) => value.toString().padLeft(2, '0'),
                  onChanged: (month) => setState(
                    () => _selectedMonth = DateTime(_selectedMonth.year, month),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYearPicker() {
    return Column(
      children: [
        _SelectedValueArea(
          text: _selectedYear.toString(),
          quickText: '今年',
          quickSelected: _selectedYear == _today.year,
          onQuickTap: _useToday,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 126.w),
            child: TransactionFilterWheel(
              controller: _yearController,
              values: _historicalYears,
              selectedValue: _selectedYear,
              onChanged: (year) => setState(() => _selectedYear = year),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomPicker(TransactionDateValidationError? error) {
    final date = _editingDate;
    return Column(
      children: [
        SizedBox(
          height: 109.w,
          child: Stack(
            children: [
              Positioned(
                left: 14.w,
                right: 14.w,
                top: 10.w,
                child: Row(
                  children: [
                    Expanded(
                      child: _DateChip(
                        key: const ValueKey('custom_start_date'),
                        date: _startDate,
                        selected: _editingStartDate,
                        onTap: () => _selectCustomEndpoint(true),
                      ),
                    ),
                    SizedBox(
                      width: 54.w,
                      child: Center(
                        child: Text(
                          '至',
                          style: TextStyle(
                            color: const Color(0xFF7B8794),
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DateChip(
                        key: const ValueKey('custom_end_date'),
                        date: _endDate,
                        selected: !_editingStartDate,
                        onTap: () => _selectCustomEndpoint(false),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 14.w,
                top: 47.w,
                child: _QuickDateButton(
                  text: '今日',
                  selected: date == _today,
                  onTap: _useToday,
                ),
              ),
              if (error != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 47.w,
                  child: Center(
                    child: _ValidationToast(error: error),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TransactionFilterWheel(
                  controller: _customYearController,
                  values: _years,
                  selectedValue: date.year,
                  onChanged: (year) => _updateCustomDate(year: year),
                ),
              ),
              Expanded(
                child: TransactionFilterWheel(
                  controller: _customMonthController,
                  values: _months,
                  selectedValue: date.month,
                  formatter: (value) => value.toString().padLeft(2, '0'),
                  onChanged: (month) => _updateCustomDate(month: month),
                ),
              ),
              Expanded(
                child: TransactionFilterWheel(
                  controller: _customDayController,
                  values: _daysFor(date),
                  selectedValue: date.day,
                  formatter: (value) => value.toString().padLeft(2, '0'),
                  onChanged: (day) => _updateCustomDate(day: day),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterSheetHeader extends StatelessWidget {
  const _FilterSheetHeader({
    required this.mode,
    required this.confirmEnabled,
    required this.onClose,
    required this.onModeChanged,
    required this.onConfirm,
  });

  final TransactionDateFilterMode mode;
  final bool confirmEnabled;
  final VoidCallback onClose;
  final ValueChanged<TransactionDateFilterMode> onModeChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.w,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: '关闭日期筛选',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: SizedBox(
                width: 46.w,
                child: Icon(Icons.close,
                    size: 23.w, color: const Color(0xFF333333)),
              ),
            ),
          ),
          for (final item in TransactionDateFilterMode.values) ...[
            _ModeButton(
              text: switch (item) {
                TransactionDateFilterMode.month => '月度',
                TransactionDateFilterMode.year => '年度',
                TransactionDateFilterMode.custom => '自定义',
              },
              selected: mode == item,
              onTap: () => onModeChanged(item),
            ),
            if (item != TransactionDateFilterMode.custom) SizedBox(width: 10.w),
          ],
          const Spacer(),
          Semantics(
            button: true,
            enabled: confirmEnabled,
            label: '确认日期筛选',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: confirmEnabled ? onConfirm : null,
              child: SizedBox(
                width: 68.w,
                child: Center(
                  child: Text(
                    '确定',
                    key: const ValueKey('transaction_filter_confirm'),
                    style: TextStyle(
                      color: confirmEnabled
                          ? const Color(0xFF0077DF)
                          : const Color(0xFFD1D4D8),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$text筛选',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 73.w,
          height: 26.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF3FC) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Text(
            text,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF0077DF) : const Color(0xFF333333),
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedValueArea extends StatelessWidget {
  const _SelectedValueArea({
    required this.text,
    required this.quickText,
    required this.quickSelected,
    required this.onQuickTap,
  });

  final String text;
  final String quickText;
  final bool quickSelected;
  final VoidCallback onQuickTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 91.w,
      child: Stack(
        children: [
          Positioned(
            left: 14.w,
            right: 14.w,
            top: 10.w,
            height: 26.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FC),
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: const Color(0xFF0077DF),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 14.w,
            bottom: 19.w,
            child: _QuickDateButton(
              text: quickText,
              selected: quickSelected,
              onTap: onQuickTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickDateButton extends StatelessWidget {
  const _QuickDateButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 26.w,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF3FC) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Text(
            text,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF0077DF) : const Color(0xFF333333),
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  String get _text =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: _text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 26.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF3FC) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Text(
            _text,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF0077DF) : const Color(0xFF292929),
              fontSize: 14.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionFilterWheel extends StatelessWidget {
  const TransactionFilterWheel({
    required this.controller,
    required this.values,
    required this.selectedValue,
    required this.onChanged,
    this.formatter,
    super.key,
  });

  final FixedExtentScrollController controller;
  final List<int> values;
  final int selectedValue;
  final ValueChanged<int> onChanged;
  final String Function(int value)? formatter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            physics: const FixedExtentScrollPhysics(),
            itemExtent: 44.w,
            diameterRatio: 8,
            perspective: 0.001,
            squeeze: 1,
            onSelectedItemChanged: (index) => onChanged(values[index]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: values.length,
              builder: (_, index) {
                final value = values[index];
                final selected = value == selectedValue;
                return Center(
                  child: Text(
                    formatter?.call(value) ?? value.toString(),
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF0077DF)
                          : const Color(0xFF929DAB),
                      fontSize: selected ? 18.sp : 15.sp,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IgnorePointer(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 44.w,
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: Color(0xFFE9E9E9), width: 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ValidationToast extends StatelessWidget {
  const _ValidationToast({required this.error});

  final TransactionDateValidationError error;

  @override
  Widget build(BuildContext context) {
    final text = error == TransactionDateValidationError.startAfterEnd
        ? '起止时间不能晚于终止时间'
        : '一次查询的跨度不能超过2年';
    return Semantics(
      label: text,
      child: SizedBox(
        key: const ValueKey('custom_date_error'),
        width: error == TransactionDateValidationError.startAfterEnd
            ? 156.w
            : 164.w,
        height: 23.w,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            CustomPaint(
              size: Size(12.w, 6.w),
              painter: const _ValidationToastArrowPainter(),
            ),
            Container(
              height: 18.w,
              margin: EdgeInsets.only(top: 5.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              alignment: Alignment.center,
              color: const Color(0xFFFE6E67),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  // 参考图的红色校验提示仅约 28px 高，文字保持单行。
                  fontSize: 10.sp,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationToastArrowPainter extends CustomPainter {
  const _ValidationToastArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFE6E67));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
