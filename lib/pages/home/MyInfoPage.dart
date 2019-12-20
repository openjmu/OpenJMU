import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/widgets/dialogs/ManuallySetSidDialog.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
  List<List<Map<String, String>>> settingsSection() => [
        if (Configs.debug)
          [
            {
              "name": "背包",
              "icon": "idols",
            },
          ],
        [
          if (!Provider.of<ThemesProvider>(currentContext, listen: false)
              .platformBrightness)
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

  bool isLogin = false;
  bool signing = false, signed = false;

  int signedCount = 0;

  DateTime now = DateTime.now();
  String hello = "你好";

  @override
  void initState() {
    getSignStatus();
    updateHello();

    super.initState();
  }

  void getSignStatus() async {
    int _signed = (await SignAPI.getTodayStatus()).data['status'];
    int _signedCount = (await SignAPI.getSignList()).data['signdata']?.length;
    signedCount = _signedCount;
    signed = _signed == 1 ? true : false;
    if (mounted) setState(() {});
  }

  void updateHello() {
    int hour = DateTime.now().hour;

    if (hour >= 0 && hour < 6) {
      hello = "深夜了，注意休息";
    } else if (hour >= 6 && hour < 8) {
      hello = "早上好";
    } else if (hour >= 8 && hour < 11) {
      hello = "上午好";
    } else if (hour >= 11 && hour < 14) {
      hello = "中午好";
    } else if (hour >= 14 && hour < 18) {
      hello = "下午好";
    } else if (hour >= 18 && hour < 20) {
      hello = "傍晚好";
    } else if (hour >= 20 && hour <= 24) {
      hello = "晚上好";
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

  void showLogoutDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("退出登录"),
        content: Text(
          "是否确认退出登录？",
          style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: suSetSp(18.0),
              ),
        ),
        actions: <Widget>[
          PlatformButton(
            android: (BuildContext context) => MaterialRaisedButtonData(
              color: Theme.of(context).dialogBackgroundColor,
              elevation: 0,
              disabledElevation: 0.0,
              highlightElevation: 0.0,
              child: Text(
                "确认",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            ios: (BuildContext context) => CupertinoButtonData(
              child: Text(
                "确认",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            onPressed: () {
              Navigator.of(_).pop();
              UserAPI.logout();
            },
          ),
          PlatformButton(
            android: (BuildContext context) => MaterialRaisedButtonData(
              color: currentThemeColor,
              elevation: 0,
              disabledElevation: 0.0,
              highlightElevation: 0.0,
              child: Text('取消', style: TextStyle(color: Colors.white)),
            ),
            ios: (BuildContext context) => CupertinoButtonData(
              child: Text(
                "取消",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            onPressed: Navigator.of(_).pop,
          ),
        ],
      ),
    );
  }

  Widget get _name => Row(
        children: <Widget>[
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                Text(
                  "${UserAPI.currentUser.name}",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.title.color,
                    fontSize: suSetSp(26.0),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );

  Widget get _signature => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              UserAPI.currentUser.signature ?? "这里空空如也~",
              style: TextStyle(
                color: Theme.of(context).textTheme.caption.color,
                fontSize: suSetSp(20.0),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      );

  Widget get _sign => InkWell(
        onTap: signed ? () {} : requestSign,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(suSetSp(20.0)),
          child: Container(
            color: currentThemeColor,
            padding: EdgeInsets.symmetric(
              horizontal: suSetSp(8.0),
              vertical: suSetSp(6.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: suSetSp(4.0),
                  ),
                  child: signing
                      ? Container(
                          width: suSetWidth(24.0),
                          height: suSetWidth(24.0),
                          padding: EdgeInsets.all(suSetWidth(4.0)),
                          child: CircularProgressIndicator(
                            strokeWidth: suSetWidth(3.0),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          Icons.assignment_turned_in,
                          color: Colors.white,
                          size: suSetWidth(26.0),
                        ),
                ),
                Text(
                  signed ? "已签$signedCount天" : "签到",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: suSetSp(20.0),
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget get userInfo => Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.only(top: Screen.topSafeHeight),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => UserPage.jump(UserAPI.currentUser.uid),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: suSetWidth(24.0),
              vertical: suSetHeight(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: suSetHeight(10.0)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      UserAPI.getAvatar(size: 100),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: suSetWidth(20.0)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _name,
                              emptyDivider(height: suSetHeight(10.0)),
                              _signature,
                              emptyDivider(height: suSetHeight(3.0)),
                            ],
                          ),
                        ),
                      ),
                      _sign,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget get currentDay => GestureDetector(
        onLongPress: () {
          if (Configs.debug) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => ManuallySetSidDialog(),
            );
          } else {
            NetUtils.updateTicket();
          }
        },
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(36.0),
            vertical: suSetHeight(20.0),
          ),
          child: Center(
            child: Selector<DateProvider, int>(
              selector: (_, provider) => provider.currentWeek,
              builder: (_, currentWeek, __) {
                return RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "${currentUser.name}，$hello~\n"),
                      TextSpan(text: "今天是"),
                      if (currentWeek != null)
                        TextSpan(text: "第$currentWeek周，"),
                      TextSpan(
                        text: "${DateFormat("MMMdd日，", "zh_CN").format(now)}",
                      ),
                      TextSpan(
                        text: "${DateFormat("EEEE", "zh_CN").format(now)}",
                      ),
                    ],
                    style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: suSetSp(24.0),
                        ),
                  ),
                );
              },
            ),
          ),
        ),
      );

  Widget settingSectionListView(context, int sectionIndex) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, i) => separator(
        context,
        color: Theme.of(context).canvasColor,
        height: 1.0,
      ),
      itemCount: settingsSection()[sectionIndex].length,
      itemBuilder: (context, itemIndex) =>
          settingItem(context, sectionIndex, itemIndex),
    );
  }

  Widget settingItem(context, int sectionIndex, int itemIndex) {
    final Map<String, String> item = settingsSection()[sectionIndex][itemIndex];
    return Selector<ThemesProvider, bool>(
      selector: (_, provider) => provider.dark,
      builder: (_, dark, __) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: suSetWidth(20.0),
              vertical: suSetHeight(18.0),
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: suSetWidth(12.0),
                    right: suSetWidth(24.0),
                  ),
                  child: SvgPicture.asset(
                    (item['name'] == "夜间模式")
                        ? dark
                            ? "assets/icons/daymode-line.svg"
                            : "assets/icons/${item['icon']}-line.svg"
                        : "assets/icons/${item['icon']}-line.svg",
                    color: Theme.of(context).iconTheme.color,
                    width: suSetWidth(40.0),
                    height: suSetHeight(32.0),
                  ),
                ),
                Expanded(
                  child: Text(
                    (item['name'] == "夜间模式")
                        ? dark ? "日间模式" : item['name']
                        : item['name'],
                    style: TextStyle(fontSize: suSetSp(23.0)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: suSetSp(12.0)),
                  child: SvgPicture.asset(
                    "assets/icons/arrow-right.svg",
                    color: Colors.grey,
                    width: suSetWidth(30.0),
                    height: suSetWidth(30.0),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            _handleItemClick(context, item['name']);
          },
        );
      },
    );
  }

  void _handleItemClick(context, String item) {
    switch (item) {
      case "背包":
        navigatorState.pushNamed("openjmu://backpack");
        break;

      case "夜间模式":
        final provider = Provider.of<ThemesProvider>(
          currentContext,
          listen: false,
        );
        provider.dark = !provider.dark;
        break;
      case "切换主题":
        navigatorState.pushNamed("openjmu://theme");
        break;
      case "设置":
        navigatorState.pushNamed("openjmu://settings");
        break;

      case "检查更新":
        OTAUtils.checkUpdate();
        break;
      case "关于OpenJMU":
        navigatorState.pushNamed("openjmu://about");
        break;

      case "退出登录":
        showLogoutDialog(context);
        break;

      case "测试页":
        navigatorState.pushNamed("openjmu://test-dashboard");
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
          userInfo,
          separator(context),
          currentDay,
          separator(context),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => separator(context),
            itemCount: settingsSection().length,
            itemBuilder: (context, index) =>
                settingSectionListView(context, index),
          ),
        ],
      ),
    );
  }
}
