import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class AppCenterPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage> {
    final ScrollController _scrollController = ScrollController();
    Color themeColor = ThemeUtils.currentColorTheme;
    Map<String, List<Widget>> webAppWidgetList = {};
    List<Widget> webAppList = [];
    List webAppListData;
    int listTotalSize = 0;

    var _futureBuilderFuture;

    @override
    void initState() {
        super.initState();
        _futureBuilderFuture = getAppList();
        Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
            if (this.mounted && event.tabIndex == 1) {
                _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
            }
        });
        Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
            setState(() {
                themeColor = event.color;
            });
        });
    }

    WebApp createWebApp(webAppData) {
        return WebApp(
            webAppData['appid'],
            webAppData['sequence'],
            webAppData['code'],
            webAppData['name'],
            webAppData['url'],
            webAppData['menutype'],
        );
    }

    Future getAppList() async {
        return NetUtils.getPlainWithCookieSet(Api.webAppLists);
    }

    Widget categoryListView(BuildContext context, AsyncSnapshot snapshot) {
        List<dynamic> data = jsonDecode(snapshot.data.toString());
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
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
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
        result = result.replaceAllMapped(sidReg, (match) => UserUtils.currentUser.sid.toString());
        result = result.replaceAllMapped(uidReg, (match) => UserUtils.currentUser.uid.toString());
        return result;
    }

    Widget getWebAppButton(webApp) {
        String url = replaceParamsInUrl(webApp.url);
        String imageUrl = Api.webAppIconsInsecure + "appid=${webApp.id}&code=${webApp.code}";
        Widget button = FlatButton(
            padding: EdgeInsets.all(0.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Container(
                        width: 64,
                        height: 64,
                        child: CircleAvatar(
                            backgroundColor: Theme.of(context).dividerColor,
                            child: Image(
                                width: 44.0,
                                height: 44.0,
                                image: CachedNetworkImageProvider(imageUrl, cacheManager: DefaultCacheManager()),
                                fit: BoxFit.cover,
                            ),
                        ),
                    ),
                    Text(
                        webApp.name,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).textTheme.body1.color,
                            fontWeight: FontWeight.normal,
                        ),
                    ),
                ],
            ),
            onPressed: () {
                return CommonWebPage.jump(context, url, webApp.name);
            },
        );
        return button;
    }

    Widget getSectionColumn(name) {
        int rows = (webAppWidgetList[name].length / 3).ceil();
        if (webAppWidgetList[name].length != 0 && rows == 0) rows += 1;
        num _width = MediaQuery.of(context).size.width / 3;
        num _height = (_width / 1.3 * rows) + 58;
        return Container(
            height: _height,
            child: Column(
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Text(
                                WebApp.category()[name],
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.title.color,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: Divider.createBorderSide(context, color: Theme.of(context).dividerColor, width: 2.0),
                            ),
                        ),
                    ),
                    Container(
                        child: GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            childAspectRatio: 1.3 / 1,
                            children: webAppWidgetList[name],
                        ),
                    ),
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return RefreshIndicator(
            child: FutureBuilder(
                builder: _buildFuture,
                future: _futureBuilderFuture,
            ),
            onRefresh: getAppList,
        );
    }
}
