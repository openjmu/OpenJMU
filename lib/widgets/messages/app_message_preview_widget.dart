///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-05 13:56
///
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class AppMessagePreviewWidget extends StatefulWidget {
  const AppMessagePreviewWidget({
    @required this.message,
    this.height = 70.0,
    Key key,
  })  : assert(message != null),
        super(key: key);

  final AppMessage message;
  final double height;

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
    timeUpdateTimer = Timer.periodic(1.minutes, timeFormat);
    super.initState();
  }

  @override
  void dispose() {
    timeUpdateTimer?.cancel();
    super.dispose();
  }

  void timeFormat(Timer _, {bool fromBuild = false}) {
    final DateTime now = DateTime.now();
    if (widget.message.sendTime.day == now.day &&
        widget.message.sendTime.month == now.month &&
        widget.message.sendTime.year == now.year) {
      formattedTime = DateFormat('HH:mm').format(widget.message.sendTime);
    } else if (widget.message.sendTime.year == now.year) {
      formattedTime = DateFormat('MM-dd HH:mm').format(widget.message.sendTime);
    } else {
      formattedTime =
          DateFormat('yy-MM-dd HH:mm').format(widget.message.sendTime);
    }
    if (mounted && !fromBuild) {
      setState(() {});
    }
  }

  Widget get unreadCounter => Consumer<MessagesProvider>(
        builder: (_, MessagesProvider provider, __) {
          final List<dynamic> messages =
              provider.appsMessages[widget.message.appId];
          final List<AppMessage> unreadMessages = messages
              .where((dynamic message) => !(message as AppMessage).read)
              ?.toList()
              ?.cast<AppMessage>();
          if (unreadMessages.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            width: suSetWidth(28.0),
            height: suSetWidth(28.0),
            decoration: BoxDecoration(
              color: currentThemeColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Selector<ThemesProvider, bool>(
                selector: (_, ThemesProvider provider) => provider.dark,
                builder: (_, bool dark, __) {
                  return Text(
                    '${unreadMessages.length}',
                    style: TextStyle(
                      color: dark ? Colors.grey[300] : Colors.white,
                      fontSize: suSetSp(18.0),
                      fontWeight: FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          );
        },
      );

  void updateApp() {
    final WebAppsProvider provider =
        Provider.of<WebAppsProvider>(currentContext, listen: false);
    app = provider.allApps
        .where((dynamic app) => (app as WebApp).appId == widget.message.appId)
        .elementAt(0);
  }

  void tryDecodeContent() {
    try {
      final Map<String, dynamic> content =
          jsonDecode(widget.message.content) as Map<String, dynamic>;
      widget.message.content = content['content'] as String;
      Provider.of<MessagesProvider>(currentContext, listen: false)
          .saveAppsMessages();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      return;
    }
  }

  @override
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
          Routes.openjmuChatAppMessagePage,
          arguments: <String, dynamic>{'app': app},
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: suSetWidth(16.0)),
        height: suSetHeight(widget.height),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: suSetWidth(16.0)),
              child: WebAppIcon(app: app),
            ),
            Expanded(
              child: SizedBox(
                height: suSetHeight(60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: suSetHeight(30.0),
                          child: app != null
                              ? Text(
                                  '${app.name ?? app.appId}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        fontSize: suSetSp(22.0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Text(
                          ' $formattedTime',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .color
                                    .withOpacity(0.5),
                              ),
                        ),
                        const Spacer(),
                        unreadCounter,
                      ],
                    ),
                    Text(
                      '${widget.message.content}',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyText2
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
