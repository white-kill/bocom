part of 'app_pages.dart';

class Routes {
  Routes._();

  static const tabs = '/tabs';

  static const login = '/login';

  static const splashPage = '/splashPage';

  static const search = '/search';

  static const scan = '/scan';

  static const customerService = '/customerService';

  static const allServices = '/allServices';

  static const homeConsumerLoan = '/homeConsumerLoan';

  static const homeDemandDepositPlus = '/homeDemandDepositPlus';

  static const homeCityZone = '/homeCityZone';

  static const homeNews = '/homeNews';

  static const homeDeposit = '/homeDeposit';

  static const homeCouponCenter = '/homeCouponCenter';

  static const homeActivityCenter = '/homeActivityCenter';

  static const homePreferredProducts = '/homePreferredProducts';

  static const homeWelfareSeason = '/homeWelfareSeason';

  static const homeOneStopCredit = '/homeOneStopCredit';

  static const homePensionZone = '/homePensionZone';

  static const homeSalaryZone = '/homeSalaryZone';

  static const accountFundsTransfer = '/accountFundsTransfer';

  static const accountLoss = '/accountLoss';

  static const accountMoreFunctions = '/accountMoreFunctions';

  static const accountApplication = '/accountApplication';

  static const accountActivation = '/accountActivation';

  static const accountUnbind = '/accountUnbind';

  static const accountSort = '/accountSort';

  static const accountFamilyPay = '/accountFamilyPay';

  static const transactionDetail = '/transactionDetail';

  static const homeCreditCard = '/homeCreditCard';

  static const homeSecurity = '/homeSecurity';

  static const homePaymentCode = '/homePaymentCode';

  static const homeTransfer = '/homeTransfer';

  static const homeTransferRecord = '/homeTransferRecord';

  static const homeAccountTransfer = '/homeAccountTransfer';

  static const homePhoneTransfer = '/homePhoneTransfer';

  static const searchHistoryPage = '/searchHistoryPage';
  static const searchListPage = '/searchListPage';
  static const confirmInfoPage = '/confirmInfoPage';

  static const transResultPage = '/transResultPage';

  static const printPage = '/printPage';
  static const ledgerPage = '/ledgerPage';
  static const comprehensiveBillPage = '/comprehensiveBillPage';
}

extension RoutesStringExtension on String {
  Future? get push => Get.toNamed(this);
}
