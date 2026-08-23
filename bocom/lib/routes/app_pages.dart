import 'package:get/get.dart';

import '../pages/index/index_view.dart';
import '../pages/login/login_view.dart';
import '../pages/other/customer_service/customer_service_view.dart';
import '../pages/other/search/search_view.dart';
import '../pages/other/scan/scan_view.dart';
import '../pages/splash/splash_view.dart';
import '../pages/tabs/home/transaction_detail/transaction_detail_view.dart';
import '../pages/tabs/home/print/print_view.dart';
import '../pages/tabs/home/feature_pages/home_feature_pages.dart';
import '../pages/tabs/home/feature_pages/home_static_feature_pages.dart';
import '../pages/tabs/home/all_services/all_services_view.dart';
import '../pages/tabs/home/transfer/home_transfer_view.dart';
import '../pages/tabs/home/transfer/account_transfer/home_account_transfer_view.dart';
import '../pages/tabs/home/transfer/record/transfer_record_view.dart';
import '../config/model/contacts_model.dart';

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
      page: () => const SearchPage(),
    ),
    GetPage(
      name: Routes.scan,
      page: () => const ScanPage(),
    ),
    GetPage(
      name: Routes.customerService,
      page: () => const CustomerServicePage(),
    ),
    GetPage(
      name: Routes.allServices,
      page: () => const AllServicesPage(),
    ),
    GetPage(
      name: Routes.homeConsumerLoan,
      page: () => const HomeConsumerLoanPage(),
    ),
    GetPage(
      name: Routes.homeDemandDepositPlus,
      page: () => const HomeDemandDepositPlusPage(),
    ),
    GetPage(
      name: Routes.homeCityZone,
      page: () => const HomeCityZonePage(),
    ),
    GetPage(
      name: Routes.homeNews,
      page: () => const HomeNewsPage(),
    ),
    GetPage(
      name: Routes.homeDeposit,
      page: () => const HomeDepositPage(),
    ),
    GetPage(
      name: Routes.homeCouponCenter,
      page: () => const HomeCouponCenterPage(),
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
    GetPage(
      name: Routes.homeTransfer,
      page: () => const HomeTransferPage(),
    ),
    GetPage(
      name: Routes.homeTransferRecord,
      page: () => const TransferRecordPage(),
    ),
    GetPage(
      name: Routes.printPage,
      page: () => PrintPage(),
    ),
    GetPage(
      name: Routes.homeAccountTransfer,
      page: () => HomeAccountTransferPage(
        initialRecipient: Get.arguments is ContactsModel
            ? Get.arguments as ContactsModel
            : null,
      ),
    ),
  ];
}
