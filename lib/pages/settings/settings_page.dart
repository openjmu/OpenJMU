///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-09-23 16:36
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';

@FFRoute(name: 'openjmu://settings', routeName: '设置页')
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: const FixedAppBar(title: Text('设置')),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 10.w),
          children: const <Widget>[
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
    final Map<String, String> info = <String, String>{
      'uid': currentUser.uid,
      'sid': currentUser.sid,
      'uuid': DeviceUtils.deviceUuid,
      'ticket': currentUser.ticket,
      'workId': currentUser.workId,
      if (DeviceUtils.devicePushToken != null)
        'pushToken': DeviceUtils.devicePushToken,
      'model': DeviceUtils.deviceModel,
    };
    final int longestKeyLength = info.keys.fold<int>(0, (int pre, String key) {
      if (key.length > pre) {
        return key.length;
      } else {
        return pre;
      }
    });
    final List<MapEntry<String, String>> entries = info.entries.toList();
    if (await ConfirmationDialog.show(
      context,
      title: '调试信息',
      child: debugContentBuilder(
        context: context,
        entries: entries,
        longestKeyLength: longestKeyLength,
      ),
      showConfirm: true,
      confirmLabel: '复制文字',
      cancelLabel: '返回',
    )) {
      String data = '';
      for (final MapEntry<String, String> e in info.entries) {
        data += '[${e.key.padRight(longestKeyLength, ' ')}] ${e.value}\n';
      }
      Clipboard.setData(ClipboardData(text: data));
      showToast('已复制到剪贴板');
    }
  }

  void gotoLicensePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'OpenJMU',
      applicationVersion: '${PackageUtils.version}+${PackageUtils.buildNumber}',
      applicationIcon: Padding(
        padding: EdgeInsets.all(20.w),
        child: Image.asset(
          R.IMAGES_LOGO_1024_ROUNDED_PNG,
          width: Screens.width / 5,
        ),
      ),
      applicationLegalese: '© ${currentTime.year} The OpenJMU Team',
    );
  }

  Widget debugContentBuilder({
    BuildContext context,
    List<MapEntry<String, String>> entries,
    int longestKeyLength,
  }) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(entries.length, (int i) {
          final MapEntry<String, String> entry = entries[i];
          return Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '[${entry.key.padRight(longestKeyLength, ' ')}] ',
                ),
                TextSpan(text: entry.value),
              ],
            ),
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'JetBrains Mono',
            ),
            textAlign: TextAlign.left,
          );
        }),
      ),
    );
  }

  Widget logoItemWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      height: 64.w,
      child: Row(
        children: <Widget>[
          Tapper(
            onDoubleTap: () => showDebugInfoDialog(context),
            child: const AspectRatio(
              aspectRatio: 1,
              child: CircleAvatar(
                backgroundImage: AssetImage(R.IMAGES_LOGO_1024_PNG),
              ),
            ),
          ),
          Gap(20.w),
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
                  'V${PackageUtils.version}+${PackageUtils.buildNumber}',
                  style: context.textTheme.caption.copyWith(
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
            color: context.theme.canvasColor,
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
        const _SettingItemWidget(
          item: _SettingItem(
            name: '服务器状态',
            description: '可用状态监控',
            url: API.statusWebsite,
            urlTitle: 'OpenJMU 状态',
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '意见和建议',
            description: '问题反馈',
            url: API.complaints,
            urlTitle: '吐个槽',
          ),
        ),
        const _SettingItemWidget(
          item: _SettingItem(
            name: '新版本更新了什么？',
            description: '版本履历',
            route: Routes.openjmuChangelogPage,
          ),
        ),
        const _SettingItemWidget(
          item: _SettingItem(
            name: '前往官网',
            description: 'openjmu.jmu.edu.cn',
            url: API.homePage,
            urlTitle: 'OpenJMU',
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '许可证信息',
            description: '开源组件许可',
            onTap: () => gotoLicensePage(context),
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
      title: '深色模式',
      children: <Widget>[
        _SettingItemWidget(
          item: _SettingItem(
            name: '深色模式',
            widget: Consumer<ThemesProvider>(
              builder: (BuildContext _, ThemesProvider provider, Widget __) {
                return CustomSwitch(
                  activeColor: context.themeColor,
                  value: provider.dark,
                  onChanged: !provider.platformBrightness
                      ? (bool value) => provider.dark = value
                      : null,
                );
              },
            ),
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '跟随系统',
            widget: Consumer<ThemesProvider>(
              builder: (BuildContext _, ThemesProvider provider, Widget __) {
                return CustomSwitch(
                  activeColor: context.themeColor,
                  value: provider.platformBrightness,
                  onChanged: (bool value) =>
                      provider.platformBrightness = value,
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
    final int currentIndex = context.watch<SettingsProvider>().homeSplashIndex;
    return _SettingsCard(
      title: '启动页设置',
      children: <Widget>[
        _SettingItemWidget(
          item: _SettingItem(
            name: '主页',
            description: MainPageState.pagesTitle[currentIndex],
            onTap: () {
              ConfirmationBottomSheet.show(
                context,
                actions: List<ConfirmationBottomSheetAction>.generate(
                  MainPageState.pagesTitle.length,
                  (int index) => ConfirmationBottomSheetAction(
                    text: MainPageState.pagesTitle[index],
                    onTap: () => HiveFieldUtils.setHomeSplashIndex(index),
                    isSelected: currentIndex == index,
                  ),
                ),
              );
            },
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
        Consumer<ThemesProvider>(
          builder: (_, ThemesProvider provider, __) {
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
                final bool isSelected = provider.currentThemeGroup == theme;
                return Tapper(
                  onTap: () {
                    if (!isSelected) {
                      provider.updateThemeColor(index);
                    }
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: currentIsDark
                          ? theme.darkThemeColor
                          : theme.lightThemeColor,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedOpacity(
                      duration: kThemeChangeDuration,
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Icon(
                        Icons.check,
                        color: adaptiveButtonColor(),
                        size: 30.w,
                      ),
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

class _EnhanceCard extends StatelessWidget {
  const _EnhanceCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: '体验优化',
      children: <Widget>[
        const _SettingItemWidget(
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
                  activeColor: context.themeColor,
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
                  selector: (_, SettingsProvider provider) =>
                      provider.newAppCenterIcon,
                  builder: (_, bool newAppCenterIcon, __) {
                    return CustomSwitch(
                      activeColor: context.themeColor,
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
                  activeColor: context.themeColor,
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
              HiveBoxes.clearCacheBoxes(context);
            },
          ),
        ),
        _SettingItemWidget(
          item: _SettingItem(
            name: '重置应用',
            onTap: () {
              HiveBoxes.clearAllBoxes(context);
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
          'Made with ',
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
        color: context.surfaceColor,
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
    return Tapper(
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
                style: context.textTheme.caption.copyWith(fontSize: 22.sp),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            if (item.widget != null) item.widget,
            if (item.url != null || item.route != null || item.onTap != null)
              Container(
                margin: EdgeInsets.only(left: 16.w),
                width: (iconSize / 1.25).w / 2,
                height: (iconSize / 1.25).w,
                child: SvgPicture.asset(
                  R.ASSETS_ICONS_ARROW_RIGHT_SVG,
                  color: context.iconTheme.color,
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
        } else if (item.url != null) {
          API.launchWeb(url: item.url, title: item.urlTitle);
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
    this.url,
    this.urlTitle = '',
  });

  final String name;
  final String description;
  final Widget widget;
  final String route;
  final VoidCallback onTap;
  final String url;
  final String urlTitle;
}
