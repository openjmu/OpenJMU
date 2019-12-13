import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/widgets/AppBar.dart';
import 'package:OpenJMU/widgets/SlideMenuItem.dart';
import 'package:OpenJMU/widgets/messages/AppMessagePreviewWidget.dart';
import 'package:OpenJMU/widgets/messages/MessagePreviewWidget.dart';

class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage>
    with TickerProviderStateMixin {
  final _messageScrollController = ScrollController();
  final List<Map<String, dynamic>> notificationItems = [
    {
      "name": "评论/留言",
      "icons": "liuyan",
      "action": () {
        navigatorState.pushNamed("openjmu://notifications");
      },
    },
    {
      "name": "集市消息",
      "icons": "idols",
      "action": () {
        navigatorState.pushNamed("openjmu://team-notifications");
      },
    },
  ];

  Color currentThemeColor = ThemeUtils.currentThemeColor;
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: Configs.homeStartUpIndex[2],
      length: 2,
      vsync: this,
    );

    Instances.eventBus
      ..on<ChangeThemeEvent>().listen((event) {
        currentThemeColor = event.color;
        if (this.mounted) setState(() {});
      });
    super.initState();
  }

  Widget _icon(int index) {
    return SvgPicture.asset(
      "assets/icons/${notificationItems[index]['icons']}-line.svg",
      color: Theme.of(context).iconTheme.color,
      width: suSetWidth(32.0),
      height: suSetWidth(32.0),
    );
  }

  Widget get _tabBar => Padding(
        padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
        child: TabBar(
          isScrollable: true,
          indicatorColor: currentThemeColor,
          indicatorPadding: EdgeInsets.only(
            bottom: suSetHeight(16.0),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: suSetHeight(6.0),
          labelColor: Theme.of(context).textTheme.body1.color,
          labelStyle: MainPageState.tabSelectedTextStyle,
          labelPadding: EdgeInsets.symmetric(
            horizontal: suSetWidth(20.0),
          ),
          unselectedLabelStyle: MainPageState.tabUnselectedTextStyle,
          tabs: <Widget>[
            Consumer<MessagesProvider>(
              builder: (_, provider, __) {
                return Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Positioned(
                      top: suSetHeight(kToolbarHeight / 4),
                      right: -suSetWidth(10.0),
                      child: Visibility(
                        visible: provider.unreadCount > 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: suSetWidth(12.0),
                            height: suSetWidth(12.0),
                            color: currentThemeColor,
                          ),
                        ),
                      ),
                    ),
                    Tab(text: "消息"),
                  ],
                );
              },
            ),
            Consumer<NotificationProvider>(
              builder: (_, provider, __) {
                return Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Positioned(
                      top: suSetHeight(kToolbarHeight / 4),
                      right: -suSetWidth(10.0),
                      child: Visibility(
                        visible: provider.showNotification,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: suSetWidth(12.0),
                            height: suSetWidth(12.0),
                            color: currentThemeColor,
                          ),
                        ),
                      ),
                    ),
                    Tab(text: "通知"),
                  ],
                );
              },
            ),
          ],
          controller: _tabController,
        ),
      );

  Widget get _notificationEntries => Consumer<NotificationProvider>(
        builder: (_, provider, __) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: suSetWidth(18.0),
                    vertical: suSetHeight(12.0),
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: suSetSp(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: badgeIcon(
                            content: provider.notification.total,
                            icon: _icon(0),
                            showBadge: provider.notification.total > 0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          notificationItems[0]['name'],
                          style: TextStyle(
                            fontSize: suSetSp(22.0),
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
                          width: suSetWidth(30.0),
                          height: suSetWidth(30.0),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: notificationItems[0]['action'],
              ),
              separator(
                context,
                color: Theme.of(context).canvasColor,
                height: 1.0,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: suSetWidth(18.0),
                    vertical: suSetHeight(12.0),
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: suSetSp(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: badgeIcon(
                            content: provider.teamNotification.total,
                            icon: _icon(1),
                            showBadge: provider.teamNotification.total > 0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          notificationItems[1]['name'],
                          style: TextStyle(
                            fontSize: suSetSp(22.0),
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
                          width: suSetWidth(30.0),
                          height: suSetWidth(30.0),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: notificationItems[1]['action'],
              ),
            ],
          );
        },
      );

  Widget get _messageList => Consumer2<MessagesProvider, WebAppsProvider>(
        builder: (context, messageProvider, webAppsProvider, _) {
          final shouldDisplayAppsMessages =
              messageProvider.appsMessages.isNotEmpty &&
                  webAppsProvider.apps.isNotEmpty;
//            final shouldDisplayPersonalMessages =
//                messageProvider.personalMessages[currentUser.uid].isNotEmpty;
          final shouldDisplayMessages = shouldDisplayAppsMessages
//                    ||
//                    shouldDisplayPersonalMessages
              ;

          if (!shouldDisplayMessages) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "images/placeholder/no_message.svg",
                  width: Screen.width / 3.5,
                  height: Screen.width / 3.5,
                ),
                Padding(
                  padding: EdgeInsets.only(top: suSetHeight(30.0)),
                  child: Text(
                    "无新消息",
                    style: TextStyle(fontSize: suSetSp(22.0)),
                  ),
                )
              ],
            );
          }
          return CustomScrollView(
            controller: _messageScrollController,
            slivers: <Widget>[
              if (shouldDisplayAppsMessages)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final _list = messageProvider.appsMessages;
                      final _index = _list.keys.length - 1 - index;
                      final appId = _list.keys.elementAt(_index);
                      final AppMessage message = _list[appId][0];
                      return SlideItem(
                        menu: <SlideMenuItem>[
                          deleteWidget(messageProvider, appId),
                        ],
                        child: AppMessagePreviewWidget(message: message),
                        height: suSetHeight(70.0),
                      );
                    },
                    childCount: messageProvider.appsMessages.keys.length,
                  ),
                ),
//                if (shouldDisplayAppsMessages)
//                  SliverToBoxAdapter(
//                    child: Constants.separator(context),
//                  ),
//                if (shouldDisplayPersonalMessages)
//                  SliverList(
//                    delegate: SliverChildBuilderDelegate(
//                      (context, index) {
//                        final mine =
//                            messageProvider.personalMessages[currentUser.uid];
//                        final uid = mine.keys.elementAt(index);
//                        final Message message = mine[uid].first;
//                        return MessagePreviewWidget(
//                          uid: uid,
//                          message: message,
//                          unreadMessages: mine[uid],
//                        );
//                      },
//                      childCount: messageProvider
//                          .personalMessages[currentUser.uid].keys.length,
//                    ),
//                  ),
            ],
          );
        },
      );

  Widget deleteWidget(MessagesProvider provider, int appId) {
    return SlideMenuItem(
      onTap: () {
        provider.deleteFromAppsMessages(appId);
      },
      child: Center(
        child: Text(
          '删除',
          style: TextStyle(
            color: Colors.white,
            fontSize: suSetSp(20.0),
          ),
        ),
      ),
      color: ThemeUtils.currentThemeColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: _tabBar,
            centerTitle: false,
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _messageList,
                ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    _notificationEntries,
                    separator(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
