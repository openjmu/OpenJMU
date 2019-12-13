import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/home/AppsPage.dart';
import 'package:OpenJMU/pages/home/MessagePage.dart';
import 'package:OpenJMU/pages/home/MyInfoPage.dart';
import 'package:OpenJMU/pages/home/PostSquareListPage.dart';
import 'package:OpenJMU/widgets/FABBottomAppBar.dart';
import 'package:OpenJMU/widgets/announcement/AnnouncementWidget.dart';

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
  static Color currentThemeColor = ThemeUtils.currentThemeColor;

  static final List<String> pagesTitle = ['首页', '应用', '消息', '我的'];
  static final List<String> pagesIcon = ["home", "apps", "message", "mine"];
  static const double bottomBarHeight = 74.0;

  static TextStyle tabSelectedTextStyle = TextStyle(
    color: currentThemeColor,
    fontSize: suSetSp(25.0),
    fontWeight: FontWeight.bold,
    textBaseline: TextBaseline.alphabetic,
  );
  static TextStyle tabUnselectedTextStyle = TextStyle(
    color: currentThemeColor,
    fontSize: suSetSp(20.0),
    textBaseline: TextBaseline.alphabetic,
  );

  Timer notificationTimer;

  int _tabIndex = Configs.homeSplashIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    debugPrint("CurrentUser's ${UserAPI.currentUser}");

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
      })
      ..on<ChangeThemeEvent>().listen((event) {
        currentThemeColor = event.color;
        if (this.mounted) setState(() {});
      });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    ThemeUtils.setDark(ThemeUtils.isDark);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    super.dispose();
  }

  void initWebAppList() {
    final provider = Provider.of<WebAppsProvider>(
      navigatorState.context,
      listen: false,
    );
    provider.initApps();
  }

  void initPushService() async {
    try {
      final UserInfo user = UserAPI.currentUser;
      final DateTime now = DateTime.now();
      String token =
          Platform.isIOS ? await ChannelUtils.iosGetPushToken() : "null";
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
    notificationTimer =
        Timer.periodic(const Duration(seconds: 10), _getNotification);
  }

  void _getNotification(_) {
    Future.wait([
      UserAPI.getNotifications(),
      TeamPostAPI.getNotifications(),
    ]).then((responses) {
      final provider =
          Provider.of<NotificationProvider>(navigatorState.context);
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
      showShortToast("再按一次退出应用");
      lastBack = DateTime.now().millisecondsSinceEpoch;
    } else {
      cancelToast();
      SystemNavigator.pop();
    }
    return Future.value(false);
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: AnnotatedRegion(
        value: ThemeUtils.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Column(
            children: <Widget>[
              if (Configs.announcementsEnabled)
                AnnouncementWidget(
                  context,
                  color: ThemeUtils.currentThemeColor,
                  gap: 24.0,
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
            ],
          ),
        ),
      ),
    );
  }
}
