import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';
import 'package:bocom/config/model/book_analysis_model.dart';
import 'package:wb_base_widget/wb_base_widget.dart';
import '../ledger_logic.dart';
import 'ledger_analysis_category_page.dart';
import 'ledger_analysis_category_detail_page.dart';

class LedgerAnalysisTab extends StatefulWidget {
  const LedgerAnalysisTab({super.key, required this.logic});
  final LedgerLogic logic;

  @override
  State<LedgerAnalysisTab> createState() => _LedgerAnalysisTabState();
}

class _LedgerAnalysisTabState extends State<LedgerAnalysisTab> {
  int _selectedYearIndex = -1;
  bool _showExpenseRanking = true;

  BookAnalysisModel get _data => widget.logic.bookAnalysis.value;
  List<BookAnalysisTrendList> get _trends => _data.trendList;
  int get _trendIndex => _trends.isEmpty
      ? 0
      : (_selectedYearIndex < 0 || _selectedYearIndex >= _trends.length)
          ? _trends.length - 1
          : _selectedYearIndex;
  bool get _showExpense => widget.logic.analysisIncomeExpenseType.value == 2;
  bool get _hasAnalysisTimeRange =>
      widget.logic.analysisBeginTime.value != null ||
      widget.logic.analysisEndTime.value != null;

