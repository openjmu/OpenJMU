import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:OpenJMU/constants/Constants.dart';

/// Event for testing.
class TestEvent {
  var content;
  TestEvent({content}) {
    this.content = content;
  }
}

class ConnectivityChangeEvent {
  ConnectivityResult type;
  ConnectivityChangeEvent(ConnectivityResult type) {
    this.type = type;
  }
}

class ActionsEvent {
  String type;
  ActionsEvent(String type) {
    this.type = type;
  }
}

//class LoginEvent {
//    bool isWizard;  // 账号是否已通过新人引导
//    LoginEvent(bool isWizard) {
//        this.isWizard = isWizard;
//    }
//}
class LogoutEvent {}

//class LoginFailedEvent {}
class TicketGotEvent {
  bool isWizard; // 账号是否已通过新人引导
  TicketGotEvent(bool isWizard) {
    this.isWizard = isWizard;
  }
}

class TicketFailedEvent {}

class PostForwardedEvent {
  int postId;
  int forwards;
  PostForwardedEvent(int id, int forwards) {
    this.postId = id;
    this.forwards = forwards;
  }
}

class PostForwardDeletedEvent {
  int postId;
  int forwards;
  PostForwardDeletedEvent(int id, int forwards) {
    this.postId = id;
    this.forwards = forwards;
  }
}

class PostCommentedEvent {
  int postId;
  PostCommentedEvent(int id) {
    this.postId = id;
  }
}

class PostCommentDeletedEvent {
  int postId;
  PostCommentDeletedEvent(int id) {
    this.postId = id;
  }
}

class PostPraisedEvent {
  int postId;
  PostPraisedEvent(int id) {
    this.postId = id;
  }
}

class PostUnPraisedEvent {
  int postId;
  PostUnPraisedEvent(int id) {
    this.postId = id;
  }
}

class PostDeletedEvent {
  int postId;
  String page;
  int index;
  PostDeletedEvent(int id, String page, int index) {
    this.postId = id;
    this.page = page;
    this.index = index;
  }
}

class ForwardInPostUpdatedEvent {
  int postId, count;
  ForwardInPostUpdatedEvent(int id, int length) {
    this.postId = id;
    this.count = length;
  }
}

class CommentInPostUpdatedEvent {
  int postId, count;
  CommentInPostUpdatedEvent(int id, int length) {
    this.postId = id;
    this.count = length;
  }
}

class PraiseInPostUpdatedEvent {
  int postId, count;
  String type;
  bool isLike;
  PraiseInPostUpdatedEvent({int id, String type, int count, bool isLike}) {
    this.postId = id;
    this.type = type;
    this.count = count;
    this.isLike = isLike;
  }
}

class AvatarUpdatedEvent {}

class SignatureUpdatedEvent {
  String signature;
  SignatureUpdatedEvent(String signature) {
    this.signature = signature;
  }
}

class AddEmoticonEvent {
  String emoticon;
  String route;
  AddEmoticonEvent(String emoticon, String route) {
    this.emoticon = emoticon;
    this.route = route;
  }
}

class HasUpdateEvent {
  String currentVersion;
  int currentBuild;
  Map<String, dynamic> response;
  HasUpdateEvent(
      String version, int buildNumber, Map<String, dynamic> response) {
    this.currentVersion = version;
    this.currentBuild = buildNumber;
    this.response = response;
  }
}

class OTAEvent {
  dynamic otaEvent;
  OTAEvent(dynamic _otaEvent) {
    this.otaEvent = _otaEvent;
  }
}

class UserInfoGotEvent {
  UserInfo currentUser;
  UserInfoGotEvent(UserInfo userInfo) {
    this.currentUser = userInfo;
  }
}

class BlacklistUpdateEvent {}

class NotificationsChangeEvent {
  Notifications notifications;

  NotificationsChangeEvent(Notifications notifications) {
    this.notifications = notifications;
  }
}

class ChangeThemeEvent {
  Color color;
  ChangeThemeEvent(Color color) {
    this.color = color;
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

class CurrentWeekUpdatedEvent {}

class AppCenterRefreshEvent {
  int currentIndex;

  AppCenterRefreshEvent(int currentIndex) {
    this.currentIndex = currentIndex;
  }
}

class AppCenterSettingsUpdateEvent {}

class ScoreRefreshEvent {}

class CourseScheduleRefreshEvent {}

class CoursePageShowWeekEvent {
  bool show;

  CoursePageShowWeekEvent(bool show) {
    this.show = show;
  }
}

/// Events for message
class MessageReceivedEvent {
  int type;
  int senderUid;
  String senderMultiPortId;
  DateTime sendTime;
  String ackId;
  Map<String, dynamic> content;

  MessageReceivedEvent({
    this.type,
    this.senderUid,
    this.senderMultiPortId,
    this.sendTime,
    this.ackId,
    this.content,
  });
}
