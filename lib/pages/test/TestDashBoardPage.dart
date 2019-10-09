import 'package:flutter/material.dart';

import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/pages/test/TestAnimatedWidgetPage.dart';
import 'package:OpenJMU/pages/test/TestCerStarAskPage.dart';
import 'package:OpenJMU/pages/test/TestCourseSchedulePage.dart';
import 'package:OpenJMU/pages/test/TestDragPage.dart';
import 'package:OpenJMU/pages/test/TestImageCropPage.dart';
import 'package:OpenJMU/pages/test/TestSocketPage.dart';
import 'package:OpenJMU/pages/test/TestUserPage.dart';


class TestDashBoardPage extends StatelessWidget {
    final List<Map<String, dynamic>> pageList = [
        {
            "builder": TestUserPage(UserAPI.currentUser.uid),
            "name": "用户测试页",
            "icon": Icons.supervised_user_circle,
        },
        {
            "builder": TestSocketPage(),
            "name": "连接测试页",
            "icon": Icons.settings_ethernet,
        },
        {
            "builder": TestDragPage(),
            "name": "滑动测试页",
            "icon": Icons.crop_free,
        },
        {
            "builder": TestImageCropPage(),
            "name": "裁剪测试页",
            "icon": Icons.crop,
        },
        {
            "builder": TestAnimatedWidgetPage(),
            "name": "动画测试页",
            "icon": Icons.av_timer,
        },
        {
            "builder": TestCourseSchedulePage(),
            "name": "课表测试页",
            "icon": Icons.date_range,
        },
        {
            "builder": TestCerStarAskPage(),
            "name": "客服测试页",
            "icon": Icons.hearing,
        },
    ];

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("测试页", style: Theme.of(context).textTheme.title),
                centerTitle: true,
            ),
            body: Center(
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3
                    ),
                    itemCount: pageList.length,
                    itemBuilder: (context, index) {
                        return InkWell(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    Icon(pageList[index]['icon']),
                                    Text(pageList[index]['name']),
                                ],
                            ),
                            onTap: () {
                                Navigator.push(context, PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 300),
                                    pageBuilder: (
                                            BuildContext context,
                                            Animation animation,
                                            Animation secondaryAnimation
                                            ) => FadeTransition(
                                        opacity: animation,
                                        child: pageList[index]['builder'],
                                    ),
                                ));
                            },
                        );
                    },
                ),
            )
        );
    }
}
