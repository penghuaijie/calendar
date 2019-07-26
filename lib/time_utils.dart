import 'package:flutter/material.dart';

class TimeUtil {
  /*
  * 每个月对应的天数
  * */
  static const List<int> _daysInMonth = <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  /*
  * 根据年月获取月的天数
  * */
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) return 29;
      return 28;
    }
    return _daysInMonth[month - 1];
  }

  /*
  * 得到这个月的第一天是星期几（0 是 星期日 1 是 星期一...）
  * */
  static int computeFirstDayOffset(
      int year, int month, MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  /// 获取天
  static List getDay(int year, int month, MaterialLocalizations localizations) {
    List labels = [];
    final int daysInMonth = getDaysInMonth(year, month);
    final int firstDayOffset =
        computeFirstDayOffset(year, month, localizations);
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        labels.add(0);
      } else {
        labels.add(DateTime(year, month, day));
      }
    }
    return labels;
  }

  /*
  * 每个月前面空出来的天数
  * */
  static int numberOfHeadPlaceholderForMonth(
      int year, int month, MaterialLocalizations localizations) {
    return computeFirstDayOffset(year, month, localizations);
  }

  /*
  * 根据当前年月份计算当前月份显示几行
  * */
  static int getRowsForMonthYear(int year, int month, MaterialLocalizations localizations){
    int currentMonthDays = getDaysInMonth(year, month);
    // 每个月前面空出来的天数
    int placeholderDays = numberOfHeadPlaceholderForMonth(year, month, localizations);
    int rows = (currentMonthDays + placeholderDays)~/7; // 向下取整
    int remainder = (currentMonthDays + placeholderDays)%7; // 取余（最后一行的天数）
    if (remainder > 0) {
      rows += 1;
    }
    return rows;
  }

  /*
  * 根据当前年月份计算每个月后面空出来的天数
  * */
  static int getLastRowDaysForMonthYear(int year, int month, MaterialLocalizations localizations){
    int count = 0;
    // 当前月份的天数
    int currentMonthDays = getDaysInMonth(year, month);
    // 每个月前面空出来的天数
    int placeholderDays = numberOfHeadPlaceholderForMonth(year, month, localizations);
    int rows = (currentMonthDays + placeholderDays)~/7; // 向下取整
    int remainder = (currentMonthDays + placeholderDays)%7; // 取余（最后一行的天数）
    if (remainder > 0) {
      count = 7-remainder;
    }
    return count;
  }
}
