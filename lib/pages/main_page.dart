///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-03-22 12:43
///
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/home/marketing_page.dart';
import 'package:openjmu/pages/home/message_page.dart';
import 'package:openjmu/pages/home/post_square_page.dart';
import 'package:openjmu/pages/home/school_work_page.dart';
import 'package:openjmu/pages/home/self_page.dart';
import 'package:openjmu/widgets/lazy_indexed_stack.dart';

@FFRoute(name: 'openjmu://home', routeName: '首页')
class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key ?? Instances.mainPageStateKey);

  @override
  State<StatefulWidget> createState() => MainPageState();

  /// Widget that placed in main page to open the self page.
  /// 首页顶栏左上角打开个人页的封装部件
  static Widget get selfPageOpener {
    return Tapper(
      onTap: () {
        Instances.mainPageStateKey.currentState._selfPageController
            .animateToPage(
          1,
          duration: kTabScrollDuration,
          curve: Curves.easeOutQuart,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15.w, right: 10.w),
            child: SvgPicture.asset(
              R.ASSETS_ICONS_SELF_PAGE_AVATAR_CORNER_SVG,
              color: currentTheme.textTheme.bodyText2.color,
              height: 14.w,
            ),
          ),
          UserAvatar(
            size: 54.0,
            canJump: false,
            isSysAvatar: UserAPI.currentUser.sysAvatar,
          ),
        ],
      ),
    );
  }

  static Widget notificationButton({
    @required BuildContext context,
    bool isTeam = false,
  }) {
    return SizedBox(
      width: 56.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Tapper(
            onTap: () async {
              final NotificationProvider p =
                  context.read<NotificationProvider>();
              p.stopNotification();
              await navigatorState.pushNamed(
                Routes.openjmuNotificationsPage.name,
                arguments: Routes.openjmuNotificationsPage.d(
                  pageType: isTeam
                      ? NotificationPageType.team
                      : NotificationPageType.square,
                ),
              );
              p.initNotification();
            },
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.w),
                color: context.theme.canvasColor,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                R.ASSETS_ICONS_NOTIFICATION_SVG,
                color: context.textTheme.bodyText2.color,
                width: 28.w,
              ),
            ),
          ),
          Positioned(
            top: 5.w,
            right: 5.w,
            child: Selector<NotificationProvider, bool>(
              selector: (_, NotificationProvider p) =>
                  isTeam ? p.showTeamNotification : p.showNotification,
              builder: (_, bool show, __) => Visibility(
                visible: show,
                child: ClipRRect(
                  borderRadius: maxBorderRadius,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    color: context.themeColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget outerNetworkIndicator(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;
    return ValueListenableBuilder<bool>(
      valueListenable: NetUtils.webVpnNotifier,
      builder: (_, bool value, __) {
        Widget child = const SizedBox.shrink();
        if (value) {
          child = Tapper(
            onTap: () {
              ConfirmationDialog.show(
                context,
                title: 'WebVPN 已连接',
                content: '由于校外网络限制，部分页面将通过 WebVPN 获取数据，'
                    '但仍有部分页面可能无法获取最新数据，请连接校园网后重试。',
                showConfirm: true,
                showCancel: false,
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Gap(8.w),
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: isDark
                          ? defaultThemeGroup.darkThemeColor
                          : defaultThemeGroup.lightThemeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Gap(6.w),
                  Text(
                    'WebVPN 已连接',
                    style: TextStyle(height: 1.45, fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          );
        }
        return AnimatedSwitcher(
          duration: kThemeChangeDuration,
          child: child,
        );
      },
    );
  }

  static Widget publishButton({
    @required BuildContext context,
    @required String route,
  }) {
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(route);
      },
      child: Container(
        width: 100.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.themeColor,
        ),
        alignment: Alignment.center,
        child: Text(
          '发动态',
          style: TextStyle(
            color: adaptiveButtonColor(),
            fontSize: 20.sp,
            height: 1.24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin, RouteAware {
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
  static const double bottomBarHeight = 80.0;

  /// Base text style for [TabBar].
  /// 顶部Tab的文字样式基类
  static TextStyle get _baseTabTextStyle => TextStyle(
        fontSize: 23.sp,
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

  /// 是否展示公告
  final ValueNotifier<bool> _showAnnouncement = ValueNotifier<bool>(true);

  /// 控制侧边栏的控制器
  final PageController _selfPageController = PageController();

  /// 当前左右滑动的页数
  final ValueNotifier<double> _currentPage = ValueNotifier<double>(0);

  /// Index for pages.
  /// 当前页面索引
  int _currentIndex;

  /// Icon size for bottom navigation bar's item.
  /// 底部导航的图标大小
  double get _bottomBarIconSize => bottomBarHeight / 2.25;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    DeviceUtils.setHighestRefreshRate();
    LogUtils.d('CurrentUser ${UserAPI.currentUser}');

    /// Initialize current page index.
    /// 设定初始页面
    _currentIndex = Provider.of<SettingsProvider>(
      currentContext,
      listen: false,
    ).homeSplashIndex;

    /// 进入首屏10秒后，公告默认消失
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(10.seconds, () {
        if (mounted && _showAnnouncement.value) {
          _showAnnouncement.value = false;
        }
      });
    });
    _selfPageController.addListener(() {
      if (_selfPageController.hasClients) {
        _currentPage.value = _selfPageController.page;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Instances.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _selfPageController.dispose();
    _showAnnouncement.dispose();
    Instances.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    context.read<NotificationProvider>().stopNotification();
  }

  @override
  void didPopNext() {
    context.read<NotificationProvider>().initNotification();
  }

  /// Method to update index.
  /// 切换页面方法
  void _selectedTab(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _scrollBackToMainPage() {
    _selfPageController.animateToPage(
      0,
      duration: kTabScrollDuration,
      curve: Curves.ease,
    );
  }

  /// Announcement widget.
  /// 公告组件
  Widget announcementWidget(BuildContext context) {
    if (!context.select<SettingsProvider, bool>(
      (SettingsProvider p) => p.announcementsEnabled,
    )) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<bool>(
      valueListenable: _showAnnouncement,
      builder: (_, bool isShowing, __) {
        final Map<String, dynamic> announcement = context
            .read<SettingsProvider>()
            .announcements[0] as Map<String, dynamic>;
        return AnimatedPositioned(
          duration: 1.seconds,
          curve: Curves.fastLinearToSlowEaseIn,
          bottom: isShowing ? 0.0 : -72.w,
          left: 0.0,
          right: 0.0,
          height: 72.w,
          child: Tapper(
            onTap: () {
              ConfirmationDialog.show(
                context,
                title: announcement['title'] as String,
                content: announcement['content'] as String,
                showCancel: false,
                showConfirm: true,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.w),
                  topRight: Radius.circular(20.w),
                ),
                color: context.theme.colorScheme.primary,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      announcement['title'] as String,
                      style: TextStyle(
                        color: adaptiveButtonColor(),
                        fontSize: 19.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Tapper(
                    onTap: () {
                      if (_showAnnouncement.value) {
                        _showAnnouncement.value = false;
                      }
                    },
                    child: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: adaptiveButtonColor(),
                      size: 40.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Bottom navigation bar.
  /// 底部导航栏
  Widget bottomNavigationBar(BuildContext context) {
    return FABBottomAppBar(
      index: _currentIndex,
      color: context.iconTheme.color,
      height: bottomBarHeight,
      iconSize: _bottomBarIconSize,
      selectedColor: context.themeColor,
      itemFontSize: 16.sp,
      onTabSelected: _selectedTab,
      items: List<FABBottomAppBarItem>.generate(
        pagesTitle.length,
        (int i) => FABBottomAppBarItem(
          iconPath: pagesIcon[i],
          text: pagesTitle[i],
        ),
      ),
    );
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: doubleBackExit,
      child: ListView(
        controller: _selfPageController,
        physics: const _CustomScrollPhysics(parent: ClampingScrollPhysics()),
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: <Widget>[
          ValueListenableBuilder<double>(
            valueListenable: _currentPage,
            builder: (_, double page, Widget child) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: page > 0 ? _scrollBackToMainPage : null,
              child: IgnorePointer(ignoring: page > 0, child: child),
            ),
            child: SizedBox.fromSize(
              size: Size(Screens.width, Screens.height),
              child: Scaffold(
                body: Stack(
                  children: <Widget>[
                    LazyIndexedStack(
                      children: <Widget>[
                        const PostSquarePage(),
                        const MarketingPage(),
                        SchoolWorkPage(key: Instances.schoolWorkPageStateKey),
                        const MessagePage(),
                      ],
                      index: _currentIndex,
                    ),
                    announcementWidget(context),
                  ],
                ),
                // drawer: SelfPage(),
                // drawerEdgeDragWidth: Screens.width * 0.3,
                bottomNavigationBar: bottomNavigationBar(context),
                resizeToAvoidBottomInset: false,
              ),
            ),
          ),
          SelfPage(),
        ],
      ),
    );
  }
}

class _CustomScrollPhysics extends PageScrollPhysics {
  const _CustomScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  _CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 500.0,
        ratio: 0.5,
      );
}
