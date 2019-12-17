///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-23 07:07
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';

class NotificationProvider extends ChangeNotifier {
  Notifications notification = Notifications();
  TeamNotifications teamNotification = TeamNotifications();

  bool get showNotification =>
      notification.total > 0 || teamNotification.total > 0;

  void updateNotification(
    Notifications notification,
    TeamNotifications teamNotification,
  ) {
    final shouldNotifyListeners = this.notification != notification &&
        this.teamNotification != teamNotification;
    this.notification
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
    notification.at = 0;
    notifyListeners();
  }

  void readReply() {
    notification.comment = 0;
    notifyListeners();
  }

  void readPraise() {
    notification.praise = 0;
    notifyListeners();
  }

  void readFans() {
    notification.fans = 0;
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
