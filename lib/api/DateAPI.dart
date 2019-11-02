import 'package:OpenJMU/constants/Constants.dart';

class DateAPI {
  static DateTime startDate;
  static int currentWeek;
  static int difference;

  static Future getCurrentWeek() async => NetUtils.get(API.firstDayOfTerm);

  static const List<String> shortWeekdays = <String>[
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];
}
