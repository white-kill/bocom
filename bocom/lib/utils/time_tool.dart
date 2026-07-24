import 'package:intl/intl.dart';

class DateRangeCalculator {
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  /// 计算近N个月的日期范围
  static Map<String, String> getRecentMonthRange(int months) {
    final DateTime now = DateTime.now();
    final DateTime endDate = DateTime(now.year, now.month, now.day);
    final DateTime startDate = _calculateStartDate(now, months);

    return {
      'start': _formatter.format(startDate),
      'end': _formatter.format(endDate),
    };
  }

  /// 计算开始日期（处理月末边界情况）
  static DateTime _calculateStartDate(DateTime endDate, int months) {
    int year = endDate.year;
    int month = endDate.month - months;
    int day = endDate.day;

    // 处理跨年情况
    while (month < 1) {
      year--;
      month += 12;
    }

    // 处理月末情况（如3月31日往前推1个月应该是2月28/29日）
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    day = day > daysInMonth ? daysInMonth : day;

    return DateTime(year, month, day);
  }

  /// 获取常用时间范围选项
  static Map<String, Map<String, String>> getCommonDateRanges() {
    final DateTime now = DateTime.now();
    return {
      '近1个月': getRecentMonthRange(1),
      '近3个月': getRecentMonthRange(3),
      '近6个月': getRecentMonthRange(6),
      '近12个月': getRecentMonthRange(12),
    };
  }
}



/// 验证时间范围工具类
class TimeRangeValidator {
  /// 验证开始时间是否不超过结束时间
  /// [startTime] 开始时间
  /// [endTime] 结束时间
  /// 返回 true 表示有效（开始时间 <= 结束时间），false 表示无效
  static bool isValidTimeRange(DateTime startTime, DateTime endTime) {
    return startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime);
  }

  /// 验证开始时间是否严格小于结束时间（不允许相等）
  /// [startTime] 开始时间
  /// [endTime] 结束时间
  /// 返回 true 表示有效（开始时间 < 结束时间），false 表示无效
  static bool isValidTimeRangeStrict(DateTime startTime, DateTime endTime) {
    return startTime.isBefore(endTime);
  }

  /// 获取验证结果和错误信息
  /// [startTime] 开始时间
  /// [endTime] 结束时间
  /// [allowSameTime] 是否允许开始和结束时间相同，默认为 true
  /// 返回 Map 包含 isValid 和 message
  static Map<String, dynamic> validateTimeRange({
    required DateTime startTime,
    required DateTime endTime,
    bool allowSameTime = true,
  }) {
    bool isValid;
    String message;

    if (allowSameTime) {
      isValid = isValidTimeRange(startTime, endTime);
      message = isValid
          ? '时间范围有效'
          : '开始时间不能晚于结束时间';
    } else {
      isValid = isValidTimeRangeStrict(startTime, endTime);
      message = isValid
          ? '时间范围有效'
          : '开始时间必须早于结束时间';
    }

    return {
      'isValid': isValid,
      'message': message,
    };
  }

  /// 快速验证方法 - 只返回布尔值
  /// [startTime] 开始时间
  /// [endTime] 结束时间
  /// [allowSameTime] 是否允许相同时间，默认为 true
  static bool checkTimeRange({
    required DateTime startTime,
    required DateTime endTime,
    bool allowSameTime = true,
  }) {
    return allowSameTime
        ? isValidTimeRange(startTime, endTime)
        : isValidTimeRangeStrict(startTime, endTime);
  }
}





class DateUtils1 {
  // 根据 yyyy-MM 格式的字符串，返回这个月的第一天和最后一天（不超过当天）
  static Map<String, DateTime> getFirstAndLastDayOfMonth(String yearMonth, {DateTime? currentDate}) {
    // 解析输入的年份和月份
    List<String> parts = yearMonth.split('-');
    if (parts.length != 2) {
      throw FormatException('格式错误，请输入 yyyy-MM 格式的字符串');
    }

    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);

    // 验证月份是否有效
    if (month < 1 || month > 12) {
      throw ArgumentError('月份必须在 1-12 之间');
    }

    // 使用传入的当前日期或系统当前日期
    DateTime now = currentDate ?? DateTime.now();

    // 获取当月的第一天
    DateTime firstDay = DateTime(year, month, 1);

    // 获取当月的最后一天
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    // 确保最后一天不超过当天
    DateTime lastDay = lastDayOfMonth.isAfter(now) ? now : lastDayOfMonth;

    // 确保最后一天不小于第一天（处理未来月份的情况）
    if (lastDay.isBefore(firstDay)) {
      lastDay = firstDay;
    }

    return {
      'firstDay': firstDay,
      'lastDay': lastDay,
    };
  }

  // 格式化输出 yyyy-MM-dd
  static Map<String, String> getFormattedFirstAndLastDay(String yearMonth, {DateTime? currentDate}) {
    final dates = getFirstAndLastDayOfMonth(yearMonth, currentDate: currentDate);

    return {
      'firstDay': DateFormat('yyyy-MM-dd').format(dates['firstDay']!),
      'lastDay': DateFormat('yyyy-MM-dd').format(dates['lastDay']!),
    };
  }
}
