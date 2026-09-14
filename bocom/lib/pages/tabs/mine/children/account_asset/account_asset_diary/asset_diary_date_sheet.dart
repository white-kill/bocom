import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

class AssetDiaryDateSheet extends StatefulWidget {
  const AssetDiaryDateSheet(
      {super.key, required this.dates, required this.initialDate});
  final List<DateTime> dates;
  final DateTime initialDate;

  @override
  State<AssetDiaryDateSheet> createState() => _AssetDiaryDateSheetState();
}

class _AssetDiaryDateSheetState extends State<AssetDiaryDateSheet> {
  late DateTime selected = widget.initialDate;
  List<int> get years =>
      widget.dates.map((e) => e.year).toSet().toList()..sort();
  List<int> get months => widget.dates
      .where((e) => e.year == selected.year)
      .map((e) => e.month)
      .toSet()
      .toList()
    ..sort();
  List<int> get days => widget.dates
      .where((e) => e.year == selected.year && e.month == selected.month)
      .map((e) => e.day)
      .toSet()
      .toList()
    ..sort();

  void selectYear(int year) {
    final matches = widget.dates.where((e) => e.year == year).toList();
    setState(() => selected =
        _nearest(matches, DateTime(year, selected.month, selected.day)));
  }

  void selectMonth(int month) {
    final matches = widget.dates
        .where((e) => e.year == selected.year && e.month == month)
        .toList();
    setState(() => selected =
        _nearest(matches, DateTime(selected.year, month, selected.day)));
  }

  DateTime _nearest(List<DateTime> dates, DateTime target) =>
      dates.reduce((a, b) =>
          a.difference(target).abs() <= b.difference(target).abs() ? a : b);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.w))),
        child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.w),
                  child: Row(children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const BaseText(
                            text: '取消',
                            fontSize: 16,
                            color: Color(0xFF333333))),
                    const Expanded(
                        child: BaseText(
                            text: '请选择查询日期',
                            textAlign: TextAlign.center,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    GestureDetector(
                        onTap: () => Navigator.pop(context, selected),
                        child: const BaseText(
                            text: '确定',
                            fontSize: 16,
                            color: Color(0xFF0075F6))),
                  ])),
              SizedBox(
                  height: 205.w,
                  child: Stack(children: [
                    Center(
                        child: Container(
                            height: 42.w,
                            decoration: const BoxDecoration(
                                border: Border.symmetric(
                                    horizontal: BorderSide(
                                        color: Color(0xFFDDDDDD),
                                        width: .5))))),
                    Row(children: [
                      _DiaryDateWheel(
                          key: const ValueKey('year'),
                          values: years,
                          selected: selected.year,
                          suffix: '年',
                          onChanged: selectYear),
                      _DiaryDateWheel(
                          key: ValueKey('month-${selected.year}'),
                          values: months,
                          selected: selected.month,
                          suffix: '月',
                          onChanged: selectMonth),
                      _DiaryDateWheel(
                          key: ValueKey(
                              'day-${selected.year}-${selected.month}'),
                          values: days,
                          selected: selected.day,
                          suffix: '日',
                          onChanged: (day) => setState(() => selected =
                              DateTime(selected.year, selected.month, day))),
                    ]),
                  ])),
              SizedBox(height: 35.w),
            ])),
      );
}

class _DiaryDateWheel extends StatefulWidget {
  const _DiaryDateWheel(
      {super.key,
      required this.values,
      required this.selected,
      required this.suffix,
      required this.onChanged});
  final List<int> values;
  final int selected;
  final String suffix;
  final ValueChanged<int> onChanged;
  @override
  State<_DiaryDateWheel> createState() => _DiaryDateWheelState();
}

class _DiaryDateWheelState extends State<_DiaryDateWheel> {
  late final controller = FixedExtentScrollController(
      initialItem: widget.values.indexOf(widget.selected));
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Expanded(
          child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 42.w,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 100,
        onSelectedItemChanged: (index) =>
            widget.onChanged(widget.values[index]),
        childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.values.length,
            builder: (_, index) {
              final value = widget.values[index];
              return Center(
                  child: BaseText(
                      text:
                          '${value.toString().padLeft(2, '0')}${widget.suffix}',
                      fontSize: value == widget.selected ? 18 : 16,
                      fontWeight: value == widget.selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: value == widget.selected
                          ? const Color(0xFF0075F6)
                          : const Color(0xFF939EAD)));
            }),
      ));
}
