///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-01 14:12
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
              color: context.theme.cardColor,
            ),
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: message.content));
                showToast('复制成功');
              },
              child: ExtendedText(
                message.content,
                style: TextStyle(fontSize: 20.sp),
                specialTextSpanBuilder: RegExpSpecialTextSpanBuilder(),
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
          actionsPadding: EdgeInsets.only(right: 18.w),
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

class _LinkText extends LinkText {
  _LinkText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  ) : super(textStyle, onTap, linkHost: startKey);

  static const String startKey = 'https://';

  @override
  TextSpan finishText() {
    return TextSpan(
      text: toString(),
      style: textStyle?.copyWith(decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final Map<String, dynamic> data = <String, dynamic>{
            'content': toString()
          };
          if (onTap != null) {
            onTap(data);
          }
        },
    );
  }
}

class _LinkOlderText extends LinkText {
  _LinkOlderText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  ) : super(textStyle, onTap, linkHost: startKey);

  static const String startKey = 'http://';

  @override
  TextSpan finishText() {
    return TextSpan(
      text: toString(),
      style: textStyle?.copyWith(decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final Map<String, dynamic> data = <String, dynamic>{
            'content': toString()
          };
          if (onTap != null) {
            onTap(data);
          }
        },
    );
  }
}

class RegExpSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  TextSpan build(
    String data, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  }) {
    final RegExp linkRegExp = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\'
      r'.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );

    if (data == null || data == '') {
      return null;
    }
    final List<InlineSpan> inlineList = <InlineSpan>[];
    if (linkRegExp.allMatches(data).isNotEmpty) {
      final Iterable<RegExpMatch> matches = linkRegExp.allMatches(data);
      for (final RegExpMatch match in matches) {
        data = data.replaceFirst(match.group(0), ' ${match.group(0)} ');
      }
    }

    if (data.isNotEmpty) {
      SpecialText specialText;
      String textStack = '';
      for (int i = 0; i < data.length; i++) {
        final String char = data[i];
        textStack += char;
        if (specialText != null) {
          if (!specialText.isEnd(textStack)) {
            specialText.appendContent(char);
          } else {
            inlineList.add(specialText.finishText());
            specialText = null;
            textStack = '';
          }
        } else {
          specialText = createSpecialText(textStack,
              textStyle: textStyle, onTap: onTap, index: i);
          if (specialText != null) {
            if (textStack.length - specialText.startFlag.length >= 0) {
              textStack = textStack.substring(
                  0, textStack.length - specialText.startFlag.length);
              if (textStack.isNotEmpty) {
                inlineList.add(TextSpan(text: textStack, style: textStyle));
              }
            }
            textStack = '';
          }
        }
      }

      if (specialText != null) {
        inlineList.add(TextSpan(
            text: specialText.startFlag + specialText.getContent(),
            style: textStyle));
      } else if (textStack.isNotEmpty) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    } else {
      inlineList.add(TextSpan(text: data, style: textStyle));
    }

    return TextSpan(children: inlineList, style: textStyle);
  }

  @override
  SpecialText createSpecialText(
    String flag, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
    int index,
  }) {
    if (flag?.isEmpty ?? true) {
      return null;
    }

    if (isStart(flag, _LinkText.startKey)) {
      return _LinkText(textStyle, onTap);
    } else if (isStart(flag, _LinkOlderText.startKey)) {
      return _LinkOlderText(textStyle, onTap);
    }
    return null;
  }
}
