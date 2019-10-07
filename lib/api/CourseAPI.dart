import 'dart:math';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:flutter/material.dart';

final _random = Random();

int next(int min, int max) => min + _random.nextInt(max - min);

class CourseAPI {
    static Future getCourse() async => NetUtils.get(
        API.courseScheduleCourses,
        data: {"sid": UserAPI.currentUser.sid},
    );

    static TimeOfDay _time(int hour, int minute) => TimeOfDay(hour: hour, minute: minute);
    static double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

    static Map<String, List<TimeOfDay>> courseTime = {
        "12": [_time(08, 00), _time(09, 35)],
        "34": [_time(10, 05), _time(11, 40)],
        "56": [_time(14, 00), _time(15, 35)],
        "78": [_time(15, 55), _time(17, 30)],
        "90": [_time(19, 00), _time(20, 45)],
        "11": [_time(20, 50), _time(21, 25)],
    };
    static Map<String, String> courseTimeChinese = {
        "12": "一二节",
        "34": "三四节",
        "56": "五六节",
        "78": "七八节",
        "90": "九十节",
        "11": "十一节",
    };

    static final List<Color> courseColors = [
        Color(0xff966c9c),
        Color(0xff4a7ba5),
        Color(0xff5a925c),
        Color(0xffab5f48),
        Color(0xffc39346),
        Color(0xffce5858),
    ];
    static Color randomCourseColor() => courseColors[next(0, courseColors.length)];
}