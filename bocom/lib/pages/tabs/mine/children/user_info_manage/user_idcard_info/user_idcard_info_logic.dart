import 'package:bocom/utils/sp_util.dart';
import 'package:get/get.dart';

import 'user_idcard_info_state.dart';

class UserIdcardInfoLogic extends GetxController {
  UserIdcardInfoLogic({
    String Function()? readAddress,
    void Function(String)? writeAddress,
  })  : _readAddress = readAddress ?? (() => userIdcardInfoAddressValue),
        _writeAddress =
            writeAddress ?? ((value) => value.saveUserIdcardInfoAddress);

  final UserIdcardInfoState state = UserIdcardInfoState();
  final String Function() _readAddress;
  final void Function(String) _writeAddress;

  @override
  void onInit() {
    super.onInit();
    loadLocalAddress();
  }

  static String maskIdCard(String value) {
    final idCard = value.trim();
    if (idCard.isEmpty) return '--';
    if (idCard.length <= 5) return idCard;

    final stars = List.filled(idCard.length - 5, '*').join();
    return '${idCard.substring(0, 3)}$stars${idCard.substring(idCard.length - 2)}';
  }

  void loadLocalAddress() {
    state.address.value = _readAddress().trim();
  }

  String addressValue(String memberCity) => state.address.value.isNotEmpty
      ? state.address.value
      : memberCity.trim();

  bool saveAddress(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    _writeAddress(trimmed);
    state.address.value = trimmed;
    return true;
  }
}
