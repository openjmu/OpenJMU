///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-14 16:22
///
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class CoursesProvider extends ChangeNotifier {
  final Box<Map<dynamic, dynamic>> _courseBox = HiveBoxes.coursesBox;
  final Box<String> _courseRemarkBox = HiveBoxes.courseRemarkBox;

  final int maxCoursesPerDay = 12;

  DateTime _now;

  DateTime get now => _now;

  set now(DateTime value) {
    assert(value != null);
    if (value == _now) {
      return;
    }
    _now = value;
    notifyListeners();
  }

  Map<int, Map<dynamic, dynamic>> _courses;

  Map<int, Map<dynamic, dynamic>> get courses => _courses;

  set courses(Map<int, Map<dynamic, dynamic>> value) {
    _courses = <int, Map<dynamic, dynamic>>{...value};
    notifyListeners();
  }

  String _remark;

  String get remark => _remark;

  set remark(String value) {
    _remark = value;
    notifyListeners();
  }

  bool _firstLoaded = false;

  bool get firstLoaded => _firstLoaded;

  set firstLoaded(bool value) {
    _firstLoaded = value;
    notifyListeners();
  }

  bool _hasCourses = true;

  bool get hasCourses => _hasCourses;

  set hasCourses(bool value) {
    _hasCourses = value;
    notifyListeners();
  }

  bool _showWeek = false;

  bool get showWeek => _showWeek;

  set showWeek(bool value) {
    _showWeek = value;
    notifyListeners();
  }

  bool _showError = false;

  bool get showError => _showError;

  set showError(bool value) {
    _showError = value;
    notifyListeners();
  }

  void initCourses() {
    now = DateTime.now();
    _courses =
        _courseBox.get(currentUser.uid)?.cast<int, Map<dynamic, dynamic>>();
    _remark = _courseRemarkBox.get(currentUser.uid);
    if (_courses == null) {
      _courses = resetCourses(_courses);
      updateCourses();
    } else {
      for (final Map<dynamic, dynamic> _map in _courses.values) {
        final Map<int, List<dynamic>> map = _map.cast<int, List<dynamic>>();
        final List<List<dynamic>> lists =
            map.values?.toList()?.cast<List<dynamic>>();
        for (final List<dynamic> list in lists) {
          final List<Course> courses = list.cast<Course>();
          for (final Course course in courses) {
            if (course.color == null) {
              Course.uniqueColor(course, CourseAPI.randomCourseColor());
            }
          }
        }
      }
      firstLoaded = true;
    }
  }

  void unloadCourses() {
    _courses = null;
    _remark = null;
    _firstLoaded = false;
    _hasCourses = true;
    _showWeek = false;
    _showError = false;
    _now = null;
  }

  Map<int, Map<dynamic, dynamic>> resetCourses(
      Map<int, Map<dynamic, dynamic>> courses) {
    courses = <int, Map<dynamic, dynamic>>{
      for (int i = 1; i < 7 + 1; i++)
        i: <dynamic, dynamic>{
          for (int i = 1; i < maxCoursesPerDay + 1; i++) i: <dynamic>[],
        },
    };
    for (final int key in courses.keys) {
      courses[key] = <dynamic, dynamic>{
        for (int i = 1; i < maxCoursesPerDay + 1; i++) i: <dynamic>[],
      };
    }
    return courses;
  }

  Future<void> updateCourses() async {
    final DateProvider dateProvider =
        Provider.of<DateProvider>(currentContext, listen: false);
    if (dateProvider.currentWeek != null) {
      Instances.courseSchedulePageStateKey.currentState
          ?.scrollToWeek(dateProvider.currentWeek);
    }
    if (showWeek) {
      showWeek = false;
      if (Instances.appsPageStateKey.currentState?.mounted ?? false) {
        // ignore: invalid_use_of_protected_member
        Instances.appsPageStateKey.currentState?.setState(() {});
      }
    }
    try {
      final List<Response<String>> responses =
          await Future.wait<Response<String>>(
        <Future<Response<String>>>[
          CourseAPI.getCourse(),
          CourseAPI.getRemark(),
        ],
      );
      await courseResponseHandler(responses[0]);
      await remarkResponseHandler(responses[1]);
      if (!_firstLoaded) {
        if (dateProvider.currentWeek != null) {
          _firstLoaded = true;
        }
      }
      if (_showError) {
        _showError = false;
      }
      Instances.courseSchedulePageStateKey.currentState
          ?.updateScrollController();
      notifyListeners();

      // ignore: invalid_use_of_protected_member
      Instances.courseSchedulePageStateKey.currentState?.setState(() {});
    } catch (e) {
      trueDebugPrint('Error when updating course: $e');
      if (!firstLoaded && dateProvider.currentWeek != null) {
        _firstLoaded = true;
      }
      _showError = true;
      notifyListeners();
    }
  }

  Future<void> courseResponseHandler(Response<String> response) async {
    final Map<String, dynamic> data =
        jsonDecode(response.data) as Map<String, dynamic>;
    final List<dynamic> _courseList = data['courses'] as List<dynamic>;
    final List<dynamic> _customCourseList = data['othCase'] as List<dynamic>;
    Map<int, Map<dynamic, dynamic>> _s;
    _s = resetCourses(_s);
    _hasCourses = _courseList.isNotEmpty || _customCourseList.isNotEmpty;
    for (final dynamic course in _courseList) {
      final Course _c = Course.fromJson(course as Map<String, dynamic>);
      addCourse(_c, _s);
    }
    for (final dynamic _course in _customCourseList) {
      final Map<String, dynamic> course = _course as Map<String, dynamic>;
      if ((course['content'] as String)?.trim()?.isNotEmpty ?? false) {
        final Course _c = Course.fromJson(course, isCustom: true);
        addCourse(_c, _s);
      }
    }
    _courses = _s;
    await _courseBox.delete(currentUser.uid);
    await _courseBox.put(
        currentUser.uid, Map<int, Map<dynamic, dynamic>>.from(_s));
  }

  Future<void> remarkResponseHandler(Response<String> response) async {
    final Map<String, dynamic> data =
        jsonDecode(response.data) as Map<String, dynamic>;
    String _r;
    if (data != null) {
      _r = data['classScheduleRemark'] as String;
    }
    if (_r != null && _r != '') {
      _remark = _r;
      await _courseRemarkBox.delete(currentUser.uid);
      await _courseRemarkBox.put(currentUser.uid, _r);
    }
  }

  void addCourse(Course course, Map<int, Map<dynamic, dynamic>> courses) {
    final int courseDay = course.day;
    final int courseTime = course.time.toInt();
    assert(courseDay != null && courseTime != null);
    try {
      courses[courseDay][courseTime].add(course);
    } catch (e) {
      trueDebugPrint(
          'Failed when trying to add course at day($courseDay) time($courseTime)');
      trueDebugPrint('$course');
    }
  }

  Future<void> setCourses(Map<int, Map<dynamic, dynamic>> courses) async {
    await _courseBox.put(currentUser.uid, courses);
    _courses = Map<int, Map<dynamic, dynamic>>.from(courses);
  }

  Future<void> setRemark(String value) async {
    await _courseRemarkBox.put(currentUser.uid, value);
    _remark = value;
  }
}
