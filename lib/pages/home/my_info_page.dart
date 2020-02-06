import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/manually_set_sid_dialog.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyInfoPageState();
}

class MyInfoPageState extends State<MyInfoPage> {
  List<List<Map<String, String>>> settingsSection() => [
        if (Provider.of<SettingsProvider>(currentContext, listen: false).debug)
          [
            {'name': '背包', 'icon': 'idols'},
          ],
        [
          {
            'name': '夜间模式${Provider.of<ThemesProvider>(
              currentContext,
              listen: false,
            ).platformBrightness ? ' (已跟随系统)' : ''}',
            'icon': 'nightmode',
          },
          {'name': '偏好设置', 'icon': 'settings'},
        ],
        [
          {'name': '关于OpenJMU', 'icon': 'idols'},
        ],
        [
          {'name': '退出登录', 'icon': 'exit'},
        ],
        if (Provider.of<SettingsProvider>(currentContext, listen: false).debug)
          [
            {'name': '测试页', 'icon': 'idols'},
          ],
      ];

  bool isLogin = false;
  bool signing = false, signed = false;

  int signedCount = 0;

  DateTime now = DateTime.now();
  String hello = '你好';

  @override
  void initState() {
    super.initState();
    getSignStatus();
    updateHello();
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
      hello = '深夜了，注意休息';
    } else if (hour >= 6 && hour < 8) {
      hello = '早上好';
    } else if (hour >= 8 && hour < 11) {
      hello = '上午好';
    } else if (hour >= 11 && hour < 14) {
      hello = '中午好';
    } else if (hour >= 14 && hour < 18) {
      hello = '下午好';
    } else if (hour >= 18 && hour < 20) {
      hello = '傍晚好';
    } else if (hour >= 20 && hour <= 24) {
      hello = '晚上好';
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

  Widget get _name => Row(
        children: <Widget>[
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                Text(
                  '${UserAPI.currentUser.name}',
                  style: TextStyle(
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
              UserAPI.currentUser.signature ?? '这里空空如也~',
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/icons/sign-line.svg',
                          color: Colors.white,
                          width: suSetWidth(26.0),
                        ),
                ),
                Text(
                  signed ? '已签$signedCount天' : '签到',
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => navigatorState.pushNamed(
            Routes.OPENJMU_USER,
            arguments: {'uid': currentUser.uid},
          ),
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

  Widget get currentDay => Selector<SettingsProvider, bool>(
        selector: (_, provider) => provider.debug,
        builder: (_, debug, __) {
          return GestureDetector(
            onLongPress: () {
              if (debug) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => ManuallySetSidDialog(),
                );
              } else {
                NetUtils.updateTicket();
              }
            },
            child: Selector<DateProvider, int>(
              selector: (_, provider) => provider.currentWeek,
              builder: (_, currentWeek, __) => currentWeek != null && currentWeek <= 20
                  ? Container(
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: suSetWidth(36.0),
                        vertical: suSetHeight(20.0),
                      ),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: '${currentUser.name}，$hello~\n'),
                              TextSpan(text: '今天是'),
                              TextSpan(text: '${DateFormat('MMMdd', 'zh_CN').format(now)}日，'),
                              TextSpan(text: '${DateFormat('EEE', 'zh_CN').format(now)}，'),
                              if (currentWeek > 0)
                                TextSpan(children: <InlineSpan>[
                                  TextSpan(text: '第'),
                                  TextSpan(
                                    text: '$currentWeek',
                                    style: TextStyle(
                                      color: currentThemeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: '周'),
                                ])
                              else
                                TextSpan(children: <InlineSpan>[
                                  TextSpan(text: '距开学还有'),
                                  TextSpan(
                                    text: '${currentWeek.abs() + 1}',
                                    style: TextStyle(
                                      color: currentThemeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: '周'),
                                ]),
                            ],
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  fontSize: suSetSp(24.0),
                                ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          );
        },
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
      itemBuilder: (context, itemIndex) => settingItem(context, sectionIndex, itemIndex),
    );
  }

  Widget settingItem(context, int sectionIndex, int itemIndex) {
    final Map<String, String> item = settingsSection()[sectionIndex][itemIndex];
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
                (item['name'] == '夜间模式')
                    ? currentIsDark
                        ? 'assets/icons/daymode-line.svg'
                        : 'assets/icons/${item['icon']}-line.svg'
                    : 'assets/icons/${item['icon']}-line.svg',
                color: Theme.of(context).iconTheme.color,
                width: suSetWidth(40.0),
                height: suSetHeight(32.0),
              ),
            ),
            Expanded(
              child: Text(
                (item['name'] == '夜间模式') ? currentIsDark ? '日间模式' : item['name'] : item['name'],
                style: TextStyle(fontSize: suSetSp(23.0)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: suSetSp(12.0)),
              child: SvgPicture.asset(
                'assets/icons/arrow-right.svg',
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
  }

  void _handleItemClick(context, String item) {
    switch (item) {
      case '背包':
        navigatorState.pushNamed(Routes.OPENJMU_BACKPACK);
        break;

      case '夜间模式':
        final provider = Provider.of<ThemesProvider>(currentContext, listen: false);
        provider.dark = !provider.dark;
        break;
      case '切换主题':
        navigatorState.pushNamed(Routes.OPENJMU_THEME);
        break;
      case '偏好设置':
        navigatorState.pushNamed(Routes.OPENJMU_SETTINGS);
        break;

      case '关于OpenJMU':
        navigatorState.pushNamed(Routes.OPENJMU_ABOUT);
        break;

      case '退出登录':
        UserAPI.logout(context);
        break;

      case '测试页':
        navigatorState.pushNamed(Routes.OPENJMU_TEST_DASHBOARD);
        break;

      default:
        break;
    }
  }

  Widget get clearBoxesButton => UnconstrainedBox(
        child: Opacity(
          opacity: 0.3,
          child: Container(
            margin: EdgeInsets.only(top: suSetHeight(40.0)),
            padding: EdgeInsets.symmetric(
              horizontal: suSetWidth(30.0),
              vertical: suSetHeight(10.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey[currentIsDark ? 800 : 100],
                  blurRadius: suSetHeight(6.0),
                  offset: Offset(0, suSetHeight(6.0)),
                ),
              ],
              color: Theme.of(context).primaryColor,
            ),
            child: GestureDetector(
              onLongPress: () => HiveBoxes.clearBoxes(context),
              child: Text(
                '(DANGER)\n清除应用数据',
                style: TextStyle(
                  color: currentThemeColor,
                  fontSize: suSetSp(20.0),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Consumer<SettingsProvider>(
        builder: (_, provider, __) => ListView(
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
              itemBuilder: (context, index) => settingSectionListView(context, index),
            ),
            clearBoxesButton,
          ],
        ),
      ),
    );
  }
}
