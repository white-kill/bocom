class AssetDiaryModel {
  AssetDiaryModel.fromJson(Map<String, dynamic> json)
      : queryDate = DateTime.tryParse(json['queryDate']?.toString() ?? ''),
        rangeType = json['rangeType']?.toString(),
        assetDate = DateTime.tryParse(json['assetDate']?.toString() ?? ''),
        dataUpdateTime = DateTime.tryParse(json['dataUpdateTime']?.toString() ?? ''),
        totalAssets = double.tryParse(json['totalAssets']?.toString() ?? ''),
        changeAmount = double.tryParse(json['changeAmount']?.toString() ?? ''),
        availableBalance = double.tryParse(json['availableBalance']?.toString() ?? ''),
        trendStartDate = DateTime.tryParse(json['trendStartDate']?.toString() ?? ''),
        trendEndDate = DateTime.tryParse(json['trendEndDate']?.toString() ?? ''),
        trendUnit = json['trendUnit']?.toString(),
        trendList = (json['trendList'] is List ? json['trendList'] as List : const [])
            .whereType<Map>()
            .map((item) => AssetDiaryEntry.fromJson(Map<String, dynamic>.from(item)))
            .whereType<AssetDiaryEntry>()
            .toList()..sort((a, b) => a.date.compareTo(b.date));

  final DateTime? queryDate;
  final String? rangeType;
  final DateTime? assetDate;
  final DateTime? dataUpdateTime;
  final double? totalAssets;
  final double? changeAmount;
  final double? availableBalance;
  final DateTime? trendStartDate;
  final DateTime? trendEndDate;
  final String? trendUnit;
  final List<AssetDiaryEntry> trendList;
}

class AssetDiaryEntry {
  const AssetDiaryEntry({required this.date, required this.amount});
  final DateTime date;
  final double amount;

  static AssetDiaryEntry? fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['dateTime']?.toString() ?? '');
    final amount = double.tryParse(json['assetBalance']?.toString() ?? '');
    if (date == null || amount == null) return null;
    return AssetDiaryEntry(date: DateTime(date.year, date.month, date.day), amount: amount);
  }
}
