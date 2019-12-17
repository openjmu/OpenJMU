import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/post/MarketingPage.dart';
//import 'package:OpenJMU/utils/NetUtils.dart';
//import 'package:OpenJMU/widgets/dialogs/ManuallySetSidDialog.dart';

class PostSquareListPage extends StatefulWidget {
  @override
  PostSquareListPageState createState() => PostSquareListPageState();
}

class PostSquareListPageState extends State<PostSquareListPage>
    with SingleTickerProviderStateMixin {
  static final List<String> tabs = [
    "微博广场",
//    "关注",
    "集市",
//    "新闻",
  ];
  static List<Widget> _post;

  final List<Map<String, dynamic>> notificationItems = [
    {
      "name": "评论/留言",
      "icons": "liuyan",
      "action": () {
        navigatorState.pushNamed("openjmu://notifications");
      },
    },
    {
      "name": "集市消息",
      "icons": "idols",
      "action": () {
        navigatorState.pushNamed("openjmu://team-notifications");
      },
    },
  ];

  List<bool> hasLoaded;
  List<Function> pageLoad = [
    () {
      _post[0] = PostList(
        PostController(
          postType: "square",
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
//          postType: "square",
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
    _tabController = TabController(
      initialIndex: Configs.homeStartUpIndex[0],
      length: tabs.length,
      vsync: this,
    );

    _post = List(_tabController.length);
    hasLoaded = [for (int i = 0; i < _tabController.length; i++) false];
    hasLoaded[_tabController.index] = true;
    pageLoad[_tabController.index]();

    _tabController.addListener(() {
      if (!hasLoaded[_tabController.index])
        setState(() {
          hasLoaded[_tabController.index] = true;
        });
      pageLoad[_tabController.index]();
    });

    super.initState();
  }

  Widget get tabBar => TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: RoundedUnderlineTabIndicator(
          borderSide: BorderSide(
            color: currentThemeColor,
            width: suSetHeight(2.5),
          ),
          width: suSetWidth(40.0),
          insets: EdgeInsets.only(bottom: suSetHeight(2.0)),
        ),
        labelColor: Theme.of(context).textTheme.body1.color,
        labelStyle: MainPageState.tabSelectedTextStyle,
        labelPadding: EdgeInsets.symmetric(
          horizontal: suSetWidth(16.0),
        ),
        unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
        tabs: List<Tab>.generate(
          tabs.length,
          (index) => Tab(text: tabs[index]),
        ),
      );

  Widget get scanQrCodeButton => SizedBox(
        width: suSetWidth(60.0),
        child: IconButton(
          alignment: Alignment.centerRight,
          icon: SvgPicture.asset(
            "assets/icons/scan-line.svg",
            color: Theme.of(context).iconTheme.color.withOpacity(0.3),
            width: suSetWidth(32.0),
            height: suSetWidth(32.0),
          ),
          onPressed: () async {
            final permissions = await PermissionHandler().requestPermissions(
              [PermissionGroup.camera],
            );
            if (permissions[PermissionGroup.camera] ==
                PermissionStatus.granted) {
              navigatorState.pushNamed("openjmu://scan-qrcode");
            }
          },
        ),
      );

  Widget get searchButton => SizedBox(
        width: suSetWidth(60.0),
        child: SvgPicture.asset(
          "assets/icons/search-line.svg",
          color: Theme.of(context).iconTheme.color.withOpacity(0.3),
          width: suSetWidth(32.0),
          height: suSetWidth(32.0),
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
                      borderRadius: BorderRadius.circular(100),
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
                    "assets/icons/liuyan-line.svg",
                    color: Theme.of(context).iconTheme.color.withOpacity(0.3),
                    width: suSetWidth(32.0),
                    height: suSetWidth(32.0),
                  ),
                  onPressed: () {
                    if (provider.notification.total > 0 &&
                        provider.teamNotification.total == 0) {
                      navigatorState.pushNamed("openjmu://notifications");
                    } else if (provider.teamNotification.total > 0 &&
                        provider.notification.total == 0) {
                      navigatorState.pushNamed("openjmu://team-notifications");
                    } else {}
                  },
                ),
              ],
            ),
          );
        },
      );

//  Widget _icon(int index) {
//    return SvgPicture.asset(
//      "assets/icons/${notificationItems[index]['icons']}-line.svg",
//      color: Theme.of(context).iconTheme.color,
//      width: suSetWidth(32.0),
//      height: suSetWidth(32.0),
//    );
//  }

