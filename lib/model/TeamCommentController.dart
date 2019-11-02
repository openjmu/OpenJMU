import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:extended_text/extended_text.dart';
import 'package:dio/dio.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/post/SearchPostPage.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class TeamCommentListInPostController {
  _TeamCommentListInPostState _commentListInPostState;

  void reload() {
    _commentListInPostState?._refreshData();
  }
}

class TeamCommentListInPost extends StatefulWidget {
  final Post post;
  final TeamCommentListInPostController controller;

  TeamCommentListInPost(this.post, this.controller, {Key key})
      : super(key: key);

  @override
  State createState() => _TeamCommentListInPostState();
}

class _TeamCommentListInPostState extends State<TeamCommentListInPost> {
  List<Comment> _comments = [];

  bool isLoading = true;
  bool canLoadMore = false;
  bool firstLoadComplete = false;

  int lastValue;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    widget.controller._commentListInPostState = this;
    _refreshList();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      _comments = [];
    });
    _refreshList();
  }

  Future<Null> _loadList() async {
    isLoading = true;
    try {
      Map<String, dynamic> response =
          (await TeamCommentAPI.getCommentInPostList(
        id: widget.post.id,
      ))
              ?.data;

      List<dynamic> list = response['replylist'];
      int total = response['total'] as int;
      if (_comments.length + response['count'] as int < total) {
        canLoadMore = true;
      } else {
        canLoadMore = false;
      }
      List<Comment> comments = [];
      list.forEach((comment) {
        comments.add(TeamCommentAPI.createCommentInPost(comment['reply']));
      });
      if (this.mounted) {
        setState(() {
          _comments.addAll(comments);
        });
        isLoading = false;
        lastValue = _comments.isEmpty ? 0 : _comments.last.id;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint("${e.response.data}");
      } else {
        debugPrint("${e.request}");
        debugPrint("${e.message}");
      }
      return;
    }
  }

  Future<Null> _refreshList() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, dynamic> response =
          (await TeamCommentAPI.getCommentInPostList(
        id: widget.post.id,
      ))
              ?.data;

      List<dynamic> list = response['data'];
      int total = response['total'] as int;
      if (response['count'] as int < total) canLoadMore = true;

      List<Comment> comments = [];
      list.forEach((comment) {
        comments.add(TeamCommentAPI.createCommentInPost(comment));
      });

      if (this.mounted) {
        setState(() {
          Instances.eventBus
              .fire(new CommentInPostUpdatedEvent(widget.post.id, total));
          _comments = comments;
          isLoading = false;
          firstLoadComplete = true;
        });
        lastValue = _comments.isEmpty ? 0 : _comments.last.id;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint("${e.response.data}");
      } else {
        debugPrint("${e.request}");
        debugPrint("${e.message}");
      }
      return;
    }
  }

  GestureDetector getCommentAvatar(context, comment) {
    return GestureDetector(
      child: Container(
        width: Constants.suSetSp(40.0),
        height: Constants.suSetSp(40.0),
        margin: EdgeInsets.symmetric(
            horizontal: Constants.suSetSp(16.0),
            vertical: Constants.suSetSp(10.0)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFECECEC),
          image: DecorationImage(
            image: UserAPI.getAvatarProvider(uid: comment.fromUserUid),
            fit: BoxFit.cover,
          ),
        ),
      ),
      onTap: () => UserPage.jump(context, comment.fromUserUid),
    );
  }

  Widget getCommentNickname(context, Comment comment) {
    return Row(
      children: <Widget>[
        Text(
          comment.fromUserName,
          style: TextStyle(
            color: Theme.of(context).textTheme.title.color,
            fontSize: Constants.suSetSp(18.0),
          ),
        ),
        Constants.emptyDivider(width: 8.0),
        if (widget.post.uid == comment.fromUserUid)
          Container(
            decoration: BoxDecoration(
              color: ThemeUtils.defaultColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Constants.suSetSp(8.0),
              vertical: 0.0,
            ),
            child: Text(
              "楼主",
              style: TextStyle(
                color: Colors.white,
                fontSize: Constants.suSetSp(16.0),
              ),
            ),
          ),
      ],
    );
  }

  Widget getCommentTime(context, Comment comment) {
    String _commentTime = comment.commentTime;
    if (int.parse(_commentTime.substring(0, 4)) == now.year) {
      _commentTime = _commentTime.substring(5, 16);
    }
    if (int.parse(_commentTime.substring(0, 2)) == now.month &&
        int.parse(_commentTime.substring(3, 5)) == now.day) {
      _commentTime = "${_commentTime.substring(5, 11)}";
    } else if (int.parse(_commentTime.substring(0, 2)) != now.month &&
        int.parse(_commentTime.substring(3, 5)) != now.day) {
      _commentTime = "${_commentTime.substring(0, 5)}";
    }

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "${comment.floor}楼",
            style: Theme.of(context).textTheme.caption.copyWith(
                  fontSize: Constants.suSetSp(12.0),
                ),
          ),
          TextSpan(
              text: "　", style: TextStyle(fontSize: Constants.suSetSp(12.0))),
          TextSpan(
            text: _commentTime,
            style: Theme.of(context).textTheme.caption.copyWith(
                  fontSize: Constants.suSetSp(12.0),
                ),
          ),
        ],
      ),
    );
  }

  Widget getExtendedText(context, content) {
    return ExtendedText(
      content != null ? "$content " : null,
      style: TextStyle(fontSize: Constants.suSetSp(17.0)),
      onSpecialTextTap: (dynamic data) {
        String text = data['content'];
        if (text.startsWith("#")) {
          SearchPage.search(context, text.substring(1, text.length - 1));
        } else if (text.startsWith("@")) {
          UserPage.jump(context, data['uid']);
        } else if (text.startsWith(API.wbHost)) {
          CommonWebPage.jump(context, text, "网页链接");
        } else if (text.startsWith("|")) {
          int imageID = data['image'];
          String imageUrl = API.commentImageUrl(imageID, "o");
          Navigator.of(context).push(CupertinoPageRoute(builder: (_) {
            return ImageViewer(
              0,
              [ImageBean(id: imageID, imageUrl: imageUrl)],
            );
          }));
        }
      },
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
    );
  }

  Widget getReplies(context, Comment comment) {
    return Container(
        color: Theme.of(context).canvasColor,
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[],
        ));
  }

  String replaceMentionTag(text) {
    String commentText = text;
    final RegExp mTagStartReg = RegExp(r"<M?\w+.*?\/?>");
    final RegExp mTagEndReg = RegExp(r"<\/M?\w+.*?\/?>");
    commentText = commentText.replaceAllMapped(mTagStartReg, (match) => "");
    commentText = commentText.replaceAllMapped(mTagEndReg, (match) => "");
    return commentText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      width: MediaQuery.of(context).size.width,
      padding: isLoading
          ? EdgeInsets.symmetric(vertical: Constants.suSetSp(42))
          : EdgeInsets.zero,
      child: isLoading
          ? Center(child: Constants.progressIndicator())
          : Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.zero,
              child: firstLoadComplete
                  ? ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Container(
                        color: Theme.of(context).dividerColor,
                        height: 1.0,
                      ),
                      itemCount: _comments.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _comments.length) {
                          if (canLoadMore && !isLoading) {
                            _loadList();
                            return Container(
                              height: Constants.suSetSp(40.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: Constants.suSetSp(15.0),
                                    height: Constants.suSetSp(15.0),
                                    child: Constants.progressIndicator(
                                        strokeWidth: 2.0),
                                  ),
                                  Text("　正在加载",
                                      style: TextStyle(
                                          fontSize: Constants.suSetSp(14.0))),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else if (index < _comments.length) {
                          Comment _c = _comments[index];
                          return InkWell(
                            onTap: () {
                              showDialog<Null>(
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                  backgroundColor: ThemeUtils.currentThemeColor,
                                  children: <Widget>[
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          if (_c.fromUserUid ==
                                                  UserAPI.currentUser.uid ||
                                              widget.post.uid ==
                                                  UserAPI.currentUser.uid)
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                IconButton(
                                                  icon: Icon(Icons.delete,
                                                      size: Constants.suSetSp(
                                                          36.0),
                                                      color: Colors.white),
                                                  padding: EdgeInsets.all(
                                                      Constants.suSetSp(6.0)),
                                                  onPressed: () {
                                                    showPlatformDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          DeleteDialog("评论",
                                                              comment: _c),
                                                    );
                                                  },
                                                ),
                                                Text("删除评论",
                                                    style: TextStyle(
                                                        fontSize:
                                                            Constants.suSetSp(
                                                                16.0),
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(Icons.content_copy,
                                                    size:
                                                        Constants.suSetSp(36.0),
                                                    color: Colors.white),
                                                padding: EdgeInsets.all(
                                                    Constants.suSetSp(6.0)),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                    text: replaceMentionTag(
                                                        _c.content),
                                                  ));
                                                  showShortToast("已复制到剪贴板");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              Text("复制评论",
                                                  style: TextStyle(
                                                      fontSize:
                                                          Constants.suSetSp(
                                                              16.0),
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                getCommentAvatar(context, _c),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: Constants.suSetSp(10.0)),
                                      getCommentNickname(context, _c),
                                      SizedBox(height: Constants.suSetSp(4.0)),
                                      getCommentTime(context, _c),
                                      SizedBox(height: Constants.suSetSp(6.0)),
                                      getExtendedText(context, _c.content),
                                      SizedBox(height: Constants.suSetSp(6.0)),
                                      getReplies(context, _c),
                                      SizedBox(height: Constants.suSetSp(10.0)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.comment,
                                    color: Theme.of(context).dividerColor,
                                    size: Constants.suSetSp(20.0),
                                  ),
                                  onPressed: () {
                                    showDialog<Null>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          CommentPositioned(
                                        post: widget.post,
                                        postType: PostType.team,
                                        comment: _comments[index],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    )
                  : SizedBox(
                      height: Constants.suSetSp(120.0),
                      child: Center(
                        child: Text(
                          "暂无内容",
                          style: TextStyle(fontSize: Constants.suSetSp(18.0)),
                        ),
                      ),
                    ),
            ),
    );
  }
}
