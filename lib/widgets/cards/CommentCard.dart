import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:extended_text/extended_text.dart';

import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';

class CommentCard extends StatelessWidget {
    final Comment comment;

    CommentCard(this.comment, {Key key}) : super(key: key);

    final TextStyle titleTextStyle = TextStyle(fontSize: 18.0);
    final TextStyle subtitleStyle = TextStyle(color: Colors.grey, fontSize: 14.0);
    final TextStyle rootTopicTextStyle = TextStyle(fontSize: 14.0);
    final TextStyle rootTopicMentionStyle = TextStyle(color: Colors.blue, fontSize: 14.0);
    final Color subIconColor = Colors.grey;

    GestureDetector getCommentAvatar(context, comment) {
        return GestureDetector(
            child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFECECEC),
                    image: DecorationImage(
                        image: UserUtils.getAvatarProvider(comment.fromUserUid),
                        fit: BoxFit.cover,
                    ),
                ),
            ),
            onTap: () => UserPage.jump(context, comment.fromUserUid),
        );
    }

    Text getCommentNickname(comment) {
        return Text(
            comment.fromUserName ?? comment.fromUid,
            style: titleTextStyle,
            textAlign: TextAlign.left,
        );
    }

    Row getCommentInfo(comment) {
        String _commentTime = comment.commentTime;
        DateTime now = DateTime.now();
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
        return Row(
            children: <Widget>[
                Icon(
                    Icons.access_time,
                    color: Colors.grey,
                    size: 12.0,
                ),
                Text(
                    " $_commentTime",
                    style: subtitleStyle,
                ),
                Container(width: 10.0),
                Icon(
                    Icons.smartphone,
                    color: Colors.grey,
                    size: 12.0,
                ),
                Text(
                    " ${comment.from}",
                    style: subtitleStyle,
                ),
            ],
        );
    }

    Widget getCommentContent(context, comment) {
        String content = comment.content;
        return Row(
            children: <Widget>[
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                topic = "<M ${comment.toReplyUid}>@${comment.toReplyUserName}<\/M> 的评论: ";
            } else {
                topic = "<M ${comment.toTopicUid}>@${comment.toTopicUserName}<\/M>: ";
            }
            topic += content;
            return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        getExtendedText(context, topic),
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
            margin: EdgeInsets.only(top: 8.0),
            padding: EdgeInsets.all(12.0),
            child: Center(
                child: Text(
                    "该条微博已被屏蔽或删除",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
            ),
        );
    }

    Widget getExtendedText(context, content) {
        return ExtendedText(
            content != null ? "$content " : null,
            style: TextStyle(fontSize: 16.0),
            onSpecialTextTap: (dynamic data) {
                String text = data['content'];
                if (text.startsWith("#")) {
                    return SearchPage.search(context, text.substring(1, text.length-1));
                } else if (text.startsWith("@")) {
                    return UserPage.jump(context, data['uid']);
                } else if (text.startsWith("https://wb.jmu.edu.cn")) {
                    return CommonWebPage.jump(context, text, "网页链接");
                }
            },
            specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        );
    }

    Widget dialog(context) {
        if (this.comment.post != null) {
            return SimpleDialog(
                backgroundColor: ThemeUtils.currentColorTheme,
                children: <Widget>[Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.delete, size: 36.0, color: Colors.white),
                                    padding: EdgeInsets.all(6.0),
                                    onPressed: () {
                                        if (
                                            this.comment.fromUserUid == UserUtils.currentUser.uid
                                                ||
                                            this.comment.post.uid == UserUtils.currentUser.uid
                                        ) {
                                            showPlatformDialog(context: context, builder: (_) => DeleteDialog("评论", comment: this.comment));
                                        }
                                    },
                                ),
                                Text("删除评论", style: TextStyle(fontSize: 16.0, color: Colors.white))
                            ],
                        ),
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.reply, size: 36.0, color: Colors.white),
                                    padding: EdgeInsets.all(6.0),
                                    onPressed: () {
                                        Navigator.pop(context);
                                        showDialog<Null>(
                                                context: context,
                                                builder: (BuildContext context) => CommentPositioned(this.comment.post, comment: this.comment)
                                        );
                                    },
                                ),
                                Text("回复评论", style: TextStyle(fontSize: 16.0, color: Colors.white))
                            ],
                        ),
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.pageview, size: 36.0, color: Colors.white),
                                    padding: EdgeInsets.all(6.0),
                                    onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => PostDetailPage(this.comment.post, beforeContext: context)));
                                    },
                                ),
                                Text("查看动态", style: TextStyle(fontSize: 16.0, color: Colors.white))
                            ],
                        ),
                    ],
                )],
            );
        } else {
            return SimpleDialog(
                backgroundColor: Colors.redAccent,
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                children: <Widget>[Center(
                    child: Text(
                        "该动态已被屏蔽或删除",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                )],
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        List<Widget> _widgets = [];
        _widgets = [
            ListTile(
                leading: getCommentAvatar(context, this.comment),
                title: getCommentNickname(this.comment),
                subtitle: getCommentInfo(this.comment),
            ),
            getCommentContent(context, this.comment),
        ];
        return InkWell(
            onTap: () => showDialog<Null>(context: context, builder: (BuildContext context) => dialog(context)),
            child: Container(
                child: Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _widgets,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
            ),
        );
    }
}

