import 'package:bocom/config/abc_config/account_city_builder.dart';
import 'package:flutter/material.dart';

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
    return AccountCityBuilder(
      builder: (_, city) => _label(city),
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
