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
    Key key,
    this.initAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
  static final List<String> pagesTitle = ['广场', '应用', '消息'];
  static final List<String> pagesIcon = ["square", "apps", "messages"];
  static const double bottomBarHeight = 72.0;
  double get bottomBarIconSize => bottomBarHeight / 2.15;

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

  void initPushService() async {
    try {
      final user = UserAPI.currentUser;
      final now = DateTime.now();
      final token = Platform.isIOS ? await ChannelUtils.iosGetPushToken() : "null";
      final data = <String, dynamic>{
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
    notificationTimer = Timer.periodic(10.seconds, _getNotification);
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
    }).catchError((e) {
      debugPrint('Error when getting notification: $e');
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
                  AppsPage(key: Instances.appsPageStateKey),
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
          color: Colors.grey[600].withOpacity(currentIsDark ? 0.8 : 0.4),
          height: bottomBarHeight,
          iconSize: bottomBarIconSize,
          selectedColor: currentThemeColor,
          onTabSelected: _selectedTab,
          showText: false,
          initIndex: pagesTitle.indexOf(widget.initAction) == -1
              ? _tabIndex
              : pagesTitle.indexOf(widget.initAction),
          items: [
            ...List<FABBottomAppBarItem>.generate(
              pagesTitle.length,
              (i) => FABBottomAppBarItem(iconPath: pagesIcon[i], text: pagesTitle[i]),
            ),
            FABBottomAppBarItem(
              text: "我的",
              child: Center(
                child: SizedBox.fromSize(
                  size: Size.square(suSetWidth(bottomBarIconSize * 1.5)),
                  child: AnimatedContainer(
                    duration: 200.milliseconds,
                    curve: Curves.easeInOut,
                    width: suSetWidth(bottomBarHeight * 0.55),
                    height: suSetWidth(bottomBarHeight * 0.55),
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
