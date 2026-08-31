import 'package:sp_util/sp_util.dart';

import '../config/app_config.dart';

class SpKey{


  static const String tokenKey = "access_token";

  static const String userTypeKey = "user_position";

  static const String userAccount = "user_account";

  static const String userPassword = "user_password";


  static const String userRememberPassword = "user_remember_password";

  static const String userIdKey = "user_id_key";

  static const String languageKey = "language_key";

  static const String deleteAccount = "delete_account";

  static const String searchHistory = "search_history";
  static const String searchHistory1 = "search_history1";

  static const String settingNickName = "setting_nickName";

  static const String editKhwd = "edit_khwd";

  static const String accountAlias = "account_alias";

  /// 基本身份信息页本地编辑内容。
  static const String userBaseInfoDate = "user_base_info_date";
  static const String userBaseInfoPinyin = "user_base_info_pinyin";

  static const String userIdcardInfoAddress = "user_idcard_info_address";

  /// 关联银行卡号（纯数字，每手机号仅一条；再次保存会覆盖）
  static const String accountLinkCard = "account_link_card_";

  /// 转账联系人列表缓存（按手机号隔离）
  static const String contactsList = "contacts_list_";

  /// 转账记录第一页缓存（按手机号隔离）
  static const String transferRecord = "transfer_record_";

}

extension SpExtensionBool on bool {

  void get saveRememberPsd => SpUtil.putBool(SpKey.userRememberPassword, this);
}


extension SpExtension on String{

  void get saveToken => SpUtil.putString(SpKey.tokenKey, this);


  void get saveAccount => SpUtil.putString(SpKey.userAccount, this);

  void get savePassword => SpUtil.putString(SpKey.userPassword, this);

  void get saveUserId => SpUtil.putString(SpKey.userIdKey, this);

  void get saveLanguage => SpUtil.putString(SpKey.languageKey, this);

  void get saveDeleteAccount => SpUtil.putString(SpKey.deleteAccount, this);

  void get saveSearchHistory => SpUtil.putString(SpKey.searchHistory, this);
  void get saveSearchHistory1 => SpUtil.putString(SpKey.searchHistory1, this);

  void get saveSettingNickName => SpUtil.putString(SpKey.settingNickName + AppConfig.config.abcLogic.phone(), this);
  void get saveEditKhwd => SpUtil.putString(SpKey.editKhwd + AppConfig.config.abcLogic.phone(), this);

  void get saveAccountAlias =>
      SpUtil.putString(SpKey.accountAlias, this);

  void get saveUserBaseInfoDate =>
      SpUtil.putString(SpKey.userBaseInfoDate, this);

  void get saveUserBaseInfoPinyin =>
      SpUtil.putString(SpKey.userBaseInfoPinyin, this);

  void get saveUserIdcardInfoAddress =>
      SpUtil.putString(SpKey.userIdcardInfoAddress, this);

  void get saveAccountLinkCard => SpUtil.putString(
        SpKey.accountLinkCard + AppConfig.config.abcLogic.phone(),
        this,
      );

}


Future<bool>? get removeAllData => SpUtil.clear();

Future<bool>? removeKey(String key) => SpUtil.remove(key);


String get token => SpUtil.getString(SpKey.tokenKey)??"";

String get account => SpUtil.getString(SpKey.userAccount)??"";

String get password => SpUtil.getString(SpKey.userPassword)??"";

bool get getRememberPsd => SpUtil.getBool(SpKey.userRememberPassword)??false;

String get userId => SpUtil.getString(SpKey.userIdKey)??'';

String get languageValue => SpUtil.getString(SpKey.languageKey)??'';

String get deleteAccountValue => SpUtil.getString(SpKey.deleteAccount)??'';

String get searchHistoryValue => SpUtil.getString(SpKey.searchHistory)??'';
String get searchHistoryValue1 => SpUtil.getString(SpKey.searchHistory1)??'';

String get editKhwdContent => SpUtil.getString(SpKey.editKhwd + AppConfig.config.abcLogic.phone())??'';

String get nickNameValue => SpUtil.getString(SpKey.settingNickName + AppConfig.config.abcLogic.phone())??'';

String get accountAliasValue =>
    SpUtil.getString(SpKey.accountAlias) ?? '';

String get userBaseInfoDateValue =>
    SpUtil.getString(SpKey.userBaseInfoDate) ?? '';

String get userBaseInfoPinyinValue =>
    SpUtil.getString(SpKey.userBaseInfoPinyin) ?? '';

String get userIdcardInfoAddressValue =>
    SpUtil.getString(SpKey.userIdcardInfoAddress) ?? '';

String get accountLinkCardValue =>
    SpUtil.getString(SpKey.accountLinkCard + AppConfig.config.abcLogic.phone()) ??
    '';


