import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:jxt/api/Api.dart';
import 'package:jxt/utils/DataUtils.dart';
import 'package:jxt/utils/NetUtils.dart';
import 'package:jxt/utils/ThemeUtils.dart';
import 'package:jxt/utils/ToastUtils.dart';
import 'package:jxt/widgets/CommonWebPage.dart';

class AppCenterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage> {
  final ScrollController _controller = new ScrollController();
  String sid;
  Color themeColor = ThemeUtils.currentColorTheme;
  List<Widget> webAppList = [];
  List webAppListData;
  int listTotalSize = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && webAppList.length < listTotalSize) {
        getAppList();
      }
    });
    DataUtils.getSid().then((sid) {
      setState(() {
        this.sid = sid;
        getAppList();
      });
    });
  }

  void getAppList() async {
    List<Cookie> cookies = [
      new Cookie("PHPSESSID", sid)
    ];
    NetUtils.getPlainWithCookieSet(Api.webAppLists, cookies: cookies).then((response) {
//      setState(() {
        webAppListData = jsonDecode(response.toString());
//      });
//      List _listData = jsonDecode(response.toString());
      List<Widget> buttons = [];
      for (var i = 0; i < webAppListData.length; i++) {
        Widget button = getWebAppListButton(webAppListData[i]);
        if (button != null) {
          buttons.add(getWebAppListButton(webAppListData[i]));
        }
      }
      print(buttons);
      setState(() {
        webAppList.addAll(buttons);
      });
    }).catchError((e) {
      print(e.toString());
      showShortToast(e.toString());
      return e;
    });
  }

  String replaceSidInUrl(url) {
    RegExp reg = new RegExp(r"{SID}");
    String result = url.replaceAllMapped(reg, (match) => sid);
    return result;
  }

  Widget getWebAppListButton(appData) {
    if (appData['url'] != "" && appData['name'] != "") {
      String url = replaceSidInUrl(appData['url']);
      String name = appData['name'];
      print("$url $name");
      Widget button = new FlatButton(
        padding: EdgeInsets.all(0.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
                Icons.thumb_up,
                color: themeColor
            ),
            new Text(
                name,
                style: new TextStyle(color: themeColor)
            )
          ],
        ),
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) {
                return new CommonWebPage(title: name, url: url);
              }
          ));
        },
      );
      print(button);
      return button;
    }
  }

  Widget renderButton(i) {
    if (webAppListData[i]['url'] != "" && webAppListData[i]['name'] != "") {
      String url = replaceSidInUrl(webAppListData[i]['url']);
      String name = webAppListData[i]['name'];
      print("$url $name");
      Widget button = new FlatButton(
        padding: EdgeInsets.all(0.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
                Icons.apps,
                color: themeColor
            ),
            new Text(
                name,
                style: new TextStyle(color: themeColor)
            )
          ],
        ),
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) {
                return new CommonWebPage(title: name, url: url);
              }
          ));
        },
      );
      print(button);
      return button;
    }
  }

  Future<Null> _pullToRefresh() async {
    getAppList();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (webAppList == null) {
//    if (webAppListData == null) {
      return new Center(
        child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        ),
      );
    } else {
      Widget gridview = new GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1,
        children: webAppList
      );
//      Widget gridview = new GridView.builder(
//        shrinkWrap: true,
//        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//            crossAxisCount: 3
//        ),
//        itemCount: webAppList.length,
//        itemBuilder: (context, i) => renderButton(i),
//        controller: _controller,
//      );
      return new RefreshIndicator(child: gridview, onRefresh: _pullToRefresh);
    }
  }

}
