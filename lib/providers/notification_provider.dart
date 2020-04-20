///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-23 07:07
///
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class NotificationProvider extends ChangeNotifier {
  Notifications _notifications = Notifications();

  Notifications get notifications => _notifications;

  set notifications(Notifications notifications) {
    final shouldNotifyListeners = this.notifications != notifications;
    this.notifications
      ..at = notifications.at
      ..comment = notifications.comment
      ..praise = notifications.praise
      ..fans = notifications.fans;
    if (shouldNotifyListeners) notifyListeners();
  }

  TeamNotifications _teamNotifications = TeamNotifications();

  TeamNotifications get teamNotifications => _teamNotifications;

  set teamNotifications(TeamNotifications value) {
    _teamNotifications = value;
    notifyListeners();
  }

  bool get showNotification => notifications.total > 0;

  bool get showTeamNotification => teamNotifications.total > 0;

  int get initialIndex =>
      _notifications.comment > 0 ? 1 : (_notifications.at > 0 ? 2 : 0);

  int get teamInitialIndex {
    int index = 0;
    switch (teamNotifications.latestNotify) {
      case 'praise':
        index = 0;
        break;
      case 'reply':
        index = 1;
        break;
      case 'mention':
        index = 2;
        break;
    }
    return index;
  }

  Timer notificationTimer;

  void initNotification() {
    getNotification(null);
    notificationTimer = Timer.periodic(10.seconds, getNotification);
  }

  void stopNotification() {
    notificationTimer?.cancel();
    notificationTimer = null;
  }

  void getNotification(Timer _) {
    _getSquareNotification(_);
    _getTeamNotification(_);
  }

  void _getSquareNotification(Timer _) {
    UserAPI.getNotifications().then((Response<Map<String, dynamic>> response) {
      final Notifications notification = Notifications.fromJson(response.data);
      updateNotification(notification);
      if (_ == null) {
        trueDebugPrint('Updated notifications with :$notification');
      }
    }).catchError((dynamic e) {
      trueDebugPrint('Error when getting notification: $e');
    });
  }

  void _getTeamNotification(Timer _) {
    TeamPostAPI.getNotifications()
        .then((Response<Map<String, dynamic>> response) {
      final TeamNotifications notification =
          TeamNotifications.fromJson(response.data);
      updateTeamNotification(notification);
      if (_ == null) {
        trueDebugPrint('Updated team notifications with: $notification');
      }
    }).catchError((dynamic e) {
      trueDebugPrint('Error when getting team notification: $e');
    });
  }

  void updateNotification(Notifications notification) {
    final shouldNotifyListeners = this.notifications != notification;
    _notifications
      ..at = notification.at
      ..comment = notification.comment
      ..praise = notification.praise
      ..fans = notification.fans;
    if (shouldNotifyListeners && notificationTimer != null) {
      notifyListeners();
    }
  }

  void updateTeamNotification(TeamNotifications teamNotification) {
    final shouldNotifyListeners = this.teamNotifications != teamNotification;
    this.teamNotifications
      ..latestNotify = teamNotification.latestNotify
      ..mention = teamNotification.mention
      ..reply = teamNotification.reply
      ..praise = teamNotification.praise;
    if (shouldNotifyListeners && notificationTimer != null) {
      notifyListeners();
    }
  }

  void readMention() {
    notifications.at = 0;
    notifyListeners();
  }

  void readReply() {
    notifications.comment = 0;
    notifyListeners();
  }

  void readPraise() {
    notifications.praise = 0;
    notifyListeners();
  }

  void readFans() {
    notifications.fans = 0;
    notifyListeners();
  }

  void readTeamMention() {
    teamNotifications.mention = 0;
    teamNotifications.latestNotify = 'mention';
    notifyListeners();
  }

  void readTeamReply() {
    teamNotifications.reply = 0;
    teamNotifications.latestNotify = 'reply';
    notifyListeners();
  }

  void readTeamPraise() {
    teamNotifications.praise = 0;
    teamNotifications.latestNotify = 'praise';
    notifyListeners();
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    super.dispose();
  }
}
