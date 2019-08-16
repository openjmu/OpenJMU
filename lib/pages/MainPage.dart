import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ChannelUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/OTAUtils.dart';

import 'package:OpenJMU/pages/home/AppCenterPage.dart';
import 'package:OpenJMU/pages/home/MessagePage.dart';
import 'package:OpenJMU/pages/home/MyInfoPage.dart';
import 'package:OpenJMU/pages/home/PostSquareListPage.dart';
import 'package:OpenJMU/widgets/FABBottomAppBar.dart';


class MainPage extends StatefulWidget {
    final int initIndex;

    MainPage({this.initIndex, Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
    static Color currentThemeColor = ThemeUtils.currentThemeColor;

    static final List<String> pagesTitle = ['首页', '应用', '消息', '我的'];
    static final List<String> pagesIcon = ["home", "apps", "message", "mine"];
    static const double bottomBarHeight = 64.4;

    List<List> sections = [
        PostSquareListPageState.tabs,
        AppCenterPageState.tabs(),
        MessagePageState.tabs,
    ];

    BuildContext pageContext;

    TextStyle tabSelectedTextStyle = TextStyle(
        color: currentThemeColor,
        fontSize: Constants.suSetSp(23.0),
        fontWeight: FontWeight.bold,
    );
    TextStyle tabUnselectedTextStyle = TextStyle(
        color: currentThemeColor,
        fontSize: Constants.suSetSp(18.0),
    );

    List<Widget> pages;
    Notifications notifications = Constants.notifications;
    Timer notificationTimer;

    List<TabController> _tabControllers = [null, null, null,];

    int _tabIndex = Constants.homeSplashIndex;
    int userUid;
    String userSid;

    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        debugPrint("CurrentUser's ${UserAPI.currentUser}");

        if (widget.initIndex != null) _tabIndex = widget.initIndex;
        if (Platform.isAndroid) OTAUtils.checkUpdate(fromHome: true);

        initPushService();
        initNotification();
        initTabController();

        pages = [
            PostSquareListPage(controller: _tabControllers[0]),
            AppCenterPage(controller: _tabControllers[1]),
            MessagePage(),
            MyInfoPage(),
        ];

        Constants.eventBus
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
            ..on<LogoutEvent>().listen((event) {
                notificationTimer?.cancel();
                Navigator.of(pageContext).pushNamedAndRemoveUntil("/login", (Route<dynamic> route) => false);
            })
            ..on<TicketFailedEvent>().listen((event) {
                notificationTimer?.cancel();
                Navigator.of(pageContext).pushNamedAndRemoveUntil("/login", (Route<dynamic> route) => false);
            })
            ..on<HasUpdateEvent>().listen((event) {
                if (this.mounted) showDialog(
                    context: context,
                    builder: (_) => OTAUtils.updateDialog(context, event),
                );
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

    void initPushService() async {
        final UserInfo user = UserAPI.currentUser;
        final String version = await OTAUtils.getCurrentVersion();
        NetUtils.post(API.pushUpload, data: {
            "token": Platform.isIOS
                    ? await ChannelUtils.iosGetPushToken()
                    : ""
            ,
            "date": await ChannelUtils.iosGetPushDate(),
            "uid": user.uid.toString(),
            "name": user.name.toString(),
            "workid": user.workId.toString(),
            "appversion": version.toString(),
            "platform": Platform.isIOS ? "ios" : "android"
        }).then((response) {
            debugPrint("Push service info upload success.");
        });
    }

    void initNotification() {
        DataUtils.getNotifications();
        notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
            DataUtils.getNotifications();
        });
        setState(() {
            this.userSid = UserAPI.currentUser.sid;
            this.userUid = UserAPI.currentUser.uid;
        });
    }

    void initTabController() {
        for (int i = 0; i < _tabControllers.length; i++) {
            _tabControllers[i] = TabController(
                initialIndex: Constants.homeStartUpIndex[i],
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

    @mustCallSuper
    Widget build(BuildContext context) {
        super.build(context);
        pageContext = context;
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
                            Flexible(
                                child: TabBar(
                                    isScrollable: true,
                                    indicatorColor: currentThemeColor,
                                    indicatorPadding: EdgeInsets.only(bottom: Constants.suSetSp(16.0)),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    indicatorWeight: Constants.suSetSp(6.0),
                                    labelColor: Theme.of(context).textTheme.body1.color,
                                    labelStyle: tabSelectedTextStyle,
                                    labelPadding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0)),
                                    unselectedLabelStyle: tabUnselectedTextStyle,
                                    tabs: <Tab>[
                                        for (int i = 0; i < sections[_tabIndex].length; i++)
                                            Tab(text: sections[_tabIndex][i])
                                    ],
                                    controller: _tabControllers[_tabIndex],
                                ),
                            ),
                        ],
                    ),
                    centerTitle: (_tabIndex == 2) ? true : false,
                    actions: <Widget>[
                        if (_tabIndex == 0) Padding(
                            padding: EdgeInsets.zero,
                            child: IconButton(
                                icon: SvgPicture.asset(
                                    "assets/icons/scan-line.svg",
                                    color: Theme.of(context).iconTheme.color,
                                    width: Constants.suSetSp(26.0),
                                    height: Constants.suSetSp(26.0),
                                ),
                                onPressed: () async {
                                    Map<PermissionGroup, PermissionStatus>permissions = await PermissionHandler().requestPermissions([
                                        PermissionGroup.camera,
                                    ]);
                                    if (permissions[PermissionGroup.camera] == PermissionStatus.granted) {
                                        Navigator.of(context).pushNamed("/scanqrcode");
                                    }
                                },
                            ),
                        ),
                        if (_tabIndex == 0) Padding(
                            padding: EdgeInsets.zero,
                            child: IconButton(
                                icon: SvgPicture.asset(
                                    "assets/icons/search-line.svg",
                                    color: Theme.of(context).iconTheme.color,
                                    width: Constants.suSetSp(26.0),
                                    height: Constants.suSetSp(26.0),
                                ),
                                onPressed: () {
                                    Navigator.of(context).pushNamed("/search");
                                },
                            ),
                        ),
                        if (_tabIndex == 1) Padding(
                            padding: EdgeInsets.only(left: Constants.suSetSp(8.0)),
                            child: IconButton(
                                icon: Icon(Icons.refresh, size: Constants.suSetSp(24.0)),
                                onPressed: () {
                                    Constants.eventBus.fire(AppCenterRefreshEvent(_tabControllers[1].index));
                                },
                            ),
                        )
                    ],
                ) : null,
                body: IndexedStack(
                    children: pages,
                    index: _tabIndex,
                ),
                bottomNavigationBar: FABBottomAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    color: Colors.grey[600],
                    height: bottomBarHeight,
                    iconSize: 30.0,
                    selectedColor: ThemeUtils.currentThemeColor,
                    onTabSelected: _selectedTab,
                    initIndex: widget.initIndex,
                    items: [for (int i = 0; i < pagesTitle.length; i++) FABBottomAppBarItem(
                        iconPath: pagesIcon[i],
                        text: pagesTitle[i],
                    )],
                ),
                floatingActionButton: SizedBox(
                    width: Constants.suSetSp(56.0),
                    height: Constants.suSetSp(40.0),
                    child: FloatingActionButton(
                        child: Icon(Icons.add, size: Constants.suSetSp(30.0)),
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
                floatingActionButtonLocation: const CustomCenterDockedFloatingActionButtonLocation(bottomBarHeight / 2),
            ),
        );
    }
}
