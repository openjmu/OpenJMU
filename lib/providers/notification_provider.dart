///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-23 07:07
///
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

  bool get showNotification => notifications.total > 0 || teamNotifications.total > 0;

  int get initialIndex => _notifications.comment > 0 ? 1 : (_notifications.praise > 0 ? 2 : 0);
  int get teamInitialIndex {
    int index = 0;
    switch (teamNotifications.latestNotify) {
      case 'mention':
        index = 0;
        break;
      case 'reply':
        index = 1;
        break;
      case 'praise':
        index = 2;
        break;
    }
    return index;
  }

  void updateNotification(Notifications notification) {
    final shouldNotifyListeners = this.notifications != notification;
    _notifications
      ..at = notification.at
      ..comment = notification.comment
      ..praise = notification.praise
      ..fans = notification.fans;
    if (shouldNotifyListeners) notifyListeners();
  }

  void updateTeamNotification(TeamNotifications teamNotification) {
    final shouldNotifyListeners = this.teamNotifications != teamNotification;
    this.teamNotifications
      ..latestNotify = teamNotification.latestNotify
      ..mention = teamNotification.mention
      ..reply = teamNotification.reply
      ..praise = teamNotification.praise;
    if (shouldNotifyListeners) notifyListeners();
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
}
