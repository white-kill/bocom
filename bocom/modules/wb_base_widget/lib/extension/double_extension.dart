
import 'package:intl/intl.dart';

extension BalanceExtension on double {
  String get bankBalance => NumberFormat("#,##0.00", "zh_CN").format(this);
}