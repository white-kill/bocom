import 'package:get/get.dart';

import '../pages/index/index_view.dart';
import '../pages/login/login_view.dart';
import '../pages/other/search/search_view.dart';
import '../pages/splash/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.tabs,
      page: () => IndexPage(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: Routes.splashPage,
      page: () => SplashPage(),
    ),

    GetPage(
      name: Routes.search,
      page: () => SearchPage(),
    ),

  ];
}
