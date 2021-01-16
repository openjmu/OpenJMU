///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-09 20:39
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/manually_set_sid_dialog.dart';

class SelfPage extends StatelessWidget {
  List<Map<String, dynamic>> get settingsSection => <Map<String, dynamic>>[
        // {
        //   'name': '背包',
        //   'icon': R.ASSETS_ICONS_SELF_PAGE_BACKPACK_SVG,
        //   'route': Routes.openjmuBackpack,
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
              unawaited(navigatorState.pushNamed(Routes.openjmuScanQrCode));
            } else {
              showToast('未获得相应权限');
            }
          },
        },
        <String, dynamic>{
          'icon': R.ASSETS_ICONS_SELF_PAGE_SEARCH_SVG,
          'name': '搜索',
          'route': Routes.openjmuSearch,
        },
        <String, dynamic>{
          'name': '偏好设置',
          'icon': R.ASSETS_ICONS_SELF_PAGE_SETTINGS_SVG,
          'route': Routes.openjmuSettings,
        },
        <String, dynamic>{
          'name': '退出账号',
          'icon': R.ASSETS_ICONS_SELF_PAGE_LOGOUT_SVG,
          'action': UserAPI.logout,
        },
      ];

  /// 顶部内容基础高度
  double get headerHeight => 266.0;

  /// 常用应用栏的高度
  double get commonAppsHeight => 140.0;

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
      height: headerHeight.h,
      child: child,
    );
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
  Widget get signButton => Consumer<SignProvider>(
        builder: (BuildContext _, SignProvider provider, Widget __) {
          return GestureDetector(
            onTap: () {
              if (!provider.hasSigned) {
                provider.requestSign();
              }
            },
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: _.themeData.colorScheme.surface,
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
                      if (provider.hasSigned) VGap(2.w),
                      SvgPicture.asset(
                        provider.hasSigned
                            ? R.ASSETS_ICONS_SELF_PAGE_SIGNED_SVG
                            : R.ASSETS_ICONS_SELF_PAGE_UNSIGNED_SVG,
                        color: currentThemeColor,
                        width: provider.hasSigned ? 15.w : 24.w,
                        height: provider.hasSigned ? 15.w : 24.w,
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

  /// Item view for setting.
  /// 设置项部件
  Widget settingItem(BuildContext context, int itemIndex) {
    final Map<String, dynamic> item = settingsSection[itemIndex];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50.h,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 12.w, right: 24.w),
              child: SvgPicture.asset(
                item['icon'] as String,
                color: context.themeData.iconTheme.color.withOpacity(0.5),
                width: 45.w,
              ),
            ),
            Expanded(
              child: Text(
                item['name'] as String,
                style: TextStyle(fontSize: 20.sp),
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
    return SizedBox(
      height: (headerHeight - commonAppsHeight).h,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
          ),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  navigatorState.pushNamed(Routes.openjmuUserPage.name);
                },
                child: ClipOval(
                  child: Image(
                    image: UserAPI.getAvatarProvider(),
                    height: math.min(64.w, (headerHeight - commonAppsHeight).h),
                  ),
                ),
              ),
              Gap(20.w),
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
        ),
      ),
    );
  }

  /// Common apps section widget.
  /// 常用应用部件栏
  Widget commonApps(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(
          horizontal: 15.w,
        ),
        height: commonAppsHeight.h,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Consumer<WebAppsProvider>(
          builder: (BuildContext _, WebAppsProvider provider, Widget __) {
            final Set<WebApp> commonWebApps = provider.commonWebApps;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
                color: context.themeData.colorScheme.surface,
              ),
              child: Row(
                children: <Widget>[
                  if (commonWebApps.isNotEmpty) ...<Widget>[
                    ...List<Widget>.generate(commonWebApps.length, (int index) {
                      return appWidget(commonWebApps, index);
                    }),
                  ] else
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          navigatorState.pushNamed(Routes.openjmuAppCenterPage);
                        },
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Text(
                              '常用应用会出现在这里\n点击右上按钮打开应用中心',
                              style: TextStyle(fontSize: 16.sp),
                              textAlign: TextAlign.center,
                            ),
                          ),
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

  Widget appWidget(Iterable<WebApp> apps, int index) {
    final WebApp app = apps.elementAt(index);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
              padding: EdgeInsets.only(top: 4.sp, bottom: 8.sp),
              child: Text(
                app.name,
                style: TextStyle(height: 1.15, fontSize: 16.sp),
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
    return Expanded(
      child: InkWell(
        splashFactory: InkSplash.splashFactory,
        onTap: () {
          navigatorState.pushNamed(Routes.openjmuAppCenterPage);
        },
        borderRadius: BorderRadius.circular(15.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8.w),
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: context.themeData.canvasColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  R.ASSETS_ICONS_ARROW_RIGHT_SVG,
                  width: 32.w,
                  height: 32.w,
                  color: currentThemeColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.sp, bottom: 8.sp),
              child: Text(
                '全部应用',
                style: TextStyle(fontSize: 16.sp),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
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

    return GestureDetector(
      onLongPress: () {
        if (Constants.isDebug) {
          showDialog<void>(
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
          if (currentWeek != null) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.symmetric(vertical: 16.h),
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
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
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
    return Container(
      width: Screens.width * 0.8,
      color: context.themeData.canvasColor,
      child: Column(
        children: <Widget>[
          headerWrapper(
            child: Stack(
              children: <Widget>[
                Container(
                  height: (headerHeight - commonAppsHeight / 2).h,
                  color: currentThemeColor,
                ),
                userInfoWidget,
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: commonApps(context),
                ),
              ],
            ),
          ),
          contentWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 12.w),
                    separatorBuilder: (_, __) => VGap(24.h),
                    itemCount: settingsSection.length,
                    itemBuilder: (BuildContext _, int index) =>
                        settingItem(context, index),
                  ),
                ),
                currentDay(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
