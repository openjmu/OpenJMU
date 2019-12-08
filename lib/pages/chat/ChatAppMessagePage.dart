///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-01 14:12
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppBar.dart';
import 'package:OpenJMU/widgets/AppIcon.dart';
import 'package:intl/intl.dart';

@FFRoute(
  name: "openjmu://chat-app-message-page",
  routeName: "应用消息页",
  argumentNames: ["app"],
)
class ChatAppMessagePage extends StatefulWidget {
  final WebApp app;

  const ChatAppMessagePage({
    @required this.app,
    Key key,
  }) : super(key: key);

  @override
  _ChatAppMessagePageState createState() => _ChatAppMessagePageState();
}

class _ChatAppMessagePageState extends State<ChatAppMessagePage> {
  final _scrollController = ScrollController();
  final color = ThemeUtils.currentThemeColor;

  bool shrinkWrap = true;

  MessagesProvider messagesProvider;

  @override
  void initState() {
    messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    super.initState();
  }

  Widget get topBar => FixedAppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(
            vertical: suSetHeight(4.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppIcon(size: 60.0, app: widget.app),
                    Text(
                      widget.app.name,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: suSetSp(23.0),
                            fontWeight: FontWeight.w500,
                          ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget get bottomBar => Theme(
        data: Theme.of(context).copyWith(
          splashFactory: InkSplash.splashFactory,
        ),
        child: Container(
          margin: EdgeInsets.only(
            bottom: math.max(MediaQuery.of(context).padding.bottom, 34.0),
          ),
          child: UnconstrainedBox(
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(500.0),
              ),
              padding: EdgeInsets.all(suSetHeight(10.0)),
              highlightElevation: 4.0,
              color: color,
              child: Center(
                child: Text(
                  "前往应用",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: suSetSp(22.0),
                  ),
                ),
              ),
              onPressed: () {
                navigatorState.pushNamed("openjmu://webpage", arguments: {
                  "url": widget.app.replacedUrl,
                  "title": widget.app.name,
                  "app": widget.app,
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      );

  Widget get messageList => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Consumer<MessagesProvider>(
                builder: (_, provider, __) {
                  final messages = provider.appsMessages[widget.app.id];
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: _scrollController,
                    shrinkWrap: shrinkWrap,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (_, i) => messageWidget(messages[i]),
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget messageWidget(AppMessage message) {
    return Container(
      margin: EdgeInsets.only(
        left: 8.0,
        right: 40.0,
        top: 8.0,
        bottom: 8.0,
      ),
      width: Screen.width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: suSetSp(16.0),
                  vertical: suSetSp(10.0),
                ),
                constraints: BoxConstraints(
                  minHeight: suSetSp(30.0),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Theme.of(context).canvasColor,
                ),
                child: SelectableText(
                  message.content,
                  style: TextStyle(fontSize: suSetSp(20.0)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: suSetWidth(8.0)),
              child: Text(
                "${timeHandler(message.sendTime)}",
                style: TextStyle(
                  color: currentTheme.textTheme.caption.color.withOpacity(0.25),
                  fontSize: suSetSp(14.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String timeHandler(DateTime dateTime) {
    final now = DateTime.now();
    String time = "";
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      time += DateFormat("HH:mm").format(dateTime);
    } else if (dateTime.year == now.year) {
      time += DateFormat("MM-dd HH:mm").format(dateTime);
    } else {
      time += DateFormat("yyyy-MM-dd HH:mm").format(dateTime);
    }
    return time;
  }

  void judgeShrink(context) {
    if (_scrollController.hasClients) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final limitExtent = 50.0;
      if (maxExtent > limitExtent && shrinkWrap) {
        shrinkWrap = false;
      } else if (maxExtent <= limitExtent && !shrinkWrap) {
        shrinkWrap = true;
      }
    }
  }

  void judgeMessageConfirm() {
    final messages = messagesProvider.appsMessages[widget.app.id];
    final unreadMessages = messages.where((appMessage) {
      return !appMessage.read;
    })?.toList();
    if (unreadMessages.isNotEmpty) {
      while (unreadMessages.last.messageId == null &&
          unreadMessages.last.ackId == null) {
        unreadMessages.last.read = true;
        unreadMessages.removeLast();
      }
      if (unreadMessages.isNotEmpty) {
        final message = unreadMessages[0];
        if (message.messageId != null && message.messageId != 0) {
          MessageUtils.sendConfirmOfflineMessage(message.messageId);
        }
        if (message.ackId != null && message.ackId != 0) {
          MessageUtils.sendConfirmMessage(ackId: message.ackId);
        }
        if (!message.read) message.read = true;
      }
      unreadMessages.forEach((message) {
        message.read = true;
      });
    }
    messagesProvider.saveAppsMessages();
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
          bottomBar,
        ],
      ),
    );
  }
}
