import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:wb_base_widget/state_widget/app_bar_widget.dart';

class HomeState {
  HomeState()
      : refreshController = RefreshController(),
        appBarController = AppBarController();

  final RefreshController refreshController;
  final AppBarController appBarController;

  void dispose() {
    refreshController.dispose();
    appBarController.dispose();
  }
}
