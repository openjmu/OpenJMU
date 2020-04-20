///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-18 16:52
///
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class DateProvider extends ChangeNotifier {
  DateProvider() {
    initCurrentWeek();
  }

  DateTime _startDate;

  DateTime get startDate => _startDate;

  set startDate(DateTime value) {
    _startDate = value;
    notifyListeners();
  }

  Timer _updateCurrentWeekTimer;
  Timer _fetchCurrentWeekTimer;

  int _currentWeek = 0;

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

  Future<void> initCurrentWeek() async {
    final DateTime _dateInCache = HiveBoxes.startWeekBox.get('startDate');
    if (_dateInCache != null) {
      _startDate = _dateInCache;
    }
    await getCurrentWeek();
    initCurrentWeekTimer();
  }

  Future<void> updateStartDate(DateTime date) async {
    _startDate = date;
    await HiveBoxes.startWeekBox.put('startDate', date);
  }

  Future<void> getCurrentWeek() async {
    now = DateTime.now();
    final Box<DateTime> box = HiveBoxes.startWeekBox;
    try {
      DateTime _day;
      _day = box.get('startDate');
      if (_day == null) {
        final String result =
            (await NetUtils.get<String>(API.firstDayOfTerm)).data;
        _day = DateTime.parse(jsonDecode(result)['start'] as String);
      }
      if (_startDate == null) {
        unawaited(updateStartDate(_day));
      } else {
        if (_startDate != _day) {
          unawaited(updateStartDate(_day));
        }
      }

      final int _d = _startDate.difference(now).inDays;
      if (_difference != _d) {
        _difference = _d;
      }

      final int _w = -((_difference - 1) / 7).floor();
      if (_currentWeek != _w && _w <= 20) {
        _currentWeek = _w;
        notifyListeners();
        Instances.eventBus.fire(CurrentWeekUpdatedEvent());
      }
      _fetchCurrentWeekTimer?.cancel();
    } catch (e) {
      trueDebugPrint('Failed when fetching current week: $e');
      startFetchCurrentWeekTimer();
    }
  }

  void initCurrentWeekTimer() {
    _updateCurrentWeekTimer?.cancel();
    _updateCurrentWeekTimer = Timer.periodic(1.minutes, (_) {
      getCurrentWeek();
    });
  }

  void startFetchCurrentWeekTimer() {
    _fetchCurrentWeekTimer?.cancel();
    _fetchCurrentWeekTimer = Timer.periodic(30.seconds, (_) {
      getCurrentWeek();
    });
  }
}

const Map<int, String> shortWeekdays = <int, String>{
  1: '周一',
  2: '周二',
  3: '周三',
  4: '周四',
  5: '周五',
  6: '周六',
  7: '周日',
};
