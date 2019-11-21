import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/MainPage.dart';

class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
//  static final List<String> tabs = ["消息", "通知"];
  static final List<String> tabs = ["消息"];

  List<String> topItems = ["评论/留言", "粉丝"];
  List<String> topIcons = ["liuyan", "idols"];

  Notifications notifications = Instances.notifications;
  Color currentThemeColor = ThemeUtils.currentThemeColor;
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: Configs.homeStartUpIndex[2],
      length: tabs.length,
      vsync: this,
    );

    Instances.eventBus
      ..on<NotificationsChangeEvent>().listen((event) {
        notifications = event.notifications;
        if (this.mounted) setState(() {});
      })
      ..on<ChangeThemeEvent>().listen((event) {
        currentThemeColor = event.color;
        if (this.mounted) setState(() {});
      });
    super.initState();
  }

  void _handleItemClick(context, String item) {
    switch (item) {
      case "评论/留言":
        navigatorState.pushNamed("openjmu://notifications");
        break;
      case "粉丝":
        navigatorState.pushNamed(
          "openjmu://userlist",
          arguments: {
            "user": UserAPI.currentUser,
            "type": 2,
          },
        );
        break;
      default:
        break;
    }
  }

  Widget _icon(int index) {
    return SvgPicture.asset(
      "assets/icons/${topIcons[index]}-line.svg",
      color: Theme.of(context).iconTheme.color,
      width: suSetSp(30.0),
      height: suSetSp(30.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: TabBar(
                isScrollable: true,
                indicatorColor: currentThemeColor,
                indicatorPadding: EdgeInsets.only(
                  bottom: suSetSp(16.0),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: suSetSp(6.0),
                labelColor: Theme.of(context).textTheme.body1.color,
                labelStyle: MainPageState.tabSelectedTextStyle,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: suSetSp(16.0),
                ),
                unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
                tabs: <Tab>[
                  for (int i = 0; i < tabs.length; i++) Tab(text: tabs[i])
                ],
                controller: _tabController,
              ),
            ),
          ],
        ),
//        centerTitle: false,
        centerTitle: true,
      ),
      body:
//      TabBarView(
//        controller: _tabController,
//        children: <Widget>[
          ListView(
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
                  horizontal: suSetSp(18.0),
                  vertical: suSetSp(8.0),
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: suSetSp(16.0),
                      ),
                      child: index == 0 && notifications.count != 0
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Constants.badgeIcon(
                                content: notifications.count,
                                icon: _icon(index),
                              ),
                            )
                          : IconButton(
                              icon: _icon(index),
                              onPressed: null,
                            ),
                    ),
                    Expanded(
                      child: Text(
                        topItems[index],
                        style: TextStyle(
                          fontSize: suSetSp(19.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: suSetSp(12.0),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/arrow-right.svg",
                        color: Colors.grey,
                        width: suSetSp(24.0),
                        height: suSetSp(24.0),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                _handleItemClick(context, topItems[index]);
              },
            ),
          ),
          Constants.separator(context),
          if (Configs.debug)
            Consumer<MessagesProvider>(
              builder: (context, provider, _) {
                if (UserAPI.currentUser.uid == null) return SizedBox.shrink();
                if (provider.personalMessages.entries.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: suSetSp(12.0),
                      vertical: suSetSp(30.0),
                    ),
                    child: SizedBox(
                      height: suSetSp(40.0),
                      child: Center(
                        child: Text(
                          "无新消息",
                          style: TextStyle(
                            fontSize: suSetSp(14.0),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: provider
                        .personalMessages[UserAPI.currentUser.uid]
                        .entries
                        .length,
                    itemBuilder: (context, index) {
                      final mine =
                          provider.personalMessages[UserAPI.currentUser.uid];
                      final uid = mine.keys.elementAt(index);
                      final message = mine[uid][0];
                      return MessagePreviewWidget(
                        uid: uid,
                        message: message,
                        unreadMessages: mine[uid],
                      );
                    },
                  );
                }
              },
            ),
          if (!Configs.debug)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(12.0),
                vertical: suSetSp(30.0),
              ),
              child: SizedBox(
                height: suSetSp(40.0),
                child: Center(
                  child: Text(
                    "无新消息",
                    style: TextStyle(
                      fontSize: suSetSp(14.0),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
//          SizedBox(),
//        ],
//      ),
    );
  }
}

class MessagePreviewWidget extends StatefulWidget {
  final int uid;
  final WebApp app;
  final Message message;
  final List<Message> unreadMessages;

  const MessagePreviewWidget({
    this.uid,
    this.app,
    @required this.message,
    @required this.unreadMessages,
    Key key,
  })  : assert(uid != null || app != null),
        super(key: key);

  @override
  _MessagePreviewWidgetState createState() => _MessagePreviewWidgetState();
}

class _MessagePreviewWidgetState extends State<MessagePreviewWidget>
    with AutomaticKeepAliveClientMixin {
  UserInfo user;

  Timer timeUpdateTimer;
  String formattedTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    UserAPI.getUserInfo(uid: widget.uid).then((response) {
      user = UserInfo.fromJson(response.data);
      if (mounted) setState(() {});
    }).catchError((e) {
      debugPrint("$e");
    });

    timeFormat(null);
    timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), timeFormat);

    super.initState();
  }

  @override
  void dispose() {
    timeUpdateTimer?.cancel();
    super.dispose();
  }

  void timeFormat(_) {
    final now = DateTime.now();
    if (widget.message.sendTime.day == now.day &&
        widget.message.sendTime.month == now.month &&
        widget.message.sendTime.year == now.year) {
      formattedTime = DateFormat("HH:mm").format(widget.message.sendTime);
    } else if (widget.message.sendTime.year == now.year) {
      formattedTime = DateFormat("MM-dd HH:mm").format(widget.message.sendTime);
    } else {
      formattedTime =
          DateFormat("YY-MM-dd HH:mm").format(widget.message.sendTime);
    }
    if (mounted) setState(() {});
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: suSetSp(16.0),
      ),
      height: suSetSp(90.0),
      decoration: BoxDecoration(),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: suSetSp(16.0),
            ),
            child: UserAPI.getAvatar(size: 60.0, uid: widget.uid),
          ),
          Expanded(
            child: SizedBox(
              height: suSetSp(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        height: suSetSp(30.0),
                        child: user != null
                            ? Text(
                                "${user.name ?? user.uid}",
                                style:
                                    Theme.of(context).textTheme.body1.copyWith(
                                          fontSize: suSetSp(20.0),
                                          fontWeight: FontWeight.w500,
                                        ),
                              )
                            : SizedBox.shrink(),
                      ),
                      Text(
                        " $formattedTime",
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .color
                                  .withOpacity(0.5),
                            ),
                      ),
                      Spacer(),
                      Container(
                        width: suSetSp(20.0),
                        height: suSetSp(20.0),
                        decoration: BoxDecoration(
                          color: ThemeUtils.currentThemeColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${widget.unreadMessages.length}",
                            style: TextStyle(
                              fontSize: suSetSp(14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.message.content['content']}",
                    style: Theme.of(context).textTheme.body1.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .body1
                              .color
                              .withOpacity(0.5),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
