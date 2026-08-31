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
import '../pages/tabs/home/transfer/phone_transfer/home_phone_transfer_view.dart';
import '../pages/tabs/home/transfer/record/transfer_record_view.dart';
import '../pages/tabs/mine/children/ledger/ledger_view.dart';
import '../pages/tabs/mine/children/comprehensive_bill/comprehensive_bill_view.dart';
import '../pages/tabs/mine/children/account_asset/account_secondary_pages.dart';
import '../pages/tabs/life/life_secondary_pages.dart';
import '../pages/tabs/‌finance‌/finance_secondary_pages.dart';
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
      name: Routes.homeActivityCenter,
      page: () => const HomeActivityCenterPage(),
    ),
    GetPage(
      name: Routes.homePreferredProducts,
      page: () => const HomePreferredProductsPage(),
    ),
    GetPage(
      name: Routes.homeWelfareSeason,
      page: () => const HomeWelfareSeasonPage(),
    ),
    GetPage(
      name: Routes.homeOneStopCredit,
      page: () => const HomeOneStopCreditPage(),
    ),
    GetPage(
      name: Routes.homePensionZone,
      page: () => const HomePensionZonePage(),
    ),
    GetPage(
      name: Routes.homeSalaryZone,
      page: () => const HomeSalaryZonePage(),
    ),
    GetPage(
      name: Routes.accountFundsTransfer,
      page: () => const AccountFundsTransferPage(),
    ),
    GetPage(
      name: Routes.accountLoss,
      page: () => const AccountLossPage(),
    ),
    GetPage(
      name: Routes.accountMoreFunctions,
      page: () => const AccountMoreFunctionsPage(),
    ),
    GetPage(
      name: Routes.accountApplication,
      page: () => const AccountApplicationPage(),
    ),
    GetPage(
      name: Routes.accountActivation,
      page: () => const AccountActivationPage(),
    ),
    GetPage(
      name: Routes.accountUnbind,
      page: () => const AccountUnbindPage(),
    ),
    GetPage(
      name: Routes.accountSort,
      page: () => const AccountSortPage(),
    ),
    GetPage(
      name: Routes.accountFamilyPay,
      page: () => const AccountFamilyPayPage(),
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
      name: Routes.ledgerPage,
      page: () => LedgerPage(),
    ),
    GetPage(
      name: Routes.comprehensiveBillPage,
      page: () => ComprehensiveBillPage(),
    ),
    GetPage(
      name: Routes.homeAccountTransfer,
      page: () {
        final arguments = Get.arguments;
        if (arguments is AccountTransferRouteArguments) {
          return HomeAccountTransferPage(
            initialRecipient: arguments.recipient,
            entryMode: arguments.mode,
          );
        }
        return HomeAccountTransferPage(
          initialRecipient: arguments is ContactsModel ? arguments : null,
        );
      },
    ),
    GetPage(
      name: Routes.homePhoneTransfer,
      page: () => const HomePhoneTransferPage(),
    ),
    GetPage(
      name: Routes.lifePayment,
      page: () => const LifePaymentPage(),
    ),
    GetPage(
      name: Routes.lifeMovie,
      page: () => const LifeMoviePage(),
    ),
    GetPage(
      name: Routes.lifePartyFee,
      page: () => const LifePartyFeePage(),
    ),
    GetPage(
      name: Routes.lifeVip,
      page: () => const LifeVipPage(),
    ),
    GetPage(
      name: Routes.lifeSocialSecurity,
      page: () => const LifeSocialSecurityPage(),
    ),
    GetPage(
      name: Routes.lifeRideCode,
      page: () => const LifeRideCodePage(),
    ),
    GetPage(
      name: Routes.lifeCultureTourism,
      page: () => const LifeCultureTourismPage(),
    ),
    GetPage(
      name: Routes.lifeCreditPoints,
      page: () => const LifeCreditPointsPage(),
    ),
    GetPage(
      name: Routes.lifeTongcheng,
      page: () => const LifeTongchengPage(),
    ),
    GetPage(
      name: Routes.lifeSupermarket,
      page: () => const LifeSupermarketPage(),
    ),
    GetPage(
      name: Routes.lifeBookstore,
      page: () => const LifeBookstorePage(),
    ),
    GetPage(
      name: Routes.lifeJdZone,
      page: () => const LifeJdZonePage(),
    ),
    GetPage(
      name: Routes.lifeAppliances,
      page: () => const LifeAppliancesPage(),
    ),
    GetPage(
      name: Routes.lifeTeaZone,
      page: () => const LifeTeaZonePage(),
    ),
    GetPage(
      name: Routes.lifeNewEnergyPayment,
      page: () => const LifeNewEnergyPaymentPage(),
    ),
    GetPage(
      name: Routes.lifeFundCollection,
      page: () => const LifeFundCollectionPage(),
    ),
    GetPage(
      name: Routes.lifeCarbonGlory,
      page: () => const LifeCarbonGloryPage(),
    ),
    GetPage(
      name: Routes.lifeMoreServices,
      page: () => const LifeMoreServicesPage(),
    ),
    GetPage(
      name: Routes.financeWealthIndex,
      page: () => const FinanceWealthIndexPage(),
    ),
    GetPage(
      name: Routes.financeTradingStars,
      page: () => const FinanceTradingStarsPage(),
    ),
    GetPage(
      name: Routes.financePensionSeason,
      page: () => const FinancePensionSeasonPage(),
    ),
    GetPage(
      name: Routes.financeWealthForYou,
      page: () => const FinanceWealthForYouPage(),
    ),
    GetPage(
      name: Routes.financeFlashNews,
      page: () => const FinanceFlashNewsPage(),
    ),
    GetPage(
      name: Routes.financeFlexibleInvestment,
      page: () => const FinanceFlexibleInvestmentPage(),
    ),
    GetPage(
      name: Routes.financeIndexZone,
      page: () => const FinanceIndexZonePage(),
    ),
    GetPage(
      name: Routes.financeRecurringInvestment,
      page: () => const FinanceRecurringInvestmentPage(),
    ),
    GetPage(
      name: Routes.financeIndustryFund,
      page: () => const FinanceIndustryFundPage(),
    ),
    GetPage(
      name: Routes.financeWealthSelection,
      page: () => const FinanceWealthSelectionPage(),
    ),
    GetPage(
      name: Routes.financeLoanRecommendation,
      page: () => const FinanceLoanRecommendationPage(),
    ),
  ];
}
