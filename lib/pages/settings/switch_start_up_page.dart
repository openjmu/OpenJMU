import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/pages/home/school_work_page.dart';

@FFRoute(name: 'openjmu://switch-startup', routeName: '切换启动页')
class SwitchStartUpPage extends StatefulWidget {
  @override
  _SwitchStartUpPageState createState() => _SwitchStartUpPageState();
}

class _SwitchStartUpPageState extends State<SwitchStartUpPage> {
  List<List<String>> get pageTab => <List<String>>[
        List<String>.from(SchoolWorkPageState.tabs),
      ];

  List<List<Map<String, dynamic>>> get pageSection =>
      <List<Map<String, dynamic>>>[
        <Map<String, dynamic>>[
          <String, dynamic>{
            'name': '启动页',
            'pages': List<String>.from(MainPageState.pagesTitle),
            'index': settingsProvider.homeSplashIndex,
          },
        ],
      ];
  SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingsProvider>(
      currentContext,
      listen: false,
    );
  }

  Widget settingItem(BuildContext context, int index, int sectionIndex) {
    final Map<String, dynamic> page = pageSection[sectionIndex][index];
    return Tapper(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${page['name']}',
                  style: context.textTheme.headline6.copyWith(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  '${page['pages'][page['index']]}',
                  style: context.textTheme.caption.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            SvgPicture.asset(
              R.ASSETS_ICONS_ARROW_RIGHT_SVG,
              color: Colors.grey,
              width: 30.w,
              height: 30.w,
            ),
          ],
        ),
      ),
      onTap: () async {
        await showSelection(context, sectionIndex, page, index);
        Future<void>.delayed(1.seconds, () {
          if (mounted) {
            setState(() {});
          }
        });
      },
    );
  }

  Widget pageSelectionItem(
    BuildContext context, {
    int sectionIndex,
    Map<String, dynamic> page,
    int pageIndex,
    int index,
    int selectedIndex,
  }) {
    return Tapper(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Center(
          child: Text(
            '${page['pages'][index]}',
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
      ),
      onTap: () {
        if (page['name'] == '启动页') {
          HiveFieldUtils.setHomeSplashIndex(index);
        } else {
          final List<int> _list = List<int>.from(
            settingsProvider.homeStartUpIndex,
          );
          _list[pageIndex] = index;
          HiveFieldUtils.setHomeStartUpIndex(_list);
        }
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> showSelection(
    BuildContext context,
    int sectionIndex,
    Map<String, dynamic> page,
    int pageIndex,
  ) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 20.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 12.w),
                child: Text(
                  '选择页面',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 6.w,
                crossAxisSpacing: 12.w,
                childAspectRatio: 2.1,
                children: List<Widget>.generate(
                  (page['pages'] as List<String>).length,
                  (int i) => pageSelectionItem(
                    context,
                    sectionIndex: sectionIndex,
                    page: page,
                    pageIndex: pageIndex,
                    index: i,
                    selectedIndex: page['index'] as int,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<List<Map<String, dynamic>>> newPageSection(
    int sectionIndex,
    int pageIndex,
    int index,
  ) {
    final List<List<Map<String, dynamic>>> _section =
        List<List<Map<String, dynamic>>>.from(pageSection);
    _section[sectionIndex][pageIndex]['index'] = index;
    return _section;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '启动页设置',
                style: context.textTheme.headline6.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '选择您偏好的启动页面',
                style: context.textTheme.caption.copyWith(
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ),
        body: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          separatorBuilder: (_, __) => VGap(20.w),
          itemCount: pageSection.length,
          itemBuilder: (_, int sectionIndex) => ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: pageSection[sectionIndex].length,
            itemBuilder: (_, int index) => settingItem(
              context,
              index,
              sectionIndex,
            ),
          ),
        ),
      ),
    );
  }
}
