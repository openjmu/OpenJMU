import 'package:flutter/material.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/pages/home/app_center_page.dart';
import 'package:openjmu/pages/home/course_schedule_page.dart';
import 'package:openjmu/pages/home/score_page.dart';
import 'package:openjmu/widgets/webview/in_app_webview.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({@required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static List<String> get tabs => ['课程表', if (!(currentUser?.isTeacher ?? false)) '成绩', '应用'];
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  final _scrollController = ScrollController();

  TabController _tabController;
  int listTotalSize = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      initialIndex: Provider.of<SettingsProvider>(
        currentContext,
        listen: false,
      ).homeStartUpIndex[1],
      length: tabs.length,
      vsync: this,
    );

    Instances.eventBus
      ..on<ScrollToTopEvent>().listen((event) {
        if (mounted && event.tabIndex == 1) {
          _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
        }
      })
      ..on<AppCenterRefreshEvent>().listen((event) {
        switch (tabs[event.currentIndex]) {
          case '课程表':
            Instances.eventBus.fire(CourseScheduleRefreshEvent());
            break;
          case '成绩':
            Provider.of<ScoresProvider>(currentContext, listen: false).requestScore();
            break;
          case '应用':
            if (_scrollController.hasClients) _scrollController.jumpTo(0.0);
            refreshIndicatorKey.currentState.show();
            Provider.of<WebAppsProvider>(currentContext, listen: false).updateApps();
            break;
        }
        if (mounted) setState(() {});
      });
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
      case '成绩':
      case '应用':
        tab = Tab(text: name);
        break;
      case '课程表':
        tab = Tab(
          child: GestureDetector(
            onTap: (Instances.courseSchedulePageStateKey.currentState != null &&
                    Instances.courseSchedulePageStateKey.currentState.hasCourse)
                ? () {
                    if (_tabController.index != 0) {
                      _tabController.animateTo(0);
                    } else {
                      Instances.courseSchedulePageStateKey.currentState.showWeekWidget();
                    }
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(name),
                if (Instances.courseSchedulePageStateKey.currentState != null &&
                    Instances.courseSchedulePageStateKey.currentState.firstLoaded &&
                    Instances.courseSchedulePageStateKey.currentState.hasCourse)
                  AnimatedCrossFade(
                    firstChild: Icon(Icons.keyboard_arrow_down, size: suSetWidth(28.0)),
                    secondChild: Icon(Icons.keyboard_arrow_up, size: suSetWidth(28.0)),
                    crossFadeState: Instances.courseSchedulePageStateKey.currentState.showWeek
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Instances.courseSchedulePageStateKey.currentState.showWeekDuration,
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
    _tabController = TabController(
      initialIndex: _tabController.index,
      length: tabs.length,
      vsync: this,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: suSetHeight(kAppBarHeight) + MediaQuery.of(context).padding.top,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Selector<ThemesProvider, bool>(
              selector: (_, provider) => provider.dark,
              builder: (_, dark, __) {
                return ExtendedTabBarView(
                  physics: tabs.contains('成绩')
                      ? const ScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  cacheExtent: 3,
                  controller: _tabController,
                  children: <Widget>[
                    UserAPI.currentUser.isTeacher != null
                        ? UserAPI.currentUser.isTeacher
                            ? InAppBrowserPage(
                                url: '${API.courseScheduleTeacher}'
                                    '?sid=${UserAPI.currentUser.sid}'
                                    '&night=${dark ? 1 : 0}',
                                title: '课程表',
                                withAppBar: false,
                                withAction: false,
                                keepAlive: true,
                              )
                            : CourseSchedulePage(key: Instances.courseSchedulePageStateKey)
                        : SizedBox(),
                    if (tabs.contains('成绩')) ScorePage(),
                    AppCenterPage(
                      refreshIndicatorKey: refreshIndicatorKey,
                      scrollController: _scrollController,
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: FixedAppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: suSetWidth(16.0)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TabBar(
                        isScrollable: true,
                        indicator: RoundedUnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: currentThemeColor,
                            width: suSetHeight(3.0),
                          ),
                          width: suSetWidth(26.0),
                          insets: EdgeInsets.only(bottom: suSetHeight(4.0)),
                        ),
                        labelColor: Theme.of(context).textTheme.bodyText2.color,
                        labelStyle: MainPageState.tabSelectedTextStyle,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: suSetWidth(16.0),
                        ),
                        unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
                        tabs: List<Tab>.generate(tabs.length, (i) => _tab(tabs[i])),
                        controller: _tabController,
                      ),
                    ),
                    SizedBox(
                      width: suSetWidth(60.0),
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        icon: Icon(Icons.refresh, size: suSetWidth(32.0)),
                        onPressed: () {
                          Instances.eventBus.fire(AppCenterRefreshEvent(_tabController.index));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
