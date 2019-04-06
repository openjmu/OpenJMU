import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class AppCenterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage> {
  final ScrollController _scrollController = new ScrollController();
  String sid;
  Color themeColor = ThemeUtils.currentColorTheme;
  List<Widget> webAppList;
  List webAppListData;
  int listTotalSize = 0;

  @override
  void initState() {
    super.initState();
    DataUtils.getSid().then((sid) {
      setState(() {
        this.sid = sid;
        getAppList(sid);
      });
    });
  }

  void getAppList(sid) async {
    NetUtils.getPlainWithCookieSet(
        Api.webAppLists,
        cookies: DataUtils.buildPHPSESSIDCookies(sid)
    ).then((response) {
      webAppListData = jsonDecode(response.toString());
      List<Widget> buttons = [];
      for (var i = 0; i < webAppListData.length; i++) {
        Widget button = getWebAppListButton(webAppListData[i]);
        if (button != null) {
          buttons.add(getWebAppListButton(webAppListData[i]));
        }
      }
      setState(() {
        webAppList = buttons;
      });
    }).catchError((e) {
      print(e.toString());
      showShortToast(e.toString());
      return e;
    });
    Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
      if (this.mounted && event.tabIndex == 1) {
        _scrollController.animateTo(0, duration: new Duration(milliseconds: 500), curve: Curves.ease);
      }
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
      String imageUrl = Api.webAppIcons + "appid=${appData['appid']}&code=${appData['code']}";
      Widget button = new FlatButton(
        padding: EdgeInsets.all(0.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Image(
              width: 64.0,
              height: 64.0,
              image: new NetworkImage(imageUrl),
              fit: BoxFit.cover
            ),
            new Text(
              name,
              style: new TextStyle(fontSize: 16.0)
            )
          ],
        ),
        onPressed: () {
          return CommonWebPage.jump(context, url, name);
        },
      );
      return button;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (webAppList == null) {
      return new Center(
        child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        ),
      );
    } else {
      return new GridView.count(
        controller: _scrollController,
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1.25 / 1,
        children: webAppList
      );
    }
  }

}
