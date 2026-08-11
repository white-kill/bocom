import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerAnalysisTab extends StatefulWidget {
  const LedgerAnalysisTab({super.key});

  @override
  State<LedgerAnalysisTab> createState() => _LedgerAnalysisTabState();
}

class _LedgerAnalysisTabState extends State<LedgerAnalysisTab> {
  bool _showExpense = true;
  int _selectedYearIndex = 3;
  bool _showExpenseRanking = true;

  static const _years = ['2020', '2021', '2022', '2023', '2024'];
  static const _incomeValues = [3200.0, 4800.0, 410000.0, 4.95, 360016.02];
  static const _expenseValues = [2800.0, 2600.0, 435000.0, 39414.36, 373061.44];
  static const _expenseRanking = [
    _RankingItem('全部提前还款', '借记卡(**2037)', '−357,762.34', Icons.subdirectory_arrow_right),
    _RankingItem('转账汇款-杨路', '借记卡(**2037)', '−3,600.00', Icons.sync_alt),
    _RankingItem('贷款到期归还', '借记卡(**2037)', '−2,968.61', Icons.subdirectory_arrow_right),
    _RankingItem('贷款到期归还', '借记卡(**2037)', '−2,962.64', Icons.subdirectory_arrow_right),
    _RankingItem('贷款到期归还', '借记卡(**2037)', '−2,921.67', Icons.subdirectory_arrow_right),
  ];
  static const _incomeRanking = [
    _RankingItem('工资收入', '借记卡(**2037)', '+352,800.00', Icons.account_balance_wallet_outlined),
    _RankingItem('转账汇款-杨路', '借记卡(**2037)', '+3,600.00', Icons.sync_alt),
    _RankingItem('退款入账', '借记卡(**2037)', '+1,826.02', Icons.subdirectory_arrow_left),
    _RankingItem('利息收入', '借记卡(**2037)', '+1,200.00', Icons.savings_outlined),
    _RankingItem('其他收入', '借记卡(**2037)', '+590.00', Icons.add_card_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7F7),
      child: ListView(
        padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 20.w),
        children: [
          _buildExpenseCard(),
          SizedBox(height: 12.w),
          _buildYearComparisonCard(),
          SizedBox(height: 12.w),
          _buildRankingCard(),
        ],
      ),
    );
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
                text: _showExpense ? '2024年总支出6笔' : '2024年总收入6笔',
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
            child: const Row(
              children: [
                BaseText(text: '合计', fontSize: 14, color: Color(0xFF999999)),
                BaseText(text: '373,061.44', fontSize: 14, color: Color(0xFF333333)),
                Spacer(),
                BaseText(text: '较去年', fontSize: 14, color: Color(0xFF999999)),
                BaseText(text: '+333,647.08', fontSize: 14, color: Color(0xFFFF565B)),
              ],
            ),
          ),
          SizedBox(height: 22.w),
          const BaseText(text: '钱都去哪儿:', fontSize: 14, color: Color(0xFF999999)),
          SizedBox(height: 20.w),
          const _CategoryItem(
            icon: Icons.subdirectory_arrow_right,
            title: '还款',
            percent: '99.0%',
            count: '5笔',
            amount: '369,461.44',
            progress: 0.99,
          ),
          SizedBox(height: 29.w),
          const _CategoryItem(
            icon: Icons.sync_alt,
            title: '转账',
            percent: '1.0%',
            count: '1笔',
            amount: '3,600.00',
            progress: 0.01,
          ),
          SizedBox(height: 18.w),
          Center(
            child: TextButton(
              onPressed: () {},
              child: BaseText(
                text: _showExpense ? '全部支出分类' : '全部收入分类',
                fontSize: 14,
                color: const Color(0xFF087DFF),
              ),
            ),
          ),
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
            _switchItem('支出', _showExpense, () => setState(() => _showExpense = true)),
            _switchItem('收入', !_showExpense, () => setState(() => _showExpense = false)),
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
    final year = _years[_selectedYearIndex];
    final income = _incomeValues[_selectedYearIndex];
    final expense = _expenseValues[_selectedYearIndex];
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
          const BaseText(
            text: '年收支对比',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF222222),
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
                BaseText(text: '$year年', fontSize: 14, color: const Color(0xFF666666)),
                SizedBox(height: 11.w),
                Row(
                  children: [
                    Expanded(child: _yearAmount(_incomeColor, '收入', _amountText(income))),
                    Expanded(child: _yearAmount(_expenseColor, '支出', _amountText(expense))),
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
                        '较去年',
                        _selectedYearIndex == 3 ? '−15,813.59' : '+26,363.99',
                        _selectedYearIndex == 3
                            ? const Color(0xFF21BC82)
                            : const Color(0xFFFF565B),
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
              builder: (context, constraints) => _buildYearChart(constraints.maxWidth),
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
    final plotLeft = 43.w;
    final plotWidth = width - plotLeft - 3.w;
    final selectedX = plotLeft + plotWidth * (_selectedYearIndex + 0.5) / _years.length;
    final showTooltipOnRight = _selectedYearIndex < _years.length ~/ 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BarChart(
          _yearChartData(),
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

  BarChartData _yearChartData() {
    return BarChartData(
      minY: 0,
      maxY: 500000,
      alignment: BarChartAlignment.spaceAround,
      groupsSpace: 11.w,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (_, __, ___, ____) => null,
        ),
        touchCallback: (event, response) {
          if (!event.isInterestedForInteractions || response?.spot == null) return;
          setState(() => _selectedYearIndex = response!.spot!.touchedBarGroupIndex);
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 125000,
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
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 43.w,
            interval: 125000,
            getTitlesWidget: (value, meta) {
              final text = value == 0
                  ? '0'
                  : value == 125000
                      ? '12.5万'
                      : value == 250000
                          ? '25万'
                          : value == 375000
                              ? '37.5万'
                              : value == 500000
                                  ? '50万'
                                  : '';
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: BaseText(text: text, fontSize: 11, color: const Color(0xFF8E9AAA)),
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
              if (index < 0 || index >= _years.length) return const SizedBox.shrink();
              final selected = index == _selectedYearIndex;
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 7.w,
                child: BaseText(
                  text: _years[index],
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFF333333) : const Color(0xFFB3BAC3),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: List.generate(_years.length, (index) {
        return BarChartGroupData(
          x: index,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: _incomeValues[index],
              width: 21.w,
              color: _incomeColor,
              borderRadius: BorderRadius.zero,
            ),
            BarChartRodData(
              toY: _expenseValues[index],
              width: 21.w,
              color: _expenseColor,
              borderRadius: BorderRadius.zero,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildYearTooltip() {
    final income = _amountText(_incomeValues[_selectedYearIndex]);
    final expense = _amountText(_expenseValues[_selectedYearIndex]);
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xCC555555),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseText(text: _years[_selectedYearIndex], fontSize: 15, color: Colors.white),
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
          Container(width: 9.w, height: 9.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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

  Widget _buildRankingCard() {
    final data = _showExpenseRanking ? _expenseRanking : _incomeRanking;
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
          ...List.generate(data.length, (index) {
            return Column(
              children: [
                _rankingItem(data[index], index),
                if (index != data.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 0,
                    color: const Color(0xFFE2E4E7),
                  ),
              ],
            );
          }),
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

  Widget _rankingItem(_RankingItem item, int index) {
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
          Icon(item.icon, size: 22.w, color: const Color(0xFF333333)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText(
                  text: item.title,
                  fontSize: 16,
                  color: const Color(0xFF333333),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.w),
                BaseText(
                  text: item.account,
                  fontSize: 14,
                  color: const Color(0xFF999999),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          BaseText(
            text: item.amount,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: income ? const Color(0xFFFF565B) : const Color(0xFF333333),
          ),
        ],
      ),
    );
  }
}

class _RankingItem {
  const _RankingItem(this.title, this.account, this.amount, this.icon);

  final String title;
  final String account;
  final String amount;
  final IconData icon;
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
    required this.icon,
    required this.title,
    required this.percent,
    required this.count,
    required this.amount,
    required this.progress,
  });

  final IconData icon;
  final String title;
  final String percent;
  final String count;
  final String amount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.w),
          child: Icon(icon, size: 22.w, color: const Color(0xFF333333)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  BaseText(text: title, fontSize: 16, color: const Color(0xFF333333)),
                  SizedBox(width: 10.w),
                  BaseText(text: percent, fontSize: 14, color: const Color(0xFF999999)),
                  SizedBox(width: 5.w),
                  BaseText(text: count, fontSize: 14, color: const Color(0xFF999999)),
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
    );
  }
}
