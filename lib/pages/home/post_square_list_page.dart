import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/pages/notification/notification_entry_page.dart';
import 'package:openjmu/pages/post/marketing_page.dart';

class PostSquareListPage extends StatefulWidget {
  @override
  PostSquareListPageState createState() => PostSquareListPageState();
}

class PostSquareListPageState extends State<PostSquareListPage>
    with SingleTickerProviderStateMixin {
  static final List<String> tabs = [
    '广场',
//    '关注',
    '集市',
//    '新闻',
  ];
  static List<Widget> _post;

  List<bool> hasLoaded;
  List<Function> pageLoad = [
    () {
      _post[0] = PostList(
        PostController(
          postType: 'square',
          isFollowed: false,
          isMore: false,
          lastValue: (int id) => id,
        ),
        needRefreshIndicator: true,
      );
    },
//    () {
//      _post[1] = PostList(
//        PostController(
//          postType: 'square',
//          isFollowed: true,
//          isMore: false,
//          lastValue: (int id) => id,
//        ),
//        needRefreshIndicator: true,
//      );
//    },
    () {
      _post[1] = MarketingPage();
    },
//    () {
//      _post[2] = NewsListPage();
//    },
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: Provider.of<SettingsProvider>(
        currentContext,
        listen: false,
      ).homeStartUpIndex[0],
      length: tabs.length,
      vsync: this,
    );

    _post = List(_tabController.length);
    hasLoaded = [for (int i = 0; i < _tabController.length; i++) false];
    hasLoaded[_tabController.index] = true;
    pageLoad[_tabController.index]();

    _tabController.addListener(() {
      if (!hasLoaded[_tabController.index]) {
        setState(() {
          hasLoaded[_tabController.index] = true;
        });
      }
      pageLoad[_tabController.index]();
    });
  }

  Widget get tabBar => TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: RoundedUnderlineTabIndicator(
          borderSide: BorderSide(
            color: currentThemeColor,
            width: suSetHeight(3.0),
          ),
          width: suSetWidth(26.0),
          insets: EdgeInsets.only(bottom: suSetHeight(4.0)),
        ),
        labelColor: Theme.of(context).textTheme.body1.color,
        labelStyle: MainPageState.tabSelectedTextStyle,
        labelPadding: EdgeInsets.symmetric(horizontal: suSetWidth(16.0)),
        unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
        tabs: List<Tab>.generate(tabs.length, (index) => Tab(text: tabs[index])),
      );

  Widget get scanQrCodeButton => IconButton(
        icon: SvgPicture.asset(
          'assets/icons/scan-line.svg',
          color: Theme.of(context).iconTheme.color.withOpacity(0.3),
          width: suSetWidth(32.0),
          height: suSetWidth(32.0),
        ),
        onPressed: () async {
          final permissions = await PermissionHandler().requestPermissions(
            [PermissionGroup.camera],
          );
          if (permissions[PermissionGroup.camera] == PermissionStatus.granted) {
            unawaited(navigatorState.pushNamed(Routes.OPENJMU_SCAN_QRCODE));
          }
        },
      );

  Widget get searchButton => IconButton(
        icon: SvgPicture.asset(
          'assets/icons/search-line.svg',
          color: Theme.of(context).iconTheme.color.withOpacity(0.3),
          width: suSetWidth(32.0),
          height: suSetWidth(32.0),
        ),
        onPressed: () {
          navigatorState.pushNamed(Routes.OPENJMU_SEARCH, arguments: {'content': null});
        },
      );

  Widget get searchBar => Align(
        alignment: Alignment.centerRight,
        child: Container(
          height: suSetHeight(48.0),
          decoration: BoxDecoration(
            borderRadius: maxBorderRadius,
            color: Theme.of(context).canvasColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              searchButton,
              scanQrCodeButton,
            ],
          ),
        ),
      );

  Widget get notificationButton => Consumer<NotificationProvider>(
        builder: (_, provider, __) {
          return SizedBox(
            width: suSetWidth(60.0),
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  top: suSetHeight(kToolbarHeight / 5),
                  right: suSetWidth(2.0),
                  child: Visibility(
                    visible: provider.showNotification,
                    child: ClipRRect(
                      borderRadius: maxBorderRadius,
                      child: Container(
                        width: suSetWidth(12.0),
                        height: suSetWidth(12.0),
                        color: currentThemeColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: SvgPicture.asset(
                    'assets/icons/liuyan-line.svg',
                    color: Theme.of(context).iconTheme.color.withOpacity(0.3),
                    width: suSetWidth(32.0),
                    height: suSetWidth(32.0),
                  ),
                  onPressed: () {
                    navigatorState.push(TransparentRoute(
                      builder: (_) => NotificationEntryPage(),
                    ));
                  },
                ),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: suSetHeight(kAppBarHeight) + MediaQuery.of(context).padding.top,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: ExtendedTabBarView(
              cacheExtent: pageLoad.length - 1,
              controller: _tabController,
              children: List<Widget>.generate(
                _tabController.length,
                (i) => hasLoaded[i] ? _post[i] : SizedBox.shrink(),
              ),
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
                    tabBar,
                    Spacer(),
                    searchBar,
                    notificationButton,
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
