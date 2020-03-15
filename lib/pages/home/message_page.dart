import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/widgets/messages/app_message_preview_widget.dart';
//import 'package:openjmu/widgets/messages/message_preview_widget.dart';

class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> with TickerProviderStateMixin {
  final _messageScrollController = ScrollController();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: Provider.of<SettingsProvider>(
        currentContext,
        listen: false,
      ).homeStartUpIndex[2],
      length: 1,
      vsync: this,
    );
  }

  Widget get _tabBar => Padding(
        padding: EdgeInsets.symmetric(horizontal: suSetWidth(16.0)),
        child: TabBar(
          isScrollable: true,
          indicator: RoundedUnderlineTabIndicator(
            borderSide: BorderSide(
              color: currentThemeColor,
              width: suSetHeight(3.0),
            ),
            width: suSetWidth(26.0),
            insets: EdgeInsets.only(bottom: suSetHeight(4.0)),
          ),
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
                    Tab(text: '通知'),
                  ],
                );
              },
            ),
          ],
          controller: _tabController,
        ),
      );

  Widget get _messageList => Consumer2<MessagesProvider, WebAppsProvider>(
        builder: (context, messageProvider, webAppsProvider, _) {
          final shouldDisplayAppsMessages = (messageProvider.appsMessages?.isNotEmpty ?? false) &&
              (webAppsProvider.apps?.isNotEmpty ?? false);
//            final shouldDisplayPersonalMessages =
//                messageProvider.personalMessages.isNotEmpty;
          final shouldDisplayMessages = shouldDisplayAppsMessages
//                    ||
//                    shouldDisplayPersonalMessages
              ;

          if (!shouldDisplayMessages) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  R.IMAGES_PLACEHOLDER_NO_MESSAGE_SVG,
                  width: Screens.width / 3.5,
                  height: Screens.width / 3.5,
                ),
                Padding(
                  padding: EdgeInsets.only(top: suSetHeight(30.0)),
                  child: Text(
                    '无新消息',
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
                        height: suSetHeight(88.0),
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
      color: currentThemeColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        title: _tabBar,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _messageList,
        ],
      ),
    );
  }
}
