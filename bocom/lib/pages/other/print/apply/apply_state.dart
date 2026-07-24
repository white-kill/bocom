import 'package:bocom/pages/other/print/apply/req_print.dart';
import 'package:intl/intl.dart';
import 'package:bocom/pages/component/sheet_widget/picker_widget.dart';

class ApplyState {

  List titles= [
    '查询时段',
    '收支',
    '币种',
    '展示交易对方信息',
    '展示完整卡号/账号'
  ];

  ReqPrint reqPrint = ReqPrint();
  List showTypeList = [
    '0',
    '1'
  ];

  DateTimePickerNotifier pickerNotifier1 = DateTimePickerNotifier();
  DateTimePickerNotifier pickerNotifier2 = DateTimePickerNotifier();

  //  开始时间
  String temBeginTime1 = '';
  String beginTime = '';
  //结束时间
  String temEndTime1 = '';
  String endTime = '';

  ApplyState() {
    ///Initialize variables
    reqPrint.beginTime = getTimeRange('近1年').first;
    reqPrint.endTime = getTimeRange('近1年').last;
    beginTime = getTimeRange('近1年').first;
    endTime = getTimeRange('近1年').last;
    temBeginTime1 = getTimeRange('近1年').first;
    temEndTime1 = getTimeRange('近1年').last;
    reqPrint.currency = '全部';
  }

  List getTimeRange(String selectedTitle) {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (selectedTitle) {
      case '近3月':
        startDate = DateTime(now.year, now.month - 3, now.day + 1);
        break;
      case '近6月':
        startDate = DateTime(now.year, now.month - 6, now.day + 1);
        break;
      case '近1年':
        startDate = DateTime(now.year - 1, now.month, now.day + 1);
        break;
      default:
        startDate = now;
    }

    String formattedStart = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEnd = DateFormat('yyyy-MM-dd').format(now);

    return [
      formattedStart,
      formattedEnd,
    ];
  }

}
