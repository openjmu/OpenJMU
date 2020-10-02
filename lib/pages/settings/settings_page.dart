///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-09-23 16:36
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

import '../main_page.dart';

@FFRoute(name: 'openjmu://settings', routeName: '设置页')
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(title: Text('设置')),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 10.w),
          children: <Widget>[
            _AboutCard(),
            _NightModeCard(),
            _ThemeCard(),
            _StartPageCard(),
            _EnhanceCard(),
            _DataCleaningCard(),
            _FlutterBrandingWidget(),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({Key key}) : super(key: key);

  Future<void> showDebugInfoDialog(BuildContext context) async {
    final String info = '[uid      ] ${currentUser.uid}\n'
        '[sid      ] ${currentUser.sid}\n'
        '[ticket   ] ${currentUser.ticket}\n'
        '[workId   ] ${currentUser.workId}\n'
        '[uuid     ] ${DeviceUtils.deviceUuid}\n'
        '${DeviceUtils.devicePushToken != null ? '[pushToken] ${DeviceUtils.devicePushToken}\n' : ''}'
        '[model    ] ${DeviceUtils.deviceModel}';
    final List<String> list = info.split('\n');
    final bool shouldCopy = await ConfirmationDialog.show(
      context,
      title: '调试信息',
      showConfirm: true,
      confirmLabel: '复制',
      cancelLabel: '返回',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(list.length, (i) {
            return Text.rich(
              TextSpan(
                children: List<InlineSpan>.generate(list[i].length, (j) {
                  return WidgetSpan(
                    alignment: ui.PlaceholderAlignment.middle,
                    child: Text(
                      list[i].substring(j, j + 1),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  );
                }),
              ),
              textAlign: TextAlign.left,
            );
          }),
        ),
      ),
    );
    if (shouldCopy) {
      unawaited(Clipboard.setData(ClipboardData(text: info)));
      showToast('已复制到剪贴板');
    }
  }

  Widget logoItemWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      height: 64.w,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onDoubleTap: () => showDebugInfoDialog(context),
            child: AspectRatio(
              aspectRatio: 1,
              child: CircleAvatar(
                backgroundImage: AssetImage(R.IMAGES_LOGO_1024_PNG),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'OPENJMU',
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'V${PackageUtils.version}',
                  style: context.themeData.textTheme.caption.copyWith(
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
          ),
          MaterialButton(
            minWidth: 84.w,
            height: 60.w,
            elevation: 0.0,
            color: context.themeData.canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.w),
            ),
            onPressed: () {
              PackageUtils.checkUpdate(isManually: true);
            },
            child: Text(
              '检查更新',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: <Widget>[
        logoItemWidget(context),
        _SettingItemWidget(
          item: _SettingItem(
            name: '吐个槽',
            description: '意见反馈',
            onTap: () {
              API.launchWeb(url: API.complaints, title: '吐个槽');
            },
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '新版本更新了什么？',
            description: '版本履历',
            route: Routes.openjmuChangelogPage,
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '前往官网',
            description: 'openjmu.jmu.edu.cn',
            hideArrow: true,
            onTap: () {
              API.launchWeb(url: API.homePage, title: 'OpenJMU');
            },
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '许可证信息',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'OpenJMU',
                applicationVersion:
                    '${PackageUtils.version}+${PackageUtils.buildNumber}',
                applicationIcon: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Image.asset(
                    R.IMAGES_LOGO_1024_ROUNDED_PNG,
                    width: Screens.width / 5,
                  ),
                ),
                applicationLegalese: '© 2020 The OpenJMU Team',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NightModeCard extends StatelessWidget {
  const _NightModeCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: '夜间模式',
      children: <Widget>[
        _SettingItemWidget(
          item: _SettingItem(
            name: '夜间模式跟随系统',
            widget: Consumer<ThemesProvider>(
              builder: (BuildContext _, ThemesProvider provider, Widget __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: provider.platformBrightness,
                  onChanged: (bool value) =>
                      provider.platformBrightness = value,
                );
              },
            ),
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '更深的黑',
            widget: Consumer<ThemesProvider>(
              builder: (BuildContext _, ThemesProvider provider, Widget __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: provider.amoledDark,
                  onChanged: (bool value) => provider.amoledDark = value,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StartPageCard extends StatelessWidget {
  const _StartPageCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: '启动页设置',
      children: <Widget>[
        _SettingItemWidget(
          item: _SettingItem(
            name: '主页',
            description: MainPageState.pagesTitle[
                context.watch<SettingsProvider>().homeStartUpIndex[0]],
            route: Routes.openjmuSwitchStartup,
          ),
        ),
      ],
    );
  }
}

class _EnhanceCard extends StatelessWidget {
  const _EnhanceCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: '体验优化',
      children: <Widget>[
        _SettingItemWidget(
          item: _SettingItem(
            name: '字体大小调整',
            route: Routes.openjmuFontScale,
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '隐藏被屏蔽的动态',
            widget: Selector<SettingsProvider, bool>(
              selector: (BuildContext _, SettingsProvider provider) =>
                  provider.hideShieldPost,
              builder: (BuildContext _, bool hideShieldPost, Widget __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: hideShieldPost,
                  onChanged: (bool value) async {
                    await HiveFieldUtils.setEnabledHideShieldPost(value);
                  },
                );
              },
            ),
          ),
        ),
        if (currentUser.isTeacher)
          _SettingItemWidget(
            item: _SettingItem(
              name: '应用中心新图标',
              description: '全新图标设计',
              widget: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Selector<SettingsProvider, bool>(
                  selector: (_, provider) => provider.newAppCenterIcon,
                  builder: (_, newAppCenterIcon, __) {
                    return CustomSwitch(
                      activeColor: currentThemeColor,
                      value: newAppCenterIcon,
                      onChanged: (bool value) async {
                        await HiveFieldUtils.setEnabledNewAppsIcon(value);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '在系统浏览器打开网页',
            widget: Selector<SettingsProvider, bool>(
              selector: (BuildContext _, SettingsProvider provider) =>
                  provider.launchFromSystemBrowser,
              builder:
                  (BuildContext _, bool launchFromSystemBrowser, Widget __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: launchFromSystemBrowser,
                  onChanged: (bool value) async {
                    await HiveFieldUtils.setLaunchFromSystemBrowser(value);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: '主题设置',
      children: <Widget>[
        Selector<ThemesProvider, ThemeGroup>(
          selector: (BuildContext _, ThemesProvider provider) =>
              provider.currentThemeGroup,
          builder: (BuildContext _, ThemeGroup currentThemeGroup, Widget __) {
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 20.w,
                crossAxisSpacing: 20.w,
              ),
              itemCount: supportThemeGroups.length,
              itemBuilder: (BuildContext _, int index) {
                final ThemeGroup theme = supportThemeGroups[index];
                final bool isSelected = currentThemeGroup == theme;
                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      context.read<ThemesProvider>().updateThemeColor(index);
                    }
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.lightThemeColor,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedOpacity(
                      duration: kThemeChangeDuration,
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Icon(Icons.check, color: Colors.white, size: 30.w),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _DataCleaningCard extends StatelessWidget {
  const _DataCleaningCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: '数据清理',
      children: <Widget>[
        _SettingItemWidget(
          item: _SettingItem(
            name: '清理缓存数据',
            onTap: () {
              HiveBoxes.clearCacheBoxes(context: context);
            },
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '清理应用数据',
            onTap: () {
              HiveBoxes.clearAllBoxes(context: context);
            },
          ),
        ),
      ],
    );
  }
}

class _FlutterBrandingWidget extends StatelessWidget {
  const _FlutterBrandingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Made by ',
          style: TextStyle(
            fontSize: 23.sp,
            fontWeight: FontWeight.w200,
          ),
        ),
        FlutterLogo(
          size: 100.w,
          style: FlutterLogoStyle.horizontal,
        ),
      ],
    );
  }
}


class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    Key key,
    @required this.children,
    this.title,
  })  : assert(children != null),
        super(key: key);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.w),
        color: context.themeData.cardColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: EdgeInsets.only(bottom: 15.w),
              child: Text(
                title,
                style: TextStyle(color: currentThemeColor, fontSize: 18.sp),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingItemWidget extends StatelessWidget {
  const _SettingItemWidget({
    Key key,
    @required this.item,
  })  : assert(item != null),
        super(key: key);

  final _SettingItem item;

  double get iconSize => 36.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 68.w,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(fontSize: 22.sp),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
            if (item.description != null)
              Text(
                item.description,
                style: context.themeData.textTheme.caption
                    .copyWith(fontSize: 22.sp),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            if (item.widget != null) item.widget,
            if ((item.route != null || item.onTap != null) && !item.hideArrow)
              Container(
                margin: EdgeInsets.only(left: 16.w),
                width: (iconSize / 1.25).w / 2,
                height: (iconSize / 1.25).w,
                child: SvgPicture.asset(
                  R.ASSETS_ICONS_ARROW_RIGHT_SVG,
                  color: context.themeData.iconTheme.color,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
      onTap: () {
        item.onTap?.call();
        if (item.route != null) {
          navigatorState.pushNamed(item.route);
        }
      },
    );
  }
}

class _SettingItem {
  const _SettingItem({
    this.name,
    this.description,
    this.widget,
    this.route,
    this.onTap,
    this.hideArrow = false,
  });

  final String name;
  final String description;
  final Widget widget;
  final String route;
  final VoidCallback onTap;
  final bool hideArrow;
}
