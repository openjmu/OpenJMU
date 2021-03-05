///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-01 14:12
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_list/extended_list.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: 'openjmu://chat-app-message-page',
  routeName: '应用消息页',
  argumentImports: <String>['import \'model/models.dart\';'],
)
class ChatAppMessagePage extends StatefulWidget {
  const ChatAppMessagePage({
    @required this.app,
    Key key,
  }) : super(key: key);

  final WebApp app;

  @override
  _ChatAppMessagePageState createState() => _ChatAppMessagePageState();
}

class _ChatAppMessagePageState extends State<ChatAppMessagePage> {
  final ScrollController _scrollController = ScrollController();

  MessagesProvider messagesProvider;

  @override
  void initState() {
    super.initState();
    messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
  }

  void judgeMessageConfirm() {
    final List<AppMessage> messages = List<AppMessage>.from(
      messagesProvider.appsMessages[widget.app.appId],
    );
    final List<AppMessage> unreadMessages =
        messages.where((AppMessage appMessage) {
      return !appMessage.read;
    })?.toList();
    if (unreadMessages.isNotEmpty) {
      while (unreadMessages.last.messageId == null &&
          unreadMessages.last.ackId == null) {
        unreadMessages.last.read = true;
        unreadMessages.removeLast();
      }
      if (unreadMessages.isNotEmpty) {
        final AppMessage message = unreadMessages[0];
        if (message.ackId != null && message.ackId != 0) {
          MessageUtils.sendConfirmMessage(ackId: message.ackId);
        }
        if (!message.read) {
          message.read = true;
        }
      }
      for (final AppMessage message in unreadMessages) {
        message.read = true;
      }
    }
    messagesProvider.saveAppsMessages();
  }

  void tryDecodeContent(AppMessage message) {
    try {
      final Map<String, dynamic> content =
          jsonDecode(message.content) as Map<String, dynamic>;
      message.content = content['content'] as String;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      return;
    }
  }

  String timeHandler(DateTime dateTime) {
    final DateTime now = currentTime;
    String time = '';
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      time += DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.year == now.year) {
      time += DateFormat('MM-dd HH:mm').format(dateTime);
    } else {
      time += DateFormat('yy-MM-dd HH:mm').format(dateTime);
    }
    return time;
  }

  Widget _appJumpButton(BuildContext context) {
    return Tapper(
      onTap: () {
        API.launchWeb(url: widget.app.replacedUrl, app: widget.app);
      },
      child: Container(
        width: 120.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.themeColor,
        ),
        alignment: Alignment.center,
        child: Text(
          '前往应用',
          style: TextStyle(
            color: adaptiveButtonColor(),
            fontSize: 20.sp,
            height: 1.24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget messageWidget(AppMessage message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      child: Column(
        children: <Widget>[
          Text(
            timeHandler(message.sendTime),
            style: context.textTheme.caption.copyWith(fontSize: 16.sp),
          ),
          VGap(16.w),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.w),
              color: context.surfaceColor,
            ),
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: message.content));
                showToast('复制成功');
              },
              child: ExtendedText(
                message.content,
                style: TextStyle(fontSize: 20.sp),
                specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
                onSpecialTextTap: (dynamic data) {
                  API.launchWeb(
                    url: data['content'] as String,
                    title: '网页链接',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    judgeMessageConfirm();

    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          title: Text(widget.app.name),
          actions: <Widget>[
            if (widget.app.url?.isNotEmpty == true) _appJumpButton(context),
          ],
        ),
        body: Consumer<MessagesProvider>(
          builder: (_, MessagesProvider provider, __) {
            final List<AppMessage> messages = List<AppMessage>.from(
              provider.appsMessages[widget.app.appId],
            );
            return ExtendedListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 8.w),
              reverse: true,
              extendedListDelegate: const ExtendedListDelegate(
                closeToTrailing: true,
              ),
              itemCount: messages.length,
              itemBuilder: (_, int i) {
                tryDecodeContent(messages[i]);
                return messageWidget(messages[i]);
              },
            );
          },
        ),
      ),
    );
  }
}
