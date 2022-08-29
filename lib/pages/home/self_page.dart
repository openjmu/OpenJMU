///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-09 20:39
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/manually_set_sid_dialog.dart';

class SelfPage extends StatelessWidget {
  List<Map<String, dynamic>> get settingsSection => <Map<String, dynamic>>[
        // {
        //   'name': '背包',
        //   'icon': R.ASSETS_ICONS_SELF_PAGE_BACKPACK_SVG,
        //   'route': Routes.openjmuBackpack.name,
        // },
        <String, dynamic>{
          'icon': R.ASSETS_ICONS_SELF_PAGE_NIGHT_MODE_SVG,
          'name': '夜间模式',
          'action': (BuildContext context) {
            final ThemesProvider provider = context.read<ThemesProvider>();
            if (!provider.platformBrightness) {
              provider.dark = !provider.dark;
            } else {
              showToast('已跟随系统夜间模式设置\n可在设置中关闭');
            }
          },
        },
        <String, dynamic>{
          'icon': R.ASSETS_ICONS_SELF_PAGE_SCAN_CODE_SVG,
          'name': '扫一扫',
          'action': (BuildContext context) async {
            if (await checkPermissions(<Permission>[Permission.camera])) {
              navigatorState.pushNamed(Routes.openjmuScanQrCode);
            } else {
              showToast('未获得相应权限');
            }
          },
        },
        <String, dynamic>{
          'icon': R.ASSETS_ICONS_SELF_PAGE_SEARCH_SVG,
          'name': '搜索',
          'route': Routes.openjmuSearch.name,
        },
        <String, dynamic>{
          'name': '偏好设置',
          'icon': R.ASSETS_ICONS_SELF_PAGE_SETTINGS_SVG,
          'route': Routes.openjmuSettings.name,
        },
        <String, dynamic>{
          'name': '退出账号',
          'icon': R.ASSETS_ICONS_SELF_PAGE_LOGOUT_SVG,
          'action': UserAPI.logout,
        },
      ];

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

