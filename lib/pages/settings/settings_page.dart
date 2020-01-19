import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/appbar.dart';

@FFRoute(
  name: "openjmu://settings",
  routeName: "设置页",
)
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<List<Map<String, dynamic>>> pageSection = [
    [
//      {
//        "name": "示例设置项1",
//        "description": "示例描述",
//        "onTap": action(),
//      },
      {
        "icon": "follow_system",
        "name": "跟随系统夜间模式",
        "description": "夜间模式将跟随系统主题切换",
      },
      {
        "icon": "night_mode",
        "name": "夜间模式",
        "description": "减轻眩光，提升夜间使用体验",
      },
      {
        "icon": "amoled_black",
        "name": "A屏黑",
        "description": "更深的背景颜色，节省电量",
      },
      {
        "icon": "theme_color",
        "name": "切换主题",
        "description": "多彩颜色，丰富你的界面",
        "route": Routes.OPENJMU_THEME,
      },
      {
        "icon": "launch_page",
        "name": "启动页设置",
        "description": "选择您偏好的启动页面",
        "route": Routes.OPENJMU_SWITCH_STARTUP,
      },
      if (currentUser.isTeacher)
        {
          "icon": "new_icons",
          "name": "应用中心新图标",
          "description": "全新图标设计，简洁直达",
        },
      {
        "icon": "font_size",
        "name": "字体大小调节",
        "description": "调整字体大小以获得最佳阅读体验",
        "route": Routes.OPENJMU_FONT_SCALE,
      },
      {
        "icon": "hide_blocked",
        "name": "隐藏屏蔽的动态",
        "description": "广场中被屏蔽的动态将被隐藏",
      },
    ],
  ];
  List<List<Widget>> settingsWidget;

  double get iconSize => 36.0;

  Widget settingItem({context, int index, int sectionIndex}) {
    final Map<String, dynamic> page = pageSection[sectionIndex][index];
    settingsWidget = [
      [
        Consumer<ThemesProvider>(
          builder: (_, provider, __) {
            return PlatformSwitch(
              activeColor: currentThemeColor,
              value: provider.platformBrightness,
              onChanged: (bool value) {
                provider.platformBrightness = value;
              },
            );
          },
        ),
        Consumer<ThemesProvider>(
          builder: (_, provider, __) {
            return PlatformSwitch(
              activeColor: currentThemeColor,
              value: provider.dark,
              onChanged: !provider.platformBrightness
                  ? (bool value) {
                      provider.dark = value;
                    }
                  : null,
            );
          },
        ),
        Consumer<ThemesProvider>(
          builder: (_, provider, __) {
            return PlatformSwitch(
              activeColor: currentThemeColor,
              value: provider.AMOLEDDark,
              onChanged: Theme.of(context).brightness == Brightness.dark
                  ? (bool value) {
                      provider.AMOLEDDark = value;
                      if (mounted) setState(() {});
                    }
                  : null,
            );
          },
        ),
        null,
        null,
        if (currentUser.isTeacher)
          Selector<SettingsProvider, bool>(
            selector: (_, provider) => provider.newAppCenterIcon,
            builder: (_, newAppCenterIcon, __) {
              return PlatformSwitch(
                activeColor: currentThemeColor,
                value: newAppCenterIcon,
                onChanged: (bool value) async {
                  await SettingUtils.setEnabledNewAppsIcon(value);
                },
              );
            },
          ),
        null,
        Selector<SettingsProvider, bool>(
          selector: (_, provider) => provider.hideShieldPost,
          builder: (_, hideShieldPost, __) {
            return PlatformSwitch(
              activeColor: currentThemeColor,
              value: hideShieldPost,
              onChanged: (bool value) async {
                await SettingUtils.setEnabledHideShieldPost(value);
              },
            );
          },
        ),
      ],
    ];
    final Widget pageWidget = settingsWidget[sectionIndex][index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: suSetSp(18.0)),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: suSetWidth(iconSize / 2)),
              child: SvgPicture.asset(
                "assets/icons/settings/${page['icon']}.svg",
                width: suSetWidth(iconSize),
                height: suSetWidth(iconSize),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${page["name"]}",
                    style: TextStyle(fontSize: suSetSp(26.0)),
                  ),
                  Text(
                    "${page["description"]}",
                    style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: suSetSp(18.0),
                        ),
                  ),
                ],
              ),
            ),
            if (pageWidget != null) pageWidget,
            if (pageWidget == null && page['route'] != null)
              SvgPicture.asset(
                "assets/icons/arrow-right.svg",
                color: Colors.grey,
                width: suSetSp(iconSize / 1.25),
                height: suSetSp(iconSize / 1.25),
              ),
          ],
        ),
      ),
      onTap: () {
        if (page['onTap'] != null) page['onTap']();
        if (pageWidget == null && page['route'] != null) {
          navigatorState.pushNamed(page['route']);
        }
        return null;
      },
    );
  }

  Widget pageSelectionItem({
    context,
    sectionIndex,
    page,
    pageIndex,
    index,
    selectedIndex,
  }) {
    return GestureDetector(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(suSetSp(10.0)),
        ),
        child: Center(
          child: Text(
            "${page['pages'][index]}",
            style: TextStyle(
              fontSize: suSetSp(20.0),
            ),
          ),
        ),
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemesProvider>(
      builder: (_, provider, __) {
        return Scaffold(
          body: Column(
            children: <Widget>[
              FixedAppBar(elevation: 0.0),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: suSetWidth(40.0),
                  ),
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "个性化",
                          style: Theme.of(context).textTheme.title.copyWith(
                                fontSize: suSetSp(40.0),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          "管理您的应用偏好设置",
                          style: Theme.of(context).textTheme.caption.copyWith(
                                fontSize: suSetSp(24.0),
                              ),
                        ),
                        emptyDivider(height: 20.0),
                      ],
                    ),
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => separator(
                        context,
                        color: Colors.transparent,
                        height: 20.0,
                      ),
                      itemCount: pageSection.length,
                      itemBuilder: (context, sectionIndex) => ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: pageSection[sectionIndex].length,
                        itemBuilder: (context, index) => settingItem(
                          context: context,
                          index: index,
                          sectionIndex: sectionIndex,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
