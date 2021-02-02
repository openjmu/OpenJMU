///
/// [Author] Alex (https://github.com/AlexV525)
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
  Timer timeUpdateTimer;
  String formattedTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    timeFormat();
    timeUpdateTimer = Timer.periodic(1.minutes, (_) => timeFormat());
  }

  @override
  void dispose() {
    timeUpdateTimer?.cancel();
    super.dispose();
  }

  void timeFormat({bool fromBuild = false}) {
    final DateTime now = DateTime.now();
    if (widget.message.sendTime.isTheSameDayOf(now)) {
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

  Widget unreadCounter(BuildContext context) {
    return Selector<MessagesProvider, Map<int, List<dynamic>>>(
      selector: (_, MessagesProvider provider) => provider.appsMessages,
      builder: (_, Map<int, List<dynamic>> appsMessages, __) {
        final List<dynamic> messages = appsMessages[widget.message.appId];
        final List<AppMessage> unreadMessages = messages
            .where((dynamic message) => !(message as AppMessage).read)
            ?.toList()
            ?.cast<AppMessage>();
        if (unreadMessages.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: currentThemeColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Selector<ThemesProvider, bool>(
              selector: (_, ThemesProvider provider) => provider.dark,
              builder: (_, bool dark, __) {
                return Text(
                  '${unreadMessages.length}',
                  style: TextStyle(
                    color: adaptiveButtonColor(),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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

  Widget _appIconWidget(BuildContext context, WebApp app) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: WebAppIcon(app: app),
    );
  }

  Widget _name(BuildContext context, WebApp app) {
    return Text(
      '${app.name ?? app.appId}',
      style: context.textTheme.bodyText2.copyWith(
        height: 1.2,
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _sendTimeWidget(BuildContext context) {
    return Text(
      ' $formattedTime',
      style: context.textTheme.caption.copyWith(
        height: 1.2,
        fontSize: 18.sp,
      ),
    );
  }

  Widget _shortContent(BuildContext context) {
    return Text(
      widget.message.content ?? '',
      style: context.textTheme.caption.copyWith(
        fontSize: 19.sp,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);

    final WebApp app = context
        .select<WebAppsProvider, Set<WebApp>>((WebAppsProvider p) => p.allApps)
        .where((WebApp app) => app.appId == widget.message.appId)
        .elementAt(0);

    timeFormat(fromBuild: true);
    tryDecodeContent();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuChatAppMessagePage.name,
          arguments: Routes.openjmuChatAppMessagePage.d(app: app),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        height: widget.height.h,
        color: context.theme.cardColor,
        child: Row(
          children: <Widget>[
            _appIconWidget(context, app),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            if (app != null) _name(context, app),
                            if (app != null) Gap(5.w),
                            _sendTimeWidget(context),
                            const Spacer(),
                          ],
                        ),
                        VGap(8.w),
                        _shortContent(context),
                      ],
                    ),
                  ),
                  unreadCounter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
