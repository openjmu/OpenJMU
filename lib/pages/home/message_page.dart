import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/widgets/messages/app_message_preview_widget.dart';
//import 'package:openjmu/widgets/messages/message_preview_widget.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key key}) : super(key: key);

  Widget _tabBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: MainPage.selfPageOpener),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Consumer<MessagesProvider>(
                builder: (_, MessagesProvider provider, __) {
                  return Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Positioned(
                        top: 0.0,
                        right: -10.w,
                        child: Visibility(
                          visible: provider.unreadCount > 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              color: currentThemeColor,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '通知',
                        style: MainPageState.tabUnselectedTextStyle,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _announcementsList(BuildContext context) {
    return Selector<SettingsProvider, List<Map<dynamic, dynamic>>>(
      selector: (_, SettingsProvider p) => p.announcements,
      builder: (_, List<Map<dynamic, dynamic>> announcements, __) {
        return DefaultTextStyle.merge(
          style: TextStyle(
            color: adaptiveButtonColor(),
            fontSize: 18.sp,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
              maxHeight: Screens.height / 3,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(
                  announcements.length,
                  (int index) => _AnnouncementItemWidget(
                    item: announcements[index].cast<String, dynamic>(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _messageList(BuildContext context) {
    return Consumer2<MessagesProvider, WebAppsProvider>(
      builder: (
        _,
        MessagesProvider messageProvider,
        WebAppsProvider webAppsProvider,
        __,
      ) {
        final bool shouldDisplayAppsMessages =
            (messageProvider.appsMessages?.isNotEmpty ?? false) &&
                (webAppsProvider.apps?.isNotEmpty ?? false);

        if (!shouldDisplayAppsMessages) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                R.IMAGES_PLACEHOLDER_NO_MESSAGE_SVG,
                width: Screens.width / 3.5,
                height: Screens.width / 3.5,
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.h),
                child: Text(
                  '无新消息',
                  style: TextStyle(fontSize: 22.sp),
                ),
              )
            ],
          );
        }
        return ListView.builder(
          itemCount: messageProvider.appsMessages.keys.length,
          itemBuilder: (_, int index) {
            final Map<int, List<dynamic>> _list = messageProvider.appsMessages;
            final int _index = _list.keys.length - 1 - index;
            final int appId = _list.keys.elementAt(_index);
            final AppMessage message = _list[appId][0] as AppMessage;
            return SlideItem(
              menu: <SlideMenuItem>[
                deleteWidget(messageProvider, appId),
              ],
              child: AppMessagePreviewWidget(message: message),
              height: 88.h,
            );
          },
        );
      },
    );
  }

  SlideMenuItem deleteWidget(MessagesProvider provider, int appId) {
    return SlideMenuItem(
      onTap: () {
        provider.deleteFromAppsMessages(appId);
      },
      child: Center(
        child: Text(
          '删除',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
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
        title: _tabBar(context),
        centerTitle: false,
        automaticallyImplyLeading: false,
        automaticallyImplyActions: false,
      ),
      body: Column(
        children: <Widget>[
          _announcementsList(context),
          Expanded(child: _messageList(context)),
        ],
      ),
    );
  }
}

class _AnnouncementItemWidget extends StatelessWidget {
  const _AnnouncementItemWidget({
    Key key,
    this.item,
  }) : super(key: key);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ).copyWith(top: 16.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.w),
        color: context.theme.colorScheme.primary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item['title'] as String,
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          VGap(5.w),
          Text(item['content'] as String),
        ],
      ),
    );
  }
}
