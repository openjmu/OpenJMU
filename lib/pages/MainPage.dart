import 'dart:async';
import 'dart:io';

import 'package:OpenJMU/widgets/announcement/AnnouncementWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/constants/Configs.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ChannelUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/OTAUtils.dart';

import 'package:OpenJMU/pages/home/AddButtonPage.dart';
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

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
  static Color currentThemeColor = ThemeUtils.currentThemeColor;

  static final List<String> pagesTitle = ['首页', '应用', '消息', '我的'];
  static final List<String> pagesIcon = ["home", "apps", "message", "mine"];
  static const double bottomBarHeight = 64.4;

  static TextStyle tabSelectedTextStyle = TextStyle(
    color: currentThemeColor,
    fontSize: Constants.suSetSp(23.0),
    fontWeight: FontWeight.bold,
    textBaseline: TextBaseline.alphabetic,
  );
  static TextStyle tabUnselectedTextStyle = TextStyle(
    color: currentThemeColor,
    fontSize: Constants.suSetSp(18.0),
    textBaseline: TextBaseline.alphabetic,
  );

  List<List> sections = [
    PostSquareListPageState.tabs,
    AppCenterPageState.tabs(),
    MessagePageState.tabs,
  ];

  BuildContext pageContext;

  List<Widget> pages;
  Notifications notifications = Constants.notifications;
  Timer notificationTimer;

  int _tabIndex = Configs.homeSplashIndex;
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

    pages = [
      PostSquareListPage(),
      AppCenterPage(),
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
      ..on<HasUpdateEvent>().listen((event) {
        if (this.mounted)
          showDialog(
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
        "platform": Platform.isIOS ? "ios" : "android"
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
    DataUtils.getNotifications();
    notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      DataUtils.getNotifications();
    });
    setState(() {
      this.userSid = UserAPI.currentUser.sid;
      this.userUid = UserAPI.currentUser.uid;
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
    pageContext = context;
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              if (Configs.announcementsEnabled)
                AnnouncementWidget(
                  context,
                  color: ThemeUtils.currentThemeColor,
                  gap: 24.0,
                ),
              Expanded(
                child: IndexedStack(
                  children: pages,
                  index: _tabIndex,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: FABBottomAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          color: Colors.grey[600],
          height: bottomBarHeight,
          iconSize: 30.0,
          selectedColor: currentThemeColor,
          onTabSelected: _selectedTab,
          initIndex: widget.initIndex,
          items: [
            for (int i = 0; i < pagesTitle.length; i++)
              FABBottomAppBarItem(
                iconPath: pagesIcon[i],
                text: pagesTitle[i],
              )
          ],
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
              Navigator.of(context).push(TransparentRoute(
                builder: (context) => AddingButtonPage(),
              ));
            },
            mini: true,
            isExtended: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.suSetSp(14.0))),
          ),
        ),
        floatingActionButtonLocation:
            const CustomCenterDockedFloatingActionButtonLocation(
                bottomBarHeight / 2),
      ),
    );
  }
}

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    @required this.builder,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;
  @override
  Color get barrierColor => null;
  @override
  String get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }
}
