import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/UserUtils.dart';

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
                ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Constants.separator(
                        context,
                        color: Theme.of(context).canvasColor,
                        height: 1.0,
                    ),
                    itemCount: topItems.length,
                    itemBuilder: (context, index) => GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Constants.suSetSp(18.0),
                                vertical: Constants.suSetSp(8.0),
                            ),
                            child: Row(
                                children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(right: Constants.suSetSp(16.0)),
                                        child: index == 0 && notifications.count != 0 ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Constants.badgeIcon(
                                                content: notifications.count,
                                                icon: _icon(index),
                                            ),
                                        ) : IconButton(
                                            icon: _icon(index),
                                            onPressed: null,
                                        ),
                                    ),
                                    Expanded(
                                        child: Text(topItems[index],
                                            style: TextStyle(fontSize: Constants.suSetSp(19.0)),
                                        ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: Constants.suSetSp(12.0)),
                                        child: SvgPicture.asset(
                                            "assets/icons/arrow-right.svg",
                                            color: Colors.grey,
                                            width: Constants.suSetSp(24.0),
                                            height: Constants.suSetSp(24.0),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        onTap: () { _handleItemClick(context, topItems[index]); },
                    ),
                ),
                Constants.separator(context),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(12.0), vertical: Constants.suSetSp(30.0)),
                    child: SizedBox(
                        height: Constants.suSetSp(40.0),
                        child: Center(
                            child: Text(
                                "无新消息",
                                style: TextStyle(
                                    fontSize: Constants.suSetSp(14.0),
                                ),
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}
