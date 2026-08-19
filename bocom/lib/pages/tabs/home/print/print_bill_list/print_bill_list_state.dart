import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class PrintBillListState {
  final RefreshController refreshController = RefreshController();

  void dispose() => refreshController.dispose();
}
