import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:oktoast/oktoast.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
//import 'package:OpenJMU/pages/Test.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/OTAUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
//import 'package:OpenJMU/widgets/CommonWebPage.dart';
//import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';
import 'package:OpenJMU/widgets/dialogs/SelectSplashDialog.dart';


class MyInfoPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
    List<String> settingsItems = [
        "切换主题",
        "启动页",
        "夜间模式",
        if (Platform.isAndroid) "检查更新",
        "注销账户",
        if (isTest) "测试页",
        "关于",
    ];
    List<String> settingsIcons = [
        "theme",
        "homeSplash",
        "nightmode",
        if (Platform.isAndroid) "checkUpdate",
        "exit",
        if (isTest) "idols",
        "idols",
    ];

    Color themeColor = ThemeUtils.currentThemeColor;

    TextStyle titleTextStyle = TextStyle(fontSize: Constants.suSetSp(16.0));

    bool isLogin = false, isDark = false;
    bool signing = false, signed = false;

    int signedCount = 0, userLevel = 0, currentWeek;

    String hello = "你好";

    Timer updateHelloTimer;

    /// For test page.
    static bool isTest = false;

    @override
    void initState() {
        super.initState();
        updateHello();
        getSignStatus();
        getCurrentWeek();
        if (this.mounted) updateHelloTimer = Timer.periodic(Duration(minutes: 1), (timer) {
            updateHello();
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
        Constants.eventBus
            ..on<ChangeThemeEvent>().listen((event) {
                if (this.mounted) {
                    setState(() {
                        themeColor = event.color;
                    });
                }
            })
            ..on<ChangeBrightnessEvent>().listen((event) {
                if (this.mounted) isDark = event.isDarkState;
            });
    }

    @override
    void dispose() {
        super.dispose();
        updateHelloTimer?.cancel();
    }

    Future<Null> getSignStatus() async {
        var _signed = (await SignAPI.getTodayStatus()).data['status'];
        var _signedCount = (await SignAPI.getSignList()).data['signdata']?.length;
        var _userTasks = (await NetUtils.getWithCookieSet(Api.task)).data;
        setState(() {
            this.signedCount = _signedCount;
            this.signed = _signed == 1 ? true : false;
            this.userLevel = _userTasks['level'];
        });
    }

    Future<Null> getCurrentWeek() async {
        String _day = jsonDecode((await DateAPI.getCurrentWeek()).data)['start'];
        DateTime startDate = DateTime.parse(_day);
        DateTime currentDate = DateTime.now();
        int difference = startDate.difference(currentDate).inDays - 1;
        if (difference < 0) {
            int week = (difference / 7).abs().ceil();
            if (week <= 20) setState(() {
              this.currentWeek = week;
            });
        }
    }

    void updateHello() {
        int hour = DateTime.now().hour;
        setState(() {
            if (hour >= 0 && hour < 6) {
                this.hello = "深夜了，注意休息";
            } else if (hour >= 6 && hour < 8) {
                this.hello = "早上好";
            } else if (hour >= 8 && hour < 11) {
                this.hello = "上午好";
            } else if (hour >= 11 && hour < 14) {
                this.hello = "中午好";
            } else if (hour >= 14 && hour < 18) {
                this.hello = "下午好";
            } else if (hour >= 18 && hour < 20) {
                this.hello = "傍晚好";
            } else if (hour >= 20 && hour <= 24) {
                this.hello = "晚上好";
            }
        });
    }

    void requestSign() async {
        if (!signed) {
            setState(() { signing = true; });
            SignAPI.requestSign().then((response) {
                setState(() {
                    signed = true;
                    signing = false;
                    signedCount++;
                });
                getSignStatus();
            }).catchError((e) {
                print(e.toString());
            });
        }
    }

    void setDarkMode(isDark) {
        ThemeUtils.isDark = isDark;
        DataUtils.setBrightnessDark(isDark);
        Constants.eventBus.fire(new ChangeBrightnessEvent(isDark));
    }

    void showSelectSplashDialog(BuildContext context) {
        showDialog(
            context: context,
            builder: (_) => SelectSplashDialog(),
        );
    }

    void showLogoutDialog(BuildContext context) {
        showPlatformDialog(
            context: context,
            builder: (_) => PlatformAlertDialog(
                title: Text("注销"),
                content: Text("是否确认注销？"),
                actions: <Widget>[
                    PlatformButton(
                        android: (BuildContext context) => MaterialRaisedButtonData(
                            color: Theme.of(context).dialogBackgroundColor,
                            elevation: 0,
                            disabledElevation: 0.0,
                            highlightElevation: 0.0,
                            child: Text("确认", style: TextStyle(color: ThemeUtils.currentThemeColor)),
                        ),
                        ios: (BuildContext context) => CupertinoButtonData(
                            child: Text("确认", style: TextStyle(color: ThemeUtils.currentThemeColor),),
                        ),
                        onPressed: () {
                            DataUtils.doLogout();
                        },
                    ),
                    PlatformButton(
                        android: (BuildContext context) => MaterialRaisedButtonData(
                            color: ThemeUtils.currentThemeColor,
                            elevation: 0,
                            disabledElevation: 0.0,
                            highlightElevation: 0.0,
                            child: Text('取消', style: TextStyle(color: Colors.white)),
                        ),
                        ios: (BuildContext context) => CupertinoButtonData(
                            child: Text("取消", style: TextStyle(color: ThemeUtils.currentThemeColor)),
                        ),
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
                    ),
                ],
            ),
        );
    }

    Widget userInfo() {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(24.0), vertical: Constants.suSetSp(16.0)),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                GestureDetector(
                                    onTap: () => UserPage.jump(context, UserUtils.currentUser.uid),
                                    child: Container(
                                        width: Constants.suSetSp(90.0),
                                        height: Constants.suSetSp(90.0),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(Constants.suSetSp(45.0)),
                                            child: FadeInImage(
                                                fadeInDuration: const Duration(milliseconds: 100),
                                                placeholder: AssetImage("assets/avatar_placeholder.png"),
                                                image: UserUtils.getAvatarProvider(uid: UserUtils.currentUser.uid),
                                            ),
                                        ),
                                    ),
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: Constants.suSetSp(20.0)),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                        Expanded(
                                                            child: Wrap(
                                                                crossAxisAlignment: WrapCrossAlignment.end,
                                                                children: <Widget>[
                                                                    Text(
                                                                        "${UserUtils.currentUser.name}",
                                                                        style: TextStyle(
                                                                            color: Theme.of(context).textTheme.title.color,
                                                                            fontSize: Constants.suSetSp(24.0),
                                                                            fontWeight: FontWeight.bold,
                                                                        ),
                                                                        overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                        Text(
                                                            "　Lv.$userLevel　",
                                                            style: TextStyle(
                                                                color: Colors.red,
                                                                fontSize: Constants.suSetSp(16.0),
                                                            ),
                                                        ),
                                                        InputChip(
                                                            avatar: signing ? SizedBox(
                                                                width: Constants.suSetSp(14.0),
                                                                height: Constants.suSetSp(14.0),
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth: 2.0,
                                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                ),
                                                            ) : Icon(
                                                                Icons.assignment_turned_in,
                                                                color: Colors.white,
                                                                size: Constants.suSetSp(20.0),
                                                            ),
                                                            backgroundColor: ThemeUtils.currentThemeColor,
                                                            label: Text(
                                                                signed ? "已签$signedCount天" : "签到",
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: Constants.suSetSp(18.0),
                                                                ),
                                                            ),
                                                            labelPadding: EdgeInsets.zero,
                                                            padding: EdgeInsets.only(right: Constants.suSetSp(6.0)),
                                                            onPressed: () {
                                                                if (signing || signed) {
                                                                    return false;
                                                                } else {
                                                                    requestSign();
                                                                }
                                                            },
                                                        )
                                                    ],
                                                ),
                                                SizedBox(height: Constants.suSetSp(4.0)),
                                                Text(
                                                    UserUtils.currentUser.signature ?? "这里空空如也~",
                                                    style: TextStyle(
                                                        color: Theme.of(context).textTheme.caption.color,
                                                        fontSize: Constants.suSetSp(18.0),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    )
                ],
            ),
        );
    }

    void _handleItemClick(context, String item) {
        switch (item) {
            case "切换主题":
                Navigator.pushNamed(context, "/changeTheme");
                break;
            case "启动页":
                showSelectSplashDialog(context);
                break;
            case "夜间模式":
                setDarkMode(!isDark);
                break;
            case "检查更新":
                OTAUtils.checkUpdate();
                break;
            case "测试页":
//                showDialog(context: context, builder: (_) => TestPage());
                Navigator.pushNamed(context, "/test");
//                Navigator.pushNamed(context, "/notificationTest");
//                NetUtils.updateTicket();
                break;
            case "注销账户":
                showLogoutDialog(context);
                break;
            case "关于":
                Navigator.pushNamed(context, "/about");
                break;
            default:
                break;
        }
    }

    @override
    Widget build(BuildContext context) {
        return SafeArea(
            top: true,
            child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: ListView(
                    children: <Widget>[
                        userInfo(),
                        Constants.separator(context),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: settingsItems.length,
                            itemBuilder: (context, index) => Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.suSetSp(10.0),
                                    vertical: Constants.suSetSp(4.0),
                                ),
                                child: ListTile(
                                    leading: SvgPicture.asset(
                                        (settingsItems[index] == "夜间模式")
                                        ? isDark
                                                ? "assets/icons/daymode-line.svg"
                                                : "assets/icons/${settingsIcons[index]}-line.svg"
                                        : "assets/icons/${settingsIcons[index]}-line.svg"
                                        ,
                                        color: Theme.of(context).iconTheme.color,
                                        width: Constants.suSetSp(30.0),
                                        height: Constants.suSetSp(30.0),
                                    ),
                                    title: Text(
                                        (settingsItems[index] == "夜间模式")
                                                ? isDark
                                                ? "日间模式"
                                                : settingsItems[index]
                                                : settingsItems[index]
                                        ,
                                        style: TextStyle(fontSize: Constants.suSetSp(18.0)),
                                    ),
                                    trailing: Icon(Icons.keyboard_arrow_right),
                                    onTap: () { _handleItemClick(context, settingsItems[index]); },
                                ),
                            ),
                        ),
                    ],
                ),
            )
        );
    }

}