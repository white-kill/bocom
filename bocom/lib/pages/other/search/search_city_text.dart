import 'package:bocom/config/abc_config/boc_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchCityText extends StatelessWidget {
  const SearchCityText({
    required this.fontSize,
    this.color = const Color(0xFF222222),
    super.key,
  });

  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BocLogic>()) {
      return _label('上海');
    }

    return GetBuilder<BocLogic>(
      id: 'updateUI',
      builder: (logic) {
        final city = logic.memberInfo.city.trim();
        return _label(city.isEmpty ? '上海' : city);
      },
    );
  }

  Widget _label(String city) {
    return Semantics(
      label: '当前城市，$city',
      child: Text(
        city,
        key: const Key('search-city-label'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          height: 1,
        ),
      ),
    );
  }
}
