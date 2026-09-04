import 'package:bocom/pages/tabs/mine/login_time_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 4, 12);

  test('shows just now within three minutes', () {
    expect(
      formatLastLogin('2026-09-04 11:57:00', now: now),
      '上次登录 刚刚',
    );
  });

  test('shows minutes when less than one hour ago', () {
    expect(
      formatLastLogin('2026-09-04 11:56:59', now: now),
      '上次登录 3分钟前',
    );
    expect(
      formatLastLogin('2026-09-04 11:00:01', now: now),
      '上次登录 59分钟前',
    );
  });

  test('shows hours when less than twenty four hours ago', () {
    expect(
      formatLastLogin('2026-09-04 11:00:00', now: now),
      '上次登录 1小时前',
    );
    expect(
      formatLastLogin('2026-09-03 12:00:01', now: now),
      '上次登录 23小时前',
    );
  });

  test('shows days from twenty four hours ago', () {
    expect(
      formatLastLogin('2026-09-03 12:00:00', now: now),
      '上次登录 1天前',
    );
    expect(
      formatLastLogin('2026-09-02 11:59:59', now: now),
      '上次登录 2天前',
    );
  });

  test('falls back when login time is empty invalid or in the future', () {
    expect(formatLastLogin('', now: now), '开启财富管理之旅');
    expect(formatLastLogin('invalid', now: now), '开启财富管理之旅');
    expect(
      formatLastLogin('2026-09-04 12:00:01', now: now),
      '开启财富管理之旅',
    );
  });
}
