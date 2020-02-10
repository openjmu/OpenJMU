import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: "openjmu://settings", routeName: "设置页")
class SettingsPage extends StatelessWidget {
  List<List<Map<String, dynamic>>> get pageSection => [
        [
          {
            'icon': 'night_mode',
            'name': '夜间模式',
            'description': '减轻眩光，提升夜间使用体验',
            'widget': Consumer<ThemesProvider>(
              builder: (_, provider, __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: provider.dark,
                  onChanged:
                      !provider.platformBrightness ? (bool value) => provider.dark = value : null,
                );
              },
            ),
          },
          {
            'icon': 'follow_system',
            'name': '跟随系统夜间模式',
            'description': '夜间模式将跟随系统主题切换',
            'level': 2,
            'widget': Consumer<ThemesProvider>(
              builder: (_, provider, __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: provider.platformBrightness,
                  onChanged: (bool value) => provider.platformBrightness = value,
                );
              },
            ),
          },
          {
            'icon': 'amoled_black',
            'name': 'AMOLED 黑',
            'description': '更深的背景颜色，节省电量',
            'level': 2,
            'widget': Consumer<ThemesProvider>(
              builder: (_, provider, __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: provider.amoledDark,
                  onChanged: currentIsDark ? (bool value) => provider.amoledDark = value : null,
                );
              },
            ),
          },
        ],
        [
          {
            'icon': 'theme_color',
            'name': '切换主题',
            'description': '多彩颜色，丰富你的界面',
            'widget': Container(
              decoration: BoxDecoration(
                color: currentThemeColor,
                shape: BoxShape.circle,
              ),
              width: suSetWidth(iconSize),
              height: suSetWidth(iconSize),
            ),
            'route': Routes.OPENJMU_THEME,
          },
          {
            'icon': 'launch_page',
            'name': '启动页设置',
            'description': '选择您偏好的启动页面',
            'route': Routes.OPENJMU_SWITCH_STARTUP,
          },
          if (currentUser.isTeacher)
            {
              'icon': 'new_icons',
              'name': '应用中心新图标',
              'description': '全新图标设计，简洁直达',
              'widget': Selector<SettingsProvider, bool>(
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
            },
          {
            'icon': 'font_size',
            'name': '字体大小调节',
            'description': '调整字体大小以获得最佳阅读体验',
            'route': Routes.OPENJMU_FONT_SCALE,
          },
          {
            'icon': 'hide_blocked',
            'name': '隐藏屏蔽的动态',
            'description': '广场中被屏蔽的动态将被隐藏',
            'widget': Selector<SettingsProvider, bool>(
              selector: (_, provider) => provider.hideShieldPost,
              builder: (_, hideShieldPost, __) {
                return CustomSwitch(
                  activeColor: currentThemeColor,
                  value: hideShieldPost,
                  onChanged: (bool value) async {
                    await HiveFieldUtils.setEnabledHideShieldPost(value);
                  },
                );
              },
            ),
          },
        ],
      ];

  double get iconSize => 36.0;

  Widget settingItem({context, int index, int sectionIndex}) {
    final page = pageSection[sectionIndex][index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(page['level'] == null || page['level'] == 1 ? 16.0 : 0.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                left: suSetWidth(((page['level'] ?? 1) - 1) * iconSize / 4),
                right: suSetWidth(iconSize / 2),
              ),
              child: page['level'] == null || page['level'] == 1
                  ? SvgPicture.asset(
                      'assets/icons/settings/${page['icon']}.svg',
                      width: suSetWidth(iconSize),
                      height: suSetWidth(iconSize),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${page['name']}',
                    style: TextStyle(
                      fontSize: suSetSp(
                        page['level'] == null || page['level'] == 1 ? 25.0 : 21.0,
                      ),
                    ),
                  ),
                  Text(
                    '${page['description']}',
                    style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: suSetSp(
                            page['level'] == null || page['level'] == 1 ? 18.0 : 16.0,
                          ),
                        ),
                  ),
                ],
              ),
            ),
            if (page['widget'] != null)
              Transform.scale(
                scale: 1 - (page['level'] ?? 0) * 0.1,
                child: page['widget'],
              ),
            if (page['route'] != null)
              Container(
                margin: EdgeInsets.only(left: suSetWidth(16.0)),
                width: 50.0,
                height: 28.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(suSetWidth(20.0)),
                  color: Theme.of(context).dividerColor,
                ),
                child: SvgPicture.asset(
                  'assets/icons/arrow-right.svg',
                  color: Colors.white.withOpacity(0.9),
                  width: suSetSp(iconSize / 1.25),
                  height: suSetSp(iconSize / 1.25),
                ),
              ),
          ],
        ),
      ),
      onTap: () {
        if (page['onTap'] != null) page['onTap']();
        if (page['route'] != null) {
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
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(suSetSp(10.0)),
        ),
        child: Center(
          child: Text(
            '${page['pages'][index]}',
            style: TextStyle(fontSize: suSetSp(20.0)),
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
              FixedAppBar(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '偏好设置',
                      style: Theme.of(context).textTheme.title.copyWith(
                            fontSize: suSetSp(26.0),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '管理您的应用偏好设置',
                      style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: suSetSp(18.0),
                          ),
                    ),
                  ],
                ),
                elevation: 0.0,
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: suSetWidth(40.0),
                  ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
