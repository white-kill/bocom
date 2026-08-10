part of 'app_pages.dart';

class Routes {
  Routes._();

  static const tabs = '/tabs';

  static const login = '/login';

  static const splashPage = '/splashPage';

  static const search = '/search';

  static const transactionDetail = '/transactionDetail';

  static const homeCreditCard = '/homeCreditCard';

  static const homeSecurity = '/homeSecurity';

  static const homePaymentCode = '/homePaymentCode';

  static const homeTransfer = '/homeTransfer';

  static const homeAccountTransfer = '/homeAccountTransfer';

  static const searchHistoryPage = '/searchHistoryPage';
  static const searchListPage = '/searchListPage';
  static const confirmInfoPage = '/confirmInfoPage';

  static const transResultPage = '/transResultPage';
}

extension RoutesStringExtension on String {
  Future? get push => Get.toNamed(this);
}
