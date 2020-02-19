import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/home/apps_page.dart';
import 'package:openjmu/pages/home/message_page.dart';
import 'package:openjmu/pages/home/my_info_page.dart';
import 'package:openjmu/pages/home/post_square_list_page.dart';
import 'package:openjmu/widgets/fab_bottom_appbar.dart';
import 'package:openjmu/widgets/announcement/announcement_widget.dart';

@FFRoute(
  name: "openjmu://home",
  routeName: "首页",
  argumentNames: ["initAction"],
)
class MainPage extends StatefulWidget {
  final int initAction;

  const MainPage({
    Key key,
    this.initAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
  static const pagesTitle = <String>['广场', '应用', '消息'];
  static const pagesIcon = <String>['square', 'apps', 'messages'];
  static const bottomBarHeight = 72.0;
  double get bottomBarIconSize => bottomBarHeight / 1.9;

  static TextStyle get tabSelectedTextStyle => TextStyle(
        fontSize: suSetSp(23.0),
        fontWeight: FontWeight.bold,
        textBaseline: TextBaseline.alphabetic,
      );
  static TextStyle get tabUnselectedTextStyle => TextStyle(
        fontSize: suSetSp(23.0),
        fontWeight: FontWeight.w300,
        textBaseline: TextBaseline.alphabetic,
      );

  Timer notificationTimer;

  int _tabIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint('CurrentUser ${UserAPI.currentUser}');

    _tabIndex = widget.initAction ??
        Provider.of<SettingsProvider>(currentContext, listen: false).homeSplashIndex;

    initPushService();
    initNotification();
    MessageUtils.initMessageSocket();

    Instances.eventBus
      ..on<ActionsEvent>().listen((event) {
        final index = Constants.quickActionsList.keys.toList().indexOf(event.type);
        if (index != -1) {
          _selectedTab(index);
          if (mounted) setState(() {});
        }
      });
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    super.dispose();
  }

  void initPushService() {
    try {
      final data = <String, dynamic>{
        'token': DeviceUtils.devicePushToken,
        'date': DateFormat('yyyy/MM/dd HH:mm:ss', 'en').format(DateTime.now()),
        'uid': '${currentUser.uid}',
        'name': '${currentUser.name ?? currentUser.uid}',
        'workid': '${currentUser.workId ?? currentUser.uid}',
        'buildnumber': OTAUtils.buildNumber,
        'uuid': DeviceUtils.deviceUuid,
        'platform': Platform.isIOS ? 'ios' : 'android',
      };
      debugPrint('Push data: $data');
      NetUtils.post(API.pushUpload, data: data).then((response) {
        debugPrint('Push service info upload success.');
      }).catchError((e) {
        debugPrint('Push service upload error: $e');
      });
    } catch (e) {
      debugPrint('Push service init error: $e');
    }
  }

  void initNotification() {
    _getNotification(null);
    notificationTimer = Timer.periodic(10.seconds, _getNotification);
  }

  void _getNotification(_) {
    final provider = Provider.of<NotificationProvider>(currentContext, listen: false);
    UserAPI.getNotifications().then((response) {
      final notification = Notifications.fromJson(response.data);
      provider.updateNotification(notification);
      if (_ == null) debugPrint('Updated notifications with :$notification');
    }).catchError((e) {
      debugPrint('Error when getting notification: $e');
    });
    TeamPostAPI.getNotifications().then((response) {
      final notification = TeamNotifications.fromJson(response.data);
      provider.updateTeamNotification(notification);
      if (_ == null) debugPrint('Updated team notifications with: $notification');
    }).catchError((e) {
      debugPrint('Error when getting team notification: $e');
    });
  }

  void _selectedTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  int lastBack = 0;
  Future<bool> doubleBackExit() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 800) {
      showToast('再按一次退出应用');
      lastBack = DateTime.now().millisecondsSinceEpoch;
    } else {
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Selector<SettingsProvider, bool>(
                selector: (_, provider) => provider.announcementsUserEnabled,
                builder: (_, announcementsUserEnabled, __) {
                  if (announcementsUserEnabled) {
                    return AnnouncementWidget(color: currentThemeColor, gap: 24.0, canClose: true);
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Expanded(
                child: IndexedStack(
                  children: <Widget>[
                    PostSquareListPage(),
                    AppsPage(key: Instances.appsPageStateKey),
                    MessagePage(),
                    MyInfoPage(),
                  ],
                  index: _tabIndex,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: FABBottomAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          color: Colors.grey[600].withOpacity(currentIsDark ? 0.8 : 0.4),
          height: bottomBarHeight,
          iconSize: bottomBarIconSize,
          selectedColor: currentThemeColor,
          onTabSelected: _selectedTab,
          showText: false,
          initIndex: _tabIndex,
          items: [
            ...List<FABBottomAppBarItem>.generate(
              pagesTitle.length,
              (i) => FABBottomAppBarItem(iconPath: pagesIcon[i], text: pagesTitle[i]),
            ),
            FABBottomAppBarItem(
              text: '我的',
              child: Center(
                child: SizedBox.fromSize(
                  size: Size.square(suSetWidth(bottomBarIconSize * 1.25)),
                  child: AnimatedContainer(
                    duration: 200.milliseconds,
                    curve: Curves.easeInOut,
                    width: suSetWidth(bottomBarHeight * 0.4),
                    height: suSetWidth(bottomBarHeight * 0.4),
                    padding: EdgeInsets.all(suSetWidth(3.0)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: _tabIndex == 3
                          ? Border.all(color: currentThemeColor, width: suSetWidth(3.0))
                          : null,
                    ),
                    child: UserAvatar(canJump: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
