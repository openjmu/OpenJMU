import 'dart:math';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

final _random = Random();

int next(int min, int max) => min + _random.nextInt(max - min);

class CourseAPI {
  static Set<Map<String, Color>> coursesColor = {};

  static Future getCourse() async => NetUtils.get(
        API.courseScheduleCourses,
        data: {"sid": UserAPI.currentUser.sid},
      );

  static Future getRemark() async => NetUtils.get(
        API.courseScheduleClassRemark,
        data: {"sid": UserAPI.currentUser.sid},
      );

  static String getCourseTime(int courseIndex) {
    final time = courseTime[courseIndex][0];
    final hour = time.hour.toString();
    final minute = '${time.minute < 10 ? '0' : ''}${time.minute}';
    return '$hour:$minute';
  }

  static Future setCustomCourse(Map<String, dynamic> course) async => NetUtils.post(
        "${API.courseScheduleCustom}?sid=${UserAPI.currentUser.sid}",
        data: course,
      );

  static TimeOfDay _time(int hour, int minute) => TimeOfDay(hour: hour, minute: minute);

  static bool inCurrentWeek(Course course, {int currentWeek}) {
    if (course.isCustom) return true;
    final provider = Provider.of<DateProvider>(currentContext, listen: false);
    final int week = currentWeek ?? provider.currentWeek;
    bool result;
    bool inRange = week >= course.startWeek && week <= course.endWeek;
    bool isOddEven = course.oddEven != 0;
    if (isOddEven) {
      if (course.oddEven == 1) {
        result = inRange && week.isOdd;
      } else if (course.oddEven == 2) {
        result = inRange && week.isEven;
      }
    } else {
      result = inRange;
    }
    return result;
  }

  static Map<int, List<TimeOfDay>> courseTime = {
    1: [_time(08, 00), _time(08, 45)],
    2: [_time(08, 50), _time(09, 35)],
    3: [_time(10, 05), _time(10, 50)],
    4: [_time(10, 55), _time(11, 40)],
    5: [_time(14, 00), _time(14, 45)],
    6: [_time(14, 50), _time(15, 35)],
    7: [_time(15, 55), _time(16, 40)],
    8: [_time(16, 45), _time(17, 30)],
    9: [_time(19, 00), _time(19, 45)],
    10: [_time(19, 50), _time(20, 35)],
    11: [_time(20, 40), _time(21, 25)],
    12: [_time(21, 30), _time(22, 15)],
  };

  static Map<String, String> courseTimeChinese = {
    "1": "一二节",
    "12": "一二节",
    "3": "三四节",
    "34": "三四节",
    "5": "五六节",
    "56": "五六节",
    "7": "七八节",
    "78": "七八节",
    "9": "九十节",
    "90": "九十节",
    "11": "十一节",
    "911": "九十十一节",
  };

  static final List<Color> courseColors = [
    Color(0xffEF9A9A),
    Color(0xffF48FB1),
    Color(0xffCE93D8),
    Color(0xffB39DDB),
    Color(0xff9FA8DA),
    Color(0xff90CAF9),
    Color(0xff81D4FA),
    Color(0xff80DEEA),
    Color(0xff80CBC4),
    Color(0xffA5D6A7),
    Color(0xffC5E1A5),
    Color(0xffE6EE9C),
    Color(0xffFFF59D),
    Color(0xffFFE082),
    Color(0xffFFCC80),
    Color(0xffFFAB91),
    Color(0xffBCAAA4),
    Color(0xffd8b5df),
    Color(0xff68c0ca),
    Color(0xff05bac3),
    Color(0xffe98b81),
    Color(0xffd86f5c),
    Color(0xfffed68e),
    Color(0xfff8b475),
    Color(0xffc16594),
    Color(0xffaccbd0),
    Color(0xffe6e5d1),
    Color(0xffe5f3a6),
    Color(0xfff6af9f),
    Color(0xfffb5320),
    Color(0xff20b1fb),
    Color(0xff3275a9),
  ];

  static Color randomCourseColor() => courseColors[next(0, courseColors.length)];
}