  /// Wrapper for content.
  /// 内容部件封装
  Widget contentWrapper({@required Widget child}) {
    return Expanded(
      child: Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: child,
      ),
    );
  }

  /// 签到按钮
  Widget get signButton {
    return Consumer<SignProvider>(
      builder: (BuildContext context, SignProvider provider, Widget __) {
        return Tapper(
          onTap: () {
            if (!provider.hasSigned) {
              provider.requestSign();
            }
          },
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: () {
              Widget widget;
              if (provider.isSigning) {
                widget = Padding(
                  padding: EdgeInsets.all(18.w),
                  child: PlatformProgressIndicator(
                    strokeWidth: 4.w,
                  ),
                );
              } else {
                widget = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (provider.hasSigned) Gap.v(2.w),
                    if (provider.hasSigned)
                      SvgPicture.asset(
                        R.ASSETS_ICONS_SELF_PAGE_SIGNED_SVG,
                        color: currentThemeColor,
                        width: 15.w,
                        height: 15.w,
                      )
                    else
                      Text(
                        '签到',
                        style: TextStyle(
                          color: context.themeColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.23,
                        ),
                      ),
                    if (provider.hasSigned)
                      Padding(
                        padding: EdgeInsets.only(top: 8.w),
                        child: Text(
                          '${provider.signedCount}',
                          style: TextStyle(
                            color: currentThemeColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                  ],
                );
              }
              return Center(child: widget);
            }(),
          ),
        );
      },
    );
  }

  /// Item view for setting.
  /// 设置项部件
  Widget settingItem(BuildContext context, int itemIndex) {
    final Map<String, dynamic> item = settingsSection[itemIndex];
    return Tapper(
      child: Container(
        height: 50.w,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: SvgPicture.asset(
                item['icon'] as String,
                color: context.iconTheme.color,
                width: 45.w,
              ),
            ),
            Gap.h(12.w),
            Expanded(
              child: Text(
                item['name'] as String,
                style: TextStyle(height: 1.2, fontSize: 20.sp),
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

  Widget get userInfoWidget {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w).copyWith(
        top: 24.w,
        bottom: 12.w,
      ),
      child: Row(
        children: <Widget>[
          UserAvatar(
            size: 64,
            isSysAvatar: UserAPI.currentUser.sysAvatar,
          ),
          Gap.h(20.w),
          Expanded(
            child: Text(
              currentUser.name,
              style: TextStyle(
                color: adaptiveButtonColor(),
                fontSize: 23.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          signButton,
        ],
      ),
    );
  }

  /// Common apps section widget.
  /// 常用应用部件栏
  Widget commonApps(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.w),
      child: Consumer<WebAppsProvider>(
        builder: (_, WebAppsProvider provider, Widget __) {
          final Set<WebApp> commonWebApps = provider.commonWebApps;
          return Container(
            height: 212.w,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.w),
              color: context.surfaceColor,
            ),
            child: Column(
              children: <Widget>[
                if (commonWebApps.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: List<Widget>.generate(
                        commonWebApps.length,
                        (int index) => appWidget(commonWebApps, index),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Text(
                        '应用捷径会出现在这里\n请前往全部应用进行设置',
                        style: context.textTheme.caption.copyWith(
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                allWebAppsButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget appWidget(Iterable<WebApp> apps, int index) {
    final WebApp app = apps.elementAt(index);
    return Expanded(
      child: Tapper(
        onTap: () {
          API.launchWeb(
            url: app.replacedUrl,
            app: app,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WebAppIcon(app: app, size: 72.0),
            Padding(
              padding: EdgeInsets.only(top: 8.w, bottom: 4.w),
              child: Text(
                app.name,
                style: TextStyle(height: 1.2, fontSize: 16.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 前往应用中心的按钮
  Widget allWebAppsButton(BuildContext context) {
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(Routes.openjmuAppCenterPage.name);
      },
      child: Container(
        height: 72.w,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: SvgPicture.asset(
                R.ASSETS_ICONS_APP_CENTER_ALL_APPS_SVG,
                width: 45.w,
                color: context.iconTheme.color,
              ),
            ),
            Gap.h(18.w),
            Text(
              '全部应用',
              style: TextStyle(height: 1.2, fontSize: 20.sp),
            ),
          ],
        ),
      ),
    );
  }

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

    return Tapper(
      onLongPress: () {
        if (Constants.isDebug) {
          showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => ManuallySetSidDialog(),
          );
        } else {
          NetUtils.updateTicket();
        }
      },
      child: Selector<DateProvider, int>(
        selector: (_, DateProvider provider) =>
            provider.currentWeek,
        builder: (_, int currentWeek, Widget __) {
          if (currentWeek != null) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: '$hello，'),
                    const TextSpan(text: '今天是'),
                    TextSpan(
                      text: '${DateFormat('MMMdd', 'zh_CN').format(now)}日，',
                    ),
                    TextSpan(
                      text: '${DateFormat('EEE', 'zh_CN').format(now)}，',
                    ),
                    if (currentWeek > 0 && currentWeek <= 20)
                      TextSpan(children: <InlineSpan>[
                        const TextSpan(text: '第'),
                        TextSpan(
                          text: '$currentWeek',
                          style: TextStyle(
                            color: currentThemeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: '周'),
                      ])
                    else if (currentWeek >= 20)
                      TextSpan(children: <InlineSpan>[
                        const TextSpan(text: '放假的第'),
                        TextSpan(
                          text: '${currentWeek.abs() - 20}',
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
                  style: context.textTheme.bodyText2.copyWith(
                    fontSize: 18.sp,
                  ),
                ),
                textAlign: TextAlign.start,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Screens.width * .8,
      child: Material(
        color: context.theme.canvasColor,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 160.w + Screens.topSafeHeight,
              child: ColoredBox(color: currentThemeColor),
            ),
            Positioned.fill(
              top: Screens.topSafeHeight,
              child: Column(
                children: <Widget>[
                  userInfoWidget,
                  commonApps(context),
                  contentWrapper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 12.w),
                            separatorBuilder: (_, __) => Gap.v(24.h),
                            itemCount: settingsSection.length,
                            itemBuilder: (_, int index) =>
                                settingItem(context, index),
                          ),
                        ),
                        currentDay(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
