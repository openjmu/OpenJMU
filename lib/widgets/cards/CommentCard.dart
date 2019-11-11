import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:extended_text/extended_text.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/post/PostDetailPage.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  CommentCard(
    this.comment, {
    Key key,
  }) : super(key: key);

  final TextStyle subtitleStyle = TextStyle(
    color: Colors.grey,
    fontSize: Constants.suSetSp(15.0),
  );
  final TextStyle rootTopicTextStyle = TextStyle(
    fontSize: Constants.suSetSp(15.0),
  );
  final TextStyle rootTopicMentionStyle = TextStyle(
    color: Colors.blue,
    fontSize: Constants.suSetSp(15.0),
  );
  final Color subIconColor = Colors.grey;

  Text getCommentNickname(context, comment) {
    return Text(
      comment.fromUserName ?? comment.fromUid,
      style: TextStyle(
        color: Theme.of(context).textTheme.title.color,
        fontSize: Constants.suSetSp(19.0),
      ),
      textAlign: TextAlign.left,
    );
  }

  Row getCommentInfo(comment) {
    String _commentTime = comment.commentTime;
    DateTime now = DateTime.now();
    if (int.parse(_commentTime.substring(0, 4)) == now.year) {
      _commentTime = _commentTime.substring(5, 16);
    }
    if (int.parse(_commentTime.substring(0, 2)) == now.month &&
        int.parse(_commentTime.substring(3, 5)) == now.day) {
      _commentTime = "${_commentTime.substring(5, 11)}";
    }
    return Row(
      children: <Widget>[
        Icon(
          Icons.access_time,
          color: Colors.grey,
          size: Constants.suSetSp(12.0),
        ),
        Text(
          " $_commentTime",
          style: subtitleStyle,
        ),
        Container(width: Constants.suSetSp(10.0)),
        Icon(
          Icons.smartphone,
          color: Colors.grey,
          size: Constants.suSetSp(12.0),
        ),
        Text(
          " ${comment.from}",
          style: subtitleStyle,
        ),
      ],
    );
  }

  Widget getCommentContent(context, Comment comment) {
    String content = comment.content;
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getExtendedText(context, content),
                getRootContent(context, comment),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getRootContent(context, comment) {
    var content = comment.toReplyContent ?? comment.toTopicContent;
    if (content != null && content.length > 0) {
      String topic;
      if (comment.toReplyExist) {
        topic =
            "<M ${comment.toReplyUid}>@${comment.toReplyUserName}<\/M> 的评论: ";
      } else {
        topic = "<M ${comment.toTopicUid}>@${comment.toTopicUserName}<\/M>: ";
      }
      topic += content;
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: Constants.suSetSp(10.0)),
        padding: EdgeInsets.symmetric(
          horizontal: Constants.suSetSp(16.0),
          vertical: Constants.suSetSp(10.0),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getExtendedText(context, topic, isRoot: true),
          ],
        ),
      );
    } else {
      return getPostBanned();
    }
  }

  Widget getPostBanned() {
    return Container(
      color: const Color(0xffaa4444),
      margin: EdgeInsets.only(top: Constants.suSetSp(10.0)),
      padding: EdgeInsets.all(Constants.suSetSp(30.0)),
      child: Center(
        child: Text(
          "该条微博已被屏蔽或删除",
          style: TextStyle(
            color: Colors.white,
            fontSize: Constants.suSetSp(20.0),
          ),
        ),
      ),
    );
  }

  Widget getExtendedText(context, content, {isRoot}) {
    return Padding(
      padding: (isRoot ?? false)
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: Constants.suSetSp(16.0),
            ),
      child: ExtendedText(
        content != null ? "$content " : null,
        style: TextStyle(fontSize: Constants.suSetSp(18.0)),
        onSpecialTextTap: specialTextTapRecognizer,
        maxLines: 8,
        overFlowTextSpan: OverFlowTextSpan(
          children: <TextSpan>[
            TextSpan(text: " ..."),
            TextSpan(
              text: "全文",
              style: TextStyle(
                color: ThemeUtils.currentThemeColor,
              ),
            ),
          ],
        ),
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      ),
    );
  }

  Widget dialog(context) {
    if (this.comment.post != null) {
      return SimpleDialog(
        backgroundColor: ThemeUtils.currentThemeColor,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (this.comment.fromUserUid == UserAPI.currentUser.uid ||
                  this.comment.post.uid == UserAPI.currentUser.uid)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (this.comment.fromUserUid == UserAPI.currentUser.uid ||
                        this.comment.post.uid == UserAPI.currentUser.uid) {
                      showPlatformDialog(
                        context: context,
                        builder: (_) =>
                            DeleteDialog("评论", comment: this.comment),
                      );
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(Constants.suSetSp(6.0)),
                        child: Icon(
                          Icons.delete,
                          size: Constants.suSetSp(36.0),
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "删除评论",
                        style: TextStyle(
                          fontSize: Constants.suSetSp(16.0),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                  Constants.navigatorKey.currentState.push(
                    TransparentRoute(
                      builder: (context) => CommentPositioned(
                        post: this.comment.post,
                        postType: PostType.square,
                        comment: this.comment
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(Constants.suSetSp(6.0)),
                      child: Icon(
                        Icons.reply,
                        size: Constants.suSetSp(36.0),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "回复评论",
                      style: TextStyle(
                        fontSize: Constants.suSetSp(16.0),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    platformPageRoute(
                      context: context,
                      builder: (context) => PostDetailPage(
                        this.comment.post,
                        parentContext: context,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(Constants.suSetSp(6.0)),
                      child: Icon(
                        Icons.pageview,
                        size: Constants.suSetSp(36.0),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "查看动态",
                      style: TextStyle(
                        fontSize: Constants.suSetSp(16.0),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      );
    } else {
      return SimpleDialog(
        backgroundColor: Colors.redAccent,
        contentPadding: EdgeInsets.symmetric(
          vertical: Constants.suSetSp(16.0),
        ),
        children: <Widget>[
          Center(
            child: Text(
              "该动态已被屏蔽或删除",
              style: TextStyle(
                color: Colors.white,
                fontSize: Constants.suSetSp(20.0),
              ),
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<Null>(
        context: context,
        builder: (BuildContext context) => dialog(context),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.suSetSp(16.0),
                vertical: Constants.suSetSp(12.0),
              ),
              child: Row(
                children: <Widget>[
                  UserAPI.getAvatar(uid: comment.fromUserUid),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(16.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          getCommentNickname(context, this.comment),
                          Constants.separator(context, height: 4.0),
                          getCommentInfo(this.comment),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            getCommentContent(context, this.comment),
          ],
        ),
      ),
    );
  }
}
