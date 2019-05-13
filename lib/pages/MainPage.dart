import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:badges/badges.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/utils/OTAUtils.dart';

import 'package:OpenJMU/pages/AppCenterPage.dart';
import 'package:OpenJMU/pages/DiscoveryPage.dart';
import 'package:OpenJMU/pages/MyInfoPage.dart';
import 'package:OpenJMU/pages/NotificationPage.dart';
import 'package:OpenJMU/pages/PostSquareListPage.dart';
import 'package:OpenJMU/pages/PublishPostPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/widgets/FABBottomAppBar.dart';


class MainPage extends StatefulWidget {
    final int initIndex;

    MainPage({this.initIndex, Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
    final List<String> bottomAppBarTitles = ['首页', '应用', '发现', '我的'];
    final List<IconData> bottomAppBarIcons = [
        Platform.isAndroid ? Icons.home : Ionicons.getIconData("ios-home"),
        Platform.isAndroid ? Icons.apps : Ionicons.getIconData("ios-apps"),
        Platform.isAndroid ? Ionicons.getIconData("md-cube") : Ionicons.getIconData("ios-cube"),
        Platform.isAndroid ? Icons.account_circle : Ionicons.getIconData("ios-contact")
    ];

    TextStyle tabTextStyleSelected = TextStyle(color: ThemeUtils.currentColorTheme);
    final tabTextStyleNormal = TextStyle(color: Colors.grey);
    Color currentThemeColor =ThemeUtils.currentColorTheme;

    Notifications notifications = Notifications(0, 0, 0, 0);
    Timer notificationTimer;

    int _tabIndex = Constants.homeSplashIndex;
    var _body;
    var pages = [
        PostSquareListPage(),
//        NewsListPage(),
        AppCenterPage(),
        DiscoveryPage(),
        MyInfoPage()
    ];

    int userUid;
    String userSid;
    var userAvatar;

    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        super.initState();
        if (widget.initIndex != null) _tabIndex = widget.initIndex;
        if (Platform.isAndroid) OTAUtils.checkUpdate(fromStart: true);
        DataUtils.isLogin().then((isLogin) {
            DataUtils.getNotifications();
            if (isLogin) {
                notificationTimer = Timer.periodic(const Duration(milliseconds: 10000), (timer) {
                    DataUtils.getNotifications();
                });
                setState(() {
                    this.userSid = UserUtils.currentUser.sid;
                    this.userUid = UserUtils.currentUser.uid;
                });
            }
        });
        Constants.eventBus.on<ActionsEvent>().listen((event) {
            if (event.type == "action_home") {
                _selectedTab(0);
            } else if (event.type == "action_apps") {
                _selectedTab(1);
            } else if (event.type == "action_discover") {
                _selectedTab(2);
            } else if (event.type == "action_mine") {
                _selectedTab(3);
            }
        });
        Constants.eventBus.on<LogoutEvent>().listen((event) {
            notificationTimer?.cancel();
            Navigator.of(context).pushReplacementNamed("/login");
        });
        Constants.eventBus.on<HasUpdateEvent>().listen((event) {
            if (this.mounted) {
                showDialog(
                    context: context,
                    builder: (_) => OTAUtils.updateDialog(context, event),
                );
            }
        });
        Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
            if (this.mounted) {
                setState(() {
                    tabTextStyleSelected = TextStyle(color: event.color);
                    currentThemeColor = event.color;
                });
            }
        });
        Constants.eventBus.on<NotificationsChangeEvent>().listen((event) {
            if (this.mounted) {
                setState(() {
                    notifications = event.notifications;
                });
            }
        });
    }

    @override
    void dispose() {
        super.dispose();
        notificationTimer?.cancel();
    }

    void _selectedTab(int index) {
        if (_tabIndex == index && index == 0) {
            Constants.eventBus.fire(new ScrollToTopEvent(tabIndex: _tabIndex, type: "MainPage"));
        }
        setState(() {
            _tabIndex = index;
        });
    }

    Image getTabImage(path) {
        return Image.asset(path, width: 20.0, height: 20.0);
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
        return GestureDetector(
            child: Padding(
                padding: EdgeInsets.fromLTRB(14, 10, 6, 10),
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        image: DecorationImage(
                            image: UserUtils.getAvatarProvider(userUid),
                            fit: BoxFit.contain,
                        ),
                    ),
                ),
            ),
            onTap: () {
                return UserPage.jump(context, UserUtils.currentUser.uid);
            },
        );
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
            Constants.eventBus.fire(new ScrollToTopEvent(tabIndex: _tabIndex, type: "MainPage"));
            return Future.value(true);
        }
    }

    @mustCallSuper
    Widget build(BuildContext context) {
        super.build(context);
        _body = IndexedStack(
            children: pages,
            index: _tabIndex,
        );
        return WillPopScope(
            onWillPop: doubleBackExit,
            child: Scaffold(
                appBar: GestureAppBar(
                    appBar: AppBar(
                        backgroundColor: currentThemeColor,
                        elevation: 1,
                        leading: getAvatar(),
                        title: FlatButton(
                            onPressed: null,
                            child: Text(
                                getTabTitle(_tabIndex),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Theme.of(context).textTheme.title.fontSize,
                                ),
                            ),
                        ),
                        centerTitle: true,
                        actions: <Widget>[
                            _tabIndex == 0
                                    ? IconButton(
                                icon: Icon(Platform.isAndroid ? Icons.search : FontAwesome.getIconData("search")),
                                onPressed: () {
                                    Navigator.of(context).pushNamed("/search");
                                },
                            )
                                    : Container(),
                            BadgeIconButton(
                                itemCount: notifications.count,
                                icon: Icon(Platform.isAndroid ? Icons.notifications : Ionicons.getIconData("ios-notifications")),
                                badgeColor: Colors.redAccent,
                                badgeTextColor: Colors.white,
                                hideZeroCount: true,
                                onPressed: () {
                                    Navigator.of(context).push(platformPageRoute(builder: (context) {
                                        return NotificationPage(arguments: {"notifications": notifications});
                                    }));
                                },
                            ),
                        ],
                        iconTheme: IconThemeData(color: Colors.white),
                        brightness: Brightness.dark,
                    ),
                    onTap: doubleTapScrollToTop,
                ),
                floatingActionButton: Builder(builder: (BuildContext context) {
                    return FloatingActionButton(
                        child: Icon(Platform.isAndroid ? Icons.add : Ionicons.getIconData("ios-add")),
                        tooltip: "发布新动态",
                        foregroundColor: Colors.white,
                        backgroundColor: currentThemeColor,
                        elevation: 0,
                        highlightElevation: 14.0,
                        onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                return PublishPostPage();
                            }));
                        },
                        mini: false,
                        shape: CircleBorder(),
                        isExtended: false,
                    );
                }),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: FABBottomAppBar(
                    color: Colors.grey,
                    selectedColor: currentThemeColor,
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
            ),
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
    Size get preferredSize => Size.fromHeight(kToolbarHeight);
}