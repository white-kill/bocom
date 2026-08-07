import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerTrendChart extends StatefulWidget {
  const LedgerTrendChart({
    super.key,
    this.incomeValues = const [],
    this.expenseValues = const [],
  });

  final List<double> incomeValues;
  final List<double> expenseValues;

  @override
  State<LedgerTrendChart> createState() => _LedgerTrendChartState();
}

class _LedgerTrendChartState extends State<LedgerTrendChart> {
  static const _incomeColor = Color(0xFF5B9FF2);
  static const _expenseColor = Color(0xFFFF914D);
  static const _pointCount = 32;
  int _selectedIndex = _pointCount - 1;

  List<double> _values(List<double> source) {
    final values = source.take(_pointCount).toList();
    return [...values, ...List<double>.filled(_pointCount - values.length, 0)];
  }

  double get _maxY {
    final values = [..._values(widget.incomeValues), ..._values(widget.expenseValues)];
    final max = values.fold<double>(0, (result, value) => value > result ? value : result);
    return max <= 0 ? 5 : max * 1.2;
  }

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
              const BaseText(text: '近一月收支', fontSize: 13, color: Color(0xFF333333)),
              const Spacer(),
              _buildSwitch(),
            ],
          ),
          SizedBox(height: 20.w),
          SizedBox(
            height: 170.w,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildChart(constraints.maxWidth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(double chartWidth) {
    final selectedX = chartWidth * _selectedIndex / (_pointCount - 1);
    final tooltipWidth = 115.w;
    final showTooltipOnRight = _selectedIndex < 14;
    final tooltipLeft = showTooltipOnRight
        ? (selectedX + 12.w)
            .clamp(0.0, chartWidth - tooltipWidth)
            .toDouble()
        : (selectedX - tooltipWidth - 12.w)
            .clamp(0.0, chartWidth - tooltipWidth)
            .toDouble();


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
        Positioned(
          left: selectedX - 8.w,
          bottom: 22.w,
          child: Container(
            width: 16.w,
            height: 16.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0x445B9FF2),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: _incomeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
            ),
          ),
        ),
        Positioned(
          left: tooltipLeft,
          top: 5.w,
          child: _buildTooltip(),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: const BaseText(
            text: '07-07',
            fontSize: 13,
            color: Color(0xFFA6ADB7),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: const BaseText(
            text: '今天08-07',
            fontSize: 13,
            color: Color(0xFF222222),
          ),
        ),
      ],
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
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.w)),
              child: const BaseText(text: '看走势', fontSize: 12, color: Color(0xFF1677FF)),
            ),
          ),
          const Expanded(
            child: Center(child: BaseText(text: '看日历', fontSize: 12, color: Color(0xFF555555))),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip() {
    final income = _values(widget.incomeValues)[_selectedIndex];
    final expense = _values(widget.expenseValues)[_selectedIndex];
    final date = DateTime(2026, 7, 7).add(Duration(days: _selectedIndex));
    final dateText =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Container(
      width: 115.w,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.w),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
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
        children: [
          Container(width: 9.w, height: 9.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 5.w),
          BaseText(text: '$label ${value.toStringAsFixed(2)}', fontSize: 12, color: const Color(0xFF666666)),
        ],
      );

  LineChartData _chartData() {
    return LineChartData(
      minX: 0,
      maxX: (_pointCount - 1).toDouble(),
      minY: 0,
      maxY: _maxY,
      clipData: const FlClipData(top: false, bottom: false, left: false, right: false),
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
