import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class MessagePage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> {
    List<String> topItems = ["评论/留言", "粉丝"];
    List<String> topIcons = ["liuyan", "idols"];

    Notifications notifications = Constants.notifications;

    @override
    void initState() {
    super.initState();
    Constants.eventBus
        ..on<NotificationsChangeEvent>().listen((event) {
            if (this.mounted) setState(() {
                notifications = event.notifications;
            });
        });
  }

    void _handleItemClick(context, String item) {
        switch (item) {
            case "评论/留言":
                Navigator.of(context).pushNamed("/notification");
                break;
            case "粉丝":
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                    return UserListPage(UserUtils.currentUser, 2);
                }));
                break;
            default:
                break;
        }
    }
    
    Widget _icon(int index) {
        return SvgPicture.asset(
            "assets/icons/${topIcons[index]}-line.svg",
            color: Theme.of(context).iconTheme.color,
            width: Constants.suSetSp(30.0),
            height: Constants.suSetSp(30.0),
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return ListView(
            shrinkWrap: true,
            children: <Widget>[
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        for (int index = 0; index < topItems.length; index++) Padding(
                            padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(10.0), vertical: Constants.suSetSp(4.0)),
                            child: ListTile(
                                leading: index == 0 ? BadgeIconButton(
                                    itemCount: notifications.count,
                                    icon: _icon(index),
                                    badgeColor: ThemeUtils.currentThemeColor,
                                ) : IconButton(
                                    icon: _icon(index),
                                    onPressed: null,
                                ),
                                title: Text(topItems[index], style: TextStyle(fontSize: Constants.suSetSp(18.0))),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                onTap: () { _handleItemClick(context, topItems[index]); },
                            ),
                        )
                    ],
                ),
                Constants.separator(context),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(12.0), vertical: Constants.suSetSp(30.0)),
                    child: SizedBox(height: Constants.suSetSp(40.0), child: Center(child: Text("无新消息"),),),
                ),
            ],
        );
    }
}
