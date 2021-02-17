import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/widgets/messages/app_message_preview_widget.dart';
//import 'package:openjmu/widgets/messages/message_preview_widget.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({Key key}) : super(key: key);

  Widget _readAllButton(BuildContext context) {
    return Tapper(
      onTap: () {
        final MessagesProvider p = context.read<MessagesProvider>();
        for (final List<dynamic> ms in p.appsMessages.values) {
          final Iterable<AppMessage> _ms = ms
              .where((dynamic message) => !(message as AppMessage).read)
              ?.cast<AppMessage>();
          for (final AppMessage m in _ms) {
            if (!m.read) {
              m.read = true;
              MessageUtils.sendConfirmMessage(ackId: m.ackId);
            }
          }
        }
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        p.notifyListeners();
      },
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.theme.canvasColor,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          R.ASSETS_ICONS_CLEAR_UNREAD_MESSAGE_SVG,
          color: context.textTheme.bodyText2.color,
          width: 28.w,
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Row(
        children: <Widget>[
          MainPage.selfPageOpener,
          MainPage.outerNetworkIndicator(),
          const Spacer(),
          if (context.watch<MessagesProvider>().unreadCount > 0)
            _readAllButton(context),
        ],
      ),
    );
  }

  Widget _announcementsList(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, SettingsProvider p, __) {
        if (!p.announcementsEnabled) {
          return const SizedBox.shrink();
        }
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 0,
            maxHeight: Screens.height / 3,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                p.announcements.length,
                (int index) => _AnnouncementItemWidget(
                  item: p.announcements[index].cast<String, dynamic>(),
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
                R.ASSETS_PLACEHOLDERS_NO_MESSAGE_SVG,
                width: 50.w,
                color: context.theme.iconTheme.color,
              ),
              VGap(20.w),
              Text(
                '无新消息',
                style: TextStyle(
                  color: context.textTheme.caption.color,
                  fontSize: 22.sp,
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
              child: Text(
                '应用通知',
                style: TextStyle(
                  color: context.textTheme.bodyText2.color.withOpacity(0.625),
                  height: 1.2,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const LineDivider(),
            Expanded(
              child: ListView.separated(
                itemCount: messageProvider.appsMessages.keys.length,
                itemBuilder: (_, int index) {
                  final Map<int, List<dynamic>> _list =
                      messageProvider.appsMessages;
                  final int _index = _list.keys.length - 1 - index;
                  final int appId = _list.keys.elementAt(_index);
                  final AppMessage message = _list[appId][0] as AppMessage;
                  return SlideItem(
                    width: Screens.width,
                    menu: <SlideMenuItem>[deleteWidget(messageProvider, appId)],
                    height: 100.w,
                    child: AppMessagePreviewWidget(message: message),
                  );
                },
                separatorBuilder: (_, __) =>
                    const LineDivider(),
              ),
            ),
          ],
        );
      },
    );
  }

  SlideMenuItem deleteWidget(MessagesProvider provider, int appId) {
    return SlideMenuItem(
      onTap: () {
        provider.deleteFromAppsMessages(appId);
      },
      width: Screens.width * 0.3,
      child: Center(
        child: Text(
          '删除对话',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
      ),
      color: currentThemeColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        title: _appBar(context),
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
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: context.textTheme.caption.color,
        height: 1.2,
        fontSize: 18.sp,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: dividerBS(context),
          ),
          color: context.appBarTheme.color,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              item['title'] as String,
              style: TextStyle(
                color: currentThemeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            VGap(12.w),
            Text(
              item['content'] as String,
              style: const TextStyle(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
