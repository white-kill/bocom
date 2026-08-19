class ComprehensiveAssetOverviewModel {
  ComprehensiveAssetOverviewModel({
    this.dateType,
    this.period,
    this.assetDate,
    this.totalAssets,
    this.changeAmount,
    this.trendUnit,
    this.trendList = const [],
  });

  final String? dateType;
  final String? period;
  final String? assetDate;
  final String? totalAssets;
  final String? changeAmount;
  final String? trendUnit;
  final List<ComprehensiveAssetTrendItem> trendList;

  factory ComprehensiveAssetOverviewModel.fromJson(
      Map<String, dynamic> json) {
    final rawTrendList = json['trendList'];
    return ComprehensiveAssetOverviewModel(
      dateType: _asString(json['dateType']),
      period: _asString(json['period']),
      assetDate: _asString(json['assetDate']),
      totalAssets: _asString(json['totalAssets']),
      changeAmount: _asString(json['changeAmount']),
      trendUnit: _asString(json['trendUnit']),
      trendList: rawTrendList is List
          ? rawTrendList
              .whereType<Map>()
              .map((item) => ComprehensiveAssetTrendItem.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class ComprehensiveAssetTrendItem {
  const ComprehensiveAssetTrendItem({
    this.dateTime,
    this.assetBalance,
  });

  final String? dateTime;
  final String? assetBalance;

  factory ComprehensiveAssetTrendItem.fromJson(Map<String, dynamic> json) =>
      ComprehensiveAssetTrendItem(
        dateTime: _asString(json['dateTime']),
        assetBalance: _asString(json['assetBalance']),
      );
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final result = value.toString();
  return result.isEmpty ? null : result;
}
