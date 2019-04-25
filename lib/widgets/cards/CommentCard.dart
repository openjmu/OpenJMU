import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:extended_text/extended_text.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  CommentCard(this.comment, {Key key}) : super(key: key);

  final TextStyle titleTextStyle = new TextStyle(fontSize: 18.0);
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 14.0);
  final TextStyle rootTopicTextStyle = new TextStyle(fontSize: 14.0);
  final TextStyle rootTopicMentionStyle = new TextStyle(color: Colors.blue, fontSize: 14.0);
  final Color subIconColor = Colors.grey;

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
        onTap: () => UserPage.jump(context, comment.fromUserUid)
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
    String _commentTime = comment.commentTime;
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
                        getExtendedText(context, content),
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
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(5.0)
            ),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  getExtendedText(context, topic),
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

  Widget getExtendedText(context, content) {
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
                          this.comment.post.userId == UserUtils.currentUser.uid
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
          )]
      );
    } else {
      return SimpleDialog(
          backgroundColor: Colors.redAccent,
          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
          children: <Widget>[Center(
              child: Text(
                "该动态已被屏蔽或删除",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              )
          )]
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgets = [];
    _widgets = [
      new ListTile(
        leading: getCommentAvatar(context, this.comment),
        title: getCommentNickname(this.comment),
        subtitle: getCommentInfo(this.comment),
      ),
      getCommentContent(context, this.comment),
    ];
    return new InkWell(
      onTap: () => showDialog<Null>(context: context, builder: (BuildContext context) => dialog(context)),
      child: Container(
        child: Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _widgets,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
        ),
      )
    );
  }
}


class CommentCardInPost extends StatelessWidget {
  final Post post;
  final List<Comment> comments;

  CommentCardInPost(this.post, this.comments, {Key key}) : super(key: key);

  GestureDetector getCommentAvatar(context, comment) {
    return new GestureDetector(
        child: new Container(
          width: 40.0,
          height: 40.0,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: CachedNetworkImageProvider(comment.fromUserAvatar, cacheManager: DefaultCacheManager()),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () => UserPage.jump(context, comment.fromUserUid)
    );
  }

  Text getCommentNickname(context, comment) {
    return new Text(
        comment.fromUserName,
        style: TextStyle(
          color: Theme.of(context).textTheme.title.color,
          fontSize: 16.0
        )
    );
  }

  Text getCommentTime(context, comment) {
    String _commentTime = comment.commentTime;
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
    return new Text(
        _commentTime,
        style: Theme.of(context).textTheme.caption
    );
  }

  Widget getExtendedText(context, content) {
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
        }
      },
      specialTextSpanBuilder: StackSpecialTextSpanBuilder()
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.zero,
        child: this.comments.length > 0
          ? ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            ),
            itemCount: this.comments.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                if (
                this.comments[index].fromUserUid == UserUtils.currentUser.uid
                ||
                this.post.userId == UserUtils.currentUser.uid
                ) {
                  showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) => SimpleDialog(
                        backgroundColor: ThemeUtils.currentColorTheme,
                        children: <Widget>[Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.delete, size: 36.0),
                                padding: EdgeInsets.all(6.0),
                                onPressed: () {
                                  showPlatformDialog(
                                      context: context,
                                      builder: (_) => PlatformAlertDialog(
                                        title: Text("删除评论"),
                                        content: Text("是否确认删除这条评论？"),
                                        actions: <Widget>[
                                          PlatformButton(
                                            android: (BuildContext context) => MaterialRaisedButtonData(
                                              color: ThemeUtils.currentColorTheme,
                                              elevation: 0,
                                            ),
                                            child: Text('确认', style: TextStyle(color: Colors.white)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              LoadingDialogController _loadingDialogController = new LoadingDialogController();
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext dialogContext) => LoadingDialog("正在删除评论", _loadingDialogController)
                                              );
                                              CommentAPI.deleteComment(this.post.id, this.comments[index].id)
                                                  .then((response) {
                                                    Constants.eventBus.fire(new PostCommentDeletedEvent(this.post.id, this.post.comments));
                                                    _loadingDialogController.changeState("success", "评论删除成功");
                                                  })
                                                  .catchError((e) {
                                                    showCenterErrorShortToast("评论删除失败");
                                                  });
                                            },
                                          ),
                                          PlatformButton(
                                            android: (BuildContext context) => MaterialRaisedButtonData(
                                              color: Theme.of(context).dialogBackgroundColor,
                                              elevation: 0,
                                            ),
                                            child: Text('取消'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      )
                                  );
                                },
                              ),
                              Text("删除评论", style: TextStyle(fontSize: 16.0))
                            ],
                          ),
                        )]
                    )
                  );
                } else {
                  return null;
                }
              },
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    getCommentAvatar(context, this.comments[index]),
                    Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(height: 10.0),
                            getCommentNickname(context, this.comments[index]),
                            Container(height: 4.0),
                            getExtendedText(context, this.comments[index].content),
                            Container(height: 6.0),
                            getCommentTime(context, this.comments[index]),
                            Container(height: 10.0),
                          ],
                        )
                    ),
                    IconButton(
                      padding: EdgeInsets.all(26.0),
                      icon: Icon(Icons.comment, color: Colors.grey),
                      onPressed: () {
                        showDialog<Null>(
                            context: context,
                            builder: (BuildContext context) => CommentPositioned(this.post, comment: this.comments[index])
                        );
                      },
                    )
                  ],
                )
              )
            )
        )
          : Container(
          height: 120.0,
          child: Center(
            child: Text(
                "暂无内容",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0
                )
            )
          )
        )
    );
  }

}
