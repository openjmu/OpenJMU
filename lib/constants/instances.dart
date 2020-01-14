import 'package:flutter/material.dart';
import 'package:event_bus/event_bus.dart';

NavigatorState get navigatorState => Instances.navigatorKey.currentState;
BuildContext get currentContext => navigatorState.context;
Brightness get currentBrightness => Theme.of(currentContext).brightness;
Color get currentThemeColor => Theme.of(currentContext).accentColor;
bool get currentIsDark => currentBrightness == Brightness.dark;

class Instances {
  static final EventBus eventBus = EventBus();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static AppLifecycleState appLifeCycleState = AppLifecycleState.resumed;
}
