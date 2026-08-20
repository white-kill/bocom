import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class PrintRecordState {
  final RefreshController refreshController = RefreshController();

  void dispose() => refreshController.dispose();
}
