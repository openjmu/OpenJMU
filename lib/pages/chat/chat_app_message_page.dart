///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-01 14:12
///
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: 'openjmu://chat-app-message-page',
  routeName: '应用消息页',
  argumentImports: <String>[
    'import \'model/models.dart\';',
  ],
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

  bool shrinkWrap = true;

  MessagesProvider messagesProvider;

  @override
  void initState() {
    super.initState();
    messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
  }

  Widget get topBar {
    return FixedAppBar(
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  WebAppIcon(size: 60.0, app: widget.app),
                  Text(
                    widget.app.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get bottomBar {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: InkSplash.splashFactory),
      child: Container(
        margin: EdgeInsets.only(
          bottom: math.max(MediaQuery.of(context).padding.bottom, 34.0),
        ),
        child: UnconstrainedBox(
          child: MaterialButton(
            shape: const RoundedRectangleBorder(borderRadius: maxBorderRadius),
            padding: EdgeInsets.all(10.h),
            highlightElevation: 4.0,
            color: currentThemeColor,
            child: Center(
              child: Text(
                '前往应用',
                style: TextStyle(color: Colors.white, fontSize: 22.sp),
              ),
            ),
            onPressed: () {
              API.launchWeb(url: widget.app.replacedUrl, app: widget.app);
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  Widget get messageList {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Consumer<MessagesProvider>(
              builder: (_, MessagesProvider provider, __) {
                final List<AppMessage> messages = List<AppMessage>.from(
                  provider.appsMessages[widget.app.appId],
                );
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  controller: _scrollController,
                  shrinkWrap: shrinkWrap,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (_, int i) {
                    tryDecodeContent(messages[i]);
                    return messageWidget(messages[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget messageWidget(AppMessage message) {
    return Container(
      margin: EdgeInsets.all(12.w).copyWith(right: 48.w),
      width: Screens.width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.w,
                ),
                constraints: BoxConstraints(minHeight: 30.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
                  color: Theme.of(context).cardColor,
                ),
                child: ExtendedText(
                  message.content,
                  selectionEnabled: true,
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
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                timeHandler(message.sendTime),
                style: context.textTheme.caption.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            )
          ],
        ),
      ),
    );
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

  void judgeShrink(BuildContext context) {
    if (_scrollController.hasClients) {
      final double maxExtent = _scrollController.position.maxScrollExtent;
      const double limitExtent = 50.0;
      if (maxExtent > limitExtent && shrinkWrap) {
        shrinkWrap = false;
      } else if (maxExtent <= limitExtent && !shrinkWrap) {
        shrinkWrap = true;
      }
    }
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

  @override
  Widget build(BuildContext context) {
    judgeShrink(context);
    judgeMessageConfirm();

    return Scaffold(
      body: Column(
        children: <Widget>[
          topBar,
          messageList,
          if (widget.app.url != null && widget.app.url.isNotEmpty) bottomBar,
        ],
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
