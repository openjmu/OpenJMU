import 'package:OpenJMU/pages/test/TestImageCropPage.dart';
import 'package:OpenJMU/pages/test/TestTextPage.dart';
import 'package:flutter/material.dart';

import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/pages/test/TestDragPage.dart';
import 'package:OpenJMU/pages/test/TestUserPage.dart';
import 'package:OpenJMU/pages/test/TestSocketPage.dart';


class TestDashBoardPage extends StatelessWidget {
    final List<Widget> pageList = [
        TestUserPage(UserAPI.currentUser.uid),
        TestSocketPage(),
        TestDragPage(),
        TestTextPage(),
        TestImageCropPage()
    ];

    final List<String> pageTitleList = [
        "用户测试页",
        "连接测试页",
        "滑动测试页",
        "输入测试页",
        "裁剪测试页",
    ];

    final List<IconData> pageIconList = [
        Icons.supervised_user_circle,
        Icons.settings_ethernet,
        Icons.crop_free,
        Icons.border_color,
        Icons.crop,
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
                                    Icon(pageIconList[index]),
                                    Text(pageTitleList[index]),
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
                                        child: pageList[index],
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
