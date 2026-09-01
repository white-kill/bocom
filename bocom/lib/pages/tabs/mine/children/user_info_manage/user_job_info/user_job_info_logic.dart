import 'dart:convert';

import 'package:get/get.dart';

import 'user_job_info_state.dart';

class UserJobInfoLogic extends GetxController {
  UserJobInfoLogic({
    Map<String, String> initialValues = const {},
    bool initialSameAsResidence = false,
    Set<String> initiallyMaskedKeys = const {},
  }) {
    state.values.addAll(initialValues);
    state.sameAsResidence.value = initialSameAsResidence;
    _initiallyMaskedKeys.addAll(initiallyMaskedKeys);
  }

  factory UserJobInfoLogic.fromLocalSnapshot(
    Map<String, dynamic> snapshot, {
    required String currentPhone,
  }) {
    final values = <String, String>{};
    final rawValues = snapshot['values'];
    if (rawValues is Map) {
      for (final entry in rawValues.entries) {
        if (entry.key is String && entry.value is String) {
          values[entry.key as String] = entry.value as String;
        }
      }
    }
    values.remove(residencePhoneKey);
    if (currentPhone.isNotEmpty) values[residencePhoneKey] = currentPhone;
    return UserJobInfoLogic(
      initialValues: values,
      initialSameAsResidence: snapshot['sameAsResidence'] == true,
      initiallyMaskedKeys: values.keys.toSet()..remove(residencePhoneKey),
    );
  }

  factory UserJobInfoLogic.fromLocalJson(
    String source, {
    required String currentPhone,
  }) {
    if (source.isEmpty) {
      return UserJobInfoLogic.fromLocalSnapshot(
        const {},
        currentPhone: currentPhone,
      );
    }
    try {
      final decoded = jsonDecode(source);
      return UserJobInfoLogic.fromLocalSnapshot(
        decoded is Map<String, dynamic> ? decoded : const {},
        currentPhone: currentPhone,
      );
    } on FormatException {
      return UserJobInfoLogic.fromLocalSnapshot(
        const {},
        currentPhone: currentPhone,
      );
    }
  }

  static const String emailKey = 'email';
  static const String occupationKey = 'occupation';
  static const String residencePhoneKey = 'residence_phone';
  static const String residenceRegionKey = 'residence_region';
  static const String residenceDetailKey = 'residence_detail';
  static const String familyPhoneKey = 'family_phone';
  static const String familyRegionKey = 'family_region';
  static const String familyDetailKey = 'family_detail';
  static const String companyNameKey = 'company_name';
  static const String companyPhoneKey = 'company_phone';
  static const String companyRegionKey = 'company_region';
  static const String companyDetailKey = 'company_detail';

  final UserJobInfoState state = UserJobInfoState();
  final Set<String> _initiallyMaskedKeys = <String>{};

  Map<String, dynamic> localSnapshot() {
    final values = Map<String, String>.from(state.values)
      ..remove(residencePhoneKey);
    return <String, dynamic>{
      'values': values,
      'sameAsResidence': sameAsResidence,
    };
  }

  String localSnapshotJson() => jsonEncode(localSnapshot());

  String valueOf(String key) => state.values[key] ?? '';

  String displayValue(String key) {
    final value = !state.sameAsResidence.value
        ? valueOf(key)
        : switch (key) {
            familyPhoneKey => valueOf(residencePhoneKey),
            familyRegionKey => valueOf(residenceRegionKey),
            familyDetailKey => valueOf(residenceDetailKey),
            _ => valueOf(key),
          };
    if (!_initiallyMaskedKeys.contains(key)) return value;
    return switch (key) {
      emailKey => _maskEmail(value),
      familyPhoneKey => _maskPhone(value),
      companyPhoneKey => _maskPhone(value),
      companyNameKey => _maskCompanyName(value),
      _ => value,
    };
  }

  bool get sameAsResidence => state.sameAsResidence.value;

  bool get showsCompanyFields {
    final occupation = valueOf(occupationKey);
    return occupation.isNotEmpty && occupation != '学生' && occupation != '无业';
  }

  void setSameAsResidence(bool value) {
    state.sameAsResidence.value = value;
  }

  void selectOccupation(String occupation) {
    updateField(occupationKey, occupation);
  }

  void updateField(String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      _initiallyMaskedKeys.remove(key);
      state.values[key] = trimmed;
    }
  }

  void deleteField(String key) {
    _initiallyMaskedKeys.remove(key);
    state.values.remove(key);
  }

  void updateRegion(String key, List<String> regions) {
    final value = regions.where((region) => region.trim().isNotEmpty).join('·');
    if (value.isNotEmpty) {
      _initiallyMaskedKeys.remove(key);
      state.values[key] = value;
    }
  }

  static String _maskEmail(String value) {
    final atIndex = value.indexOf('@');
    if (atIndex <= 0) return value;
    final visibleLength = atIndex < 3 ? atIndex : 3;
    return '${value.substring(0, visibleLength)}***${value.substring(atIndex)}';
  }

  static String _maskPhone(String value) {
    if (value.length <= 7) return value;
    return '${value.substring(0, 3)}'
        '${'*' * (value.length - 7)}'
        '${value.substring(value.length - 4)}';
  }

  static String _maskCompanyName(String value) {
    final result = StringBuffer();
    for (var start = 0, group = 0;
        start < value.length;
        start += 2, group++) {
      final end = start + 2 < value.length ? start + 2 : value.length;
      result.write(group.isEven ? value.substring(start, end) : '**');
    }
    return result.toString();
  }
}
