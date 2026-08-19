import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

class AssetOverviewTrendChart extends StatelessWidget {
  const AssetOverviewTrendChart({
    super.key,
    required this.values,
    required this.dateValues,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<double> values;
  final List<String> dateValues;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _lineColor = Color(0xFF48A7EF);

  @override
  Widget build(BuildContext context) {
    final startLabel = dateValues.isEmpty ? '' : dateValues.first;
    final endLabel = dateValues.isEmpty ? '' : dateValues.last;
    final pointCount = math.max(2, values.length);
    final rawMax = values.fold<double>(0, math.max);
    final interval = _axisInterval(rawMax);
    final maxY = interval * 5;
    final activeIndex = values.isEmpty
        ? 0
        : selectedIndex.clamp(0, values.length - 1).toInt();
    final spots = values.isEmpty
        ? const <FlSpot>[]
        : List.generate(
            values.length,
            (index) => FlSpot(index.toDouble(), values[index]),
          );
    return SizedBox(
      height: 155.w,
      child: LayoutBuilder(builder: (context, constraints) {
        final plotWidth = math.max(0, constraints.maxWidth - 42.w).toDouble();
        final markerLeft = 42.w +
            (values.length <= 1
                ? 0
                : plotWidth * activeIndex / (values.length - 1)) -
            5.w;
        return Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(
          child: LineChart(
            LineChartData(
          minX: 0,
          maxX: (pointCount - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: values.isNotEmpty,
            handleBuiltInTouches: false,
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response?.lineBarSpots?.isEmpty != false) {
                return;
              }
              onSelected(response!.lineBarSpots!.first.spotIndex);
            },
          ),
          clipData: const FlClipData.all(),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(
                color: Color(0xFFBFCBD6),
                width: 1,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0xFFDCE6EE),
              strokeWidth: 1,
              dashArray: [3, 3],
            ),
          ),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              VerticalLine(
                x: activeIndex.toDouble(),
                color: Color(0xFF168BF2),
                strokeWidth: 1,
              ),
            ],
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42.w,
                interval: interval,
                getTitlesWidget: (value, meta) => Container(
                  width: 42.w,
                  padding: EdgeInsets.only(right: 6.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: BaseText(
                      text: _axisValue(value),
                      fontSize: 10,
                      color: const Color(0xFF7D8792),
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25.w,
                getTitlesWidget: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: _lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _lineColor.withOpacity(.24),
                    _lineColor.withOpacity(.03),
                  ],
                ),
              ),
            ),
          ],
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          ),
        ),
        Positioned(
          left: 42.w,
          bottom: 5.w,
          child: BaseText(
            text: startLabel,
            fontSize: 10,
            color: const Color(0xFF7D8792),
          ),
        ),
        if (dateValues.length > 1)
          Positioned(
            right: 0,
            bottom: 5.w,
            child: BaseText(
              text: endLabel,
              fontSize: 10,
              color: const Color(0xFF7D8792),
            ),
          ),
        Positioned(
          left: markerLeft,
          top: 125.w,
          child: Container(
            width: 10.w,
            height: 10.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _lineColor.withOpacity(.22),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: const BoxDecoration(
                color: _lineColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        ]);
      }),
    );
  }

  String _axisValue(double value) {
    return value.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }

  double _axisInterval(double maxValue) {
    if (maxValue <= 0) return 1;
    final rawInterval = maxValue / 5;
    final magnitude = math.pow(10, (math.log(rawInterval) / math.ln10).floor()).toDouble();
    return (rawInterval / magnitude).ceil() * magnitude;
  }
}
