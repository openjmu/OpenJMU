import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';

import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/model/PraiseController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  TabController _tabController, _mentionTabController;
  final List<IconData> actionsIcons = [
    Platform.isAndroid
        ? Ionicons.getIconData("ios-at")
        : Ionicons.getIconData("md-at"),
    Platform.isAndroid ? Icons.comment : Foundation.getIconData("comment"),
    Platform.isAndroid ? Icons.thumb_up : Ionicons.getIconData("ios-thumbs-up")
  ];

  Color badgeColor = ThemeUtils.currentThemeColor;
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
    currentNotifications = Constants.notifications;
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
    List<Widget> _tabs = [
      Tab(
        child: currentNotifications.at != 0
            ? IconButton(
                icon: Constants.badgeIcon(
                  content: currentNotifications.at == 0
                      ? ""
                      : currentNotifications.at,
                  icon: Icon(actionsIcons[0], size: Constants.suSetSp(26.0)),
                ),
                onPressed: () {
                  _tabController.animateTo(0);
                  Notifications _notify = currentNotifications;
                  setState(() {
                    currentNotifications = Notifications(
                      count: _notify.count - _notify.at,
                      at: 0,
                      comment: _notify.comment,
                      praise: _notify.praise,
                    );
                  });
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(actionsIcons[0], size: Constants.suSetSp(26.0)),
              ),
      ),
      Tab(
        child: currentNotifications.comment != 0
            ? IconButton(
                icon: Constants.badgeIcon(
                  content: currentNotifications.comment == 0
                      ? ""
                      : currentNotifications.comment,
                  icon: Icon(actionsIcons[1], size: Constants.suSetSp(26.0)),
                ),
                onPressed: () {
                  _tabController.animateTo(1);
                  Notifications _notify = currentNotifications;
                  setState(() {
                    currentNotifications = Notifications(
                      count: _notify.count - _notify.comment,
                      at: _notify.at,
                      comment: 0,
                      praise: _notify.praise,
                    );
                  });
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(actionsIcons[1], size: Constants.suSetSp(26.0)),
              ),
      ),
      Tab(
        child: currentNotifications.praise != 0
            ? IconButton(
                icon: Constants.badgeIcon(
                  content: currentNotifications.praise == 0
                      ? ""
                      : currentNotifications.praise,
                  icon: Icon(actionsIcons[2], size: Constants.suSetSp(26.0)),
                ),
                onPressed: () {
                  _tabController.animateTo(2);
                  Notifications _notify = currentNotifications;
                  setState(() {
                    currentNotifications = Notifications(
                      count: _notify.count - _notify.praise,
                      at: _notify.at,
                      comment: _notify.comment,
                      praise: 0,
                    );
                  });
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(actionsIcons[2], size: Constants.suSetSp(26.0)),
              ),
      ),
    ];
    return [
      SizedBox(
        width: Constants.suSetSp(210.0),
        child: TabBar(
          indicatorColor: ThemeUtils.currentThemeColor,
          indicatorPadding: const EdgeInsets.only(bottom: 18.0),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 6.0,
          labelPadding:
              EdgeInsets.symmetric(horizontal: Constants.suSetSp(8.0)),
          tabs: _tabs,
          controller: _tabController,
        ),
      )
    ];
  }

  Icon getActionIcon(int curIndex) => Icon(actionsIcons[curIndex]);

  void postByMention() {
    _mentionPost = PostList(
      PostController(
        postType: "mention",
        isFollowed: false,
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: true,
    );
  }

  void commentByMention() {
    _mentionComment = CommentList(
      CommentController(
        commentType: "mention",
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: true,
    );
  }

  void commentByReply() {
    _replyComment = CommentList(
      CommentController(
        commentType: "reply",
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: true,
    );
  }

  void praiseList() {
    _praiseList = PraiseList(
      PraiseController(
        isMore: false,
        lastValue: (Praise praise) => praise.id,
      ),
      needRefreshIndicator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: actions(),
      ),
      body: ExtendedTabBarView(
        cacheExtent: 2,
        controller: _tabController,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: Constants.suSetSp(42.0),
                child: TabBar(
                  indicatorColor: ThemeUtils.currentThemeColor,
                  indicatorPadding:
                      EdgeInsets.only(bottom: Constants.suSetSp(6.0)),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: Constants.suSetSp(4.0),
                  labelStyle: TextStyle(fontSize: Constants.suSetSp(17.0)),
                  tabs: <Tab>[
                    Tab(text: "@我的评论"),
                    Tab(text: "@我的动态"),
                  ],
                  controller: _mentionTabController,
                ),
              ),
              Expanded(
                child: ExtendedTabBarView(
                  cacheExtent: 1,
                  controller: _mentionTabController,
                  children: <Widget>[
                    _mentionComment,
                    _mentionPost,
                  ],
                ),
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
