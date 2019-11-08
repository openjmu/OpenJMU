///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 10:52
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';

class MessagesProvider with ChangeNotifier {
  Map<int, Map<int, List<Message>>> _appsMessages = {};
  Map<int, Map<int, List<Message>>> _personalMessages = {};

  Map<int, Map<int, List<Message>>> get appsMessages => _appsMessages;
  Map<int, Map<int, List<Message>>> get personalMessages => _personalMessages;

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
    print(event);
  }

  void _incomingPersonalMessage(MessageReceivedEvent event) {
    if (!_personalMessages.containsKey(UserAPI.currentUser.uid)) {
      _personalMessages[UserAPI.currentUser.uid] = Map<int, List<Message>>();
    }
    final _uMessages = _personalMessages[UserAPI.currentUser.uid];
    if (!_uMessages.containsKey(event.senderUid)) {
      _uMessages[event.senderUid] = <Message>[];
    }
    final message = Message.fromEvent(event);
    if (message.content['content'] != Messages.inputting) {
      _uMessages[event.senderUid].insert(0, Message.fromEvent(event));
      notifyListeners();
    }
  }
}
