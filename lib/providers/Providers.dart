///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 10:53
///
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:OpenJMU/constants/Constants.dart';

export 'package:provider/provider.dart';
export 'package:OpenJMU/providers/DateProvider.dart';
export 'package:OpenJMU/providers/MessagesProvider.dart';
export 'package:OpenJMU/providers/WebAppsProvider.dart';
export 'package:OpenJMU/providers/TeamPostProvider.dart';
export 'package:OpenJMU/providers/ThemesProvider.dart';
export 'package:OpenJMU/providers/NotificationProvider.dart';

ChangeNotifierProvider<T> buildProvider<T extends ChangeNotifier>(T value) {
  return ChangeNotifierProvider<T>.value(value: value);
}

List<SingleChildCloneableWidget> get providers => _providers;

final _providers = [
  buildProvider<DateProvider>(DateProvider()..initCurrentWeek()),
  buildProvider<MessagesProvider>(MessagesProvider()..initListener()),
  buildProvider<NotificationProvider>(NotificationProvider()),
  buildProvider<ThemesProvider>(ThemesProvider()..initTheme()),
  buildProvider<WebAppsProvider>(WebAppsProvider()),
];