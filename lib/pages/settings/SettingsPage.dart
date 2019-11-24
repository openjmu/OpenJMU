import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';

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
        "icon": "nightmode",
        "name": "夜间模式",
        "description": "减轻眩光，提升夜间使用体验",
      },
      {
        "icon": "nightmode",
        "name": "跟随系统夜间模式",
        "description": "夜间模式跟随系统主题切换",
      },
      {
        "icon": "nightmode",
        "name": "A屏黑",
        "description": "使用AMOLED黑主题作为夜间模式",
      },
      {
        "icon": "theme",
        "name": "切换主题",
        "description": "多彩颜色，丰富你的界面",
        "route": "theme",
      },
      {
        "icon": "homeSplash",
        "name": "启动页设置",
        "description": "设置各个页面的启动页",
        "route": "switch-startup",
      },
      {
        "icon": "apps",
        "name": "应用中心新图标",
        "description": "全新图标设计，简洁直达",
      },
      {
        "icon": "fontScale",
        "name": "调节字体大小",
        "description": "选择最适合你的字体大小",
        "route": "font-scale"
      },
    ],
  ];
  List<List<Widget>> settingsWidget;

  Widget settingItem({context, int index, int sectionIndex}) {
    final Map<String, dynamic> page = pageSection[sectionIndex][index];
    settingsWidget = [
      [
        PlatformSwitch(
          activeColor: ThemeUtils.currentThemeColor,
          value: ThemeUtils.isDark,
          onChanged: !ThemeUtils.isPlatformBrightness
              ? (bool value) {
                  ThemeUtils.isDark = value;
                  DataUtils.setBrightness(value);
                  Instances.eventBus.fire(ChangeBrightnessEvent(value));
                }
              : null,
        ),
        PlatformSwitch(
          activeColor: ThemeUtils.currentThemeColor,
          value: ThemeUtils.isPlatformBrightness,
          onChanged: (bool value) {
            ThemeUtils.isPlatformBrightness = value;
            DataUtils.setBrightnessPlatform(value);
            Instances.eventBus.fire(ChangeBrightnessEvent(
              MediaQuery.of(context).platformBrightness == Brightness.dark,
            ));
            if (mounted) setState(() {});
          },
        ),
        PlatformSwitch(
          activeColor: ThemeUtils.currentThemeColor,
          value: ThemeUtils.isAMOLEDDark,
          onChanged: (bool value) {
            ThemeUtils.isAMOLEDDark = value;
            DataUtils.setAMOLEDDark(value);
            Instances.eventBus.fire(ChangeAMOLEDDarkEvent(value));
            if (mounted) setState(() {});
          },
        ),
        null,
        null,
        PlatformSwitch(
          activeColor: ThemeUtils.currentThemeColor,
          value: Configs.newAppCenterIcon,
          onChanged: (bool value) {
            DataUtils.setEnabledNewAppsIcon(value);
            Instances.eventBus.fire(AppCenterSettingsUpdateEvent());
            if (mounted) setState(() {});
          },
        ),
        null,
      ],
    ];
    final Widget pageWidget = settingsWidget[sectionIndex][index];
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: suSetSp(18.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: suSetSp(12.0),
              ),
              child: SvgPicture.asset(
                "assets/icons/${page['icon']}-line.svg",
                color: Theme.of(context).iconTheme.color,
                width: suSetSp(30.0),
                height: suSetSp(30.0),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${page["name"]}",
                    style: TextStyle(
                      fontSize: suSetSp(22.0),
                    ),
                  ),
                  Text(
                    "${page["description"]}",
                    style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: suSetSp(14.0),
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
                width: suSetSp(24.0),
                height: suSetSp(24.0),
              ),
          ],
        ),
      ),
      onTap: () {
        if (page['onTap'] != null) page['onTap']();
        if (pageWidget == null && page['route'] != null) {
          navigatorState.pushNamed("openjmu://${page['route']}");
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
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: suSetWidth(40.0),
        ),
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "设置",
                style: Theme.of(context).textTheme.title.copyWith(
                      fontSize: suSetSp(40.0),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                "管理该应用的各项设置",
                style: Theme.of(context).textTheme.subtitle.copyWith(
                      fontSize: suSetSp(20.0),
                    ),
              ),
              Constants.emptyDivider(height: 20.0),
            ],
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Constants.separator(
              context,
              color: Colors.transparent,
              height: 20.0,
            ),
            itemCount: pageSection.length,
            itemBuilder: (context, sectionIndex) => ListView.builder(
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
    );
  }
}
