import 'dart:math' as math;

import 'package:bocom/config/dio/network.dart';
import 'package:bocom/config/model/book_analysis_model.dart';
import 'package:bocom/config/net_config/apis.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wb_base_widget/text_widget/bank_text.dart';

class LedgerAnalysisCategoryPage extends StatefulWidget {
  const LedgerAnalysisCategoryPage({super.key, required this.params});

  final Map<String, dynamic> params;

  @override
  State<LedgerAnalysisCategoryPage> createState() =>
      _LedgerAnalysisCategoryPageState();
}

class _LedgerAnalysisCategoryPageState
    extends State<LedgerAnalysisCategoryPage> {
  static const _colors = [
    Color(0xFF62A2ED),
    Color(0xFFFF9478),
    Color(0xFF70CEB2),
    Color(0xFF9B8DEF),
    Color(0xFFFFC45D),
    Color(0xFF67C7E8),
    Color(0xFFE56B9F),
    Color(0xFF7CB342),
    Color(0xFFEF6C57),
    Color(0xFF5C6BC0),
    Color(0xFFFFB74D),
    Color(0xFF26A69A),
    Color(0xFFAB6BC7),
    Color(0xFF42A5F5),
    Color(0xFFD4A62A),
    Color(0xFFEC5F7A),
    Color(0xFF66BB6A),
    Color(0xFF7E73D8),
    Color(0xFFFF8A65),
    Color(0xFF26B5CE),
    Color(0xFFC06C84),
    Color(0xFF8BC34A),
    Color(0xFFEF5350),
    Color(0xFF3F8FD2),
    Color(0xFFFFCA5C),
    Color(0xFF45B39D),
    Color(0xFFBA68C8),
    Color(0xFF29B6A8),
    Color(0xFFF07F55),
    Color(0xFF7986CB),
  ];

  BookAnalysisModel _data = BookAnalysisModel();
  bool _loading = true;

  bool get _isExpense => (widget.params['incomeExpenseType'] as int? ?? 2) == 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await Http.post(
      Apis.bookAnalysisCategoryList,
      data: Map<String, dynamic>.from(widget.params),
      isLoading: false,
    );
    if (!mounted) return;
    setState(() {
      if (value is Map) {
        _data = BookAnalysisModel.fromJson(Map<String, dynamic>.from(value));
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF222222), size: 22),
        ),
        title: BaseText(
          text: '${_isExpense ? '支出' : '收入'}分类',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF222222),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(15.w, 25.w, 15.w, 15.w),
                  child: Column(
                    children: [
                      BaseText(
                        text: '${_periodText()}总${_isExpense ? '支出' : '收入'}',
                        fontSize: 17,
                        color: const Color(0xFF333333),
                      ),
                      SizedBox(height: 10.w),
                      BaseText(
                        text: _amount(_data.totalAmount),
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2A2A2A),
                      ),
                      SizedBox(height: 30.w),
                      SizedBox(
                        width: 1.sw - 30.w,
                        height: 245.w,
                        child: _buildPieChart(),
                      ),
                      SizedBox(height: 10.w),
                      ...List.generate(
                          _data.categoryList.length,
                          (index) =>
                              _categoryRow(_data.categoryList[index], index)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15.w, 10.w, 15.w, 15.w),
                  child: const BaseText(
                    text: '本人银行卡同名互转、还交行信用卡、投资理财交易、默认不计入总账本收入和支出。',
                    fontSize: 12,
                    maxLines: 3,
                    color: Color(0xFF94A0B1),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPieChart() {
    final chartItems = _data.categoryList
        .where((e) => (double.tryParse(e.percentage) ?? 0) > 0)
        .toList();
    if (chartItems.isEmpty) {
      return Center(
        child: SizedBox(
          width: 145.w,
          height: 145.w,
          child: PieChart(PieChartData(sectionsSpace: 0, sections: [
            PieChartSectionData(
              value: 1,
              color: const Color(0xFFE9EEF4),
              radius: 17.w,
              showTitle: false,
            )
          ])),
        ),
      );
    }
    return LayoutBuilder(builder: (_, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return Stack(
        children: [
          Center(
            child: SizedBox(
              width: 145.w,
              height: 145.w,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  centerSpaceRadius: 48.w,
                  sectionsSpace: 0,
                  sections: List.generate(chartItems.length, (index) {
                    final item = chartItems[index];
                    return PieChartSectionData(
                      value: double.tryParse(item.percentage) ?? 0,
                      color: _colors[index % _colors.length],
                      radius: 17.w,
                      showTitle: false,
                    );
                  }),
                ),
              ),
            ),
          ),
          CustomPaint(
            size: size,
            painter: _PieLabelPainter(chartItems, _colors),
          ),
        ],
      );
    });
  }

  Widget _categoryRow(BookAnalysisCategoryList item, int index) {
    final color = _colors[index % _colors.length];
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.w),
              child: item.icon.isEmpty
                  ? Icon(Icons.receipt_long_outlined,
                      size: 24.w, color: const Color(0xFF333333))
                  : Image.network(item.icon,
                      width: 24.w,
                      height: 24.w,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.receipt_long_outlined,
                          size: 24.w,
                          color: const Color(0xFF333333))),
            ),
            SizedBox(width: 13.w),
            Expanded(
                child: Column(
              children: [
                Row(
                  children: [
                    BaseText(text: item.categoryName, fontSize: 16),
                    SizedBox(width: 10.w),
                    BaseText(
                      text: '${item.billCount}笔',
                      fontSize: 14,
                      color: const Color(0xFF999999),
                    ),
                    const Spacer(),
                    BaseText(
                      text: _amount(item.amount),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.w),
                  child: LinearProgressIndicator(
                    minHeight: 4.w,
            value: _progressValue(item.percentage),
                    backgroundColor: const Color(0xFFEDF1F5),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ))
          ],
        ),
        if (index != _data.categoryList.length - 1)...[
          SizedBox(height: 5.w,),
          Divider(height: 22.w, color: Color(0xFFE4E6E9)),
        ]
      ],
    );
  }

  String _periodText() {
    final dateType = _data.dateType.isEmpty
        ? widget.params['dateType']?.toString() ?? ''
        : _data.dateType;
    final period = _data.period.isEmpty
        ? widget.params['period']?.toString() ?? ''
        : _data.period;
    if (dateType == '月') {
      final parts = period.split('-');
      if (parts.length == 2) {
        return '${parts[0]}年${int.tryParse(parts[1]) ?? parts[1]}月';
      }
    }
    if (dateType == '年') return '${period}年';
    // 快捷时间范围和自定义范围只显示“总收入/总支出”。
    return '';
  }

  String _amount(String value) {
    final number = double.tryParse(value.replaceAll(',', '')) ?? 0;
    final parts = number.toStringAsFixed(2).split('.');
    final chars = parts.first.split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) result.add(',');
      result.add(chars[i]);
    }
    return '${result.reversed.join()}.${parts.last}';
  }

  double _progressValue(String percentage) {
    final value = ((double.tryParse(percentage) ?? 0) / 100)
        .clamp(0, 1)
        .toDouble();
    return value > 0 && value < 0.01 ? 0.01 : value;
  }
}

