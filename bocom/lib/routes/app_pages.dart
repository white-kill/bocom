import 'package:get/get.dart';

import '../pages/index/index_view.dart';
import '../pages/login/login_view.dart';
import '../pages/other/search/search_view.dart';
import '../pages/splash/splash_view.dart';
import '../pages/tabs/home/transaction_detail/transaction_detail_view.dart';
import '../pages/tabs/home/feature_pages/home_feature_pages.dart';

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
    GetPage(
      name: Routes.transactionDetail,
      page: () => const TransactionDetailPage(),
    ),
    GetPage(
      name: Routes.homeCreditCard,
      page: () => const HomeCreditCardPage(),
    ),
    GetPage(
      name: Routes.homeSecurity,
      page: () => const HomeSecurityPage(),
    ),
    GetPage(
      name: Routes.homePaymentCode,
      page: () => const HomePaymentCodePage(),
    ),
  ];
}
