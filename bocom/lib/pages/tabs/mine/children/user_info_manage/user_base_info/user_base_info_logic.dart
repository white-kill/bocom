import 'package:bocom/utils/sp_util.dart';
import 'package:get/get.dart';

import 'user_base_info_state.dart';

class UserBaseInfoLogic extends GetxController {
  UserBaseInfoLogic({
    String Function()? readDate,
    String Function()? readPinyin,
    void Function(String)? writeDate,
    void Function(String)? writePinyin,
  })  : _readDate = readDate ?? (() => userBaseInfoDateValue),
        _readPinyin = readPinyin ?? (() => userBaseInfoPinyinValue),
        _writeDate = writeDate ?? ((value) => value.saveUserBaseInfoDate),
        _writePinyin =
            writePinyin ?? ((value) => value.saveUserBaseInfoPinyin);

  final UserBaseInfoState state = UserBaseInfoState();
  final String Function() _readDate;
  final String Function() _readPinyin;
  final void Function(String) _writeDate;
  final void Function(String) _writePinyin;

  @override
  void onInit() {
    super.onInit();
    loadLocalValues();
  }

  void loadLocalValues() {
    state.date.value = _readDate().trim();
    state.pinyin.value = _readPinyin().trim();
  }

  String dateValue(String memberBirthday) => state.date.value.isNotEmpty
      ? state.date.value
      : maskBirthday(memberBirthday);

  String pinyinValue(String memberNamePinyin) => state.pinyin.value.isNotEmpty
      ? state.pinyin.value
      : maskNamePinyin(memberNamePinyin);

  static String maskBirthday(String value) {
    final birthday = value.trim();
    if (birthday.isEmpty) return '';

    final datePart = birthday.split(RegExp(r'[ T]')).first;
    final dayMatch = RegExp(r'(\d{1,2})$').firstMatch(datePart);
    if (dayMatch == null) return '';
    return '****.**.${dayMatch.group(1)}';
  }

  static String maskNamePinyin(String value) {
    final pinyin = value.trim();
    if (pinyin.isEmpty) return '';

    final surnameSeparator = RegExp(r'\s+').firstMatch(pinyin);
    if (surnameSeparator == null) return '***';
    return '***${pinyin.substring(surnameSeparator.start)}';
  }

  bool saveDate(String value) => _save(value, state.date, _writeDate);

  bool savePinyin(String value) => _save(value, state.pinyin, _writePinyin);

  bool _save(String value, RxString target, void Function(String) writer) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    writer(trimmed);
    target.value = trimmed;
    return true;
  }
}
