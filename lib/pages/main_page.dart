import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/home/apps_page.dart';
import 'package:openjmu/pages/home/message_page.dart';
import 'package:openjmu/pages/home/post_square_page.dart';
import 'package:openjmu/pages/home/self_page.dart';
import 'package:openjmu/pages/home/marketing_page.dart';

@FFRoute(
  name: 'openjmu://home',
  routeName: '首页',
  argumentNames: ['initAction'],
)
class MainPage extends StatefulWidget {
  const MainPage({
    Key key,
    this.initAction,
  }) : super(key: key);

  final int initAction;

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
  static List<String> get pagesTitle => <String>['广场', '集市', '课业', '消息'];

  /// Icons for bottom navigation.
  /// 底部导航的各项图标
  static const List<String> pagesIcon = <String>[
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_SQUARE_SVG,
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_MARKET_SVG,
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_SCHOOL_WORK_SVG,
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_MESSAGES_SVG,
  ];

  static double get bottomBarHeight => 72.0;

  static TextStyle get tabSelectedTextStyle => TextStyle(
        fontSize: suSetSp(23.0),
        fontWeight: FontWeight.bold,
        textBaseline: TextBaseline.alphabetic,
      );

  static TextStyle get tabUnselectedTextStyle => TextStyle(
        fontSize: suSetSp(23.0),
        fontWeight: FontWeight.w300,
        textBaseline: TextBaseline.alphabetic,
      );

  double get bottomBarIconSize => bottomBarHeight / 2.25;

  final PageController appPageController = PageController(initialPage: 1);
  int _tabIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    trueDebugPrint('CurrentUser ${UserAPI.currentUser}');

    _tabIndex = widget.initAction ??
        Provider.of<SettingsProvider>(currentContext, listen: false).homeSplashIndex;

    Instances.eventBus
      ..on<ActionsEvent>().listen((ActionsEvent event) {
        final int index = Constants.quickActionsList.keys.toList().indexOf(event.type);
        if (index != -1) {
          _selectedTab(index);
          if (mounted) {
            setState(() {});
          }
        }
      });
  }

  void _selectedTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  /// Announcement widget.
  /// 公告组件
  Widget get announcementWidget => Selector<SettingsProvider, bool>(
        selector: (_, SettingsProvider provider) => provider.announcementsUserEnabled,
        builder: (_, bool announcementsUserEnabled, __) {
          if (announcementsUserEnabled) {
            return AnnouncementWidget(gap: 24.0, canClose: true);
          } else {
            return const SizedBox.shrink();
          }
        },
      );

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: Material(
        type: MaterialType.transparency,
        child: PageView(
          controller: appPageController,
          scrollDirection: Axis.vertical,
          children: <Widget>[
//            Container(color: currentThemeColor, child: Center(child: Text('App Page'))),
            Scaffold(
              key: Instances.mainPageScaffoldKey,
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    announcementWidget,
                    Expanded(
                      child: IndexedStack(
                        children: <Widget>[
                          PostSquarePage(),
                          MarketingPage(),
                          AppsPage(key: Instances.appsPageStateKey),
                          MessagePage(),
                        ],
                        index: _tabIndex,
                      ),
                    ),
                  ],
                ),
              ),
              drawer: SelfPage(),
              drawerEdgeDragWidth: Screens.width * 0.25,
              bottomNavigationBar: FABBottomAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                color: Colors.grey[600].withOpacity(currentIsDark ? 0.8 : 0.4),
                height: bottomBarHeight,
                iconSize: bottomBarIconSize,
                selectedColor: currentThemeColor,
                itemFontSize: 16.0,
                onTabSelected: _selectedTab,
                showText: true,
                initIndex: _tabIndex,
                items: List<FABBottomAppBarItem>.generate(
                  pagesTitle.length,
                  (int i) => FABBottomAppBarItem(iconPath: pagesIcon[i], text: pagesTitle[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
