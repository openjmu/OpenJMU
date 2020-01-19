///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 10:52
///
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class MessagesProvider with ChangeNotifier {
  Map<int, List> _appsMessages;
//  Map<int, List> _personalMessages;

  Map<int, List> get appsMessages => _appsMessages;
//  Map<int, List> get personalMessages => _personalMessages;

  int get unreadCount => appsMessages.values.fold(
      0,
      (initialValue, list) =>
          initialValue +
          list.cast<AppMessage>().fold(0, (init, message) => init + (message.read ? 0 : 1)));

  bool get hasMessages => _appsMessages.isNotEmpty
//          || _personalMessages[currentUser.uid].isNotEmpty
      ;

  void initMessages() {
    final appBox = HiveBoxes.appMessagesBox;
//    final personalBox = HiveBoxes.personalMessagesBox;

    if (!appBox.containsKey(currentUser.uid)) {
      appBox.put(currentUser.uid, Map<int, List>());
    }
//    if (!personalBox.containsKey(currentUser.uid)) {
//      personalBox.put(currentUser.uid, Map<int, List>());
//    }

    _appsMessages = appBox.get(currentUser.uid).cast<int, List>();
//    _personalMessages = personalBox.get(currentUser.uid).cast<int, List>();
  }

  void unloadMessages() {
    _appsMessages = null;
//    _personalMessages = null;
  }

  void initListener() {
    MessageUtils.messageListeners.add(incomingMessage);
  }

  void incomingMessage(MessageReceivedEvent event) {
    if (event.senderUid == 0) {
      _incomingAppsMessage(event);
    } else {
      _incomingPersonalMessage(event);
    }
  }

  void _incomingAppsMessage(MessageReceivedEvent event) {
    final message = AppMessage.fromEvent(event);
    String content = message.content;
    try {
      content = jsonDecode(content)['content'];
    } catch (e) {}
    if (content.trim().replaceAll("\n", "").replaceAll("\r", "").isNotEmpty && content != null) {
      final provider = Provider.of<WebAppsProvider>(currentContext, listen: false);
      debugPrint(provider.allApps.toString());
      debugPrint(message.toString());
      final app = provider.allApps.where((app) => app.id == message.appId).elementAt(0);

      if (!_appsMessages.containsKey(message.appId)) {
        _appsMessages[message.appId] = <AppMessage>[];
      }
      _appsMessages[message.appId].insert(0, message);
      final tempMessages = List.from(_appsMessages[message.appId]);
      _appsMessages.remove(message.appId);
      _appsMessages[message.appId] = List.from(tempMessages);
      saveAppsMessages();
      if (Instances.appLifeCycleState != AppLifecycleState.resumed) {
        NotificationUtils.show(
          app.name,
          content.trim().replaceAll("\n", "").replaceAll("\r", ""),
        );
      }
      if (message.messageId != null && message.messageId != 0) {
        MessageUtils.sendConfirmOfflineMessageOne(message.messageId);
      }
      if (message.ackId != null && message.ackId != 0) {
        MessageUtils.sendACKedMessageToOtherMultiPort(
          senderUid: 0,
          ackId: message.ackId,
        );
      }
      notifyListeners();
    }
  }

  void _incomingPersonalMessage(MessageReceivedEvent event) {
//    final message = Message.fromEvent(event);
//    if (!_personalMessages.containsKey(event.senderUid)) {
//      _personalMessages[event.senderUid] = <Message>[];
//    }
//    if (message.content['content'] != Messages.inputting) {
//      _personalMessages[event.senderUid].insert(0, message);
//      HiveBoxes.personalMessagesBox.put(currentUser.uid, _personalMessages);
//      if (message.messageId != null && message.messageId != 0) {
//        MessageUtils.sendConfirmOfflineMessageOne(message.messageId);
//      }
//      notifyListeners();
//    }
  }

//  void reduceUnreadMessageCount(int appId) {
//    int count = appMessagesUnreadCount[appId];
//    if (count != null) {
//      if (count > 0) {
//        count--;
//      }
//    } else {
//      count = 0;
//    }
//  }

  void deleteFromAppsMessages(int appId) {
    _appsMessages.remove(appId);
    saveAppsMessages();
    notifyListeners();
  }

  void saveAppsMessages() {
    HiveBoxes.appMessagesBox.put(currentUser.uid, Map.from(_appsMessages));
  }

//  void savePersonalMessage() {
//    HiveBoxes.personalMessagesBox.put(currentUser.uid, _personalMessages);
//  }
}
