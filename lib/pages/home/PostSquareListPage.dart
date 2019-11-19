import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/news/NewsListPage.dart';
import 'package:OpenJMU/pages/post/MarketingPage.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/widgets/dialogs/ManuallySetSidDialog.dart';

class PostSquareListPage extends StatefulWidget {
  @override
  PostSquareListPageState createState() => PostSquareListPageState();
}

class PostSquareListPageState extends State<PostSquareListPage>
    with SingleTickerProviderStateMixin {
  static final List<String> tabs = [
    "首页",
    "关注",
    "集市",
    "新闻",
  ];
  static List<Widget> _post;

  Color currentThemeColor = ThemeUtils.currentThemeColor;
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
    () {
      _post[1] = PostList(
        PostController(
          postType: "square",
          isFollowed: true,
          isMore: false,
          lastValue: (int id) => id,
        ),
        needRefreshIndicator: true,
      );
    },
    () {
      _post[2] = MarketingPage();
    },
    () {
      _post[3] = NewsListPage();
//      _post[2] = NewsListPage();
    },
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

    Instances.eventBus.on<ChangeThemeEvent>().listen((event) {
      currentThemeColor = event.color;
      if (this.mounted) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onLongPress: () {
                if (Configs.debug) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => ManuallySetSidDialog(),
                  );
                } else {
                  NetUtils.updateTicket();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(right: suSetSp(4.0)),
                child: Text(
                  "Jmu",
                  style: TextStyle(
                    color: currentThemeColor,
                    fontSize: suSetSp(34),
                    fontFamily: "chocolate",
                  ),
                ),
              ),
            ),
            Flexible(
              child: TabBar(
                isScrollable: true,
                indicatorColor: currentThemeColor,
                indicatorPadding: EdgeInsets.only(bottom: suSetSp(16.0)),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: suSetSp(6.0),
                labelColor: Theme.of(context).textTheme.body1.color,
                labelStyle: MainPageState.tabSelectedTextStyle,
                labelPadding: EdgeInsets.symmetric(horizontal: suSetSp(16.0)),
                unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
                tabs: <Tab>[
                  for (int i = 0; i < tabs.length; i++) Tab(text: tabs[i])
                ],
                controller: _tabController,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/scan-line.svg",
              color: Theme.of(context).iconTheme.color,
              width: suSetSp(26.0),
              height: suSetSp(26.0),
            ),
            onPressed: () async {
              Map<PermissionGroup, PermissionStatus> permissions =
                  await PermissionHandler().requestPermissions([
                PermissionGroup.camera,
              ]);
              if (permissions[PermissionGroup.camera] ==
                  PermissionStatus.granted) {
                currentState.pushNamed("openjmu://scan-qrcode");
              }
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search-line.svg",
              color: Theme.of(context).iconTheme.color,
              width: suSetSp(26.0),
              height: suSetSp(26.0),
            ),
            onPressed: () {
              currentState.pushNamed(
                "openjmu://search",
                arguments: {"content": null},
              );
            },
          ),
        ],
      ),
      body: ExtendedTabBarView(
        cacheExtent: pageLoad.length - 1,
        controller: _tabController,
        children: <Widget>[
          for (int i = 0; i < _tabController.length; i++)
            hasLoaded[i]
                ? CupertinoScrollbar(child: _post[i])
                : SizedBox.shrink(),
        ],
      ),
    );
  }
}
