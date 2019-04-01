import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:jxt/api/Api.dart';
import 'package:jxt/constants/Constants.dart';
import 'package:jxt/events/ChangeBrightnessEvent.dart';
import 'package:jxt/events/ChangeThemeEvent.dart';
import 'package:jxt/events/LogoutEvent.dart';
import 'package:jxt/pages/ChangeThemePage.dart';
import 'package:jxt/utils/DataUtils.dart';
import 'package:jxt/utils/ThemeUtils.dart';

import 'package:jxt/pages/Test.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyInfoPageState();
  }
}

class MyInfoPageState extends State<MyInfoPage> {
  Color themeColor = ThemeUtils.currentColorTheme;

  var titles = ["夜间模式", "切换主题", "退出登录", "测试页"];
  var icons = [Icons.invert_colors, Icons.color_lens, Icons.exit_to_app, Icons.dialpad];
  var userAvatar;
  var userName;
  var titleTextStyle = new TextStyle(fontSize: 16.0);

  bool isLogin = false;
  bool isDark = false;

  void changeBrightness(bool isDark) {
    Constants.eventBus.fire(new ChangeBrightnessEvent(isDark));
  }

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isLogin = isLogin;
      });
      getUserInfo();
    });
    DataUtils.getBrightness().then((isDark) {
      if (isDark != null) {
        setState(() {
          this.isDark = isDark;
        });
      } else {
        this.isDark = false;
      }
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

  void getUserInfo() {
    DataUtils.getUserInfo().then((userInfo) {
      String avatar = Api.userFace+"?uid=${userInfo.uid}&size=f128";
      setState(() {
        userAvatar = avatar;
        userName = userInfo.name;
      });
    });
  }

  Widget renderRow(i) {
//    if (i == 0) {
//      var avatarContainer = new Container(
//        color: themeColor,
//        height: 200.0,
//        child: new Center(
//          child: new Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              userAvatar == null
//                ? new Image.asset(
//                  "images/ic_avatar_default.png",
//                  width: 100.0,
//                )
//                : new Container(
//                  width: 100.0,
//                  height: 100.0,
//                  decoration: new BoxDecoration(
//                    shape: BoxShape.circle,
//                    color: Colors.transparent,
//                    image: new DecorationImage(
//                        image: new NetworkImage(userAvatar),
//                        fit: BoxFit.cover
//                    ),
//                    border: new Border.all(
//                      color: Colors.white,
//                      width: 2.0,
//                    ),
//                  ),
//                ),
//                new Padding(
//                  padding: EdgeInsets.symmetric(vertical: 10.0),
//                ),
//                new Text(
//                  userName == null ? "点击头像登录" : userName,
//                  style: new TextStyle(color: Colors.white, fontSize: 24.0),
//                ),
//            ],
//          ),
//        ),
//      );
//      return new GestureDetector(
//        child: avatarContainer,
//      );
//    }
//    --i;
    // 添加分割线
    if (i.isOdd) {
      return new Divider(
        height: 1.0,
      );
    }
    // 恢复正常索引
    i = i ~/ 2;
    String title = titles[i];
    var listItemContent = new Padding(
      padding: title == "夜间模式"
        ? EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0)
        : EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0)
      ,
      child: new Row(
        children: <Widget>[
          new Container(
              padding: EdgeInsets.only(left: 4.0),
              child: new Icon(icons[i])
          ),
          new Expanded(
              child: new Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: new PlatformText(
                    title,
                    style: titleTextStyle,
                  )
              )
          ),
          title == "夜间模式"
              ? new PlatformSwitch(
                activeColor: themeColor,
                value: isDark,
                onChanged: (isDark) {
                  setDarkMode(isDark);
                  DataUtils.setBrightness(isDark);
                  Constants.eventBus.fire(ChangeBrightnessEvent(isDark));
                }
              )
              : new Icon(Icons.keyboard_arrow_right)
        ],
      ),
    );
    return new InkWell(
      child: listItemContent,
      onTap: () {
        _handleListItemClick(context, title);
      },
    );
  }

  void setDarkMode(isDark) {
    if (isDark) {
      ThemeUtils.currentPrimaryColor = Colors.grey[850];
      ThemeUtils.currentBrightness = Brightness.dark;
    } else {
      ThemeUtils.currentPrimaryColor = Colors.white;
      ThemeUtils.currentBrightness = Brightness.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    var listView = new ListView.builder(
      itemCount: titles.length * 2,  // 此处两倍数量用于添加分割线
//      itemCount: titles.length,
      itemBuilder: (context, i) => renderRow(i),
    );
    return listView;
  }

  void _handleListItemClick(context, String title) {
    if (title == "退出登录") {
      DataUtils.doLogout().then((whatever) {
        print("Logged out.");
      });
      DataUtils.clearLoginInfo().then((arg) {
        Constants.eventBus.fire(new LogoutEvent());
      });
    } else if (title == "切换主题") {
      Navigator.push(context, platformPageRoute(builder: (context) {
        return new ChangeThemePage();
      }));
    } else if (title == "测试页") {
      Navigator.push(context, platformPageRoute(builder: (context) {
        return new TestPage();
      }));
    }
  }
}