  @override
  Widget build(BuildContext context) {
    return Obx(() => ColoredBox(
          color: const Color(0xFFF7F7F7),
          child: ListView(
            padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 20.w),
            children: [
              _buildExpenseCard(),
              if (!_hasAnalysisTimeRange) ...[
                SizedBox(height: 12.w),
                _buildYearComparisonCard(),
                SizedBox(height: 12.w),
                _buildRankingCard(),
              ],
            ],
          ),
        ));
  }

  Widget _buildExpenseCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BaseText(
                text:
                    '${_analysisTitle()}总${_showExpense ? '支出' : '收入'}${_data.billCount}笔',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2E2E2E),
              ),
              const Spacer(),
              _buildTypeSwitch(),
            ],
          ),
          SizedBox(height: 18.w),
          Container(
            height: 50.w,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Row(
              children: [
                const BaseText(
                    text: '合计', fontSize: 14, color: Color(0xFF999999)),
                BaseText(
                    text: _formatAmount(_data.totalAmount),
                    fontSize: 14,
                    color: const Color(0xFF333333)),
                if (!_hasAnalysisTimeRange) ...[
                  const Spacer(),
                  BaseText(
                      text: _compareLabel(),
                      fontSize: 14,
                      color: const Color(0xFF999999)),
                  BaseText(
                      text: _signedAmount(_data.comparedPrevious),
                      fontSize: 14,
                      color: _changeColor(_data.comparedPrevious)),
                ],
              ],
            ),
          ),
          SizedBox(height: 22.w),
          BaseText(
            text: _showExpense ? '钱都去哪儿:' : '钱从哪里来:',
            fontSize: 14,
            color: const Color(0xFF999999),
          ),
          if (_data.categoryList.isEmpty)
            _buildEmptyState(
              text: '暂无${_showExpense ? '支出' : '收入'}明细',
              height: 170.w,
            )
          else ...[
            SizedBox(height: 20.w),
            ...List.generate(_data.categoryList.length, (index) {
              final item = _data.categoryList[index];
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == _data.categoryList.length - 1 ? 0 : 29.w),
                child: _CategoryItem(
                  onTap: () => Get.to(
                    () => LedgerAnalysisCategoryDetailPage(
                      params: widget.logic.buildAnalysisParams(),
                      category: item,
                    ),
                  ),
                  imageUrl: item.icon,
                  title: item.categoryName,
                  percent: '${item.percentage}%',
                  count: '${item.billCount}笔',
                  amount: _formatAmount(item.amount),
                  progress: _progressValue(item.percentage),
                ),
              );
            }),
            SizedBox(height: 18.w),
            Center(
              child: TextButton(
                onPressed: () => Get.to(
                  () => LedgerAnalysisCategoryPage(
                    params: widget.logic.buildAnalysisParams(),
                  ),
                ),
                child: BaseText(
                  text: _showExpense ? '全部支出分类' : '全部收入分类',
                  fontSize: 14,
                  color: const Color(0xFF087DFF),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSwitch() => Container(
        width: 94.w,
        height: 30.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(18.w),
        ),
        child: Row(
          children: [
            _switchItem('支出', _showExpense,
                () => widget.logic.selectAnalysisIncomeExpenseType(2)),
            _switchItem('收入', !_showExpense,
                () => widget.logic.selectAnalysisIncomeExpenseType(1)),
          ],
        ),
      );

  Widget _switchItem(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: BaseText(
            text: text,
            fontSize: 12,
            color: selected ? const Color(0xFF087DFF) : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  Widget _buildYearComparisonCard() {
    final trend =
        _trends.isEmpty ? BookAnalysisTrendList() : _trends[_trendIndex];
    final year = trend.dateTime;
    final income = double.tryParse(trend.incomeTotal) ?? 0;
    final expense = double.tryParse(trend.expensesTotal) ?? 0;
    final balance = income - expense;

    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 18.w, 15.w, 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseText(
            text: _data.dateType == '月' ? '月收支对比' : '年收支对比',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF222222),
          ),
          SizedBox(height: 18.w),
          Container(
            padding: EdgeInsets.fromLTRB(15.w, 14.w, 15.w, 15.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText(
                    text: _comparisonPeriodText(year),
                    fontSize: 14,
                    color: const Color(0xFF666666)),
                SizedBox(height: 11.w),
                Row(
                  children: [
                    Expanded(
                        child: _yearAmount(
                            _incomeColor, '收入', _amountText(income))),
                    Expanded(
                        child: _yearAmount(
                            _expenseColor, '支出', _amountText(expense))),
                  ],
                ),
                SizedBox(height: 15.w),
                Row(
                  children: [
                    Expanded(
                      child: _labelValue(
                        '结余',
                        '${balance < 0 ? '−' : '+'}${_amountText(balance.abs())}',
                        const Color(0xFF333333),
                      ),
                    ),
                    Expanded(
                      child: _labelValue(
                        _compareLabel(),
                        _signedAmount(_data.balanceComparedPrevious),
                        _changeColor(_data.balanceComparedPrevious),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 23.w),
          SizedBox(
            height: 180.w,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildYearChart(constraints.maxWidth),
            ),
          ),
        ],
      ),
    );
  }

  static const _incomeColor = Color(0xFF62A2ED);
  static const _expenseColor = Color(0xFFFFB574);

  Widget _yearAmount(Color color, String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4.w, height: 15.w, color: color),
            SizedBox(width: 9.w),
            BaseText(text: label, fontSize: 14, color: const Color(0xFF999999)),
          ],
        ),
        SizedBox(height: 6.w),
        BaseText(text: amount, fontSize: 18, color: const Color(0xFF333333)),
      ],
    );
  }

  Widget _labelValue(String label, String value, Color color) {
    return Row(
      children: [
        BaseText(text: label, fontSize: 14, color: const Color(0xFF999999)),
        Flexible(child: BaseText(text: value, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildYearChart(double width) {
    if (_trends.isEmpty) return const SizedBox.shrink();
    final plotLeft = 43.w;
    final plotWidth = width - plotLeft - 3.w;
    final selectedX =
        plotLeft + plotWidth * (_trendIndex + 0.5) / _trends.length;
    final showTooltipOnRight = _trendIndex < _trends.length ~/ 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BarChart(
          _yearChartData(plotWidth),
          duration: const Duration(milliseconds: 250),
        ),
        Positioned(
          left: plotLeft,
          top: 0,
          right: 3.w,
          child: SizedBox(
            height: 1.w,
            child: CustomPaint(painter: _AnalysisHorizontalDashPainter()),
          ),
        ),
        Positioned(
          left: selectedX,
          top: 4.w,
          bottom: 27.w,
          child: Container(width: 1.w, color: const Color(0xFF287CFF)),
        ),
        Positioned(
          left: showTooltipOnRight ? selectedX + 8.w : null,
          right: showTooltipOnRight ? null : width - selectedX + 8.w,
          top: 10.w,
          child: _buildYearTooltip(),
        ),
      ],
    );
  }

  BarChartData _yearChartData(double plotWidth) {
    final values = _trends.expand((e) => [
          double.tryParse(e.incomeTotal) ?? 0,
          double.tryParse(e.expensesTotal) ?? 0,
        ]);
    final largest =
        values.fold<double>(0, (max, value) => value > max ? value : max);
    final maxY = largest <= 0 ? 1.0 : largest * 1.2;
    // 每组包含收入、支出两根柱子。根据可用宽度和数据条数动态
    // 分配柱宽，最多 12 组时也不会互相挤压，少量数据时则限制最大宽度。
    final groupWidth = plotWidth / _trends.length;
    final rodWidth = (groupWidth * 0.28).clamp(4.w, 21.w).toDouble();
    final groupsSpace = (groupWidth * 0.18).clamp(2.w, 11.w).toDouble();
    return BarChartData(
      minY: 0,
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      groupsSpace: groupsSpace,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (_, __, ___, ____) => null,
        ),
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions || response?.spot == null)
            return;
          setState(
              () => _selectedYearIndex = response!.spot!.touchedBarGroupIndex);
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: Color(0xFFD8DEE7),
          strokeWidth: 1,
          dashArray: [3, 3],
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(bottom: BorderSide(color: Color(0xFFCCD3DC))),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 43.w,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) {
              final text = _axisAmount(value);
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: BaseText(
                    text: text, fontSize: 11, color: const Color(0xFF8E9AAA)),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 27.w,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= _trends.length)
                return const SizedBox.shrink();
              if (_data.dateType == '月' && index % 3 != 0) {
                return const SizedBox.shrink();
              }
              final selected = index == _trendIndex;
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 7.w,
                child: BaseText(
                  text: _trendLabel(_trends[index].dateTime),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? const Color(0xFF333333)
                      : const Color(0xFFB3BAC3),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: List.generate(_trends.length, (index) {
        return BarChartGroupData(
          x: index,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: double.tryParse(_trends[index].incomeTotal) ?? 0,
              width: rodWidth,
              color: _incomeColor,
              borderRadius: BorderRadius.zero,
            ),
            BarChartRodData(
              toY: double.tryParse(_trends[index].expensesTotal) ?? 0,
              width: rodWidth,
              color: _expenseColor,
              borderRadius: BorderRadius.zero,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildYearTooltip() {
    final trend = _trends[_trendIndex];
    final income = _formatAmount(trend.incomeTotal);
    final expense = _formatAmount(trend.expensesTotal);
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xCC555555),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseText(
              text: _tooltipPeriodText(trend.dateTime),
              fontSize: 15,
              color: Colors.white),
          SizedBox(height: 6.w),
          _tooltipRow(_incomeColor, '收入：$income'),
          SizedBox(height: 5.w),
          _tooltipRow(_expenseColor, '支出：$expense'),
        ],
      ),
    );
  }

  Widget _tooltipRow(Color color, String text) => Row(
        children: [
          Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 5.w),
          BaseText(text: text, fontSize: 13, color: Colors.white),
        ],
      );

  String _amountText(double value) {
    if (value == 4.95) return '4.95';
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final chars = parts.first.split('').reversed.toList();
    final grouped = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) grouped.add(',');
      grouped.add(chars[i]);
    }
    return '${grouped.reversed.join()}.${parts.last}';
  }

  String _formatAmount(String value) =>
      _amountText(double.tryParse(value.replaceAll(',', '')) ?? 0);

  double _progressValue(String percentage) {
    final value =
        ((double.tryParse(percentage) ?? 0) / 100).clamp(0, 1).toDouble();
    return value > 0 && value < 0.001 ? 0.001 : value;
  }

  String _signedAmount(String value) {
    final number = double.tryParse(value.replaceAll(',', '')) ?? 0;
    return '${number >= 0 ? '+' : '−'}${_amountText(number.abs())}';
  }

  Color _changeColor(String value) =>
      (double.tryParse(value.replaceAll(',', '')) ?? 0) < 0
          ? const Color(0xFF21BC82)
          : const Color(0xFFFF565B);

  String _analysisTitle() {
    if (_data.dateType == '自定义') return '';
    final period = _data.period;
    if (period.isEmpty) return '';
    if (_data.dateType == '月') {
      final month = int.tryParse(period.split('-').last);
      return month == null ? '' : '$month月';
    }
    return '${period}年';
  }

  String _compareLabel() => _data.dateType == '月' ? '较上月' : '较去年';

  String _comparisonPeriodText(String period) {
    if (_data.dateType == '月') {
      final parts = period.split('-');
      if (parts.length >= 2) {
        final month = int.tryParse(parts[1]);
        if (month != null) return '${parts[0]}年$month月';
      }
      return period;
    }
    return period.isEmpty || period.endsWith('年') ? period : '${period}年';
  }

  String _trendLabel(String value) {
    if (_data.dateType == '月' && value.length >= 7 && value[4] == '-') {
      final month = int.tryParse(value.substring(5, 7));
      return month == null ? value : '$month月';
    }
    return value.length >= 4 ? value.substring(0, 4) : value;
  }

  String _tooltipPeriodText(String value) {
    if (_data.dateType == '月') {
      final parts = value.split('-');
      if (parts.length >= 2) {
        final month = int.tryParse(parts[1]);
        if (month != null) return '$month月';
      }
      return value;
    }
    return value.length >= 4 ? value.substring(0, 4) : value;
  }

  String _axisAmount(double value) {
    if (value == 0) return '0';
    if (value >= 10000) {
      final text =
          (value / 10000).toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
      return '$text万';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildRankingCard() {
    final data =
        _showExpenseRanking ? _data.expenseRankList : _data.incomeRankList;
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 61.w,
            child: Row(
              children: [
                Expanded(
                  child: _rankingTab(
                    text: '支出排行',
                    selected: _showExpenseRanking,
                    onTap: () => setState(() => _showExpenseRanking = true),
                  ),
                ),
                Expanded(
                  child: _rankingTab(
                    text: '收入排行',
                    selected: !_showExpenseRanking,
                    onTap: () => setState(() => _showExpenseRanking = false),
                  ),
                ),
              ],
            ),
          ),
          if (data.isEmpty)
            _buildEmptyState(text: '暂无排行数据', height: 200.w)
          else
            ...List.generate(data.length, (index) {
              return Column(
                children: [
                  _rankingItem(data[index], index),
                  if (index != data.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 0,
                      color: Color(0xFFE2E4E7),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required String text, required double height}) {
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 1.sw,
            child: Center(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/bg_lefger_water_empty.png',
                    width: 110.w,
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BaseText(
                          text: text,
                          fontSize: 14,
                          color: const Color(0xFF333333),
                        )
                      ],
                    ).withSizedBox(width: 110.w),
                  )
                ],
              ),
            ),
          ),
          // SizedBox(height: 14.w),
          // BaseText(
          //   text: text,
          //   fontSize: 16,
          //   color: const Color(0xFF333333),
          // ),
        ],
      ),
    );
  }

  Widget _rankingTab({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BaseText(
            text: text,
            fontSize: 16,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? const Color(0xFF222222) : const Color(0xFF666666),
          ),
          SizedBox(height: 8.w),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 29.w : 0,
            height: 3.w,
            decoration: BoxDecoration(
              color: const Color(0xFF087DFF),
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankingItem(BookAnalysisRankList item, int index) {
    final income = !_showExpenseRanking;
    return SizedBox(
      height: 76.w,
      child: Row(
        children: [
          SizedBox(
            width: 25.w,
            child: index < 3
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 25.w,
                        color: const [
                          Color(0xFFFFD784),
                          Color(0xFFD8DEEB),
                          Color(0xFFFFD0B5),
                        ][index],
                      ),
                      BaseText(
                        text: '${index + 1}',
                        fontSize: 14,
                        color: index == 0
                            ? const Color(0xFFA26A21)
                            : const Color(0xFF7D8491),
                      ),
                    ],
                  )
                : Center(
                    child: BaseText(
                      text: '${index + 1}',
                      fontSize: 15,
                      color: const Color(0xFF333333),
                    ),
                  ),
          ),
          SizedBox(width: 9.w),
          Icon(
              item.type == 1
                  ? Icons.account_balance_wallet_outlined
                  : Icons.sync_alt,
              size: 22.w,
              color: const Color(0xFF333333)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText(
                  text: item.excerpt,
                  fontSize: 16,
                  color: const Color(0xFF333333),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.w),
                BaseText(
                  text:
                      '借记卡(${item.bankCardText.substring(item.bankCardText.length - 6)})',
                  fontSize: 14,
                  color: const Color(0xFF999999),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          BaseText(
            text: '${income ? '+' : '−'}${_formatAmount(item.amount)}',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: income ? const Color(0xFFFF565B) : const Color(0xFF333333),
          ),
        ],
      ),
    );
  }
}

class _AnalysisHorizontalDashPainter extends CustomPainter {
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

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.onTap,
    required this.imageUrl,
    required this.title,
    required this.percent,
    required this.count,
    required this.amount,
    required this.progress,
  });

  final VoidCallback onTap;
  final String imageUrl;
  final String title;
  final String percent;
  final String count;
  final String amount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.w),
            child: imageUrl.isEmpty
                ? Icon(Icons.receipt_long_outlined,
                    size: 22.w, color: const Color(0xFF333333))
                : Image.network(imageUrl,
                    width: 22.w,
                    height: 22.w,
                    errorBuilder: (_, __, ___) => Icon(
                        Icons.receipt_long_outlined,
                        size: 22.w,
                        color: const Color(0xFF333333))),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    BaseText(
                        text: title,
                        fontSize: 16,
                        color: const Color(0xFF333333)),
                    SizedBox(width: 10.w),
                    BaseText(
                        text: percent,
                        fontSize: 14,
                        color: const Color(0xFF999999)),
                    SizedBox(width: 5.w),
                    BaseText(
                        text: count,
                        fontSize: 14,
                        color: const Color(0xFF999999)),
                    const Spacer(),
                    BaseText(
                      text: amount,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  ],
                ),
                SizedBox(height: 8.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.w),
                  child: LinearProgressIndicator(
                    minHeight: 4.w,
                    value: progress,
                    backgroundColor: const Color(0xFFEDF1F5),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFB57C)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
