import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
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
  final String initAction;

  const MainPage({
    this.initAction,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
  static final List<String> pagesTitle = ['首页', '应用', '消息'];
  static final List<String> pagesIcon = ["home", "apps", "message", "mine"];
  static const double bottomBarHeight = 74.0;

  static final tabSelectedTextStyle = TextStyle(
    fontSize: suSetSp(23.0),
    fontWeight: FontWeight.bold,
    textBaseline: TextBaseline.alphabetic,
  );
  static final tabUnselectedTextStyle = TextStyle(
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
    debugPrint("CurrentUser's ${UserAPI.currentUser}");

    _tabIndex = Provider.of<SettingsProvider>(currentContext, listen: false).homeSplashIndex;
    if (widget.initAction != null) {
      _tabIndex = pagesTitle.indexOf(widget.initAction);
    }

    initWebAppList();
    initPushService();
    initNotification();
    MessageUtils.initMessageSocket();

    Instances.eventBus
      ..on<ActionsEvent>().listen((event) {
        if (event.type == "action_home") {
          _selectedTab(0);
        } else if (event.type == "action_apps") {
          _selectedTab(1);
        } else if (event.type == "action_message") {
          _selectedTab(2);
        } else if (event.type == "action_user") {
          _selectedTab(3);
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    super.dispose();
  }

  void initWebAppList() {
    Provider.of<WebAppsProvider>(currentContext, listen: false).initApps();
  }

  void initPushService() async {
    try {
      final UserInfo user = UserAPI.currentUser;
      final DateTime now = DateTime.now();
      String token = Platform.isIOS ? await ChannelUtils.iosGetPushToken() : "null";
      final Map<String, dynamic> data = {
        "token": token,
        "date": DateFormat("yyyy/MM/dd/HH:mm:ss", "en").format(now),
        "uid": user.uid.toString(),
        "name": user.name.toString(),
        "workid": user.workId.toString(),
        "appversion": await OTAUtils.getCurrentVersion(),
        "platform": Platform.isIOS ? "ios" : "android",
      };
      NetUtils.post(API.pushUpload, data: data).then((response) {
        debugPrint("Push service info upload success.");
      }).catchError((e) {
        debugPrint("Push service upload error: $e");
      });
    } catch (e) {
      debugPrint("Push service init error: $e");
    }
  }

  void initNotification() {
    _getNotification(null);
    notificationTimer = Timer.periodic(const Duration(seconds: 10), _getNotification);
  }

  void _getNotification(_) {
    Future.wait([
      UserAPI.getNotifications(),
      TeamPostAPI.getNotifications(),
    ]).then((responses) {
      final provider = Provider.of<NotificationProvider>(currentContext, listen: false);
      provider.updateNotification(
        Notifications.fromJson(responses[0].data),
        TeamNotifications.fromJson(responses[1].data),
      );
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
      showToast("再按一次退出应用");
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
        body: Column(
          children: <Widget>[
            Selector<SettingsProvider, bool>(
              selector: (_, provider) => provider.announcementsEnabled,
              builder: (_, announcementEnabled, __) {
                if (announcementEnabled) {
                  return AnnouncementWidget(context, color: currentThemeColor, gap: 24.0);
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
            Expanded(
              child: IndexedStack(
                children: <Widget>[
                  PostSquareListPage(),
                  AppsPage(),
                  MessagePage(),
                  MyInfoPage(),
                ],
                index: _tabIndex,
              ),
            ),
          ],
        ),
        bottomNavigationBar: FABBottomAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          color: Colors.grey[600],
          height: bottomBarHeight,
          iconSize: 34.0,
          selectedColor: currentThemeColor,
          onTabSelected: _selectedTab,
          initIndex: pagesTitle.indexOf(widget.initAction) == -1
              ? 0
              : pagesTitle.indexOf(widget.initAction),
          items: [
            for (int i = 0; i < pagesTitle.length; i++)
              FABBottomAppBarItem(
                iconPath: pagesIcon[i],
                text: pagesTitle[i],
              ),
            FABBottomAppBarItem(
              child: Center(
                child: AnimatedContainer(
                  duration: 200.milliseconds,
                  padding: EdgeInsets.all(suSetWidth(3)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _tabIndex == 3
                        ? Border.all(color: currentThemeColor, width: suSetWidth(3.0))
                        : null,
                  ),
                  child: UserAvatar(size: 40.0, canJump: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
