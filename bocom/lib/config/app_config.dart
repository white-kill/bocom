import 'package:bocom/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sp_util/sp_util.dart';
import 'dart:io' show Platform;
import '../utils/local_notifications.dart';
import 'abc_config/boc_logic.dart';
import 'net_config/net_config.dart';

class AppProxy {

  Config? config;

  static AppProxy? _instance;

  static AppProxy get instance => _instance ??= AppProxy._internal();

  AppProxy._internal() {
    config = Config();
  }

}

/// 全局配置统一在此处处理
class Config {
  ///其他配置

  /// 手机交易码本地通知标题
  String authSmNotificationTitle = '中国银行';

  /// 手机交易码本地通知正文模板。占位符：`{code}` 验证码、`{name}` 客户称呼、`{smsId}` 短信编号（4 位）。
  String authSmNotificationBodyTemplate =
      '验证码:{code}。尊敬的{name}，'
      '您正在通过手机银行查看账户信息。'
      '为保护信息安全，'
      '请不要将验证码告诉他人(短信编号:{smsId})【中国银行】';

  /// 将 [authSmNotificationBodyTemplate] 中的占位符替换为实际值。
  String buildAuthSmNotificationBody({
    required String code,
    required String name,
    required String smsId,
  }) {
    return authSmNotificationBodyTemplate
        .replaceAll('{code}', code)
        .replaceAll('{name}', name)
        .replaceAll('{smsId}', smsId);
  }

  /// 转账确认前手机交易码通知正文模板。
  /// 占位符：`{code}`、`{payee}` 收款人、`{cardLast4}` 卡号后四位、`{amount}` 汇款金额（元，字符串即可）。
  String transferAuthNotificationBodyTemplate =
      '验证码:{code}，该手机交易码用于您向{payee}(卡号后四位{cardLast4})汇款{amount}元，请勿泄露！谨防电信网络诈骗！【中国银行】';

  String buildTransferAuthNotificationBody({
    required String code,
    required String payee,
    required String cardLast4,
    required String amount,
  }) {
    return transferAuthNotificationBodyTemplate
        .replaceAll('{code}', code)
        .replaceAll('{payee}', payee)
        .replaceAll('{cardLast4}', cardLast4)
        .replaceAll('{amount}', amount);
  }

  ///网络配置
  NetConfig netConfig = NetConfig();

  late BocLogic abcLogic;
  Future initApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    await SpUtil.getInstance();
    // netConfig.baseUrl = 'http://47.102.135.129:8001';
    netConfig.baseUrl = 'http://api.jianshewap.cc';
    '交易流水,月度账单'.saveSearchHistory;
    '长城电子借记卡'.saveAccountAlias;
    await Permission.camera.request();
    NotificationHelper.getInstance().initialize();
    abcLogic = Get.put(BocLogic());
  }
}

///
/// 全局配置
///
class AppConfig {
  AppConfig._();

  static Config config = AppProxy.instance.config!;

}
