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
          'icon': R.ASSETS_ICONS_SELF_PAGE_SCAN_CODE_SVG,
          'name': '扫码',
          'route': Routes.OPENJMU_SCAN_QRCODE,
        },
        {
          'icon': R.ASSETS_ICONS_SELF_PAGE_BACKPACK_SVG,
          'name': '背包',
          'route': Routes.OPENJMU_BACKPACK,
        },
        {
          'icon': R.ASSETS_ICONS_SELF_PAGE_CHANGE_THEME_SVG,
          'name': '主题',
          'route': Routes.OPENJMU_THEME,
        },
        {
          'icon': R.ASSETS_ICONS_SELF_PAGE_NIGHT_MODE_SVG,
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

  List<List<Map<String, dynamic>>> get settingsSection =>
      <List<Map<String, dynamic>>>[
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
    return SizedBox(
      height: headerHeight.h,
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: -30.0.w,
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
            bottom: -30.0.w,
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: const Color.fromARGB(120, 50, 50, 50)),
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
          padding: EdgeInsets.all(25.0.w),
          width: Screens.width * 0.7,
          height: (headerHeight - 20.0).h - Screens.topSafeHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0.w),
              topRight: Radius.circular(25.0.w),
            ),
            color: currentThemeColor,
            gradient: const LinearGradient(
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
                height: 40.0.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SvgPicture.asset(
                      R.IMAGES_JMU_NAME_SVG,
                      color: const Color(0xffffcb28),
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
                  fontSize: 24.0.sp,
                  fontFamily: 'JetBrains Mono',
                  letterSpacing: 4.0.sp,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black26,
                      offset: Offset(4.0.w, 4.0.w),
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
          width: double.maxFinite,
          padding: EdgeInsets.all(20.0.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0.w),
              topRight: Radius.circular(25.0.w),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 2.0,
                color: currentTheme.dividerColor,
                offset: Offset(0, -2.0.h),
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
            minWidth: (provider.hasSigned ? 130.0 : 100.0).w,
            height: 50.0.h,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.0.w),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (provider.isSigning)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.0.w),
                    width: 28.0.w,
                    height: 28.0.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0.w,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(right: 6.0.w),
                    child: provider.hasSigned
                        ? Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 28.0.w,
                          )
                        : SvgPicture.asset(
                            R.ASSETS_ICONS_SIGN_LINE_SVG,
                            color: Colors.white,
                            width: 28.0.w,
                          ),
                  ),
                Text(
                  provider.hasSigned ? '已签${provider.signedCount}天' : '签到',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0.sp,
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
        height: 1.0.h,
      ),
      itemCount: settingsSection[index].length,
      itemBuilder: (BuildContext _, int itemIndex) =>
          settingItem(context, index, itemIndex),
    );
  }

  /// Item view for setting.
  /// 设置项部件
  Widget settingItem(BuildContext context, int sectionIndex, int itemIndex) {
    final Map<String, dynamic> item = settingsSection[sectionIndex][itemIndex];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64.0.h,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 12.0.w, right: 24.0.w),
              child: SvgPicture.asset(
                item['icon'] as String,
                color: currentThemeColor,
                width: 34.0.w,
              ),
            ),
            Expanded(
              child: Text(
                item['name'],
                style: TextStyle(fontSize: 20.0.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.0.w),
              child: SvgPicture.asset(
                R.ASSETS_ICONS_ARROW_RIGHT_SVG,
                color: Theme.of(context).dividerColor,
                width: 12.0.w,
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
            margin: EdgeInsets.symmetric(vertical: 15.0.h),
            padding: EdgeInsets.symmetric(
              horizontal: 30.0.w,
              vertical: 10.0.h,
            ),
            decoration: BoxDecoration(
              borderRadius: maxBorderRadius,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey[currentIsDark ? 800 : 100],
                  blurRadius: 6.0.h,
                  offset: Offset(0, 6.0.h),
                ),
              ],
              color: Theme.of(context).primaryColor,
            ),
            child: GestureDetector(
              onLongPress: () => HiveBoxes.clearAllBoxes(context: context),
              child: Text(
                '(DANGER)\n清除应用数据',
                style: TextStyle(
                  color: currentThemeColor,
                  fontSize: 20.0.sp,
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
                builder: (BuildContext _) => ManuallySetSidDialog(),
              );
            } else {
              NetUtils.updateTicket();
            }
          },
          child: Selector<DateProvider, int>(
            selector: (BuildContext _, DateProvider provider) =>
                provider.currentWeek,
            builder: (BuildContext _, int currentWeek, Widget __) {
              if (currentWeek != null && currentWeek <= 20) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0.w,
                    vertical: 10.0.h,
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: '$hello～'),
                        const TextSpan(text: '今天是'),
                        TextSpan(
                          text: '${DateFormat('MMMdd', 'zh_CN').format(now)}日，',
                        ),
                        TextSpan(
                          text: '${DateFormat('EEE', 'zh_CN').format(now)}，',
                        ),
                        if (currentWeek > 0)
                          TextSpan(children: <InlineSpan>[
                            const TextSpan(text: '第'),
                            TextSpan(
                              text: '${currentWeek}',
                              style: TextStyle(
                                color: currentThemeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '周'),
                          ])
                        else
                          TextSpan(children: <InlineSpan>[
                            const TextSpan(text: '距开学还有'),
                            TextSpan(
                              text: '${currentWeek.abs() + 1}',
                              style: TextStyle(
                                color: currentThemeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '周'),
                          ]),
                      ],
                      style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: 16.0.sp,
                          ),
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return const SizedBox.shrink();
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
                    Padding(
                      padding: EdgeInsets.only(right: 20.0.w),
                      child: UserAvatar(size: 44.0),
                    ),
                    Expanded(
                      child: Text(
                        '${currentUser.name ?? currentUser.workId}',
                        style: TextStyle(fontSize: 21.0.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    signButton,
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0.h),
                  height: 80.0.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        List<Widget>.generate(actions.length, (int index) {
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
                              width: 40.0.w,
                              color: currentThemeColor,
                            ),
                            Text(
                              action['name'] as String,
                              style: TextStyle(fontSize: 16.0.sp),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                    separatorBuilder: (BuildContext _, int __) =>
                        separator(context),
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
