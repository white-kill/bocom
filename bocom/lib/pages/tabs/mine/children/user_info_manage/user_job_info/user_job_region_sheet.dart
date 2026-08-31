import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:wb_base_widget/wb_base_widget.dart';

class JobRegionSelection {
  const JobRegionSelection({
    required this.province,
    required this.city,
    required this.district,
  });

  final String province;
  final String city;
  final String district;

  List<String> get regions => [province, city, district];
}

class JobRegionPickerSheet extends StatefulWidget {
  const JobRegionPickerSheet({super.key});

  @override
  State<JobRegionPickerSheet> createState() => _JobRegionPickerSheetState();
}

class _JobRegionPickerSheetState extends State<JobRegionPickerSheet> {
  static const Color _blue = Color(0xFF0075F6);
  static const Color _textColor = Color(0xFF181818);
  static const Color _lineColor = Color(0xFFE8E8E8);

  final ScrollController _provinceController = ScrollController();
  List<_RegionNode> _provinces = const [];
  _RegionNode? _province;
  _RegionNode? _city;
  int _level = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    final source = await rootBundle.loadString('assets/china_regions.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    final regions = decoded
        .whereType<Map<String, dynamic>>()
        .map(_RegionNode.fromJson)
        .toList()
      ..sort((a, b) => _pinyin(a.label).compareTo(_pinyin(b.label)));
    if (!mounted) return;
    setState(() {
      _provinces = regions;
      _loading = false;
    });
  }

  static String _pinyin(String value) =>
      PinyinHelper.getPinyinE(value).replaceAll(' ', '').toUpperCase();

  static String _initial(String value) {
    final pinyin = _pinyin(value);
    return pinyin.isEmpty ? '#' : pinyin.substring(0, 1);
  }

  List<_RegionNode> get _cities => _province?.children ?? const [];

  List<_RegionNode> get _districts => _city?.children ?? const [];

  void _selectProvince(_RegionNode province) {
    final directDistricts = province.children.isNotEmpty &&
        province.children.every((child) => child.children.isEmpty);
    setState(() {
      _province = province;
      _city = directDistricts
          ? _RegionNode(label: province.label, children: province.children)
          : null;
      _level = directDistricts ? 2 : 1;
    });
  }

  void _selectCity(_RegionNode city) {
    setState(() {
      _city = city;
      _level = 2;
    });
  }

  void _selectDistrict(_RegionNode district) {
    final province = _province;
    final city = _city;
    if (province == null || city == null) return;
    Navigator.pop(
      context,
      JobRegionSelection(
        province: province.label,
        city: city.label,
        district: district.label,
      ),
    );
  }

  void _jumpToInitial(String initial) {
    final index = _provinces.indexWhere(
      (province) => _initial(province.label) == initial,
    );
    if (index < 0 || !_provinceController.hasClients) return;
    _provinceController.animateTo(
      index * 55.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('user-job-region-sheet'),
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: _textColor),
                    ),
                  ),
                  const BaseText(
                    text: '选择所在地区',
                    color: _textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            Container(
              height: 56,
              width: double.infinity,
              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  if (_province != null)
                    _Breadcrumb(
                      text: _province!.label,
                      onTap: () => setState(() => _level = 0),
                    ),
                  if (_city != null && _level >= 2)
                    _Breadcrumb(
                      text: _city!.label,
                      onTap: () => setState(() => _level = 1),
                    ),
                  const BaseText(
                    text: '请选择',
                    color: _blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : switch (_level) {
                      0 => _buildProvinceList(),
                      1 => _buildSimpleList(_cities, _selectCity),
                      _ => _buildSimpleList(_districts, _selectDistrict),
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceList() {
    final initials = _provinces.map((item) => _initial(item.label)).toSet();
    return Stack(
      children: [
        ListView.separated(
          key: const Key('user-job-province-list'),
          controller: _provinceController,
          padding: const EdgeInsets.fromLTRB(18, 4, 36, 20),
          itemCount: _provinces.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 32,
            color: _lineColor,
          ),
          itemBuilder: (_, index) {
            final province = _provinces[index];
            final initial = _initial(province.label);
            final showInitial =
                index == 0 || _initial(_provinces[index - 1].label) != initial;
            return InkWell(
              onTap: () => _selectProvince(province),
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: showInitial
                          ? BaseText(
                              text: initial,
                              color: const Color(0xFF999999),
                              fontSize: 15,
                            )
                          : null,
                    ),
                    BaseText(
                      text: province.label,
                      color: _textColor,
                      fontSize: 15,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          top: 10,
          right: 7,
          bottom: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final initial in initials)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _jumpToInitial(initial),
                  child: SizedBox(
                    width: 24,
                    height: 19,
                    child: Center(
                      child: BaseText(
                        text: initial,
                        color: _textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleList(
    List<_RegionNode> items,
    ValueChanged<_RegionNode> onSelected,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: _lineColor),
      itemBuilder: (_, index) {
        final item = items[index];
        return InkWell(
          onTap: () => onSelected(item),
          child: SizedBox(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: BaseText(
                text: item.label,
                color: _textColor,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: BaseText(
          text: text,
          color: const Color(0xFF181818),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RegionNode {
  const _RegionNode({required this.label, required this.children});

  factory _RegionNode.fromJson(Map<String, dynamic> json) {
    final children = (json['child'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(_RegionNode.fromJson)
            .toList() ??
        const <_RegionNode>[];
    return _RegionNode(label: json['label'] as String? ?? '', children: children);
  }

  final String label;
  final List<_RegionNode> children;
}
