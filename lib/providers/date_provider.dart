///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-18 16:52
///
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class DateProvider extends ChangeNotifier {
  DateTime _startDate;
  DateTime get startDate => _startDate;
  set startDate(DateTime value) {
    _startDate = value;
    notifyListeners();
  }

  Timer _updateCurrentWeekTimer;

  int _currentWeek;
  int get currentWeek => _currentWeek;
  set currentWeek(int value) {
    _currentWeek = value;
    notifyListeners();
  }

  int _difference;
  int get difference => _difference;
  set difference(int value) {
    _difference = value;
    notifyListeners();
  }

  void initCurrentWeek() async {
    final _dateInCache = HiveBoxes.startWeekBox.get("startDate");
    if (_dateInCache != null) _startDate = _dateInCache;
    await getCurrentWeek(init: _dateInCache == null);
    initCurrentWeekTimer();
  }

  Future updateStartDate(DateTime date) async {
    _startDate = date;
    await HiveBoxes.startWeekBox.put("startDate", date);
  }

  Future getCurrentWeek({bool init = false, bool remote = false}) async {
    final now = DateTime.now();
    final box = HiveBoxes.startWeekBox;
    try {
      DateTime _day;
      if (init) {
        final result = (await NetUtils.get(API.firstDayOfTerm)).data;
        _day = DateTime.parse(jsonDecode(result)['start']);
      } else {
        _day = box.get("startDate");
      }
      if (_startDate == null) {
        updateStartDate(_day);
      } else {
        if (_startDate != _day) updateStartDate(_day);
      }

      final _d = startDate.difference(now).inDays - 1;
      if (_difference != _d) _difference = _d;

      final _w = -(_difference / 7).floor();
      if (_currentWeek != _w) {
        if (_w <= 20) {
          _currentWeek = _w;
        } else {
          _currentWeek = null;
        }
        notifyListeners();
        Instances.eventBus.fire(CurrentWeekUpdatedEvent());
      }
    } catch (e) {}
  }

  void initCurrentWeekTimer() {
    if (_updateCurrentWeekTimer == null) {
      _updateCurrentWeekTimer = Timer.periodic(
        const Duration(minutes: 1),
        (timer) {
          getCurrentWeek();
        },
      );
    }
  }
}

const List<String> shortWeekdays = <String>[
  '周一',
  '周二',
  '周三',
  '周四',
  '周五',
  '周六',
  '周日',
];
