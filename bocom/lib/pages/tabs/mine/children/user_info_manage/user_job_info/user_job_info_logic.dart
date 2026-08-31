import 'package:get/get.dart';

import 'user_job_info_state.dart';

class UserJobInfoLogic extends GetxController {
  UserJobInfoLogic({Map<String, String> initialValues = const {}}) {
    state.values.addAll(initialValues);
  }

  static const String emailKey = 'email';
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

  String valueOf(String key) => state.values[key] ?? '';

  void updateField(String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) state.values[key] = trimmed;
  }

  void deleteField(String key) {
    state.values.remove(key);
  }

  void updateRegion(String key, List<String> regions) {
    final value = regions.where((region) => region.trim().isNotEmpty).join('·');
    if (value.isNotEmpty) state.values[key] = value;
  }
}
