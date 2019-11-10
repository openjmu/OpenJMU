import 'package:flutter/material.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/home/CourseSchedulePage.dart';
import 'package:OpenJMU/pages/home/ScorePage.dart';
import 'package:OpenJMU/widgets/AppIcon.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/InAppBrowser.dart';

class AppCenterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AppCenterPageState _appCenterPageState;
  final GlobalKey<CourseSchedulePageState> coursePageKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  static List<String> tabs() =>
      ["课程表", if (!(UserAPI.currentUser?.isTeacher ?? false)) "成绩", "应用"];

  TabController _tabController;
  Color currentThemeColor = ThemeUtils.currentThemeColor;
  Map<String, List<Widget>> webAppWidgetList = {};
  List<Widget> webAppList = [];
  List webAppListData;
  int listTotalSize = 0;
  bool enableNewIcon = Configs.newAppCenterIcon;

  Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _appCenterPageState = this;

    _tabController = TabController(
      initialIndex: Configs.homeStartUpIndex[1],
      length: tabs().length,
      vsync: this,
    );

    Instances.eventBus
      ..on<ScrollToTopEvent>().listen((event) {
        if (mounted && event.tabIndex == 1) {
          _scrollController.animateTo(0,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        }
      })
      ..on<ChangeThemeEvent>().listen((event) {
        currentThemeColor = event.color;
        if (mounted) setState(() {});
      })
      ..on<AppCenterRefreshEvent>().listen((event) {
        switch (tabs()[event.currentIndex]) {
          case "课程表":
            Instances.eventBus.fire(CourseScheduleRefreshEvent());
            break;
          case "成绩":
            Instances.eventBus.fire(ScoreRefreshEvent());
            break;
          case "应用":
            _scrollController.jumpTo(0.0);
            refreshIndicatorKey.currentState.show();
            getAppList();
            break;
        }
        if (mounted) setState(() {});
      })
      ..on<AppCenterSettingsUpdateEvent>().listen((event) {
        enableNewIcon = Configs.newAppCenterIcon;
        if (mounted) setState(() {});
      })
      ..on<ChangeThemeEvent>().listen((event) {
        currentThemeColor = event.color;
        if (mounted) setState(() {});
      });

    _futureBuilderFuture = getAppList();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future getAppList() async => NetUtils.getWithCookieSet(API.webAppLists);

  Widget categoryListView(BuildContext context, AsyncSnapshot snapshot) {
    final data = snapshot.data?.data;
    Map<String, List<Widget>> appList = {};
    for (int i = 0; i < data.length; i++) {
      final url = data[i]['url'];
      final name = data[i]['name'];
      if ((url != "" && url != null) && (name != "" && name != null)) {
        final _app = appWrapper(WebApp.fromJson(data[i]));
        if (appList[_app.menuType] == null) {
          appList[_app.menuType] = [];
        }
        if (!appFiltered(_app)) {
          appList[_app.menuType].add(getWebAppButton(_app));
        }
      }
    }
    webAppWidgetList = appList;
    List<Widget> _list = [];
    WebApp.category.forEach((name, value) {
      _list.add(getSectionColumn(context, name));
    });
    return ListView.builder(
      controller: _scrollController,
      itemCount: _list.length,
      itemBuilder: (BuildContext context, index) => _list[index],
    );
  }

  WebApp appWrapper(WebApp app) {
//    print("${app.code}-${app.name}");
    switch (app.name) {
//      case "集大通":
//        app.name = "OpenJMU";
//        app.url = "https://openjmu.jmu.edu.cn/";
//        break;
      default:
        break;
    }
    return app;
  }

  bool appFiltered(WebApp app) {
    if ((!UserAPI.currentUser.isCY && app.code == "6101") ||
        (UserAPI.currentUser.isCY && app.code == "5001") ||
        (app.code == "6501") ||
        (app.code == "4001" && app.name == "集大通")) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Center(child: Text('尚未加载'));
      case ConnectionState.active:
        return Center(child: Text('正在加载'));
      case ConnectionState.waiting:
        return Center(
          child: Constants.progressIndicator(),
        );
      case ConnectionState.done:
        if (snapshot.hasError) return Text('错误: ${snapshot.error}');
        return categoryListView(context, snapshot);
      default:
        return Center(child: Text('尚未加载'));
    }
  }

  String replaceParamsInUrl(url) {
    RegExp sidReg = RegExp(r"{SID}");
    RegExp uidReg = RegExp(r"{UID}");
    String result = url;
    result = result.replaceAllMapped(
      sidReg,
      (match) => UserAPI.currentUser.sid.toString(),
    );
    result = result.replaceAllMapped(
      uidReg,
      (match) => UserAPI.currentUser.uid.toString(),
    );
    return result;
  }

  Widget getWebAppButton(WebApp webApp) {
    final String url = replaceParamsInUrl(webApp.url);
    return FlatButton(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIcon(app: webApp, size: 70.0),
          Text(
            webApp.name,
            style: Theme.of(context).textTheme.body1.copyWith(
                  fontSize: Constants.suSetSp(17.0),
                  fontWeight: FontWeight.normal,
                ),
          ),
        ],
      ),
      onPressed: () => CommonWebPage.jump(
        url,
        webApp.name,
        app: webApp,
      ),
    );
  }

  Widget getSectionColumn(context, name) {
    if (webAppWidgetList[name] != null) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                vertical: Constants.suSetSp(16.0),
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).canvasColor,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  WebApp.category[name],
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: Constants.suSetSp(18.0),
                      ),
                ),
              ),
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: webAppWidgetList[name].length,
              itemBuilder: (context, index) {
                final int _rows = (webAppWidgetList[name].length / 3).ceil();
                final bool showBottom = ((index + 1) / 3).ceil() != _rows;
                final bool showRight =
                    ((index + 1) / 3).ceil() != (index + 1) ~/ 3;
                Widget _w = webAppWidgetList[name][index];
                _w = DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: showBottom
                          ? BorderSide(
                              color: Theme.of(context).canvasColor,
                            )
                          : BorderSide.none,
                      right: showRight
                          ? BorderSide(
                              color: Theme.of(context).canvasColor,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: _w,
                );
                return _w;
              },
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _tab(String name) {
    Widget tab;
    switch (name) {
      case "成绩":
      case "应用":
        tab = Tab(text: name);
        break;
      case "课程表":
        tab = Tab(
          child: GestureDetector(
            onTap: (coursePageKey.currentState != null &&
                    coursePageKey.currentState.hasCourse)
                ? () {
                    if (_tabController.index != 0) {
                      _tabController.animateTo(0);
                    } else {
                      coursePageKey.currentState.showWeekWidget();
                    }
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(name),
                if (coursePageKey.currentState != null &&
                    coursePageKey.currentState.firstLoaded &&
                    coursePageKey.currentState.hasCourse)
                  AnimatedCrossFade(
                    firstChild: Icon(
                      Icons.keyboard_arrow_down,
                      size: Constants.suSetSp(28.0),
                    ),
                    secondChild: Icon(
                      Icons.keyboard_arrow_up,
                      size: Constants.suSetSp(28.0),
                    ),
                    crossFadeState: coursePageKey.currentState.showWeek
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: coursePageKey.currentState.showWeekDuration,
                  ),
              ],
            ),
          ),
        );
    }
    return tab;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _appCenterPageState = this;
    _tabController = TabController(
      initialIndex: _tabController.index,
      length: tabs().length,
      vsync: this,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: TabBar(
          isScrollable: true,
          indicatorColor: currentThemeColor,
          indicatorPadding: EdgeInsets.only(
            bottom: Constants.suSetSp(16.0),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: Constants.suSetSp(6.0),
          labelColor: Theme.of(context).textTheme.body1.color,
          labelStyle: MainPageState.tabSelectedTextStyle,
          labelPadding: EdgeInsets.symmetric(
            horizontal: Constants.suSetSp(16.0),
          ),
          unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
          tabs: <Tab>[
            for (int i = 0; i < List.from(tabs()).length; i++) _tab(tabs()[i])
          ],
          controller: _tabController,
        ),
        centerTitle: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: Constants.suSetSp(8.0),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                size: Constants.suSetSp(24.0),
              ),
              onPressed: () {
                Instances.eventBus
                    .fire(AppCenterRefreshEvent(_tabController.index));
              },
            ),
          ),
        ],
      ),
      body: ExtendedTabBarView(
        physics: tabs().contains("成绩")
            ? const ScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          UserAPI.currentUser.isTeacher != null
              ? UserAPI.currentUser.isTeacher
                  ? InAppBrowserPage(
                      url: "${API.courseScheduleTeacher}"
                          "?sid=${UserAPI.currentUser.sid}"
                          "&night=${ThemeUtils.isDark ? 1 : 0}",
                      title: "课程表",
                      withAppBar: false,
                      withAction: false,
                      keepAlive: true,
                    )
                  : CourseSchedulePage(
                      key: coursePageKey,
                      appCenterPageState: _appCenterPageState,
                    )
              : SizedBox(),
          if (tabs().contains("成绩")) ScorePage(),
          RefreshIndicator(
            key: refreshIndicatorKey,
            child: FutureBuilder(
              builder: _buildFuture,
              future: _futureBuilderFuture,
            ),
            onRefresh: getAppList,
          ),
        ],
      ),
    );
  }
}
