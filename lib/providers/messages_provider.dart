///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-08 10:52
///
part of 'providers.dart';

class MessagesProvider with ChangeNotifier {
  MessagesProvider() {
    initListener();
  }

  Map<int, List<dynamic>> _appsMessages;
//  Map<int, List<dynamic>> _personalMessages;

  Map<int, List<dynamic>> get appsMessages => _appsMessages;
//  Map<int, List<dynamic>> get personalMessages => _personalMessages;

  int get unreadCount =>
      appsMessages?.values?.fold<int>(
          0,
          (int initialValue, List<dynamic> list) =>
              initialValue +
              list.cast<AppMessage>().fold<int>(
                  0,
                  (int init, AppMessage message) =>
                      init + (message.read ? 0 : 1))) ??
      0;

  bool get hasMessages => _appsMessages?.isNotEmpty
//          || _personalMessages[currentUser.uid]?.isNotEmpty
      ;

  Future<void> initMessages() async {
    final Box<Map<dynamic, dynamic>> appBox = HiveBoxes.appMessagesBox;
//    final personalBox = HiveBoxes.personalMessagesBox;

    if (!appBox.containsKey(currentUser.uid)) {
      await appBox.put(currentUser.uid, <int, List<AppMessage>>{});
    }
//    if (!personalBox.containsKey(currentUser.uid)) {
//      await personalBox.put(currentUser.uid, Map<int, List>());
//    }

    _appsMessages = appBox.get(currentUser.uid).cast<int, List<dynamic>>();
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
    if (event.senderUid == '0') {
      _incomingAppsMessage(event);
    } else {
      _incomingPersonalMessage(event);
    }
  }

  void _incomingAppsMessage(MessageReceivedEvent event) {
    final AppMessage message = AppMessage.fromEvent(event);
    String content = message.content;
    try {
      content = jsonDecode(content)['content'] as String;
    } catch (e) {
      LogUtils.d('Incoming message don\'t need to convert.');
    }
    if (content != null &&
        content.trim().replaceAll('\n', '').replaceAll('\r', '').isNotEmpty) {
      final WebAppsProvider provider =
          Provider.of<WebAppsProvider>(currentContext, listen: false);
      LogUtils.d(provider.allApps.toString());
      LogUtils.d(message.toString());
      final WebApp app = provider.allApps
          .where((WebApp app) => app.appId == message.appId)
          .elementAt(0);

      if (!_appsMessages.containsKey(message.appId)) {
        _appsMessages[message.appId] = <AppMessage>[];
      }
      _appsMessages[message.appId].insert(0, message);
      final List<dynamic> tempMessages =
          List<dynamic>.from(_appsMessages[message.appId]);
      _appsMessages.remove(message.appId);
      _appsMessages[message.appId] = List<dynamic>.from(tempMessages);
      saveAppsMessages();
      if (Instances.appLifeCycleState != AppLifecycleState.resumed) {
        NotificationUtils.show(
          app.name,
          content.trim().replaceAll('\n', '').replaceAll('\r', ''),
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
    HiveBoxes.appMessagesBox
        .put(currentUser.uid, Map<int, List<dynamic>>.from(_appsMessages));
  }

//  void savePersonalMessage() {
//    HiveBoxes.personalMessagesBox.put(currentUser.uid, _personalMessages);
//  }
}