//  Widget get _notificationEntries => Consumer<NotificationProvider>(
//        builder: (_, provider, __) {
//          return Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              GestureDetector(
//                behavior: HitTestBehavior.opaque,
//                child: Padding(
//                  padding: EdgeInsets.symmetric(
//                    horizontal: suSetWidth(18.0),
//                    vertical: suSetHeight(12.0),
//                  ),
//                  child: Row(
//                    children: <Widget>[
//                      Padding(
//                        padding: EdgeInsets.only(
//                          right: suSetSp(16.0),
//                        ),
//                        child: Padding(
//                          padding: const EdgeInsets.all(8.0),
//                          child: badgeIcon(
//                            content: provider.notification.total,
//                            icon: _icon(0),
//                            showBadge: provider.notification.total > 0,
//                          ),
//                        ),
//                      ),
//                      Expanded(
//                        child: Text(
//                          notificationItems[0]['name'],
//                          style: TextStyle(
//                            fontSize: suSetSp(22.0),
//                          ),
//                        ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.only(
//                          right: suSetSp(12.0),
//                        ),
//                        child: SvgPicture.asset(
//                          "assets/icons/arrow-right.svg",
//                          color: Colors.grey,
//                          width: suSetWidth(30.0),
//                          height: suSetWidth(30.0),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                onTap: notificationItems[0]['action'],
//              ),
//              separator(
//                context,
//                color: Theme.of(context).canvasColor,
//                height: 1.0,
//              ),
//              GestureDetector(
//                behavior: HitTestBehavior.opaque,
//                child: Padding(
//                  padding: EdgeInsets.symmetric(
//                    horizontal: suSetWidth(18.0),
//                    vertical: suSetHeight(12.0),
//                  ),
//                  child: Row(
//                    children: <Widget>[
//                      Padding(
//                        padding: EdgeInsets.only(
//                          right: suSetSp(16.0),
//                        ),
//                        child: Padding(
//                          padding: const EdgeInsets.all(8.0),
//                          child: badgeIcon(
//                            content: provider.teamNotification.total,
//                            icon: _icon(1),
//                            showBadge: provider.teamNotification.total > 0,
//                          ),
//                        ),
//                      ),
//                      Expanded(
//                        child: Text(
//                          notificationItems[1]['name'],
//                          style: TextStyle(
//                            fontSize: suSetSp(22.0),
//                          ),
//                        ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.only(
//                          right: suSetSp(12.0),
//                        ),
//                        child: SvgPicture.asset(
//                          "assets/icons/arrow-right.svg",
//                          color: Colors.grey,
//                          width: suSetWidth(30.0),
//                          height: suSetWidth(30.0),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                onTap: notificationItems[1]['action'],
//              ),
//            ],
//          );
//        },
//      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: suSetWidth(16.0)),
              child: Row(
                children: <Widget>[
//                GestureDetector(
//                  behavior: HitTestBehavior.opaque,
//                  onLongPress: () {
//                    if (Configs.debug) {
//                      showDialog(
//                        context: context,
//                        barrierDismissible: true,
//                        builder: (_) => ManuallySetSidDialog(),
//                      );
//                    } else {
//                      NetUtils.updateTicket();
//                    }
//                  },
//                  child: Container(
//                    margin: EdgeInsets.only(right: suSetWidth(8.0)),
//                    child: Text(
//                      "Jmu",
//                      style: TextStyle(
//                        color: currentThemeColor,
//                        fontSize: suSetSp(38.0),
//                        fontFamily: "chocolate",
//                      ),
//                    ),
//                  ),
//                ),
                  tabBar,
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        navigatorState.pushNamed(
                          "openjmu://search",
                          arguments: {"content": null},
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: suSetHeight(10.0),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
                          color: Theme.of(context).canvasColor,
                        ),
                        child: Row(
                          children: <Widget>[
                            searchButton,
                            Expanded(
                              child: Text(
                                "搜索",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(0.3),
                                  fontSize: suSetSp(20.0),
                                ),
                              ),
                            ),
                            scanQrCodeButton,
                          ],
                        ),
                      ),
                    ),
                  ),
                  notificationButton,
                ],
              ),
            ),
          ),
          Expanded(
            child: ExtendedTabBarView(
              cacheExtent: pageLoad.length - 1,
              controller: _tabController,
              children: <Widget>[
                for (int i = 0; i < _tabController.length; i++)
                  hasLoaded[i]
                      ? CupertinoScrollbar(child: _post[i])
                      : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
