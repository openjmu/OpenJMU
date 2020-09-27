import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/home/marketing_page.dart';
import 'package:openjmu/pages/home/message_page.dart';
import 'package:openjmu/pages/home/post_square_page.dart';
import 'package:openjmu/pages/home/school_work_page.dart';
import 'package:openjmu/pages/home/self_page.dart';

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

  /// Which page should be loaded at the first init time.
  /// 设置应初始化加载的页面索引
  final int initAction;

  @override
  State<StatefulWidget> createState() => MainPageState();

  /// Widget that placed in main page to open the self page.
  /// 首页顶栏左上角打开个人页的封装部件
  static Widget get selfPageOpener {
    return GestureDetector(
      onTap: Instances.mainPageScaffoldKey.currentState.openDrawer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 5.0.w),
            child: SvgPicture.asset(
              R.ASSETS_ICONS_SELF_PAGE_AVATAR_CORNER_SVG,
              color: currentTheme.iconTheme.color,
              height: 15.w,
            ),
          ),
          UserAvatar(size: 54.0, canJump: false)
        ],
      ),
    );
  }

  static Widget notificationButton({
    BuildContext context,
    bool isTeam = false,
  }) {
    return Consumer<NotificationProvider>(
      builder: (BuildContext _, NotificationProvider provider, Widget __) {
        return SizedBox(
          width: 56.w,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                top: (kToolbarHeight / 5).h,
                right: 2.w,
                child: Visibility(
                  visible: isTeam
                      ? provider.showTeamNotification
                      : provider.showNotification,
                  child: ClipRRect(
                    borderRadius: maxBorderRadius,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      color: currentThemeColor,
                    ),
                  ),
                ),
              ),
              MaterialButton(
                elevation: 0.0,
                minWidth: 56.w,
                height: 56.w,
                padding: EdgeInsets.zero,
                color: context.themeData.canvasColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(suSetWidth(13.0)),
                ),
                child: SvgPicture.asset(
                  R.ASSETS_ICONS_LIUYAN_LINE_SVG,
                  color: currentTheme.iconTheme.color,
                  width: suSetWidth(32.0),
                  height: suSetWidth(32.0),
                ),
                onPressed: () async {
                  provider.stopNotification();
                  await navigatorState.pushNamed(
                    Routes.openjmuNotifications,
                    arguments: <String, dynamic>{
                      'initialPage': isTeam ? '集市' : '广场',
                    },
                  );
                  provider.initNotification();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget publishButton(String route) {
    return MaterialButton(
      color: currentThemeColor,
      elevation: 0.0,
      minWidth: suSetWidth(120.0),
      height: 56.w,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(suSetWidth(13.0)),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: suSetWidth(6.0)),
            child: SvgPicture.asset(
              R.ASSETS_ICONS_SEND_SVG,
              height: suSetHeight(22.0),
              color: Colors.white,
            ),
          ),
          Text(
            '发动态',
            style: TextStyle(
              color: Colors.white,
              fontSize: suSetSp(20.0),
              height: 1.24,
            ),
          ),
        ],
      ),
      onPressed: () {
        navigatorState.pushNamed(route);
      },
    );
  }
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin {
  /// Titles for bottom navigation.
  /// 底部导航的各项标题
  static const List<String> pagesTitle = <String>['广场', '集市', '课业', '消息'];

  /// Icons for bottom navigation.
  /// 底部导航的各项图标
  static const List<String> pagesIcon = <String>[
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_SQUARE_SVG,
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_MARKET_SVG,
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_SCHOOL_WORK_SVG,
    R.ASSETS_ICONS_BOTTOM_NAVIGATION_MESSAGES_SVG,
  ];

  /// Bottom navigation bar's height;
  /// 底部导航的高度
  static const double bottomBarHeight = 72.0;

  /// Base text style for [TabBar].
  /// 顶部Tab的文字样式基类
  static TextStyle get _baseTabTextStyle => TextStyle(
        fontSize: 23.0.sp,
        textBaseline: TextBaseline.alphabetic,
      );

  /// Selected text style for [TabBar].
  /// 选中的Tab文字样式
  static TextStyle get tabSelectedTextStyle => _baseTabTextStyle.copyWith(
        fontWeight: FontWeight.bold,
      );

  /// Un-selected text style for [TabBar].
  /// 未选中的Tab文字样式
  static TextStyle get tabUnselectedTextStyle => _baseTabTextStyle.copyWith(
        fontWeight: FontWeight.w300,
      );

  /// Index for pages.
  /// 当前页面索引
  int _currentIndex;

  /// Icon size for bottom navigation bar's item.
  /// 底部导航的图标大小
  double get bottomBarIconSize => bottomBarHeight / 1.75;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    trueDebugPrint('CurrentUser ${UserAPI.currentUser}');

    /// Initialize current page index.
    /// 设定初始页面
    _currentIndex = widget.initAction ??
        Provider.of<SettingsProvider>(currentContext, listen: false)
            .homeSplashIndex;

    Instances.eventBus
      ..on<ActionsEvent>().listen((ActionsEvent event) {
        /// Listen to actions event to react with quick actions both on Android and iOS.
        /// 监听原生捷径时间以切换页面
        final int index =
            Constants.quickActionsList.keys.toList().indexOf(event.type);
        if (index != -1) {
          _selectedTab(index);
          if (mounted) setState(() {});
        }
      });
  }

  /// Method to update index.
  /// 切换页面方法
  void _selectedTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  /// Announcement widget.
  /// 公告组件
  Widget get announcementWidget {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Selector<SettingsProvider, bool>(
          selector: (BuildContext _, SettingsProvider provider) =>
              provider.announcementsUserEnabled,
          builder: (BuildContext _, bool announcementsUserEnabled, Widget __) {
            if (announcementsUserEnabled) {
              return AnnouncementWidget(
                height: 72.w,
                gap: 24.0,
                canClose: true,
                backgroundColor: currentThemeColor,
                radius: 15.w,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  /// Bottom navigation bar.
  /// 底部导航栏
  Widget get bottomNavigationBar => FABBottomAppBar(
        backgroundColor: Theme.of(context).primaryColor,
        color: Colors.grey[600].withOpacity(currentIsDark ? 0.8 : 0.4),
        height: bottomBarHeight,
        iconSize: bottomBarIconSize,
        selectedColor: currentThemeColor,
        itemFontSize: 16.0,
        onTabSelected: _selectedTab,
        showText: false,
        initIndex: _currentIndex,
        items: List<FABBottomAppBarItem>.generate(
          pagesTitle.length,
          (int i) => FABBottomAppBarItem(
            iconPath: pagesIcon[i],
            text: pagesTitle[i],
          ),
        ),
      );

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (Instances.mainPageScaffoldKey.currentState.isDrawerOpen) {
          Instances.mainPageScaffoldKey.currentState.openEndDrawer();
          return false;
        } else {
          return doubleBackExit();
        }
      },
      child: Scaffold(
        key: Instances.mainPageScaffoldKey,
        body: Stack(
          children: <Widget>[
            IndexedStack(
              children: <Widget>[
                const PostSquarePage(),
                const MarketingPage(),
                SchoolWorkPage(key: Instances.schoolWorkPageStateKey),
                const MessagePage(),
              ],
              index: _currentIndex,
            ),
            announcementWidget,
          ],
        ),
        drawer: SelfPage(),
        drawerEdgeDragWidth: Screens.width * 0.0666,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
