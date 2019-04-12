import 'package:OpenJMU/model/Bean.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

class LoginEvent {}
class LogoutEvent {}
class LoginFailedEvent {}
class TicketGotEvent {}
class TicketFailedEvent {}

class HasUpdateEvent {
  Map<String, dynamic> response;
  HasUpdateEvent(Map<String, dynamic> response) {
    this.response = response;
  }
}

class OTAEvent {
  OtaEvent otaEvent;
  OTAEvent(OtaEvent _otaEvent) {
    this.otaEvent = _otaEvent;
  }
}

class UserInfoGotEvent {
  UserInfo currentUser;
  UserInfoGotEvent(UserInfo userInfo) {
    this.currentUser = userInfo;
  }
}

class NotificationCountChangeEvent {
  int notifications;

  NotificationCountChangeEvent(int count) {
    this.notifications = count;
  }
}

class ChangeThemeEvent {
  Color color;

  ChangeThemeEvent(Color c) {
    this.color = c;
  }
}

class ChangeBrightnessEvent {
  bool isDarkState;
  Brightness brightness;
  Color primaryColor;

  ChangeBrightnessEvent(bool isDark) {
    if (isDark) {
      this.isDarkState = true;
      this.brightness = Brightness.dark;
      this.primaryColor = Colors.grey[850];
    } else {
      this.isDarkState = false;
      this.brightness = Brightness.light;
      this.primaryColor = Colors.white;
    }
  }
}

class ScrollToTopEvent {
  int tabIndex;
  String type;

  ScrollToTopEvent({int tabIndex, String type}) {
    this.tabIndex = tabIndex;
    this.type = type;
  }
}

class PostChangeEvent {
  Post post;
  bool remove;

  PostChangeEvent(this.post, [this.remove = false]);
}
