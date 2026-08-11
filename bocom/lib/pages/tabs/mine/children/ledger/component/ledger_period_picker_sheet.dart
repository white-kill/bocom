import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerPeriodSelection {
  const LedgerPeriodSelection({
    required this.year,
    required this.month,
  });

  final int year;
  final int month;
}

class LedgerPeriodPickerSheet extends StatefulWidget {
  const LedgerPeriodPickerSheet({
    super.key,
    required this.isYearMode,
    required this.initialYear,
    required this.initialMonth,
  });

  final bool isYearMode;
  final int initialYear;
  final int initialMonth;

  static Future<LedgerPeriodSelection?> show(
    BuildContext context, {
    required bool isYearMode,
    required int initialYear,
    required int initialMonth,
  }) {
    return showModalBottomSheet<LedgerPeriodSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.43),
      builder: (_) => LedgerPeriodPickerSheet(
        isYearMode: isYearMode,
        initialYear: initialYear,
        initialMonth: initialMonth,
      ),
    );
  }

  @override
  State<LedgerPeriodPickerSheet> createState() =>
      _LedgerPeriodPickerSheetState();
}

class _LedgerPeriodPickerSheetState extends State<LedgerPeriodPickerSheet> {
  static const int _yearCount = 20;
  late final int _lastYear;
  late final int _firstYear;
  late int _selectedYear;
  late int _selectedMonth;
  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;

  List<int> get _years =>
      List<int>.generate(_yearCount, (index) => _firstYear + index);

  List<int> get _months {
    final lastMonth = _selectedYear == _lastYear ? DateTime.now().month : 12;
    return List<int>.generate(lastMonth, (index) => index + 1);
  }

  @override
  void initState() {
    super.initState();
    _lastYear = DateTime.now().year;
    _firstYear = _lastYear - _yearCount + 1;
    _selectedYear = widget.initialYear.clamp(_firstYear, _lastYear).toInt();
    final maxMonth = _selectedYear == _lastYear ? DateTime.now().month : 12;
    _selectedMonth = widget.initialMonth.clamp(1, maxMonth).toInt();
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - _firstYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _selectYear(int index) {
    setState(() {
      _selectedYear = _years[index];
      final maxMonth = _months.length;
      if (_selectedMonth > maxMonth) {
        _selectedMonth = maxMonth;
        _monthController.jumpToItem(_selectedMonth - 1);
      }
    });
  }

  void _confirm() {
    Navigator.of(context).pop(
      LedgerPeriodSelection(year: _selectedYear, month: _selectedMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 410.w + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14.w)),
      ),
      child: Column(
        children: [
          _header(),
          Divider(height: 1, thickness: 0.5.w, color: const Color(0xFFE8E8E8)),
          SizedBox(height: 24.w),
          _selectionSummary(),
          SizedBox(height: 25.w),
          SizedBox(
            height: 235.w,
            child: Row(
              children: [
                Expanded(child: _yearPicker()),
                if (!widget.isYearMode) Expanded(child: _monthPicker()),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  Widget _header() => SizedBox(
        height: 56.w,
        width: 1.sw,
        child: Stack(
          alignment: Alignment.center,
          children: [
            BaseText(
              text: widget.isYearMode ? '选择年份' : '选择年月',
              fontSize: 18,
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
            Positioned(
              left: 16.w,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: SizedBox(
                  width: 30.w,
                  height: 40.w,
                  child: Icon(Icons.close, size: 25.w, color: const Color(0xFF333333)),
                ),
              ),
            ),
            Positioned(
              right: 16.w,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _confirm,
                child: SizedBox(
                  height: 40.w,
                  child: const Center(
                    child: BaseText(text: '确定', fontSize: 16, color: Color(0xFF0075F6)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _selectionSummary() => Container(
        height: 32.w,
        margin: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE5F2FF),
          borderRadius: BorderRadius.circular(6.w),
        ),
        child: BaseText(
          text: widget.isYearMode
              ? '$_selectedYear'
              : '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}',
          fontSize: 16,
          color: const Color(0xFF0075F6),
        ),
      );

  Widget _yearPicker() => _flatPicker(
        controller: _yearController,
        itemCount: _years.length,
        onSelectedItemChanged: _selectYear,
        itemBuilder: (index) => _pickerText(
          '${_years[index]}年',
          selected: _years[index] == _selectedYear,
        ),
      );

  Widget _monthPicker() => _flatPicker(
        controller: _monthController,
        itemCount: _months.length,
        onSelectedItemChanged: (index) {
          setState(() => _selectedMonth = _months[index]);
        },
        itemBuilder: (index) => _pickerText(
          '${_months[index].toString().padLeft(2, '0')}月',
          selected: _months[index] == _selectedMonth,
        ),
      );

  Widget _flatPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
    required Widget Function(int index) itemBuilder,
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
              onSelectedItemChanged: onSelectedItemChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: itemCount,
                builder: (_, index) => itemBuilder(index),
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

  Widget _pickerText(String text, {required bool selected}) => Center(
        child: BaseText(
          text: text,
          fontSize: selected ? 19 : 17,
          color: selected ? const Color(0xFF0075F6) : const Color(0xFF9AA5B5),
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      );
}
