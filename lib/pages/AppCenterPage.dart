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
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class AppCenterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage> {
  final ScrollController _scrollController = new ScrollController();
  String sid;
  Color themeColor = ThemeUtils.currentColorTheme;
  Map<String, List<Widget>> webAppWidgetList = new Map();
  List<Widget> webAppList = [];
  List webAppListData;
  int listTotalSize = 0;

  @override
  void initState() {
    super.initState();
    getAppList();
    Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
      if (this.mounted && event.tabIndex == 1) {
        _scrollController.animateTo(0, duration: new Duration(milliseconds: 500), curve: Curves.ease);
      }
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        themeColor = event.color;
      });
    });
  }

  WebApp createWebApp(webAppData) {
    return new WebApp(
      webAppData['appid'],
      webAppData['sequence'],
      webAppData['code'],
      webAppData['name'],
      webAppData['url'],
      webAppData['menutype']
    );
  }

  void getAppList() async {
    NetUtils.getPlainWithCookieSet(
        Api.webAppLists
    ).then((response) {
      webAppListData = jsonDecode(response.toString());
      for (var i = 0; i < webAppListData.length; i++) {
        String url = webAppListData[i]['url'];
        String name = webAppListData[i]['name'];
        if ((url != "" && url != null) && (name != "" && name != null)) {
          WebApp _app = createWebApp(webAppListData[i]);
          WebApp.category().forEach((name, value) {
            if (_app.menuType == name) {
              if (webAppWidgetList[name] == null) {
                webAppWidgetList[name] = [];
              }
              webAppWidgetList[name].add(getWebAppButton(_app));
            }
          });
        }
      }
      List<Widget> _list = [];
      WebApp.category().forEach((name, value) {
        _list.add(getSectionColumn(name));
      });
      setState(() {
        webAppList = _list;
      });
    }).catchError((e) {
      print(e.toString());
      showShortToast(e.toString());
      return e;
    });
  }

  String replaceParamsInUrl(url) {
    RegExp sidReg = new RegExp(r"{SID}");
    RegExp uidReg = new RegExp(r"{UID}");
    String result = url;
    result = result.replaceAllMapped(sidReg, (match) => UserUtils.currentUser.sid.toString());
    result = result.replaceAllMapped(uidReg, (match) => UserUtils.currentUser.uid.toString());
    return result;
  }

  Widget getWebAppButton(webApp) {
    String url = replaceParamsInUrl(webApp.url);
    String imageUrl = Api.webAppIconsInsecure + "appid=${webApp.id}&code=${webApp.code}";
    Widget button = new FlatButton(
      padding: EdgeInsets.all(0.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Image(
              width: 64.0,
              height: 64.0,
              image: CachedNetworkImageProvider(imageUrl, cacheManager: DefaultCacheManager()),
              fit: BoxFit.cover
          ),
          new Text(
              webApp.name,
              style: new TextStyle(fontSize: 16.0)
          )
        ],
      ),
      onPressed: () {
        return CommonWebPage.jump(context, url, webApp.name);
//        return InAppBrowserPage.open(context, url, name);
      },
    );
    return button;
  }

  Widget getSectionColumn(name) {
    int rows = (webAppWidgetList[name].length / 3).ceil();
    if (webAppWidgetList[name].length != 0 && rows == 0) rows += 1;
    num _width = MediaQuery.of(context).size.width / 3;
    num _height = (_width / 1.3 * rows) + 58;
    return new Container(
      height: _height,
        child: new Column(
            children: <Widget>[
              new Container(
                margin: EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
                padding: EdgeInsets.symmetric(vertical: 8.0),
                width: MediaQuery.of(context).size.width,
                child: new Center(
                    child: new Text(
                        WebApp.category()[name],
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold
                        )
                    )
                ),
                decoration: new BoxDecoration(
                  border: Border(
                    bottom: Divider.createBorderSide(context, color: Colors.grey, width: 2.0),
                  ),
                ),
              ),
              new Container(
                  child: new GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 1.3 / 1,
                      children: webAppWidgetList[name]
                  )
              )
            ]
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    if (webAppList.length == 0) {
      return new Center(
        child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(themeColor),
        ),
      );
    } else {
      return new ListView(
        controller: _scrollController,
        children: webAppList
      );
    }
  }

}
