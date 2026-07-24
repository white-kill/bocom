// ignore_for_file: constant_identifier_names
import 'package:intl/intl.dart';

enum DateTimeFormatType { Y, YM, YMD, YMDHM, YMDHMS, MDHM, HMS, HM }

extension DateTimeExtension on DateTime {
  /// 格式化时间输出
  String formatString({
    DateTimeFormatType? type = DateTimeFormatType.YMDHMS,
    DateSplitString? split,
  }) {
    split ??= DateSplitString.defaultFormat();

    String format;
    switch (type) {
      case DateTimeFormatType.Y:

        // 年份：yyyy年
        format = "yyyy${_clearLastCharacter(split.year)}";
        break;

      case DateTimeFormatType.YM:
        // 年月：yyyy年MM月
        format = "yyyy${split.year}MM${_clearLastCharacter(split.month)}";
        break;

      case DateTimeFormatType.YMD:
        // 年月日：yyyy年MM月dd日
        format = "yyyy${split.year}MM${split.month}dd${_clearLastCharacter(split.day)}";
        break;

      case DateTimeFormatType.YMDHM:
        // 年月日时分：yyyy年MM月dd日 HH:mm
        format = "yyyy${split.year}MM${split.month}dd${_clearLastCharacter(split.day)} HH${split.hour}mm${_clearLastCharacter(split.minute)}";
        break;

      case DateTimeFormatType.YMDHMS:
        // 年月日时分秒：yyyy年MM月dd日 HH:mm:ss
        format = "yyyy${split.year}MM${split.month}dd${_clearLastCharacter(split.day)} HH${split.hour}mm${split.minute}ss${_clearLastCharacter(split.seconds)}";
        break;

      case DateTimeFormatType.MDHM:
        // 月日时分：MM月dd日 HH:mm
        format = "MM${split.month}dd${_clearLastCharacter(split.day)} HH${split.hour}mm${_clearLastCharacter(split.minute)}";
        break;

      case DateTimeFormatType.HMS:
        // 时分秒：HH:mm:ss
        format = "HH${split.hour}mm${split.minute}ss${_clearLastCharacter(split.seconds)}";
        break;

      case DateTimeFormatType.HM:
        // 时分：HH:mm
        format = "HH${split.hour}mm${_clearLastCharacter(split.minute)}";
        break;

      default:
        // 默认：年月日时分秒
        format = "yyyy${split.year}MM${split.month}dd${_clearLastCharacter(split.day)} HH${split.hour}mm${split.minute}ss${_clearLastCharacter(split.seconds)}";
    }

    format = format.replaceAll(r"$", "");
    return DateFormat(format).format(this);
  }

  /// 清除最后一个字符
  _clearLastCharacter(String value) {
    if (value.endsWith(r"$")) {
      return value;
    }
    return "";
  }

  /// 转换成时间戳
  int toTimestamp() {
    return millisecondsSinceEpoch ~/ 1000;
  }

  /// 计算与目标时间的间隔，并转换为小时格式（向上取整）
  /// [targetTime] 目标时间，如果为null则使用当前时间
  /// 例如：距离目标时间还有1小时1分1秒 -> "2时"（向上取整为2小时）
  String toHoursTimeString({DateTime? targetTime}) {
    targetTime ??= DateTime.now();

    // 计算时间差（秒）
    int totalSeconds = difference(targetTime).inSeconds;

    if (totalSeconds <= 0) return '0小时';

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    // 如果有剩余的分钟或秒，小时数+1
    if (minutes > 0 || seconds > 0) {
      hours += 1;
    }

    return hours > 0 ? '$hours小时' : '0小时';
  }

  /// 计算与目标时间的间隔，并转换为分钟格式（向上取整）
  /// [targetTime] 目标时间，如果为null则使用当前时间
  /// 例如：距离目标时间还有1小时1分1秒 -> "1时2分"（1秒向上取整为1分钟）
  String toMinutesTimeString({DateTime? targetTime}) {
    targetTime ??= DateTime.now();

    // 计算时间差（秒）
    int totalSeconds = targetTime.difference(this).inSeconds;

    if (totalSeconds <= 0) return '0分';

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    // 如果有剩余的秒，分钟数+1
    if (seconds > 0) {
      minutes += 1;
    }

    String result = '';
    if (hours > 0) result += '$hours时';
    if (minutes > 0) result += '$minutes分';

    return result.isEmpty ? '0分' : result;
  }

  /// 计算与目标时间的间隔，并转换为秒格式（完整显示）
  /// [targetTime] 目标时间，如果为null则使用当前时间
  /// 例如：距离目标时间还有1小时1分1秒 -> "1时1分1秒"
  String toSecondsTimeString({DateTime? targetTime}) {
    targetTime ??= DateTime.now();

    // 计算时间差（秒）
    int totalSeconds = targetTime.difference(this).inSeconds;

    if (totalSeconds <= 0) return '0秒';

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String result = '';
    if (hours > 0) result += '$hours时';
    if (minutes > 0) result += '$minutes分';
    if (seconds > 0) result += '$seconds秒';

    return result.isEmpty ? '0秒' : result;
  }

  /// 根据情况格式化时间，
  /// 是本年，则不显示年份，
  /// 是今日，则不显示年月日，
  /// - `allowMinutesSituation` 是否在以一小时内就显示几分钟前
  String formatStringBySituation({bool allowMinutesSituation = false}) {
    final current = DateTime.now();
    if (current.year == year) {
      if (current.month == month) {
        if (current.day == day) {
          if (allowMinutesSituation) {
            final remainingSeconds = (current.toTimestamp() - toTimestamp()) ~/ 60;
            if (remainingSeconds < 60) {
              return remainingSeconds == 0 ? '刚刚' : '$remainingSeconds分钟前';
            }
          }
          return formatString(type: DateTimeFormatType.HM);
        }
      }
      return formatString(type: DateTimeFormatType.MDHM);
    }
    return formatString(type: DateTimeFormatType.YMDHM);
  }
}

/// 日期格式
class DateSplitString {
  final String year;
  final String month;
  final String day;
  final String hour;
  final String minute;
  final String seconds;

  /// 默认构造方法 - 年月日：：
  const DateSplitString({
    this.year = r'年$',
    this.month = r'月$',
    this.day = r'日$',
    this.hour = ':',
    this.minute = ':',
    this.seconds = '',
  });

  // 2025年08月08日 10:10:10 构造方法
  static DateSplitString defaultFormat() {
    return const DateSplitString();
  }

  // 2025年08月08日 10时10分10秒 构造方法
  static DateSplitString chineseFormat() {
    return const DateSplitString(hour: r"时$", minute: r"分$", seconds: r"秒$");
  }

  // 2025-08-08 10:10:10 构造方法
  static DateSplitString lineFormat() {
    return const DateSplitString(
      year: "-",
      month: "-",
      day: "-",
    );
  }

  // 2025.08.08 10:10:10 构造方法
  static DateSplitString dotFormat() {
    return const DateSplitString(
      year: ".",
      month: ".",
      day: ".",
    );
  }
}
