import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:badges/badges.dart';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
//import 'package:OpenJMU/pages/NewsListPage.dart';
import 'package:OpenJMU/pages/PostListPage.dart';
import 'package:OpenJMU/pages/AppCenterPage.dart';
import 'package:OpenJMU/pages/DiscoveryPage.dart';
import 'package:OpenJMU/pages/PublishPostPage.dart';
import 'package:OpenJMU/pages/MyInfoPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/widgets/FABBottomAppBar.dart';


class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
//  final List<String> bottomAppBarTitles = ['首页', '新闻', '应用中心', '消息', '我的'];
  final List<String> bottomAppBarTitles = ['首页', '应用中心', '消息', '我的'];
//  final List<IconData> bottomAppBarIcons = [
//    Icons.home, Icons.fiber_new, Icons.apps, Icons.chat, Icons.account_circle
//  ];
  final List<IconData> bottomAppBarIcons = [
    Icons.home, Icons.apps, Icons.chat, Icons.account_circle
  ];
  TextStyle tabTextStyleSelected = new TextStyle(color: ThemeUtils.currentColorTheme);
  final tabTextStyleNormal = new TextStyle(color: Colors.grey);
  Color currentPrimaryColor = ThemeUtils.currentPrimaryColor;
  Color currentThemeColor = ThemeUtils.currentColorTheme;

  int currentNotifications = 0;
  Timer notificationTimer;
  Stopwatch watch = new Stopwatch();

  int _tabIndex = 0;
  var _body;
  var pages;

  int userUid;
  String userSid;
  var userAvatar;

  bool isUserLogin = false;

  void _selectedTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isUserLogin = isLogin;
      });
      if (isLogin) {
        watch.start();
        notificationTimer = new Timer.periodic(const Duration(milliseconds: 10000), (timer) {
          DataUtils.getNotifications();
        });
        setState(() {
          this.userSid = UserUtils.currentUser.sid;
          this.userUid = UserUtils.currentUser.uid;
        });
      }
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          this.isUserLogin = true;
        });
      }
    });
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      Navigator.of(context).pushReplacementNamed("/login");
    });
    DataUtils.getColorThemeIndex().then((index) {
      if (this.mounted && index != null) {
        setState(() {
          ThemeUtils.currentColorTheme = ThemeUtils.supportColors[index];
        });
        Constants.eventBus.fire(new ChangeThemeEvent(ThemeUtils.supportColors[index]));
      }
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          tabTextStyleSelected = new TextStyle(color: event.color);
          currentThemeColor = event.color;
        });
      }
    });
    Constants.eventBus.on<NotificationCountChangeEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          currentNotifications = event.notifications;
        });
      }
    });
    pages = <Widget>[
      PostListPage("square"),
//      NewsListPage(),
      AppCenterPage(),
      DiscoveryPage(),
      MyInfoPage()
    ];
  }

  @override
  void dispose() {
    notificationTimer != null ? notificationTimer.cancel() : null;
    super.dispose();
  }

  Image getTabImage(path) {
    return new Image.asset(path, width: 20.0, height: 20.0);
  }

  TextStyle getTabTextStyle(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabTextStyleSelected;
    }
    return tabTextStyleNormal;
  }

  String getTabTitle(int curIndex) {
    return bottomAppBarTitles[curIndex];
  }

  GestureDetector getAvatar() {
    return new GestureDetector(
        child: new Padding(
          padding: EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: new Container(
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              image: new DecorationImage(
                  image: new NetworkImage(Api.userAvatar+"?uid=$userUid&size=f100"),
                  fit: BoxFit.contain
              ),
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, UserUtils.currentUser.uid);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return mainPage(context);
  }

  int lastBack = 0;
  Future<bool> doubleBackExit() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 800) {
      showShortToast("再按一次退出应用");
      lastBack = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      cancelToast();
      return Future.value(true);
    }
  }

  int lastAppBarTap = 0;
  Future<bool> doubleTapScrollToTop() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastAppBarTap > 400) {
      lastAppBarTap = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      Constants.eventBus.fire(new ScrollToTopEvent(_tabIndex));
      return Future.value(true);
    }
  }

  WillPopScope mainPage(context) {
    _body = new IndexedStack(
      children: pages,
      index: _tabIndex,
    );
    return new WillPopScope(
        onWillPop: doubleBackExit,
        child: new Scaffold(
          appBar: GestureAppBar(
              appBar: new AppBar(
                elevation: 1,
                leading: getAvatar(),
                title: new FlatButton(
                    onPressed: null,
                    child: new Text(
                        getTabTitle(_tabIndex),
                        style: new TextStyle(
                            color: currentThemeColor,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold
                        )
                    )
                ),
                centerTitle: true,
                actions: <Widget>[
                  BadgeIconButton(
                      itemCount: currentNotifications,
                      icon: Icon(Icons.notifications),
                      badgeColor: currentThemeColor,
                      badgeTextColor: Colors.white,
                      hideZeroCount: true,
                      onPressed: null
                  ),
                ],
                iconTheme: new IconThemeData(color: currentThemeColor),
                brightness: Theme.of(context).brightness,
              ),
              onTap: () {
                doubleTapScrollToTop();
              }
          ),
          floatingActionButton: new Builder(builder: (BuildContext context) {
            return new FloatingActionButton(
              child: new Icon(Icons.add),
              tooltip: "发布新动态",
              foregroundColor: Colors.white,
              backgroundColor: currentThemeColor,
              elevation: 8.0,
              highlightElevation: 14.0,
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) {
                      return new PublishPostPage();
                    }
                ));
              },
              mini: false,
              shape: new CircleBorder(),
              isExtended: false,
            );
          }),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: FABBottomAppBar(
//            centerItemText: '',
            color: Colors.grey,
            selectedColor: ThemeUtils.currentColorTheme,
            notchedShape: CircularNotchedRectangle(),
            onTabSelected: _selectedTab,
            items: [
              FABBottomAppBarItem(iconData: bottomAppBarIcons[0], text: getTabTitle(0)),
              FABBottomAppBarItem(iconData: bottomAppBarIcons[1], text: getTabTitle(1)),
              FABBottomAppBarItem(iconData: bottomAppBarIcons[2], text: getTabTitle(2)),
              FABBottomAppBarItem(iconData: bottomAppBarIcons[3], text: getTabTitle(3)),
            ],
          ),
          body: _body,
        )
    );
  }
}

class GestureAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTap;
  final AppBar appBar;

  const GestureAppBar({Key key, this.onTap,this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: appBar);
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}