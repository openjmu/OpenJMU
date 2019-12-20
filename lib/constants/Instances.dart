import 'package:flutter/material.dart';
import 'package:event_bus/event_bus.dart';

NavigatorState get navigatorState => Instances.navigatorKey.currentState;
BuildContext get currentContext => navigatorState.context;
Color get currentThemeColor => Theme.of(currentContext).accentColor;

class Instances {
  static final EventBus eventBus = EventBus();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static AppLifecycleState appLifeCycleState = AppLifecycleState.resumed;
}
