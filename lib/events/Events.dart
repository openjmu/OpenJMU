import 'package:OpenJMU/model/Bean.dart';
import 'package:flutter/material.dart';


class LoginEvent {}
class LogoutEvent {}
class LoginFailedEvent {}
class TicketGotEvent {}
class TicketFailedEvent {}

class UserInfoGotEvent {
  UserInfo currentUser;
  UserInfoGotEvent(UserInfo userInfo) {
    currentUser = userInfo;
  }
}

class NotificationCountChangeEvent {
  int notifications;

  NotificationCountChangeEvent(int count) {
    notifications = count;
  }
}

class ChangeThemeEvent {
  Color color;

  ChangeThemeEvent(Color c) {
    color = c;
  }
}

class ChangeBrightnessEvent {
  bool isDarkState;
  Brightness brightness;
  Color primaryColor;

  ChangeBrightnessEvent(bool isDark) {
    if (isDark) {
      isDarkState = true;
      brightness = Brightness.dark;
      primaryColor = Colors.grey[850];
    } else {
      isDarkState = false;
      brightness = Brightness.light;
      primaryColor = Colors.white;
    }
  }
}

class ScrollToTopEvent {
  int tabIndex;

  ScrollToTopEvent(int currentTabIndex) {
    tabIndex = currentTabIndex;
  }
}

class PostChangeEvent {
  Post post;
  bool remove;

  PostChangeEvent(this.post, [this.remove = false]);
}
