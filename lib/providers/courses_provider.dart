///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-14 16:22
///
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class CoursesProvider extends ChangeNotifier {
  final _courseBox = HiveBoxes.coursesBox;
  final _courseRemarkBox = HiveBoxes.courseRemarkBox;

  final maxCoursesPerDay = 12;

  DateTime _now;
  DateTime get now => _now;
  set now(DateTime value) {
    assert(value != null);
    if (value == _now) return;
    _now = value;
    notifyListeners();
  }

  Map<int, Map> _courses;
  Map<int, Map> get courses => _courses;
  set courses(Map<int, Map> value) {
    _courses = Map<int, Map>.from(value);
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
    _courses = _courseBox.get(currentUser.uid)?.cast<int, Map>();
    _remark = _courseRemarkBox.get(currentUser.uid);
    if (_courses == null) {
      _courses = resetCourses(_courses);
      updateCourses();
    } else {
      _courses.values.forEach((map) {
        map.cast<int, List>().values.cast<List>().forEach((list) {
          list.cast<Course>().forEach((course) {
            if (course.color == null) {
              Course.uniqueColor(course, CourseAPI.randomCourseColor());
            }
          });
        });
      });
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

  Map<int, Map> resetCourses(Map<int, Map> courses) {
    courses = {
      for (int i = 1; i < 7 + 1; i++)
        i: {
          for (int i = 1; i < maxCoursesPerDay + 1; i++) i: [],
        },
    };
    for (int key in courses.keys) {
      courses[key] = {
        for (int i = 1; i < maxCoursesPerDay + 1; i++) i: [],
      };
    }
    return courses;
  }

  Future updateCourses() async {
    final dateProvider = Provider.of<DateProvider>(currentContext, listen: false);
    if (dateProvider.currentWeek != null) {
      Instances.courseSchedulePageStateKey.currentState?.scrollToWeek(dateProvider.currentWeek);
    }
    if (showWeek) {
      showWeek = false;
      if (Instances.appsPageStateKey.currentState?.mounted ?? false) {
        // ignore: invalid_use_of_protected_member
        Instances.appsPageStateKey.currentState?.setState(() {});
      }
    }
    try {
      final responses = await Future.wait(<Future>[CourseAPI.getCourse(), CourseAPI.getRemark()]);
      await courseResponseHandler(responses[0]);
      await remarkResponseHandler(responses[1]);
      if (!_firstLoaded) {
        if (dateProvider.currentWeek != null) _firstLoaded = true;
      }
      if (_showError) _showError = false;
      Instances.courseSchedulePageStateKey.currentState?.updateScrollController();
      notifyListeners();

      // ignore: invalid_use_of_protected_member
      Instances.courseSchedulePageStateKey.currentState?.setState(() {});
    } catch (e) {
      debugPrint('Error when updating course: $e');
      if (!firstLoaded && dateProvider.currentWeek != null) _firstLoaded = true;
      _showError = true;
      notifyListeners();
    }
  }

  Future courseResponseHandler(response) async {
    final data = jsonDecode(response.data);
    final _courseList = data['courses'];
    final _customCourseList = data['othCase'];
    Map<int, Map> _s;
    _s = resetCourses(_s);
    if (_courseList.length == 0) {
      _hasCourses = false;
    }
    _courseList.forEach((course) {
      final _c = Course.fromJson(course);
      addCourse(_c, _s);
    });
    _customCourseList.forEach((course) {
      if (course['content'].trim().isNotEmpty) {
        final _c = Course.fromJson(course, isCustom: true);
        addCourse(_c, _s);
      }
    });
    if (_courses.toString() != _s.toString()) {
      _courses = _s;
      await _courseBox.put(currentUser.uid, Map.from(_s));
    }
  }

  Future remarkResponseHandler(response) async {
    final data = jsonDecode(response.data);
    String _r;
    if (data != null) _r = data['classScheduleRemark'];
    if (_remark != _r && _r != '' && _r != null) {
      _remark = _r;
      await _courseRemarkBox.put(currentUser.uid, _r);
    }
  }

  void addCourse(Course course, Map<int, Map> courses) {
    final courseDay = course.day;
    final courseTime = course.time.toInt();
    assert(courseDay != null && courseTime != null);
    try {
      courses[courseDay][courseTime].add(course);
    } catch (e) {
      debugPrint('Failed when trying to add course at day($courseDay) time($courseTime)');
      debugPrint('$course');
    }
  }

  Future setCourses(Map<int, Map> courses) async {
    await _courseBox.put(currentUser.uid, courses);
    _courses = Map<int, Map>.from(courses);
  }

  Future setRemark(String value) async {
    await _courseRemarkBox.put(currentUser.uid, value);
    _remark = value;
  }
}
