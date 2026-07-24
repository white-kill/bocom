import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class NotificationHelper {
  static NotificationHelper? _instance;
  static NotificationHelper getInstance() {
    _instance ??= NotificationHelper._initial();
    return _instance!;
  }

  factory NotificationHelper() => _instance ??= NotificationHelper._initial();

  //创建命名构造函数
  NotificationHelper._initial() {
    initialize();
  }

  // FlutterLocalNotificationsPlugin实例
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final StreamController<NotificationResponse> selectNotificationStream = StreamController<NotificationResponse>.broadcast();
  // 常量定义
  static const String _channelId = 'message_notifications';
  static const String _channelName = 'message notification';
  static const String _channelDescription = 'Notifications for receiving new messages';
  static const String _ticker = 'ticker';
  static const String _darwinNotificationCategoryPlain = 'plainCategory';
  static const String darwinNotificationCategoryText = 'textCategory';
  int id = 0;
  bool _notificationsEnabled = false;

  // 初始化通知插件
  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(requestSoundPermission: false, requestBadgePermission: false, requestAlertPermission: false);
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: selectNotificationStream.add,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (e) {
      print('初始化通知插件失败: $e');
    }
  }

  initPermission() {
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureSelectNotificationSubject();
  }

  closeSubject() {
    selectNotificationStream.close();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted =
          await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ??
              false;
      _notificationsEnabled = granted;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission = await androidImplementation?.requestNotificationsPermission();
      _notificationsEnabled = grantedNotificationPermission ?? false;
    }
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((NotificationResponse? response) async {
      // await Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (BuildContext context) =>
      //       SecondPage(response?.payload, data: response?.data),
      // ));
      print("点击消息携带的数据$response");
    });
  }

  // 显示通知
  Future<void> showNotification({required String title, required String body, String payload = ""}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: _ticker,
    );
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(categoryIdentifier: _darwinNotificationCategoryPlain);
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
    await _notificationsPlugin.show(
      id++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// 取消全部通知
  cancelAll() {
    _notificationsPlugin.cancelAll();
  }

  /// 取消对应ID的通知
  cancelId(int id) {
    _notificationsPlugin.cancel(id);
  }
}