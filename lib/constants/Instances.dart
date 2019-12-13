import 'package:flutter/material.dart';
import 'package:event_bus/event_bus.dart';

NavigatorState get navigatorState => Instances.navigatorKey.currentState;
ThemeData get currentTheme => Theme.of(navigatorState.context);

class Instances {
  static final EventBus eventBus = EventBus();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static AppLifecycleState appLifeCycleState = AppLifecycleState.resumed;
}
