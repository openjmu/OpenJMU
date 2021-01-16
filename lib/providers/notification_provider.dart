///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-23 07:07
///
part of 'providers.dart';

class NotificationProvider extends ChangeNotifier {
  Notifications _notifications = const Notifications();

  Notifications get notifications => _notifications;

  set notifications(Notifications value) {
    if (value == null) {
      return;
    }
    final bool shouldNotifyListeners = notifications != value;
    _notifications = Notifications(
      at: value.at,
      comment: value.comment,
      praise: value.praise,
      fans: value.fans,
    );
    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  TeamNotifications _teamNotifications = const TeamNotifications();

  TeamNotifications get teamNotifications => _teamNotifications;

  set teamNotifications(TeamNotifications value) {
    if (value == null) {
      return;
    }
    _teamNotifications = value;
    final bool shouldNotifyListeners = _teamNotifications != value;
    _teamNotifications = TeamNotifications(
      latestNotify: value.latestNotify,
      mention: value.mention,
      reply: value.reply,
      praise: value.praise,
    );
    if (shouldNotifyListeners) {
      notifyListeners();
    }
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
      notifications = notification;
      if (_ == null) {
        LogUtils.d('Updated notifications with :$notification');
      }
    }).catchError((dynamic e) {
      LogUtils.e('Error when getting notification: $e');
    });
  }

  void _getTeamNotification(Timer _) {
    TeamPostAPI.getNotifications().then(
      (Response<Map<String, dynamic>> response) {
        final TeamNotifications notification = TeamNotifications.fromJson(
          response.data,
        );
        teamNotifications = notification;
        if (_ == null) {
          LogUtils.d('Updated team notifications with: $notification');
        }
      },
    ).catchError((dynamic e) {
      LogUtils.e('Error when getting team notification: $e');
    });
  }

  void readMention() {
    notifications = notifications.copyWith(at: 0);
  }

  void readReply() {
    notifications = notifications.copyWith(comment: 0);
  }

  void readPraise() {
    notifications = notifications.copyWith(praise: 0);
  }

  void readFans() {
    notifications = notifications.copyWith(fans: 0);
  }

  void readTeamMention() {
    teamNotifications = teamNotifications.copyWith(
      mention: 0,
      latestNotify: 'mention',
    );
  }

  void readTeamReply() {
    teamNotifications = teamNotifications.copyWith(
      reply: 0,
      latestNotify: 'reply',
    );
  }

  void readTeamPraise() {
    teamNotifications = teamNotifications.copyWith(
      praise: 0,
      latestNotify: 'praise',
    );
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    super.dispose();
  }
}
