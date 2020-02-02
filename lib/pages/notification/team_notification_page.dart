///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-23 06:50
///
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_mention_list_page.dart';
import 'package:openjmu/pages/post/team_reply_list_page.dart';
import 'package:openjmu/pages/post/team_praise_list_page.dart';

@FFRoute(name: 'openjmu://team-notifications', routeName: '小组通知页')
class TeamNotificationPage extends StatefulWidget {
  @override
  _TeamNotificationPageState createState() => _TeamNotificationPageState();
}

class _TeamNotificationPageState extends State<TeamNotificationPage> with TickerProviderStateMixin {
  final List<IconData> actionsIcons = [
    Platform.isAndroid ? Ionicons.md_at : Ionicons.ios_at,
    Platform.isAndroid ? Icons.comment : Foundation.comment,
    Platform.isAndroid ? Icons.thumb_up : Ionicons.ios_thumbs_up,
  ];

  NotificationProvider provider;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<NotificationProvider>(currentContext, listen: false);

    _tabController = TabController(
      initialIndex: getInitialIndex(),
      length: 3,
      vsync: this,
    );
  }

  int getInitialIndex() {
    final latestNotify = provider.teamNotifications.latestNotify;
    int index = 0;
    switch (latestNotify) {
      case 'mention':
        index = 0;
        break;
      case 'reply':
        index = 1;
        break;
      case 'praise':
        index = 2;
        break;
    }
    return index;
  }

  Widget actions() {
    final notification = provider.teamNotifications;
    return SizedBox(
      width: suSetWidth(220.0),
      child: Consumer<NotificationProvider>(
        builder: (_, provider, __) => TabBar(
          controller: _tabController,
          indicator: RoundedUnderlineTabIndicator(
            borderSide: BorderSide(
              color: currentThemeColor,
              width: suSetHeight(3.0),
            ),
            width: suSetWidth(28.0),
            insets: EdgeInsets.only(bottom: suSetHeight(6.0)),
          ),
          labelPadding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
          tabs: [
            Tab(
              child: notification.mention != 0
                  ? IconButton(
                      icon: badgeIcon(
                        showBadge: notification.mention != 0,
                        content: notification.mention,
                        icon: Icon(actionsIcons[0], size: suSetSp(26.0)),
                      ),
                      onPressed: () {
                        _tabController.animateTo(0);
                        provider.readMention();
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(actionsIcons[0], size: suSetWidth(30.0)),
                    ),
            ),
            Tab(
              child: notification.reply != 0
                  ? IconButton(
                      icon: badgeIcon(
                        showBadge: notification.reply != 0,
                        content: notification.reply,
                        icon: Icon(actionsIcons[1], size: suSetWidth(30.0)),
                      ),
                      onPressed: () {
                        _tabController.animateTo(1);
                        provider.readReply();
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(actionsIcons[1], size: suSetWidth(30.0)),
                    ),
            ),
            Tab(
              child: notification.praise != 0
                  ? IconButton(
                      icon: badgeIcon(
                        showBadge: notification.praise != 0,
                        content: notification.praise,
                        icon: Icon(actionsIcons[2], size: suSetWidth(30.0)),
                      ),
                      onPressed: () {
                        _tabController.animateTo(2);
                        provider.readPraise();
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(actionsIcons[2], size: suSetWidth(30.0)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [actions()]),
      body: ExtendedTabBarView(
        cacheExtent: 2,
        controller: _tabController,
        children: <Widget>[
          TeamMentionListPage(),
          TeamReplyListPage(),
          TeamPraiseListPage(),
        ],
      ),
    );
  }
}
