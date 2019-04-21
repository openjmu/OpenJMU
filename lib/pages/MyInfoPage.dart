import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/utils/OTAUpdate.dart';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/LoadingDialog.dart';

import 'dart:async';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
  Color themeColor = ThemeUtils.currentColorTheme;

//  List<String> titles = ["夜间模式", "切换主题", "退出登录", "测试页", "关于"];
  List<String> titles = ["夜间模式", "切换主题", "退出登录", "关于"];
//  List<IconData> icons = [Icons.invert_colors, Icons.color_lens, Icons.exit_to_app, Icons.dialpad, Icons.info];
  List<IconData> icons = [Icons.invert_colors, Icons.color_lens, Icons.exit_to_app, Icons.info];
  var userAvatar;
  var userName;
  var titleTextStyle = new TextStyle(fontSize: 16.0);
  var currentVersion;

  bool isLogin = false;
  bool isDark = false;

  void changeBrightness(bool isDark) {
    Constants.eventBus.fire(new ChangeBrightnessEvent(isDark));
  }

  @override
  void initState() {
    super.initState();
    OTAUpdate.getCurrentVersion().then((version) {
      setState(() {
        currentVersion = version;
      });
    });
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isLogin = isLogin;
      });
      getUserInfo();
    });
    DataUtils.getBrightnessDark().then((isDark) {
      setState(() {
        if (isDark != null) {
            this.isDark = isDark;
        } else {
            this.isDark = false;
        }
      });
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          themeColor = event.color;
        });
      }
    });
    Constants.eventBus.on<ChangeBrightnessEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          isDark = event.isDarkState;
        });
      }
    });
  }

  void getUserInfo() {
    String avatar = Api.userAvatar+"?uid=${UserUtils.currentUser.uid}&size=f128";
    setState(() {
      userAvatar = avatar;
      userName = UserUtils.currentUser.name;
    });
  }

  Widget renderRow(i) {
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
    DataUtils.setBrightnessDark(isDark);
    Constants.eventBus.fire(new ChangeBrightnessEvent(isDark));
  }

  @override
  Widget build(BuildContext context) {
    var listView = new ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => Container(
        color: Theme.of(context).dividerColor,
        height: 1.0,
      ),
      itemCount: titles.length,
      itemBuilder: (context, i) => renderRow(i),
    );
    return listView;
  }

  void _handleListItemClick(context, String title) {
    if (title == "退出登录") {
      showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text("注销"),
            content: Text("是否确认注销？"),
            actions: <Widget>[
              PlatformButton(
                android: (BuildContext context) => MaterialRaisedButtonData(
                  color: ThemeUtils.currentColorTheme,
                  elevation: 0,
                ),
                child: Text('确认', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  DataUtils.doLogout();
                },
              ),
              PlatformButton(
                android: (BuildContext context) => MaterialRaisedButtonData(
                  color: Theme.of(context).dialogBackgroundColor,
                  elevation: 0,
                ),
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
      );
    } else if (title == "夜间模式") {
      setDarkMode(!isDark);
    } else if (title == "切换主题") {
      Navigator.pushNamed(context, "/changeTheme");
    } else if (title == "测试页") {
//      Navigator.pushNamed(context, "/test");
      Navigator.pushNamed(context, "/notificationTest");
    } else if (title == "关于") {
      showAboutDialog(context);
    } else if (title == "检查更新") {
      OTAUpdate.checkUpdate();
    }
  }

  void showAboutDialog(BuildContext context) {
    final String name = 'OpenJMU';
    final String version = currentVersion;
    final Widget icon = new Image.asset(
        "images/ic_jmu_logo_trans_original.png",
        width: 40.0,
        height: 40.0
    );
    List<Widget> body = <Widget>[];
    if (icon != null)
      body.add(IconTheme(data: const IconThemeData(size: 48.0), child: icon));
    body.add(Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListBody(
                children: <Widget>[
                  Text(name, style: Theme.of(context).textTheme.headline),
                  Text(version, style: Theme.of(context).textTheme.body1),
                  Container(height: 18.0)
                ]
            )
        )
    ));
    body = <Widget>[
      Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: body
      ),
      RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: "Developed By ", style: TextStyle(color: Theme.of(context).textTheme.body1.color)),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    return CommonWebPage.jump(context, "https://blog.alexv525.com/", "Alex Vincent");
                  },
                  text: "Alex Vincent",
                  style: TextStyle(color: Colors.lightBlue)
              ),
              TextSpan(text: " And ", style: TextStyle(color: Theme.of(context).textTheme.body1.color)),
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      return CommonWebPage.jump(context, "https://135792468.xyz/", "Evsio0n");
                    },
                  text: "Evsio0n",
                  style: TextStyle(color: Colors.lightBlue)
              ),
              TextSpan(text: ".", style: TextStyle(color: Theme.of(context).textTheme.body1.color)),
            ]
          )
      )
    ];
    showDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
            content: SingleChildScrollView(
              child: ListBody(children: body),
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text(MaterialLocalizations.of(context).closeButtonLabel, style: TextStyle(color:ThemeUtils.currentColorTheme)),
                  onPressed: () {
                    Navigator.pop(context);
                  }
              ),
            ]
        )
    );
  }

}
