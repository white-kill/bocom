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

  static const lifePayment = '/lifePayment';

  static const lifeMovie = '/lifeMovie';

  static const lifePartyFee = '/lifePartyFee';

  static const lifeVip = '/lifeVip';

  static const lifeSocialSecurity = '/lifeSocialSecurity';

  static const lifeRideCode = '/lifeRideCode';

  static const lifeCultureTourism = '/lifeCultureTourism';

  static const lifeCreditPoints = '/lifeCreditPoints';

  static const lifeTongcheng = '/lifeTongcheng';

  static const lifeSupermarket = '/lifeSupermarket';

  static const lifeBookstore = '/lifeBookstore';

  static const lifeJdZone = '/lifeJdZone';

  static const lifeAppliances = '/lifeAppliances';

  static const lifeTeaZone = '/lifeTeaZone';

  static const lifeNewEnergyPayment = '/lifeNewEnergyPayment';

  static const lifeFundCollection = '/lifeFundCollection';

  static const lifeCarbonGlory = '/lifeCarbonGlory';

  static const lifeMoreServices = '/lifeMoreServices';

  static const financeWealthIndex = '/financeWealthIndex';

  static const financeTradingStars = '/financeTradingStars';

  static const financePensionSeason = '/financePensionSeason';

  static const financeWealthForYou = '/financeWealthForYou';

  static const financeFlashNews = '/financeFlashNews';

  static const financeFlexibleInvestment = '/financeFlexibleInvestment';

  static const financeIndexZone = '/financeIndexZone';

  static const financeRecurringInvestment = '/financeRecurringInvestment';

  static const financeIndustryFund = '/financeIndustryFund';

  static const financeWealthSelection = '/financeWealthSelection';

  static const financeLoanRecommendation = '/financeLoanRecommendation';

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
