import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:bocom/config/model/bill_item_model.dart';

class LedgerState {
  LedgerState();

  RefreshController? _overviewRefreshController;
  RefreshController? _waterRefreshController;

  RefreshController get overviewRefreshController =>
      _overviewRefreshController ??= RefreshController();

  RefreshController get waterRefreshController =>
      _waterRefreshController ??= RefreshController();

  List<BillItemList>? _dataList;

  List<BillItemList> get dataList => _dataList ??= _buildMockBillItems();

  void dispose() {
    _overviewRefreshController?.dispose();
    _overviewRefreshController = null;
    _waterRefreshController?.dispose();
    _waterRefreshController = null;
  }

  List<BillItemList> _buildMockBillItems() {
    return [
      _billItem(
        id: 1,
        month: '05',
        day: '05.26',
        week: '周五',
        incomeTotal: '0.00',
        expensesTotal: '3,330.28',
        title: '跨行汇款-杨路',
        amount: '3500.00',
        type: '1',
        time: '5-26 16:01',
        card: '借记卡(**2037)',
        billType: '不计入',
      ),
      _billItem(
        id: 2,
        title: '餐饮消费',
        amount: '128.00',
        type: '2',
        time: '5-26 12:35',
        card: '借记卡(**2037)',
      ),
      _billItem(
        id: 3,
        day: '05.25',
        week: '周四',
        incomeTotal: '500.00',
        expensesTotal: '45.80',
        title: '工资收入',
        amount: '500.00',
        type: '1',
        time: '5-25 09:20',
        card: '借记卡(**2037)',
      ),
      _billItem(
        id: 4,
        title: '便利店消费',
        amount: '45.80',
        type: '2',
        time: '5-25 08:15',
        card: '借记卡(**2037)',
      ),
    ];
  }

  BillItemList _billItem({
    required int id,
    String month = '',
    String day = '',
    String week = '',
    String incomeTotal = '',
    String expensesTotal = '',
    required String title,
    required String amount,
    required String type,
    required String time,
    required String card,
    String billType = '',
  }) {
    final detail = BillItemListBillDetail()
      ..oppositeName = title
      ..bankCard = card
      ..transactionTime = time
      ..billType = billType;

    return BillItemList()
      ..id = id
      ..month = month
      ..day = day
      ..week = week
      ..incomeTotal = incomeTotal
      ..expensesTotal = expensesTotal
      ..oppositeName = title
      ..amount = amount
      ..type = type
      ..transactionTime = time
      ..billDetail = detail;
  }
}
