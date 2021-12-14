///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-08 10:53
///
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openjmu/constants/constants.dart';
import 'package:provider/single_child_widget.dart';

export 'package:provider/provider.dart';

part 'courses_provider.dart';
part 'date_provider.dart';
part 'messages_provider.dart';
part 'notification_provider.dart';
part 'report_records_provider.dart';
part 'scores_provider.dart';
part 'settings_provider.dart';
part 'sign_provider.dart';
part 'team_post_provider.dart';
part 'themes_provider.dart';
part 'webapps_provider.dart';

ChangeNotifierProvider<T> buildProvider<T extends ChangeNotifier>(T value) {
  return ChangeNotifierProvider<T>.value(value: value);
}

List<SingleChildWidget> get providers => _providers;

final List<ChangeNotifierProvider<dynamic>> _providers =
    <ChangeNotifierProvider<dynamic>>[
  buildProvider<CoursesProvider>(CoursesProvider()),
  buildProvider<DateProvider>(DateProvider()),
  buildProvider<MessagesProvider>(MessagesProvider()),
  buildProvider<NotificationProvider>(NotificationProvider()),
  buildProvider<ReportRecordsProvider>(ReportRecordsProvider()),
  buildProvider<ScoresProvider>(ScoresProvider()),
  buildProvider<SettingsProvider>(SettingsProvider()),
  buildProvider<SignProvider>(SignProvider()),
  buildProvider<ThemesProvider>(ThemesProvider()),
  buildProvider<WebAppsProvider>(WebAppsProvider()),
];
