import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/api/DateAPI.dart';
import 'package:OpenJMU/api/SignAPI.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/constants/Configs.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/constants/Screens.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/OTAUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
  final List<List<Map<String, String>>> settingsSection = [
    if (Configs.debug)
      [
        {
          "name": "背包",
          "icon": "idols",
        },
      ],
    [
      {
        "name": "夜间模式",
        "icon": "nightmode",
      },
      {
        "name": "设置",
        "icon": "settings",
      },
    ],
    [
      if (Platform.isAndroid)
        {
          "name": "检查更新",
          "icon": "checkUpdate",
        },
      {
        "name": "关于OpenJMU",
        "icon": "idols",
      },
    ],
    [
      {
        "name": "退出登录",
        "icon": "exit",
      },
    ],
    if (Configs.debug)
      [
        {
          "name": "测试页",
          "icon": "idols",
        },
      ],
  ];

  Color themeColor = ThemeUtils.currentThemeColor;

  TextStyle titleTextStyle = TextStyle(fontSize: Constants.suSetSp(16.0));

  bool isLogin = false, isDark = false;
  bool signing = false, signed = false;

  int signedCount = 0, currentWeek;

  DateTime now = DateTime.now();
  String hello = "你好";

  Timer _timer;

  @override
  void initState() {
    isDark = DataUtils.getBrightnessDark();

    getSignStatus();
    getCurrentWeek();
    updateHello();

    if (_timer == null)
      _timer = Timer.periodic(Duration(minutes: 1), (timer) {
        now = DateTime.now();
        getSignStatus();
        getCurrentWeek();
        updateHello();
      });
    Instances.eventBus
      ..on<ChangeThemeEvent>().listen((event) {
        themeColor = event.color;
        if (mounted) setState(() {});
      })
      ..on<ChangeBrightnessEvent>().listen((event) {
        isDark = event.isDarkState;
        if (mounted) setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void getSignStatus() async {
    int _signed = (await SignAPI.getTodayStatus()).data['status'];
    int _signedCount = (await SignAPI.getSignList()).data['signdata']?.length;
    if (mounted)
      setState(() {
        this.signedCount = _signedCount;
        this.signed = _signed == 1 ? true : false;
      });
  }

  void getCurrentWeek() async {
    if (DateAPI.startDate == null) {
      String _day = jsonDecode((await DateAPI.getCurrentWeek()).data)['start'];
      DateAPI.startDate = DateTime.parse(_day);
    }
    DateAPI.difference = DateAPI.startDate.difference(now).inDays - 1;
    DateAPI.currentWeek = -(DateAPI.difference / 7).floor();
    if (DateAPI.currentWeek <= 20) {
      currentWeek = DateAPI.currentWeek;
    } else {
      currentWeek = null;
    }
    if (mounted) setState(() {});
    Instances.eventBus.fire(CurrentWeekUpdatedEvent());
  }

  void updateHello() {
    int hour = DateTime.now().hour;

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
    if (mounted) setState(() {});
  }

  void requestSign() {
    if (!signed) {
      setState(() {
        signing = true;
      });
      SignAPI.requestSign().then((response) {
        setState(() {
          signed = true;
          signing = false;
          signedCount++;
        });
        getSignStatus();
      }).catchError((e) {
        debugPrint(e.toString());
      });
    }
  }

  static void setDarkMode(isDark) {
    ThemeUtils.isDark = isDark;
    DataUtils.setBrightnessDark(isDark);
    Instances.eventBus.fire(ChangeBrightnessEvent(isDark));
  }

  void showLogoutDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("退出登录"),
        content: Text(
          "是否确认退出登录？",
          style: Theme.of(context).textTheme.body1.copyWith(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          PlatformButton(
            android: (BuildContext context) => MaterialRaisedButtonData(
              color: Theme.of(context).dialogBackgroundColor,
              elevation: 0,
              disabledElevation: 0.0,
              highlightElevation: 0.0,
              child: Text("确认",
                  style: TextStyle(color: ThemeUtils.currentThemeColor)),
            ),
            ios: (BuildContext context) => CupertinoButtonData(
              child: Text(
                "确认",
                style: TextStyle(color: ThemeUtils.currentThemeColor),
              ),
            ),
            onPressed: () {
              Navigator.of(_).pop();
              UserAPI.logout();
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
              child: Text("取消",
                  style: TextStyle(color: ThemeUtils.currentThemeColor)),
            ),
            onPressed: Navigator.of(_).pop,
          ),
        ],
      ),
    );
  }

  Widget userInfo() {
    Widget avatar = SizedBox(
      width: Constants.suSetSp(100.0),
      height: Constants.suSetSp(100.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Constants.suSetSp(50.0)),
        child: FadeInImage(
          fadeInDuration: const Duration(milliseconds: 100),
          placeholder: AssetImage("assets/avatar_placeholder.png"),
          image: UserAPI.getAvatarProvider(uid: UserAPI.currentUser.uid),
        ),
      ),
    );
    Widget name = Row(
      children: <Widget>[
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              Text(
                "${UserAPI.currentUser.name}",
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
      ],
    );
    Widget signature = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            UserAPI.currentUser.signature ?? "这里空空如也~",
            style: TextStyle(
              color: Theme.of(context).textTheme.caption.color,
              fontSize: Constants.suSetSp(18.0),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
    Widget sign = InkWell(
      onTap: signed ? () {} : requestSign,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
        child: Container(
          color: ThemeUtils.currentThemeColor,
          padding: EdgeInsets.symmetric(
            horizontal: Constants.suSetSp(8.0),
            vertical: Constants.suSetSp(6.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: Constants.suSetSp(signing ? 3.0 : 0.0),
                  bottom: Constants.suSetSp(signing ? 3.0 : 0.0),
                  left: Constants.suSetSp(signing ? 2.0 : 0.0),
                  right: Constants.suSetSp(signing ? 8.0 : 4.0),
                ),
                child: signing
                    ? SizedBox(
                        width: Constants.suSetSp(18.0),
                        height: Constants.suSetSp(18.0),
                        child: Constants.progressIndicator(
                          strokeWidth: 3.0,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.assignment_turned_in,
                        color: Colors.white,
                        size: Constants.suSetSp(24.0),
                      ),
              ),
              Text(
                signed ? "已签$signedCount天" : "签到",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Constants.suSetSp(18.0),
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(top: Screen.topSafeHeight),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => UserPage.jump(context, UserAPI.currentUser.uid),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.suSetSp(24.0),
            vertical: Constants.suSetSp(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    avatar,
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: Constants.suSetSp(20.0)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            name,
                            Constants.emptyDivider(
                              height: Constants.suSetSp(10.0),
                            ),
                            signature,
                            Constants.emptyDivider(
                              height: Constants.suSetSp(3.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    sign,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget currentDay(context, DateTime now) => Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: Constants.suSetSp(30.0),
          vertical: Constants.suSetSp(20.0),
        ),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "${UserAPI.currentUser.name}，$hello~\n"),
                TextSpan(text: "今天是"),
                if (currentWeek != null) TextSpan(text: "第$currentWeek周，"),
                TextSpan(text: "${DateFormat("MMMdd日，", "zh_CN").format(now)}"),
                TextSpan(text: "${DateFormat("EEEE", "zh_CN").format(now)}"),
              ],
              style: TextStyle(
                fontSize: Constants.suSetSp(20.0),
                color: Theme.of(context).textTheme.body1.color,
              ),
            ),
          ),
        ),
      );

  Widget settingSectionListView(context, int sectionIndex) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, i) => Constants.separator(
        context,
        color: Theme.of(context).canvasColor,
        height: 1.0,
      ),
      itemCount: settingsSection[sectionIndex].length,
      itemBuilder: (context, itemIndex) =>
          settingItem(context, sectionIndex, itemIndex),
    );
  }

  Widget settingItem(context, int sectionIndex, int itemIndex) {
    final Map<String, String> item = settingsSection[sectionIndex][itemIndex];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: Constants.suSetSp(18.0),
          vertical: Constants.suSetSp(18.0),
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: Constants.suSetSp(12.0),
                right: Constants.suSetSp(16.0),
              ),
              child: SvgPicture.asset(
                (item['name'] == "夜间模式")
                    ? isDark
                        ? "assets/icons/daymode-line.svg"
                        : "assets/icons/${item['icon']}-line.svg"
                    : "assets/icons/${item['icon']}-line.svg",
                color: Theme.of(context).iconTheme.color,
                width: Constants.suSetSp(30.0),
                height: Constants.suSetSp(30.0),
              ),
            ),
            Expanded(
              child: Text(
                (item['name'] == "夜间模式")
                    ? isDark ? "日间模式" : item['name']
                    : item['name'],
                style: TextStyle(fontSize: Constants.suSetSp(19.0)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: Constants.suSetSp(12.0)),
              child: SvgPicture.asset(
                "assets/icons/arrow-right.svg",
                color: Colors.grey,
                width: Constants.suSetSp(24.0),
                height: Constants.suSetSp(24.0),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _handleItemClick(context, item['name']);
      },
    );
  }

  void _handleItemClick(context, String item) {
    switch (item) {
      case "背包":
        Navigator.pushNamed(context, "/backpack");
        break;

      case "夜间模式":
        setDarkMode(!isDark);
        break;
      case "切换主题":
        Navigator.pushNamed(context, "/changeTheme");
        break;
      case "设置":
        Navigator.pushNamed(context, "/settings");
        break;

      case "检查更新":
        OTAUtils.checkUpdate();
        break;
      case "关于OpenJMU":
        Navigator.pushNamed(context, "/about");
        break;

      case "退出登录":
        showLogoutDialog(context);
        break;

      case "测试页":
        Navigator.pushNamed(context, "/test");
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          userInfo(),
          Constants.separator(context),
          currentDay(context, now),
          Constants.separator(context),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => Constants.separator(context),
            itemCount: settingsSection.length,
            itemBuilder: (context, index) =>
                settingSectionListView(context, index),
          ),
        ],
      ),
    );
  }
}
