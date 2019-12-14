///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-13 14:11
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:OpenJMU/constants/Constants.dart';

class NotificationUtils {
  static final plugin = FlutterLocalNotificationsPlugin();

  static void initSettings() {
    final _settingsAndroid = AndroidInitializationSettings('ic_stat_name');
    final _settingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: _onReceive,
    );
    final _settings = InitializationSettings(_settingsAndroid, _settingsIOS);
    NotificationUtils.plugin.initialize(
      _settings,
      onSelectNotification: _onSelect,
    );
  }

  static Future show(String title, String body) async {
    final androidDetails = AndroidNotificationDetails(
      'openjmu_message_channel',
      '推送消息',
      '通知接收到的消息',
      importance: Importance.High,
      priority: Priority.High,
      color: ThemeUtils.defaultColor,
      style: AndroidNotificationStyle.Default,
      ticker: 'ticker',
    );
    final iOSDetails = IOSNotificationDetails();
    final _details = NotificationDetails(androidDetails, iOSDetails);
    await NotificationUtils.plugin.show(0, title, body, _details);
  }

  static Future cancelAll() async {
    await NotificationUtils.plugin.cancelAll();
  }

  static Future _onReceive(
    int id,
    String title,
    String body,
    String payload,
  ) async {}

  static Future _onSelect(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }
}
