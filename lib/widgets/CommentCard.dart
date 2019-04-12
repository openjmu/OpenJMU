import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
//import 'package:OpenJMU/widgets/InAppBrowser.dart';

class CommentCardItem extends StatefulWidget {
  final Comment comment;

  CommentCardItem(this.comment, {Key key}) : super(key: key);

  @override
  State createState() => _CommentCardItemState();
}

class _CommentCardItemState extends State<CommentCardItem> {
  final TextStyle titleTextStyle = new TextStyle(fontSize: 18.0);
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 14.0);
  final TextStyle rootTopicTextStyle = new TextStyle(fontSize: 14.0);
  final TextStyle rootTopicMentionStyle = new TextStyle(color: Colors.blue, fontSize: 14.0);
  final Color subIconColor = Colors.grey;

  Color currentRootContentColor = Colors.grey[200];

  Widget pics;

  @override
  void initState() {
    super.initState();
    DataUtils.getBrightnessDark().then((isDark) {
      if (this.mounted) {
        setRootContentColor(isDark);
      }
    });
    Constants.eventBus.on<ChangeBrightnessEvent>().listen((event) {
      if (this.mounted) {
        setRootContentColor(event.isDarkState);
      }
    });
  }

  void setRootContentColor(isDarkState) {
    setState(() {
      if (isDarkState == null || !isDarkState) {
        currentRootContentColor = Colors.grey[200];
      } else {
        currentRootContentColor = Colors.grey[850];
      }
    });
  }

  GestureDetector getCommentAvatar(context, comment) {
    return new GestureDetector(
        child: new Container(
          width: 40.0,
          height: 40.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: CachedNetworkImageProvider(comment.fromUserAvatar, cacheManager: DefaultCacheManager()),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, comment.fromUserUid);
        }
    );
  }

  Text getCommentNickname(comment) {
    return new Text(
      comment.fromUserName ?? comment.fromUid,
      style: titleTextStyle,
      textAlign: TextAlign.left,
    );
  }

  Row getCommentInfo(comment) {
    String _commentTime = comment.postTime;
    DateTime now = new DateTime.now();
    if (int.parse(_commentTime.substring(0, 4)) == now.year) {
      _commentTime = _commentTime.substring(5, 16);
    }
    if (
    int.parse(_commentTime.substring(0, 2)) == now.month
        &&
        int.parse(_commentTime.substring(3, 5)) == now.day
    ) {
      _commentTime = "${_commentTime.substring(5, 11)}";
    }
    return new Row(
        children: <Widget>[
          new Icon(
              Icons.access_time,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " $_commentTime",
              style: subtitleStyle
          ),
          new Container(width: 10.0),
          new Icon(
              Icons.smartphone,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " ${comment.from}",
              style: subtitleStyle
          ),
        ]
    );
  }

  Widget getCommentContent(context, comment) {
    String content = comment.content;
    return new Row(
        children: <Widget>[
          new Expanded(
              child: new Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getExtendedText(content),
                        getRootContent(context, comment)
                      ]
                  )
              )
          )
        ]
    );
  }

  Widget getRootContent(context, comment) {
    var content = comment.toReplyContent ?? comment.toTopicContent;
    if (content != null && content.length > 0) {
      String topic;
      if (comment.toReplyExist) {
        topic = "<M ${comment.toReplyUid}>@${comment.toReplyUserName}<\/M> 的评论: ";
      } else {
        topic = "<M ${comment.toTopicUid}>@${comment.toTopicUserName}<\/M>: ";
      }
      topic += content;
      return new Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 8.0),
          padding: EdgeInsets.all(8.0),
          decoration: new BoxDecoration(
              color: currentRootContentColor,
              borderRadius: BorderRadius.circular(5.0)
          ),
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getExtendedText(topic),
              ]
          )
      );
    } else {
      return getPostBanned();
    }
  }

  Widget getPostBanned() {
    return new Container(
        color: const Color(0xffaa4444),
        margin: EdgeInsets.only(top: 8.0),
        padding: EdgeInsets.all(12.0),
        child: new Center(
            child: new Text(
                "该条微博已被屏蔽或删除",
                style: new TextStyle(fontSize: 20.0, color: Colors.white)
            )
        )
    );
  }

  Widget getExtendedText(content) {
    return new ExtendedText(
      content,
      style: new TextStyle(fontSize: 16.0),
      onSpecialTextTap: (dynamic data) {
        String text = data['content'];
        if (text.startsWith("#")) {
          return SearchPage.search(context, text.substring(1, text.length-1));
        } else if (text.startsWith("@")) {
          return UserPage.jump(context, data['uid']);
        } else if (text.startsWith("https://wb.jmu.edu.cn")) {
          return CommonWebPage.jump(context, text, "网页链接");
//            return InAppBrowserPage.open(context, text, "网页链接");
        }
      },
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
//        overflow: ExtendedTextOverflow.ellipsis,
//        maxLines: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgets = [];
    _widgets = [
      new ListTile(
        leading: getCommentAvatar(context, widget.comment),
        title: getCommentNickname(widget.comment),
        subtitle: getCommentInfo(widget.comment),
      ),
      getCommentContent(context, widget.comment),
    ];
    return new Container(
      child: Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _widgets,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
      ),
    );
  }

}