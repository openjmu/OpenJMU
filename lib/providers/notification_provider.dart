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

  TeamNotifications teamNotification = TeamNotifications();

  bool get showNotification => notifications.total > 0 || teamNotification.total > 0;

  void updateNotification(
    Notifications notification,
    TeamNotifications teamNotification,
  ) {
    final shouldNotifyListeners =
        this.notifications != notification && this.teamNotification != teamNotification;
    this.notifications
      ..at = notification.at
      ..comment = notification.comment
      ..praise = notification.praise
      ..fans = notification.fans;
    this.teamNotification
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
    teamNotification.mention = 0;
    teamNotification.latestNotify = "mention";
    notifyListeners();
  }

  void readTeamReply() {
    teamNotification.reply = 0;
    teamNotification.latestNotify = "reply";
    notifyListeners();
  }

  void readTeamPraise() {
    teamNotification.praise = 0;
    teamNotification.latestNotify = "praise";
    notifyListeners();
  }
}
