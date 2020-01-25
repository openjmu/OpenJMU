import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: "openjmu://notifications",
  routeName: "通知页",
)
class NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  final List<IconData> actionsIcons = [
    Platform.isAndroid ? Ionicons.md_at : Ionicons.ios_at,
    Platform.isAndroid ? Icons.comment : Foundation.comment,
    Platform.isAndroid ? Icons.thumb_up : Ionicons.ios_thumbs_up
  ];

  NotificationProvider provider;

  TabController _tabController, _mentionTabController;

  PostList _mentionPost;
  CommentList _mentionComment;
  CommentList _replyComment;
  PraiseList _praiseList;

  @override
  void initState() {
    provider = Provider.of<NotificationProvider>(currentContext, listen: false);
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: provider.initialIndex,
    );
    _mentionTabController = TabController(
      length: 2,
      vsync: this,
    );

    postByMention();
    commentByMention();
    commentByReply();
    praiseList();

    super.initState();
  }

  List<Widget> get actions => [
        SizedBox(
          width: suSetWidth(220.0),
          child: Consumer<NotificationProvider>(
            builder: (_, provider, __) => TabBar(
              indicatorColor: currentThemeColor,
              indicatorPadding: EdgeInsets.only(bottom: suSetHeight(18.0)),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: suSetHeight(6.0),
              labelPadding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
              tabs: [
                Tab(
                  child: provider.notifications.at != 0
                      ? IconButton(
                          icon: badgeIcon(
                            content:
                                provider.notifications.at == 0 ? "" : provider.notifications.at,
                            icon: Icon(
                              actionsIcons[0],
                              size: suSetWidth(30.0),
                            ),
                          ),
                          onPressed: () {
                            _tabController.animateTo(0);
                            provider.readMention();
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            actionsIcons[0],
                            size: suSetWidth(30.0),
                          ),
                        ),
                ),
                Tab(
                  child: provider.notifications.comment != 0
                      ? IconButton(
                          icon: badgeIcon(
                            content: provider.notifications.comment == 0
                                ? ""
                                : provider.notifications.comment,
                            icon: Icon(
                              actionsIcons[1],
                              size: suSetWidth(30.0),
                            ),
                          ),
                          onPressed: () {
                            _tabController.animateTo(1);
                            provider.readReply();
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            actionsIcons[1],
                            size: suSetWidth(30.0),
                          ),
                        ),
                ),
                Tab(
                  child: provider.notifications.praise != 0
                      ? IconButton(
                          icon: badgeIcon(
                            content: provider.notifications.praise == 0
                                ? ""
                                : provider.notifications.praise,
                            icon: Icon(
                              actionsIcons[2],
                              size: suSetWidth(30.0),
                            ),
                          ),
                          onPressed: () {
                            _tabController.animateTo(2);
                            provider.readPraise();
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            actionsIcons[2],
                            size: suSetWidth(30.0),
                          ),
                        ),
                ),
              ],
              controller: _tabController,
            ),
          ),
        )
      ];

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(suSetHeight(kAppBarHeight)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
          height: Screens.topSafeHeight + suSetHeight(kAppBarHeight),
          child: SafeArea(
            child: Row(
              children: <Widget>[
                BackButton(),
                Spacer(),
                ...actions,
              ],
            ),
          ),
        ),
      ),
      body: ExtendedTabBarView(
        cacheExtent: 2,
        controller: _tabController,
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: suSetHeight(50.0),
                child: TabBar(
                  indicatorColor: currentThemeColor,
                  indicatorPadding: EdgeInsets.only(
                    bottom: suSetHeight(6.0),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: suSetHeight(4.0),
                  labelStyle: TextStyle(
                    fontSize: suSetSp(20.0),
                  ),
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
