///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-03-09 20:39
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/manually_set_sid_dialog.dart';

class SelfPage extends StatelessWidget {
  List<Map<String, dynamic>> get actions => <Map<String, dynamic>>[
        {
          'icon': R.ASSETS_ICONS_SCAN_LINE_SVG,
          'name': '扫码',
          'route': Routes.OPENJMU_SCAN_QRCODE,
        },
        {
          'icon': R.ASSETS_ICONS_IDOLS_LINE_SVG,
          'name': '背包',
          'route': Routes.OPENJMU_BACKPACK,
        },
        {
          'icon': R.ASSETS_ICONS_SETTINGS_THEME_COLOR_SVG,
          'name': '主题',
          'route': Routes.OPENJMU_THEME,
        },
        {
          'icon': R.ASSETS_ICONS_SETTINGS_NIGHT_MODE_SVG,
          'name': '夜间模式',
          'action': () {
            final ThemesProvider provider =
                Provider.of<ThemesProvider>(currentContext, listen: false);
            if (!provider.platformBrightness) {
              provider.dark = !provider.dark;
            }
          },
        },
      ];

  List<List<Map<String, dynamic>>> get settingsSection => <List<Map<String, dynamic>>>[
        [
          {
            'name': '偏好设置',
            'icon': R.ASSETS_ICONS_SETTINGS_LINE_SVG,
            'route': Routes.OPENJMU_SETTINGS,
          },
          {
            'name': '关于OpenJMU',
            'icon': R.ASSETS_ICONS_IDOLS_LINE_SVG,
            'route': Routes.OPENJMU_ABOUT,
          },
          {
            'name': '退出登录',
            'icon': R.ASSETS_ICONS_EXIT_LINE_SVG,
            'action': (BuildContext context) {
              UserAPI.logout(context);
            },
          },
        ],
        if (Provider.of<SettingsProvider>(currentContext, listen: false).debug)
          [
            {
              'name': '测试页',
              'icon': R.ASSETS_ICONS_IDOLS_LINE_SVG,
              'route': Routes.OPENJMU_TEST_DASHBOARD,
            },
          ],
      ];

  /// 顶部内容基础高度
  double get headerHeight => 200.0;

  /// Handler for setting item.
  /// 设置项的回调处理
  void _handleItemClick(BuildContext context, Map<String, dynamic> item) {
    if (item['route'] != null) {
      navigatorState.pushNamed(item['route'] as String);
    }
    if (item['action'] != null) {
      (item['action'] as Function(BuildContext))(context);
    }
  }