class _PieLabelPainter extends CustomPainter {
  const _PieLabelPainter(this.items, this.colors);

  final List<BookAnalysisCategoryList> items;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 圆环外半径为 65.w，外圈额外留出 8.w。
    // 小圆点和引导线起点共用此半径，确保圆点中心准确落在外圈上。
    final outerCircleRadius = 73.w;
    canvas.drawCircle(
      center,
      outerCircleRadius,
      Paint()
        ..color = const Color(0xFFE1E4E8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.w,
    );
    var angle = -math.pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2.w;
    for (var i = 0; i < items.length; i++) {
      final percentage = double.tryParse(items[i].percentage) ?? 0;
      final sweep = math.pi * 2 * percentage / 100;
      final middle = angle + sweep / 2;
      final start = center +
          Offset(math.cos(middle), math.sin(middle)) * outerCircleRadius;
      final elbow = center +
          Offset(math.cos(middle), math.sin(middle)) *
              (outerCircleRadius + 14.w);
      final right = math.cos(middle) >= 0;
      final end = Offset(right ? size.width - 4.w : 4.w, elbow.dy);
      paint.color = colors[i % colors.length];
      canvas.drawCircle(start, 3.w, Paint()..color = paint.color);
      canvas.drawLine(start, elbow, paint);
      canvas.drawLine(elbow, end, paint);

      final span = TextSpan(
        text:
            '${items[i].categoryName} ${_formatPercentage(percentage)}%',
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
      );
      final textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width / 2);
      textPainter.paint(
        canvas,
        Offset(
          right ? end.dx - textPainter.width : end.dx,
          end.dy - textPainter.height - 5.w,
        ),
      );
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieLabelPainter oldDelegate) => true;
}

String _formatPercentage(double value) {
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
