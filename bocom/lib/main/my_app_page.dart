import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/extension/widget_extension.dart';

import '../config/app_config.dart';
import '../main/app_plugin.dart';
import '../routes/app_pages.dart';
import '../utils/sp_util.dart';

class MyApp extends GetMaterialApp {
  const MyApp({
    super.key,
    super.transitionDuration = const Duration(milliseconds: 240),
  });

  ///代理设置
  @override
  Iterable<LocalizationsDelegate> get localizationsDelegates => [
        RefreshLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  @override
  Iterable<Locale> get supportedLocales => [
        const Locale('en'),
        const Locale('zh'),
      ];

  @override
  GlobalKey<NavigatorState>? get navigatorKey =>
      AppConfig.config.abcLogic.navigatorKey;

  @override
  List<NavigatorObserver>? get navigatorObservers =>
      [FlutterSmartDialog.observer];

  @override
  Transition? get defaultTransition =>
      GetPlatform.isAndroid ? Transition.fadeIn : Transition.native;

  @override
  ThemeData get theme => ThemeData(
        splashColor: Colors.transparent,
        // 点击时的高亮效果设置为透明
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
        ),
        useMaterial3: false,
      );

  @override
  TransitionBuilder? get builder => FlutterSmartDialog.init(
        builder: (context, child) => appBuilder(context, child),
      );

  // @override
  // String? get initialRoute => token.isNullOrEmpty ? Routes.login : Routes.tabs;

  @override
  String? get initialRoute => Routes.splashPage;

  @override
  List<GetPage>? get getPages => AppPages.routes;
}
