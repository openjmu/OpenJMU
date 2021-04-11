import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:event_bus/event_bus.dart';

import '../pages/home/course_schedule_page.dart';
import '../pages/home/school_work_page.dart';
import '../pages/main_page.dart';
import 'constants.dart';

NavigatorState get navigatorState => Instances.navigatorKey.currentState;

BuildContext get currentContext => navigatorState.context;

ThemeData get currentTheme => Theme.of(currentContext);

ThemeGroup get currentThemeGroup =>
    currentContext.read<ThemesProvider>().currentThemeGroup;

Color get currentThemeColor => currentTheme.accentColor;

bool get currentIsDark => currentTheme.brightness == Brightness.dark;

T lessThanOne<T extends num>(T value) =>
    math.min((value is int ? 1 : 1.0) as T, value);

T lessThanZero<T extends num>(T value) =>
    math.min((value is int ? 0 : 0.0) as T, value);

T moreThanOne<T extends num>(T value) =>
    math.max((value is int ? 1 : 1.0) as T, value);

T moreThanZero<T extends num>(T value) =>
    math.max((value is int ? 0 : 0.0) as T, value);

T betweenZeroAndOne<T extends num>(T value) => moreThanZero(lessThanOne(value));

DateTime get currentTime => DateTime.now();

int get currentTimeStamp => currentTime.millisecondsSinceEpoch;

class Instances {
  const Instances._();

  static final EventBus eventBus = EventBus()
    ..on<dynamic>().listen((dynamic event) {
      LogUtils.d('Event fired: ${event.runtimeType}');
    });
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final RouteObserver<Route<dynamic>> routeObserver =
      RouteObserver<Route<dynamic>>();
  static AppLifecycleState appLifeCycleState = AppLifecycleState.resumed;
  static ConnectivityResult connectivityResult;

  static GlobalKey appRepaintBoundaryKey = GlobalKey();
  static GlobalKey<MainPageState> mainPageStateKey =
      GlobalKey<MainPageState>();
  static final GlobalKey<SchoolWorkPageState> schoolWorkPageStateKey =
      GlobalKey<SchoolWorkPageState>();
  static final GlobalKey<CourseSchedulePageState> courseSchedulePageStateKey =
      GlobalKey<CourseSchedulePageState>();

  static String defaultAvatarData;
}
