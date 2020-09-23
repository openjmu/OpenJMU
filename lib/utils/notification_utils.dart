///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-13 14:11
///
import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:openjmu/constants/constants.dart';

class NotificationUtils {
  const NotificationUtils._();

  static final plugin = FlutterLocalNotificationsPlugin();

  static void initSettings() {
    final _settingsAndroid = AndroidInitializationSettings('ic_stat_name');
    final _settingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: _onReceive,
    );
    final _settings = InitializationSettings(_settingsAndroid, _settingsIOS);
    NotificationUtils.plugin
        .initialize(_settings, onSelectNotification: _onSelect);
  }

  static Future show(String title, String body) async {
    final color = currentThemeColor;
    final androidDetails = AndroidNotificationDetails(
      'openjmu_message_channel',
      '推送消息',
      '通知接收到的消息',
      importance: Importance.High,
      priority: Priority.High,
      color: color,
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
      trueDebugPrint('notification payload: ' + payload);
    }
  }
}
