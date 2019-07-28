import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/pages/ScorePage.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/InAppBrowser.dart';


class AppCenterPage extends StatefulWidget {
    final TabController controller;

    AppCenterPage({Key key, @required this.controller}) : super(key: key);

    @override
    State<StatefulWidget> createState() => AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage> {
    final ScrollController _scrollController = ScrollController();
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    static final List<String> tabs = ["课程表", if (Constants.isTest) "成绩", "应用"];

    Color themeColor = ThemeUtils.currentThemeColor;
    Map<String, List<Widget>> webAppWidgetList = {};
    List<Widget> webAppList = [];
    List webAppListData;
    int listTotalSize = 0;

    Future _futureBuilderFuture;

    @override
    void initState() {
        super.initState();
        _futureBuilderFuture = getAppList();
        Constants.eventBus
            ..on<ScrollToTopEvent>().listen((event) {
                if (this.mounted && event.tabIndex == 1) {
                    _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                }
            })
            ..on<ChangeThemeEvent>().listen((event) {
                if (this.mounted) setState(() {
                    themeColor = event.color;
                });
            })
            ..on<AppCenterRefreshEvent>().listen((event) {
                if (this.mounted) {
                    if (event.currentIndex == 0) {
                        Constants.eventBus.fire(CourseScheduleRefreshEvent());
                    } else if (event.currentIndex == 1) {
                        _scrollController.jumpTo(0.0);
                        refreshIndicatorKey.currentState.show();
                        getAppList();
                    }
                }
            });
    }

    WebApp createWebApp(webAppData) {
        return WebApp(
            id: webAppData['appid'],
            sequence: webAppData['sequence'],
            code: webAppData['code'],
            name: webAppData['name'],
            url: webAppData['url'],
            menuType: webAppData['menutype'],
        );
    }

    Future getAppList() async => NetUtils.getWithCookieSet(Api.webAppLists);

    Widget categoryListView(BuildContext context, AsyncSnapshot snapshot) {
        List<dynamic> data = snapshot.data?.data;
        Map<String, List<Widget>> appList = {};
        for (var i = 0; i < data.length; i++) {
            String url = data[i]['url'];
            String name = data[i]['name'];
            if ((url != "" && url != null) && (name != "" && name != null)) {
                WebApp _app = createWebApp(data[i]);
                WebApp.category().forEach((name, value) {
                    if (_app.menuType == name) {
                        if (appList[name.toString()] == null) {
                            appList[name.toString()] = [];
                        }
                        appList[name].add(getWebAppButton(_app));
                    }
                });
            }
        }
        webAppWidgetList = appList;
        List<Widget> _list = [];
        WebApp.category().forEach((name, value) {
            _list.add(getSectionColumn(name));
        });
        return ListView.builder(
            controller: _scrollController,
            itemCount: _list.length,
            itemBuilder: (BuildContext context, index) => _list[index],
        );
    }

    Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
            case ConnectionState.none:
                return Center(child: Text('尚未加载'));
            case ConnectionState.active:
                return Center(child: Text('正在加载'));
            case ConnectionState.waiting:
                return Center(
                    child: CircularProgressIndicator(),
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
        result = result.replaceAllMapped(sidReg, (match) => UserAPI.currentUser.sid.toString());
        result = result.replaceAllMapped(uidReg, (match) => UserAPI.currentUser.uid.toString());
        return result;
    }

    Widget getWebAppButton(webApp) {
        String url = replaceParamsInUrl(webApp.url);
        String imageUrl = "${Api.webAppIcons}"
                "appid=${webApp.id}"
                "&code=${webApp.code}"
        ;
        Widget button = FlatButton(
            padding: EdgeInsets.zero,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    SizedBox(
                        width: Constants.suSetSp(68.0),
                        height: Constants.suSetSp(68.0),
                        child: CircleAvatar(
                            backgroundColor: Theme.of(context).dividerColor,
                            child: Image(
                                width: Constants.suSetSp(44.0),
                                height: Constants.suSetSp(44.0),
                                image: CachedNetworkImageProvider(imageUrl, cacheManager: DefaultCacheManager()),
                                fit: BoxFit.cover,
                            ),
                        ),
                    ),
                    Text(
                        webApp.name,
                        style: TextStyle(
                            fontSize: Constants.suSetSp(17.0),
                            color: Theme.of(context).textTheme.body1.color,
                            fontWeight: FontWeight.normal,
                        ),
                    ),
                ],
            ),
            onPressed: () => CommonWebPage.jump(context, url, webApp.name),
        );
        return button;
    }

    Widget getSectionColumn(name) {
        if (webAppWidgetList[name] != null) {
            int rows = (webAppWidgetList[name].length / 3).ceil();
            if (webAppWidgetList[name].length != 0 && rows == 0) rows += 1;
            num _width = MediaQuery.of(context).size.width / 3;
            num _height = (_width / 1.3 * rows) + Constants.suSetSp(59);
            return Container(
                height: _height,
                child: Column(
                    children: <Widget>[
                        Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: Constants.suSetSp(36.0),
                                vertical: Constants.suSetSp(8.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: Constants.suSetSp(8.0)),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: Text(
                                    WebApp.category()[name],
                                    style: TextStyle(
                                        color: Theme.of(context).textTheme.title.color,
                                        fontSize: Constants.suSetSp(18.0),
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: Divider.createBorderSide(
                                        context,
                                        color: Theme.of(context).dividerColor,
                                        width: 2.0,
                                    ),
                                ),
                            ),
                        ),
                        GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            childAspectRatio: 1.3 / 1,
                            children: webAppWidgetList[name],
                        ),
                    ],
                ),
            );
        } else {
            return Container();
        }
    }

    @override
    Widget build(BuildContext context) {
        return ExtendedTabBarView(
            physics: NeverScrollableScrollPhysics(),
            cacheExtent: 2,
            children: <Widget>[
                if (UserAPI.currentUser.isTeacher != null) InAppBrowserPage(
                    url: ""
                            "${UserAPI.currentUser.isTeacher ? Api.courseScheduleTeacher : Api.courseSchedule}"
                            "?sid=${UserAPI.currentUser.sid}"
                            "&night=${ThemeUtils.isDark ? 1 : 0}",
                    title: "课程表",
                    withAppBar: false,
                    withAction: false,
                    keepAlive: true,
                ),
                if (tabs[1] == "成绩") ScorePage(),
                RefreshIndicator(
                    key: refreshIndicatorKey,
                    child: FutureBuilder(
                        builder: _buildFuture,
                        future: _futureBuilderFuture,
                    ),
                    onRefresh: getAppList,
                ),
            ],
            controller: widget.controller,
        );
    }
}
