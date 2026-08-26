import 'dart:math';

import 'package:get/get.dart';

import '../../../../../utils/sp_util.dart';

import 'user_info_state.dart';

class UserInfoLogic extends GetxController {
  UserInfoLogic({
    String Function()? readNickname,
    void Function(String value)? writeNickname,
    Random? random,
  })  : _readNickname = readNickname ?? (() => nickNameValue),
        _writeNickname =
            writeNickname ?? ((value) => value.saveSettingNickName),
        _random = random ?? Random();

  final UserInfoState state = UserInfoState();
  final String Function() _readNickname;
  final void Function(String value) _writeNickname;
  final Random _random;

  @override
  void onInit() {
    super.onInit();
    loadNickname();
  }

  void loadNickname() {
    final storedNickname = _readNickname().trim();
    if (storedNickname.isNotEmpty) {
      state.nickname.value = storedNickname;
      return;
    }

    final generatedNickname = _generateNickname();
    state.nickname.value = generatedNickname;
    _writeNickname(generatedNickname);
  }

  bool saveNickname(String value) {
    final nickname = value.trim();
    if (nickname.isEmpty) return false;

    _writeNickname(nickname);
    state.nickname.value = nickname;
    return true;
  }

  String _generateNickname() {
    final digits = List.generate(7, (_) => _random.nextInt(10)).join();
    const letters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final suffix =
        List.generate(3, (_) => letters[_random.nextInt(letters.length)])
            .join();
    return '用户$digits$suffix';
  }
}
