import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import 'account_asset_diary_logic.dart';

class AssetDiaryChart extends StatelessWidget {
  const AssetDiaryChart(
      {super.key,
      required this.entries,
      required this.selectedIndex,
      required this.onSelected,
      required this.onDetails,
      required this.showYear});
  final List<AssetDiaryEntry> entries;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onDetails;
  final bool showYear;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty)
      return SizedBox(
          height: 165.w, child: const Center(child: BaseText(text: '暂无资产数据')));
    final peak = entries.fold<double>(0, (v, e) => math.max(v, e.amount));
    final raw = math.max(peak / 5, 1.0);
    final magnitude =
        math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final step = (raw / magnitude).ceil() * magnitude;
    final maxY = step * 5;
    final index = selectedIndex.clamp(0, entries.length - 1).toInt();
    const blue = Color(0xFF75B1FA);
    return SizedBox(
        height: 170.w,
        child: LayoutBuilder(builder: (context, box) {
          final plotWidth = box.maxWidth - 30.w;
          final plotHeight = box.maxHeight - 25.w - 1;
          final x = 30.w + plotWidth * index / math.max(1, entries.length - 1);
          final y = plotHeight * (1 - entries[index].amount / maxY);
          final dateFormat = DateFormat(showYear ? 'yyyy-MM-dd' : 'MM-dd');
          return Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(
                child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: math.max(1, entries.length - 1).toDouble(),
                      minY: 0,
                      maxY: maxY,
                      borderData: FlBorderData(
                          show: true,
                          border: const Border(
                              bottom: BorderSide(color: Color(0xFFCCD3DC)))),
                      gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: step,
                          getDrawingHorizontalLine: (_) => const FlLine(
                              color: Color(0xFFCED7E2),
                              strokeWidth: 1,
                              dashArray: [2, 2])),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 25.w,
                                getTitlesWidget: (_, __) =>
                                    const SizedBox.shrink())),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30.w,
                                interval: step,
                                getTitlesWidget: (value, _) => Padding(
                                    padding: EdgeInsets.only(right: 8.w),
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: BaseText(
                                            text: NumberFormat('#,##0')
                                                .format(value),
                                            fontSize: 11,
                                            color: const Color(0xFF999999)))))),
                      ),
                      lineTouchData: LineTouchData(
                          handleBuiltInTouches: false,
                          touchCallback: (event, response) {
                            if (event.isInterestedForInteractions &&
                                response?.lineBarSpots?.isNotEmpty == true)
                              onSelected(
                                  response!.lineBarSpots!.first.spotIndex);
                          }),
                      extraLinesData: ExtraLinesData(verticalLines: [
                        VerticalLine(
                            x: index.toDouble(),
                            color: const Color(0xFFBADBFF),
                            strokeWidth: 1)
                      ]),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(entries.length,
                              (i) => FlSpot(i.toDouble(), entries[i].amount)),
                          color: blue,
                          barWidth: 2,
                          isCurved: false,
                          dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, _) =>
                                  spot.x == entries.length - 1,
                              getDotPainter: (_, __, ___, ____) =>
                                  FlDotCirclePainter(
                                      radius: 3.w,
                                      color: const Color(0xFFFF861C),
                                      strokeWidth: 0)),
                          belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    blue.withValues(alpha: .25),
                                    blue.withValues(alpha: .05)
                                  ])),
                        )
                      ],
                    ),
                    duration: Duration.zero)),
            Positioned(
                left: 30.w,
                bottom: 2.w,
                child: BaseText(
                    text: dateFormat.format(entries.first.date),
                    fontSize: 11,
                    color: const Color(0xFF999999))),
            Positioned(
                right: 0,
                bottom: 2.w,
                child: BaseText(
                    text: dateFormat.format(entries.last.date),
                    fontSize: 11,
                    color: const Color(0xFF999999))),
            Positioned(
                left: x - 15.w,
                top: y - 11.w,
                child: Semantics(
                    button: true,
                    label: '查看选中日期资产详情',
                    child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onDetails,
                        child: Image.asset(
                            'assets/images/ic_account_asset_diary.png',
                            width: 30.w,
                            height: 22.w)))),
          ]);
        }));
  }
}
