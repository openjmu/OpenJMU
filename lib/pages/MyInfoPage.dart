import 'package:flutter/material.dart';
import 'package:jxt/api/Api.dart';
import 'package:jxt/constants/Constants.dart';
import 'package:jxt/events/ChangeBrightnessEvent.dart';
import 'package:jxt/events/ChangeThemeEvent.dart';
import 'package:jxt/events/LoginEvent.dart';
import 'package:jxt/events/LogoutEvent.dart';
import 'package:jxt/pages/ChangeThemePage.dart';
import 'package:jxt/utils/DataUtils.dart';
import 'package:jxt/utils/ThemeUtils.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyInfoPageState();
  }
}

class MyInfoPageState extends State<MyInfoPage> {
  Color themeColor = ThemeUtils.currentColorTheme;

  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  var titles = ["切换主题", "退出登录", "夜间模式"];
  var imagePaths = [
    'images/ic_discover_nearby.png',
    'images/ic_discover_nearby.png',
    'images/ic_discover_nearby.png'
  ];
  var icons = [];
  var userAvatar;
  var userName;
  var titleTextStyle = new TextStyle(fontSize: 16.0);
  var rightArrowIcon = new Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );

  bool isLogin = false;
  bool isDark = ThemeUtils.currentIsDarkState;

  void changeBrightness(bool isDark) {
    Constants.eventBus.fire(new ChangeBrightnessEvent(isDark));
  }

  MyInfoPageState() {
    for (int i = 0; i < imagePaths.length; i++) {
      icons.add(getIconImage(imagePaths[i]));
    }
  }

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isLogin = isLogin;
      });
      _getUserInfo();
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        themeColor = event.color;
      });
    });
    Constants.eventBus.on<ChangeBrightnessEvent>().listen((event) {
      setState(() {
        isDark = event.isDarkState;
      });
    });
  }

  void _getUserInfo() {
    DataUtils.getUserInfo().then((userInfo) {
      print(userInfo);
      String avatar = Api.userFace+"?uid=${userInfo.uid}&size=f100";
      setState(() {
        this.isLogin = isLogin;
        userAvatar = avatar;
        userName = userInfo.name;
      });
    });
  }

  Widget getIconImage(path) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: new Image.asset(path,
          width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
    );
  }

  Widget renderRow(i) {
    if (i == 0) {
      var avatarContainer = new Container(
        color: themeColor,
        height: 200.0,
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              userAvatar == null
                  ? new Image.asset(
                "images/ic_avatar_default.png",
                width: 100.0,
              )
                  : new Container(
                width: 100.0,
                height: 100.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  image: new DecorationImage(
                      image: new NetworkImage(userAvatar),
                      fit: BoxFit.cover),
                  border: new Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
              ),
              new Text(
                userName == null ? "点击头像登录" : userName,
                style: new TextStyle(color: Colors.white, fontSize: 24.0),
              ),
            ],
          ),
        ),
      );
      return new GestureDetector(
        child: avatarContainer,
      );
    }
    --i;
    if (i.isOdd) {
      return new Divider(
        height: 1.0,
      );
    }
    i = i ~/ 2;
    String title = titles[i];
    var listItemContent;
    if (title == "夜间模式") {
      listItemContent = new Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        child: new Row(
          children: <Widget>[
            icons[i],
            new Expanded(
                child: new Text(
                  title,
                  style: titleTextStyle,
                )
            ),
            new Switch(
              activeColor: themeColor,
                value: isDark,
                onChanged: (isDark) {
                  DataUtils.setBrightness(isDark);
                  Constants.eventBus.fire(ChangeBrightnessEvent(isDark));
                }
            )
          ],
        ),
      );
    } else {
      listItemContent = new Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        child: new Row(
          children: <Widget>[
            icons[i],
            new Expanded(
                child: new Text(
                  title,
                  style: titleTextStyle,
                )),
            rightArrowIcon
          ],
        ),
      );
    }
    return new InkWell(
      child: listItemContent,
      onTap: () {
        _handleListItemClick(context, title);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var listView = new ListView.builder(
      itemCount: titles.length * 2,
      itemBuilder: (context, i) => renderRow(i),
    );
    return listView;
  }

  void _handleListItemClick(context, String title) {
    if (title == "退出登录") {
      DataUtils.doLogout().then(() {
        print("Logged out.");
      });
      DataUtils.clearLoginInfo().then((arg) {
        Constants.eventBus.fire(new LogoutEvent());
      });
    } else if (title == "切换主题") {
      Navigator.push(context, new MaterialPageRoute(builder: (context) {
        return new ChangeThemePage();
      }));
    }
  }
}
