const _loginTimeFallback = '开启财富管理之旅';

String formatLastLogin(String loginTime, {DateTime? now}) {
  final value = loginTime.trim();
  if (!RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')
      .hasMatch(value)) {
    return _loginTimeFallback;
  }

  final parsedLoginTime = DateTime.tryParse(value);
  final currentTime = now ?? DateTime.now();
  if (parsedLoginTime == null || parsedLoginTime.isAfter(currentTime)) {
    return _loginTimeFallback;
  }

  final difference = currentTime.difference(parsedLoginTime);
  if (difference <= const Duration(minutes: 3)) {
    return '上次登录 刚刚';
  }
  if (difference < const Duration(hours: 1)) {
    return '上次登录 ${difference.inMinutes}分钟前';
  }
  if (difference < const Duration(hours: 24)) {
    return '上次登录 ${difference.inHours}小时前';
  }
  return '上次登录 ${difference.inDays}天前';
}
