import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/utils/OTAUtils.dart';

import 'package:OpenJMU/pages/AppCenterPage.dart';
import 'package:OpenJMU/pages/MessagePage.dart';
import 'package:OpenJMU/pages/MyInfoPage.dart';
import 'package:OpenJMU/pages/PostSquareListPage.dart';
import 'package:OpenJMU/widgets/FABBottomAppBar.dart';


class MainPage extends StatefulWidget {
    final int initIndex;

    MainPage({this.initIndex, Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
    static Color currentThemeColor = ThemeUtils.currentThemeColor;

    final List<String> bottomAppBarTitles = ['首页', '应用', '消息', '我的'];
    final List<String> bottomAppBarIcons = ["home", "apps", "message", "mine"];
    TextStyle tabSelectedTextStyle = TextStyle(
        color: currentThemeColor,
        fontSize: Constants.suSetSp(22.0),
        fontWeight: FontWeight.bold,
    );
    TextStyle tabUnselectedTextStyle = TextStyle(
        color: currentThemeColor,
        fontSize: Constants.suSetSp(18.0),
    );
    final Color primaryColor = Colors.white;

    List<Widget> pages;
    Notifications notifications = Constants.notifications;
    Timer notificationTimer;

    List<TabController> _tabControllers = [null, null, null,];
    List<List> sections = [
        ["首页", "关注"],
        ["课程表", "应用"],
//        ["消息", "联系人"],
        ["消息"],
    ];

    int _tabIndex = Constants.homeSplashIndex;
    int userUid;
    String userSid;

    @override
    void initState() {
        super.initState();
        if (widget.initIndex != null) _tabIndex = widget.initIndex;
        if (Platform.isAndroid) OTAUtils.checkUpdate(fromStart: true);
        DataUtils.isLogin().then((isLogin) {
            DataUtils.getNotifications();
            if (isLogin) {
                notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
                    DataUtils.getNotifications();
                });
                setState(() {
                    this.userSid = UserUtils.currentUser.sid;
                    this.userUid = UserUtils.currentUser.uid;
                });
            }
        });
        Constants.eventBus
            ..on<ActionsEvent>().listen((event) {
                if (event.type == "action_home") {
                    _selectedTab(0);
                } else if (event.type == "action_apps") {
                    _selectedTab(1);
                } else if (event.type == "action_discover") {
                    _selectedTab(2);
                } else if (event.type == "action_user") {
                    _selectedTab(3);
                }
            })
            ..on<LogoutEvent>().listen((event) {
                notificationTimer?.cancel();
                Navigator.of(context).pushNamedAndRemoveUntil("/login", (Route<dynamic> route) => false);
            })
            ..on<TicketFailedEvent>().listen((event) {
                Navigator.of(context).pushNamedAndRemoveUntil("/login", (Route<dynamic> route) => false);
            })
            ..on<HasUpdateEvent>().listen((event) {
                if (this.mounted) showDialog(
                    context: context,
                    builder: (_) => OTAUtils.updateDialog(context, event),
                );
            })
            ..on<ChangeThemeEvent>().listen((event) {
                if (this.mounted) setState(() {
                    currentThemeColor = event.color;
                });
            });
        initTabController();
        pages = [
            PostSquareListPage(controller: _tabControllers[0]),
            AppCenterPage(controller: _tabControllers[1]),
            MessagePage(),
            MyInfoPage()
        ];
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        ThemeUtils.setDark(ThemeUtils.isDark);
    }

    @override
    void dispose() {
        super.dispose();
        notificationTimer?.cancel();
    }

    void initTabController() {
        for (int i = 0; i < _tabControllers.length; i++) {
            _tabControllers[i] = TabController(
                length: sections[i].length,
                vsync: this,
            );
        }
    }

    void _selectedTab(int index) {
        setState(() { _tabIndex = index; });
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

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: doubleBackExit,
            child: Scaffold(
                appBar: _tabIndex != 3 ? AppBar(
                    title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            if (_tabIndex == 0) Padding(
                                padding: EdgeInsets.only(right: Constants.suSetSp(4.0)),
                                child: Text(
                                    "Jmu",
                                    style: TextStyle(
                                        color: currentThemeColor,
                                        fontSize: Constants.suSetSp(34),
                                        fontFamily: "chocolate",
                                    ),
                                ),
                            ),
                            ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                    SizedBox(
                                        width: sections[_tabIndex].length * Constants.suSetSp(80.0),
                                        child: TabBar(
                                            indicatorColor: currentThemeColor,
                                            indicatorPadding: EdgeInsets.only(bottom: Constants.suSetSp(20.0)),
                                            indicatorSize: TabBarIndicatorSize.label,
                                            indicatorWeight: Constants.suSetSp(6.0),
                                            labelColor: Theme.of(context).textTheme.body1.color,
                                            labelStyle: tabSelectedTextStyle,
                                            labelPadding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(8.0)),
                                            unselectedLabelStyle: tabUnselectedTextStyle,
                                            tabs: <Tab>[
                                                for (int i = 0; i < sections[_tabIndex].length; i++) Tab(text: sections[_tabIndex][i])
                                            ],
                                            controller: _tabControllers[_tabIndex],
                                        ),
                                    ),
                                ],
                            ),
                        ],
                    ),
                    centerTitle: (_tabIndex == 2) ? true : false,
                    actions: <Widget>[
                        if (_tabIndex == 0) Padding(
                            padding: EdgeInsets.only(left: Constants.suSetSp(8.0)),
                            child: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                    Navigator.of(context).pushNamed("/search");
                                },
                            ),
                        ),
                    ],
                ) : null,
                body: IndexedStack(
                    children: pages,
                    index: _tabIndex,
                ),
                bottomNavigationBar: FABBottomAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    color: Colors.grey[600],
                    selectedColor: ThemeUtils.currentThemeColor,
                    onTabSelected: _selectedTab,
                    items: [
                        for (int i = 0; i < bottomAppBarTitles.length; i++)
                            FABBottomAppBarItem(
                                iconPath: bottomAppBarIcons[i],
                                text: bottomAppBarTitles[i],
                            ),
                    ],
                ),
                floatingActionButton: Container(
                    width: Constants.suSetSp(56.0),
                    height: Constants.suSetSp(40.0),
                    child: FloatingActionButton(
                        child: Stack(
                            children: <Widget>[
                                Positioned(
                                    child: Icon(
                                        Platform.isAndroid ? Icons.add : Ionicons.getIconData("ios-add"),
                                        size: Constants.suSetSp(30.0),
                                    ),
                                ),
                            ],
                        ),
                        tooltip: "发布新动态",
                        foregroundColor: Colors.white,
                        backgroundColor: currentThemeColor,
                        elevation: 0,
                        onPressed: () {
                            Navigator.of(context).pushNamed("/publishPost");
                        },
                        mini: true,
                        isExtended: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.suSetSp(14.0))),
                    ),
                ),
                floatingActionButtonLocation: const CustomCenterDockedFloatingActionButtonLocation(),
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
