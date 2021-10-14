///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-13 14:11
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:openjmu/constants/constants.dart' hide Message;

class NotificationUtils {
  const NotificationUtils._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static void initSettings() {
    const AndroidInitializationSettings _settingsAndroid =
        AndroidInitializationSettings('ic_stat_name');
    const IOSInitializationSettings _settingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: _onReceive,
    );
    const InitializationSettings _settings = InitializationSettings(
      android: _settingsAndroid,
      iOS: _settingsIOS,
    );
    NotificationUtils.plugin.initialize(
      _settings,
      onSelectNotification: _onSelect,
    );
  }

  static Future<void> show(String title, String body) async {
    final Color color = currentThemeColor;
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'openjmu_message_channel',
      '推送消息',
      channelDescription: '通知接收到的消息',
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      ticker: 'ticker',
    );
    const IOSNotificationDetails iOSDetails = IOSNotificationDetails();
    final NotificationDetails _details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    await NotificationUtils.plugin.show(0, title, body, _details);
  }

  static Future<void> showAppMessage(
    WebApp app,
    String body,
  ) async {
    final Color color = currentThemeColor;
    final WebAppIcon icon = WebAppIcon(app: app);
    final Person p = Person(
      name: app.name,
      key: app.appId.toString(),
      icon: await icon.exist
          ? FlutterBitmapAssetAndroidIcon(icon.iconPath)
          : null,
    );
    final List<Message> messages = <Message>[Message(body, DateTime.now(), p)];
    final MessagingStyleInformation messagingStyle = MessagingStyleInformation(
      p,
      conversationTitle: app.name,
      groupConversation: false,
      messages: messages,
    );
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'openjmu_message_channel',
      '推送消息',
      channelDescription: '通知接收到的消息',
      category: 'msg',
      color: color,
      importance: Importance.high,
      priority: Priority.high,
      ticker: app.name,
      styleInformation: messagingStyle,
    );
    final NotificationDetails _details = NotificationDetails(
      android: androidDetails,
      iOS: const IOSNotificationDetails(),
    );
    await NotificationUtils.plugin.show(0, app.name, body, _details);
  }

  static Future<void> cancelAll() {
    return NotificationUtils.plugin.cancelAll();
  }

  static Future<void> _onReceive(
    int id,
    String title,
    String body,
    String payload,
  ) async {}

  static Future<void> _onSelect(String payload) async {
    if (payload != null) {
      LogUtils.d('notification payload: ' + payload);
    }
  }
}
