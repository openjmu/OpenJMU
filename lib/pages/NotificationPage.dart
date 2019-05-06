import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:badges/badges.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';

import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/model/PraiseController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class NotificationPage extends StatefulWidget {
  final Map arguments;

  NotificationPage({this.arguments});

  @override
  State<StatefulWidget> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  TabController _tabController, _mentionTabController;
  final List<IconData> actionsIcons = [
    Platform.isAndroid ? Ionicons.getIconData("ios-at") : Ionicons.getIconData("md-at"),
    Platform.isAndroid ? Icons.comment : Foundation.getIconData("comment"),
    Platform.isAndroid ? Icons.thumb_up : Ionicons.getIconData("ios-thumbs-up")
  ];

  Color badgeColor = Colors.redAccent;
  Color primaryColor = Colors.white;
  Notifications currentNotifications;

  PostList _mentionPost;
  CommentList _mentionComment;
  CommentList _replyComment;
  PraiseList _praiseList;

  int testIndex;

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      currentNotifications = widget.arguments['notifications'];
    } else {
      currentNotifications = Notifications(0,0,0,0);
    }
    _tabController = TabController(length: 3, vsync: this);
    _tabController.animation.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          testIndex = _tabController.index;
        });
      }
    });
    _mentionTabController = TabController(length: 2, vsync: this);
    postByMention();
    commentByMention();
    commentByReply();
    praiseList();
    Constants.eventBus.on<NotificationsChangeEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          currentNotifications = event.notifications;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> actions() {
    List<Tab> _tabs = [
      Tab(child: BadgeIconButton(
        itemCount: currentNotifications.at,
        icon: Icon(actionsIcons[0], color: primaryColor),
        badgeColor: badgeColor,
        badgeTextColor: primaryColor,
        hideZeroCount: true,
        onPressed: () {
          _tabController.animateTo(0);
          Notifications _notify = currentNotifications;
          setState(() {
            currentNotifications = Notifications(_notify.count - _notify.at, 0, _notify.comment, _notify.praise);
          });
        },
      )),
      Tab(child: BadgeIconButton(
        itemCount: currentNotifications.comment,
        icon: Icon(actionsIcons[1], color: primaryColor),
        badgeColor: badgeColor,
        badgeTextColor: primaryColor,
        hideZeroCount: true,
        onPressed: () {
          _tabController.animateTo(1);
          Notifications _notify = currentNotifications;
          setState(() {
            currentNotifications = Notifications(_notify.count - _notify.comment, _notify.at, 0, _notify.praise);
          });
        },
      )),
      Tab(child: BadgeIconButton(
        itemCount: currentNotifications.praise,
        icon: Icon(actionsIcons[2], color: primaryColor),
        badgeColor: badgeColor,
        badgeTextColor: primaryColor,
        hideZeroCount: true,
        onPressed: () {
          _tabController.animateTo(2);
          Notifications _notify = currentNotifications;
          setState(() {
            currentNotifications = Notifications(_notify.count - _notify.praise, _notify.at, _notify.comment, 0);
          });
        },
      )),
    ];
    return [
      Container(
        width: 220.0,
        child: TabBar(
          indicatorColor: primaryColor,
          tabs: _tabs,
          controller: _tabController,
        )
      )
    ];
  }

  Icon getActionIcon(int curIndex) {
    return Icon(actionsIcons[curIndex], color: primaryColor);
  }

  void postByMention() {
    _mentionPost = new PostList(
        PostController(
            postType: "mention",
            isFollowed: false,
            isMore: false,
            lastValue: (int id) => id
        ),
        needRefreshIndicator: true
    );
  }

  void commentByMention() {
    _mentionComment = new CommentList(
        CommentController(
            commentType: "mention",
            isMore: false,
            lastValue: (int id) => id
        ),
        needRefreshIndicator: true
    );
  }

  void commentByReply() {
    _replyComment = new CommentList(
        CommentController(
            commentType: "reply",
            isMore: false,
            lastValue: (int id) => id
        ),
        needRefreshIndicator: true
    );
  }

  void praiseList() {
    _praiseList = new PraiseList(
        PraiseController(
            isMore: false,
            lastValue: (Praise praise) => praise.id
        ),
        needRefreshIndicator: true
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeUtils.currentColorTheme,
        elevation: 0,
        actions: actions(),
        brightness: Brightness.dark,
      ),
      body: ExtendedTabBarView(
        controller: _tabController,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 42.0,
                  color: ThemeUtils.currentColorTheme,
                  child: TabBar(
                    indicatorColor: primaryColor,
                    labelColor: primaryColor,
                    tabs: <Tab>[
                      Tab(text: "@我的动态"),
                      Tab(text: "@我的评论"),
                    ],
                    controller: _mentionTabController,
                  )
              ),
              Expanded(
                  child: ExtendedTabBarView(
                      controller: _mentionTabController,
                      children: <Widget>[
                        _mentionPost,
                        _mentionComment,
                      ]
                  )
              ),
            ],
          ),
          _replyComment,
          _praiseList,
        ],
      ),
    );
  }

}