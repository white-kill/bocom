import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../../config/model/apply_record_model.dart';

class PrintRecordsState {
  int pageNum = 1;
  List<ApplyRecordList> list = [];
  ApplyRecordModel recordModel = ApplyRecordModel();
  RefreshController refreshController = RefreshController();
  List titles = [
    '申请时间',
    '日期区间',
    '申请邮箱',
    '打开密码'
  ];
  PrintRecordsState() {
    ///Initialize variables
  }
}
