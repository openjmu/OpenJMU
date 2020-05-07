///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-05 10:55
///
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class MessagePreviewWidget extends StatefulWidget {
  const MessagePreviewWidget({
    this.uid,
    this.app,
    @required this.message,
    @required this.unreadMessages,
    this.height = 80.0,
    Key key,
  })  : assert(uid != null || app != null),
        super(key: key);

  final int uid;
  final WebApp app;
  final Message message;
  final List<Message> unreadMessages;
  final double height;

  @override
  _MessagePreviewWidgetState createState() => _MessagePreviewWidgetState();
}

class _MessagePreviewWidgetState extends State<MessagePreviewWidget>
    with AutomaticKeepAliveClientMixin {
  UserInfo user;

  Timer timeUpdateTimer;
  String formattedTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    UserAPI.getUserInfo(uid: widget.uid).then((dynamic response) {
      user = UserInfo.fromJson(
          (response as Response<dynamic>).data as Map<String, dynamic>);
      if (mounted) {
        setState(() {});
      }
    }).catchError((dynamic e) {
      trueDebugPrint('$e');
    });

    timeFormat(null);
    timeUpdateTimer = Timer.periodic(1.minutes, timeFormat);

    super.initState();
  }

  @override
  void dispose() {
    timeUpdateTimer?.cancel();
    super.dispose();
  }

  void timeFormat(Timer _) {
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: suSetWidth(16.0)),
      height: suSetHeight(widget.height),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: suSetWidth(16.0)),
            child: UserAPI.getAvatar(size: 60.0, uid: widget.uid),
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
                        child: user != null
                            ? Text(
                                '${user.name ?? user.uid}',
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
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
                      Container(
                        width: suSetWidth(28.0),
                        height: suSetWidth(28.0),
                        decoration: BoxDecoration(
                          color: currentThemeColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.unreadMessages.length}',
                            style: TextStyle(
                              fontSize: suSetSp(18.0),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.message.content['content']}',
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
    );
  }
}
