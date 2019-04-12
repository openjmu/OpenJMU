import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  TabController _tabController, _mentionTabController;
  final List<IconData> actionsIcons = [Icons.alternate_email, Icons.comment, Icons.thumb_up];

  Color themeColor = ThemeUtils.currentColorTheme;
  Color primaryColor = Colors.white;
  int currentNotifications = 0;

  PostList _mentionPost;
  CommentList _mentionComment;
  CommentList _replyComment;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
    _mentionTabController = new TabController(length: 2, vsync: this);
    postByMention();
    commentByMention();
    commentByReply();
//    Constants.eventBus.on<NotificationCountChangeEvent>().listen((event) {
//      if (this.mounted) {
//        setState(() {
//          currentNotifications = event.notifications;
//        });
//      }
//    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> actions() {
    List<Tab> _tabs = [];
    actionsIcons.forEach((icon) => _tabs.add(
      Tab(icon: new Icon(icon, color: primaryColor))
    ));
    return [
      new Container(
        width: 200.0,
        child: new TabBar(
          tabs: _tabs,
          controller: _tabController,
        )
      )
    ];
  }

  Icon getActionIcon(int curIndex) {
    return new Icon(actionsIcons[curIndex], color: primaryColor);
  }

  void postByMention() {
    _mentionPost = new PostList(
        PostController(
            postType: "mention",
            isFollowed: false,
            isMore: false,
            lastValue: (Post post) => post.id
        ),
        needRefreshIndicator: true
    );
  }

  void commentByMention() {
    _mentionComment = new CommentList(
        CommentController(
            commentType: "mention",
            isMore: false,
            lastValue: (Comment comment) => comment.id
        ),
        needRefreshIndicator: true
    );
  }

  void commentByReply() {
    _replyComment = new CommentList(
        CommentController(
            commentType: "reply",
            isMore: false,
            lastValue: (Comment comment) => comment.id
        ),
        needRefreshIndicator: true
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        actions: actions(),
        iconTheme: new IconThemeData(color: primaryColor),
        brightness: Brightness.dark,
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 42.0,
                  color: themeColor,
                  child: TabBar(
                    labelColor: primaryColor,
                    tabs: <Tab>[
                      Tab(text: "@我的动态"),
                      Tab(text: "@我的评论"),
                    ],
                    controller: _mentionTabController,
                  )
              ),
              Expanded(
                  child: TabBarView(
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
          Center(child: Text("赞")),
        ],
      ),
    );
  }

}