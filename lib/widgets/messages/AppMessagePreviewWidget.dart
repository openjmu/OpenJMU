///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-05 13:56
///
import 'dart:async';
import 'dart:convert';

import 'package:OpenJMU/widgets/AppIcon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';

class AppMessagePreviewWidget extends StatefulWidget {
  final AppMessage message;
  final double height;

  const AppMessagePreviewWidget({
    @required this.message,
    this.height = 70.0,
    Key key,
  })  : assert(message != null),
        super(key: key);

  @override
  _AppMessagePreviewWidgetState createState() =>
      _AppMessagePreviewWidgetState();
}

class _AppMessagePreviewWidgetState extends State<AppMessagePreviewWidget>
    with AutomaticKeepAliveClientMixin {
  WebApp app;

  Timer timeUpdateTimer;
  String formattedTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    timeFormat(null);
    timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), timeFormat);
    super.initState();
  }

  @override
  void dispose() {
    timeUpdateTimer?.cancel();
    super.dispose();
  }

  void timeFormat(_, {bool fromBuild = false}) {
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
    if (mounted && !fromBuild) setState(() {});
  }

  Widget get unreadCounter => Consumer<MessagesProvider>(
        builder: (_, provider, __) {
          final messages = provider.appsMessages[widget.message.appId];
          final unreadMessages =
              messages.where((message) => !message.read)?.toList();
          if (unreadMessages.isEmpty) return SizedBox.shrink();
          return Container(
            width: suSetWidth(28.0),
            height: suSetWidth(28.0),
            decoration: BoxDecoration(
              color: ThemeUtils.currentThemeColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${unreadMessages.length}",
                style: TextStyle(
                  fontSize: suSetSp(18.0),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        },
      );

  void updateApp() {
    final provider = Provider.of<WebAppsProvider>(
      navigatorState.context,
      listen: false,
    );
    app = provider.apps
        .where((app) => app.id == widget.message.appId)
        .elementAt(0);
  }

  void tryDecodeContent() {
    try {
      final content = jsonDecode(widget.message.content);
      widget.message.content = content['content'];
      Provider.of<MessagesProvider>(navigatorState.context, listen: false)
          .saveAppsMessages();
    } catch (e) {}
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    updateApp();
    timeFormat(null, fromBuild: true);
    tryDecodeContent();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        navigatorState.pushNamed(
          "openjmu://chat-app-message-page",
          arguments: {"app": app},
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: suSetSp(16.0),
        ),
        height: suSetHeight(widget.height),
        decoration: BoxDecoration(),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                right: suSetSp(16.0),
              ),
              child: AppIcon(app: app),
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
                          child: app != null
                              ? Text(
                                  "${app.name ?? app.id}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(
                                        fontSize: suSetSp(22.0),
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
                        unreadCounter,
                      ],
                    ),
                    Text(
                      "${widget.message.content}",
                      style: Theme.of(context).textTheme.body1.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .body1
                                .color
                                .withOpacity(0.5),
                            fontSize: suSetSp(19.0),
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
      ),
    );
  }
}
