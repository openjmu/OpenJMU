import 'package:OpenJMU/pages/home/AppCenterPage.dart';
import 'package:flutter/material.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/home/CourseSchedulePage.dart';
import 'package:OpenJMU/pages/home/ScorePage.dart';
import 'package:OpenJMU/widgets/InAppBrowser.dart';

class AppsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static List<String> tabs() =>
      ["课程表", if (!(UserAPI.currentUser?.isTeacher ?? false)) "成绩", "应用"];
  final coursePageKey = GlobalKey<CourseSchedulePageState>();
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  final _scrollController = ScrollController();

  AppsPageState _appCenterPageState;
  TabController _tabController;
  Color currentThemeColor = ThemeUtils.currentThemeColor;
  int listTotalSize = 0;
  bool enableNewIcon = Configs.newAppCenterIcon;

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
            if (_scrollController.hasClients) _scrollController.jumpTo(0.0);
            refreshIndicatorKey.currentState.show();
            Provider.of<WebAppsProvider>(
              navigatorState.context,
              listen: false,
            ).updateApps();
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

    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _tabController?.dispose();
    super.dispose();
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
                      size: suSetWidth(28.0),
                    ),
                    secondChild: Icon(
                      Icons.keyboard_arrow_up,
                      size: suSetWidth(28.0),
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

  @mustCallSuper
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(suSetHeight(kAppBarHeight)),
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
          height: Screen.topSafeHeight + suSetHeight(kAppBarHeight),
          child: SafeArea(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: currentThemeColor,
                    indicatorPadding: EdgeInsets.only(
                      bottom: suSetHeight(16.0),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: suSetHeight(6.0),
                    labelColor: Theme.of(context).textTheme.body1.color,
                    labelStyle: MainPageState.tabSelectedTextStyle,
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: suSetWidth(16.0),
                    ),
                    unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
                    tabs: <Tab>[
                      for (int i = 0; i < List.from(tabs()).length; i++)
                        _tab(tabs()[i])
                    ],
                    controller: _tabController,
                  ),
                ),
                SizedBox(
                  width: suSetWidth(60.0),
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    icon: Icon(
                      Icons.refresh,
                      size: suSetWidth(32.0),
                    ),
                    onPressed: () {
                      Instances.eventBus
                          .fire(AppCenterRefreshEvent(_tabController.index));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
          AppCenterPage(
            refreshIndicatorKey: refreshIndicatorKey,
            scrollController: _scrollController,
          ),
        ],
      ),
    );
  }
}
