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

  static const String defaultDate = '****.**.**';
  static const String defaultPinyin = '***KAN';

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
    final localDate = _readDate().trim();
    final localPinyin = _readPinyin().trim();
    state.date.value = localDate.isEmpty ? defaultDate : localDate;
    state.pinyin.value = localPinyin.isEmpty ? defaultPinyin : localPinyin;
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
