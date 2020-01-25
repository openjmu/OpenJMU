import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/pages/home/apps_page.dart';
import 'package:openjmu/pages/home/post_square_list_page.dart';

@FFRoute(
  name: "openjmu://switch-startup",
  routeName: "切换启动页",
)
class SwitchStartUpPage extends StatefulWidget {
  @override
  _SwitchStartUpPageState createState() => _SwitchStartUpPageState();
}

class _SwitchStartUpPageState extends State<SwitchStartUpPage> {
  List<List<String>> get pageTab => [
        List.from(PostSquareListPageState.tabs),
        List.from(AppsPageState.tabs),
      ];
  List<List<Map<String, dynamic>>> get pageSection => [
        [
          {
            "name": "启动页",
            "pages": List.from(MainPageState.pagesTitle),
            "index": settingsProvider.homeSplashIndex,
          },
        ],
        [
          for (int i = 0; i < pageTab.length; i++)
            {
              "name": MainPageState.pagesTitle[i],
              "pages": pageTab[i],
              "index": settingsProvider.homeStartUpIndex[i],
            }
        ],
      ];
  SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(currentContext, listen: false);
    super.initState();
  }

  Widget settingItem(context, index, sectionIndex) {
    final page = pageSection[sectionIndex][index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: suSetHeight(16.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${page["name"]}",
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: suSetSp(26.0),
                        fontWeight: FontWeight.normal,
                      ),
                ),
                Text(
                  "${page["pages"][page["index"]]}",
                  style: Theme.of(context).textTheme.caption.copyWith(
                        fontSize: suSetSp(18.0),
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ),
            SvgPicture.asset(
              "assets/icons/arrow-right.svg",
              color: Colors.grey,
              width: suSetWidth(30.0),
              height: suSetWidth(30.0),
            ),
          ],
        ),
      ),
      onTap: () async {
        await showSelection(context, sectionIndex, page, index);
        Future.delayed(1.seconds, () {
          if (mounted) setState(() {});
        });
      },
    );
  }

  Widget pageSelectionItem(
    context, {
    int sectionIndex,
    Map<String, dynamic> page,
    int pageIndex,
    int index,
    int selectedIndex,
  }) {
    return GestureDetector(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(suSetSp(10.0)),
        ),
        child: Center(
          child: Text(
            "${page['pages'][index]}",
            style: TextStyle(fontSize: suSetSp(20.0)),
          ),
        ),
      ),
      onTap: () {
        if (page["name"] == "启动页") {
          HiveFieldUtils.setHomeSplashIndex(index);
        } else {
          final _list = List<int>.from(settingsProvider.homeStartUpIndex);
          _list[pageIndex] = index;
          HiveFieldUtils.setHomeStartUpIndex(_list);
        }
        Navigator.of(context).pop();
      },
    );
  }

  Future showSelection(context, sectionIndex, page, pageIndex) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: suSetSp(20.0),
            horizontal: suSetSp(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: suSetSp(12.0)),
                child: Text(
                  "选择页面",
                  style: TextStyle(
                    fontSize: suSetSp(24.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: suSetSp(6.0),
                crossAxisSpacing: suSetSp(12.0),
                childAspectRatio: 2.1,
                children: List<Widget>.generate(
                  page['pages'].length,
                  (i) => pageSelectionItem(
                    context,
                    sectionIndex: sectionIndex,
                    page: page,
                    pageIndex: pageIndex,
                    index: i,
                    selectedIndex: page["index"],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List newPageSection(sectionIndex, pageIndex, index) {
    List<List<Map<String, dynamic>>> _section = List.from(pageSection);
    _section[sectionIndex][pageIndex]["index"] = index;
    return _section;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FixedAppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "启动页设置",
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: suSetSp(26.0),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  "选择您偏好的启动页面",
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
              padding: EdgeInsets.symmetric(horizontal: suSetSp(40.0)),
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
                  context,
                  index,
                  sectionIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
