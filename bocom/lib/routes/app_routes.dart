part of 'app_pages.dart';

class Routes {
  Routes._();

  static const tabs = '/tabs';

  static const login = '/login';

  static const splashPage = '/splashPage';

  static const search = '/search';

  static const searchHistoryPage = '/searchHistoryPage';
  static const searchListPage = '/searchListPage';
  static const confirmInfoPage = '/confirmInfoPage';

  static const transResultPage = '/transResultPage';
}

extension RoutesStringExtension on String {
  Future? get push => Get.toNamed(this);
}