  /// Wrapper for header.
  /// 顶部部件封装
  Widget headerWrapper({@required Widget child}) {
    return Container(
      height: suSetHeight(headerHeight),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: -suSetWidth(30.0),
            child: SizedBox(
              width: double.maxFinite,
              child: Image(
                image: UserAPI.getAvatarProvider(),
                width: Screens.width,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: -suSetWidth(30.0),
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Color.fromARGB(120, 50, 50, 50)),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  /// School card widget.
  /// 校园卡部件
  Widget get userCard => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(25.0),
            vertical: suSetHeight(25.0),
          ),
          width: Screens.width * 0.7,
          height: suSetHeight(headerHeight - 20.0) - Screens.topSafeHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(suSetWidth(25.0)),
              topRight: Radius.circular(suSetWidth(25.0)),
            ),
            color: currentThemeColor,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color.fromRGBO(94, 121, 136, 1.0),
                Color.fromRGBO(53, 70, 78, 1.0),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: suSetHeight(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      R.IMAGES_JMU_NAME_PNG,
                      color: Color(0xffffcb28),
                    ),
                    ClipRRect(
                      borderRadius: maxBorderRadius,
                      child: Image.asset(R.IMAGES_LOGO_1024_PNG),
                    ),
                  ],
                ),
              ),
              Text(
                '${currentUser.workId}',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: suSetSp(22.0),
                  fontFamily: 'JetBrains Mono',
                  letterSpacing: suSetSp(4.0),
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black26,
                      offset: Offset(suSetWidth(4.0), suSetHeight(4.0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  /// Wrapper for content.
  /// 内容部件封装
  Widget contentWrapper({@required Widget child}) {
    return Expanded(
      child: OverflowBox(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(20.0),
            vertical: suSetHeight(20.0),
          ),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(suSetWidth(25.0)),
              topRight: Radius.circular(suSetWidth(25.0)),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 2.0,
                color: currentTheme.dividerColor,
                offset: Offset(0, -suSetHeight(2.0)),
              ),
            ],
            color: currentTheme.primaryColor,
          ),
          child: child,
        ),
      ),
    );
  }

  /// 签到按钮
  Widget get signButton => Consumer<SignProvider>(
        builder: (BuildContext _, SignProvider provider, Widget __) {
          return MaterialButton(
            color: currentThemeColor,
            minWidth: provider.hasSigned ? suSetWidth(130.0) : suSetWidth(100.0),
            height: suSetHeight(50.0),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(suSetWidth(13.0)),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (provider.isSigning)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: suSetWidth(6.0)),
                    width: suSetWidth(28.0),
                    height: suSetWidth(28.0),
                    child: CircularProgressIndicator(
                      strokeWidth: suSetWidth(3.0),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(right: suSetWidth(6.0)),
                    child: provider.hasSigned
                        ? Icon(
                            Icons.create,
                            color: Colors.white,
                            size: suSetWidth(28.0),
                          )
                        : SvgPicture.asset(
                            R.ASSETS_ICONS_SIGN_LINE_SVG,
                            color: Colors.white,
                            width: suSetWidth(28.0),
                          ),
                  ),
                Text(
                  provider.hasSigned ? '已签${provider.signedCount}天' : '签到',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: suSetSp(20.0),
                    height: 1.24,
                  ),
                ),
              ],
            ),
            onPressed: () {
              if (!provider.hasSigned) {
                provider.requestSign();
              }
            },
          );
        },
      );

  /// Section view for settings.
  /// 设置项的分区部件
  Widget settingSectionListView(BuildContext context, int index) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (BuildContext _, int __) => separator(
        context,
        color: Theme.of(context).canvasColor,
        height: suSetHeight(1.0),
      ),
      itemCount: settingsSection[index].length,
      itemBuilder: (BuildContext _, int itemIndex) => settingItem(context, index, itemIndex),
    );
  }

  /// Item view for setting.
  /// 设置项部件
  Widget settingItem(BuildContext context, int sectionIndex, int itemIndex) {
    final Map<String, dynamic> item = settingsSection[sectionIndex][itemIndex];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: suSetHeight(64.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: suSetWidth(12.0),
                right: suSetWidth(24.0),
              ),
              child: SvgPicture.asset(
                item['icon'] as String,
                color: currentThemeColor,
                width: suSetWidth(32.0),
              ),
            ),
            Expanded(
              child: Text(
                item['name'],
                style: TextStyle(fontSize: suSetSp(19.0)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: suSetSp(12.0)),
              child: SvgPicture.asset(
                R.ASSETS_ICONS_ARROW_RIGHT_SVG,
                color: Theme.of(context).dividerColor,
                width: suSetWidth(24.0),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _handleItemClick(context, item);
      },
    );
  }

  /// Button to clear hive boxes.
  /// 清除存储内容按钮
  Widget clearBoxesButton(BuildContext context) => UnconstrainedBox(
        child: Opacity(
          opacity: 0.3,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: suSetHeight(15.0)),
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
              onLongPress: () => HiveBoxes.clearBoxes(context: context),
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

  /// Current date tips.
  /// 当前日期问候
  Widget currentDay(BuildContext context) {
    String hello = '你好';
    final DateTime now = DateTime.now();
    final int hour = now.hour;

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

    return Selector<SettingsProvider, bool>(
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
            selector: (BuildContext _, DateProvider provider) => provider.currentWeek,
            builder: (BuildContext _, int currentWeek, Widget __) {
              if (currentWeek != null && currentWeek <= 20) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: suSetWidth(24.0),
                    vertical: suSetHeight(10.0),
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: '$hello～'),
                        TextSpan(text: '今天是'),
                        TextSpan(
                          text: '${DateFormat('MMMdd', 'zh_CN').format(now)}日，',
                        ),
                        TextSpan(
                          text: '${DateFormat('EEE', 'zh_CN').format(now)}，',
                        ),
                        if (currentWeek > 0)
                          TextSpan(children: <InlineSpan>[
                            TextSpan(text: '第'),
                            TextSpan(
                              text: '${currentWeek}',
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
                      style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: suSetSp(16.0),
                          ),
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Screens.width * 0.85,
      child: Column(
        children: <Widget>[
          headerWrapper(child: userCard),
          contentWrapper(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: suSetWidth(20.0)),
                      child: UserAvatar(size: 44.0),
                    ),
                    Expanded(
                      child: Text(
                        '${currentUser.name ?? currentUser.workId}',
                        style: TextStyle(fontSize: suSetSp(20.0)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    signButton,
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
                  height: suSetHeight(72.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List<Widget>.generate(actions.length, (int index) {
                      final Map<String, dynamic> action = actions[index];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (action['action'] != null) {
                            (action['action'] as VoidCallback)();
                          }
                          if (action['route'] != null) {
                            navigatorState.pushNamed(action['route'] as String);
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SvgPicture.asset(
                              action['icon'] as String,
                              width: suSetWidth(36.0),
                              color: currentThemeColor,
                            ),
                            Text(
                              action['name'] as String,
                              style: TextStyle(fontSize: suSetSp(14.0)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
                    separatorBuilder: (BuildContext _, int __) => separator(context),
                    itemCount: settingsSection.length,
                    itemBuilder: (BuildContext _, int index) =>
                        settingSectionListView(context, index),
                  ),
                ),
                clearBoxesButton(context),
                currentDay(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
