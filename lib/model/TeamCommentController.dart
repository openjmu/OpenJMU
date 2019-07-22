import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:extended_text/extended_text.dart';
import 'package:dio/dio.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/TeamAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';


//class TeamCommentController {
//    final String commentType;
//    final bool isMore;
//    final Function lastValue;
//    final Map<String, dynamic> additionAttrs;
//
//    TeamCommentController({
//        @required this.commentType,
//        @required this.isMore,
//        @required this.lastValue,
//        this.additionAttrs,
//    });
//
//    _TeamCommentListState _teamCommentListState;
//
//    void reload() {
//        _teamCommentListState._refreshData();
//    }
//
//    int getCount() {
//        return _teamCommentListState._commentList.length;
//    }
//}

//class TeamCommentList extends StatefulWidget {
//    final TeamCommentController _commentController;
//    final bool needRefreshIndicator;
//
//    TeamCommentList(this._commentController, {
//        Key key, this.needRefreshIndicator = true
//    }) : super(key: key);
//
//    @override
//    State createState() => _TeamCommentListState();
//}
//
//class _TeamCommentListState extends State<TeamCommentList> with AutomaticKeepAliveClientMixin {
//    final ScrollController _scrollController = ScrollController();
//    Color currentColorTheme = ThemeUtils.currentThemeColor;
//
//    num _lastValue = 0;
//    bool _isLoading = false;
//    bool _canLoadMore = true;
//    bool _firstLoadComplete = false;
//    bool _showLoading = true;
//
//    var _itemList;
//
//    Widget _emptyChild;
//    Widget _errorChild;
//    bool error = false;
//
//    Widget _body = Center(
//        child: CircularProgressIndicator(),
//    );
//
//    List<Comment> _commentList = [];
//    List<int> _idList = [];
//
//    @override
//    bool get wantKeepAlive => true;
//
//    @override
//    void initState() {
//        super.initState();
//        widget._commentController._teamCommentListState = this;
//        Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
//            if (
//            this.mounted
//                    &&
//                    ((event.tabIndex == 0 && widget._commentController.commentType == "square") || (event.type == "Post"))
//            ) {
//                _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
//            }
//        });
//
//        _emptyChild = GestureDetector(
//            onTap: () {
//            },
//            child: Container(
//                child: Center(
//                    child: Text('这里空空如也~', style: TextStyle(color: ThemeUtils.currentThemeColor)),
//                ),
//            ),
//        );
//
//        _errorChild = GestureDetector(
//            onTap: () {
//                setState(() {
//                    _isLoading = false;
//                    _showLoading = true;
//                    _refreshData();
//                });
//            },
//            child: Container(
//                child: Center(
//                    child: Text('加载失败，轻触重试', style: TextStyle(color: ThemeUtils.currentThemeColor)),
//                ),
//            ),
//        );
//
//        _refreshData();
//    }
//
//    @mustCallSuper
//    Widget build(BuildContext context) {
//        super.build(context);
//        if (!_showLoading) {
//            if (_firstLoadComplete) {
//                _itemList = ListView.separated(
//                    padding: EdgeInsets.symmetric(vertical: Constants.suSetSp(4.0)),
//                    separatorBuilder: (context, index) => Container(
//                        color: Theme.of(context).canvasColor,
//                        height: Constants.suSetSp(8.0),
//                    ),
//                    itemBuilder: (context, index) {
//                        if (index == _commentList.length) {
//                            if (this._canLoadMore) {
//                                _loadData();
//                                return Container(
//                                    height: Constants.suSetSp(40.0),
//                                    child: Row(
//                                        mainAxisAlignment: MainAxisAlignment.center,
//                                        children: <Widget>[
//                                            SizedBox(
//                                                width: Constants.suSetSp(15.0),
//                                                height: Constants.suSetSp(15.0),
//                                                child: Platform.isAndroid
//                                                        ? CircularProgressIndicator(
//                                                    strokeWidth: 2.0,
//                                                )
//                                                        : CupertinoActivityIndicator(),
//                                            ),
//                                            Text("　正在加载", style: TextStyle(fontSize: Constants.suSetSp(14.0)))
//                                        ],
//                                    ),
//                                );
//                            } else {
//                                return Container(
//                                    height: Constants.suSetSp(50.0),
//                                    color: Theme.of(context).canvasColor,
//                                    child: Center(
//                                        child: Text(Constants.endLineTag, style: TextStyle(
//                                            fontSize: Constants.suSetSp(14.0),
//                                        )),
//                                    ),
//                                );
//                            }
//                        } else {
//                            return CommentCard(_commentList[index]);
//                        }
//                    },
//                    itemCount: _commentList.length + 1,
//                    controller: widget._commentController.commentType == "mention" ? null : _scrollController,
//                );
//
//                if (widget.needRefreshIndicator) {
//                    _body = RefreshIndicator(
//                        color: currentColorTheme,
//                        onRefresh: _refreshData,
//                        child: _commentList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList,
//                    );
//                } else {
//                    _body = _commentList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList;
//                }
//            }
//            return _body;
//        } else {
//            return Container(
//                child: Center(
//                    child: CircularProgressIndicator(),
//                ),
//            );
//        }
//    }
//
//    Future<Null> _loadData() async {
//        _firstLoadComplete = true;
//        if (!_isLoading && _canLoadMore) {
//            _isLoading = true;
//
//            Map result = (await CommentAPI.getCommentList(
//                widget._commentController.commentType,
//                true,
//                _lastValue,
//                additionAttrs: widget._commentController.additionAttrs,
//            )).data;
//            List<Comment> commentList = [];
//            List _topics = result['replylist'];
//            int _total = int.parse(result['total'].toString());
//            int _count = int.parse(result['count'].toString());
//            for (var commentData in _topics) {
//                commentList.add(CommentAPI.createComment(commentData['reply']));
//                _idList.add(commentData['id']);
//            }
//            _commentList.addAll(commentList);
//
//            if (mounted) {
//                setState(() {
//                    _showLoading = false;
//                    _firstLoadComplete = true;
//                    _isLoading = false;
//                    _canLoadMore = _idList.length < _total && (_count != 0 && _count != "0");
//                    _lastValue = _idList.isEmpty ? 0 : widget._commentController.lastValue(_idList.last);
//                });
//            }
//        }
//    }
//
//    Future<Null> _refreshData() async {
//        if (!_isLoading) {
//            _isLoading = true;
//            _commentList.clear();
//
//            _lastValue = 0;
//
//            Map result = (await CommentAPI.getCommentList(
//                widget._commentController.commentType,
//                false,
//                _lastValue,
//                additionAttrs: widget._commentController.additionAttrs,
//            )).data;
//            List<Comment> commentList = [];
//            List<int> idList = [];
//            List _topics = result['replylist'];
//            int _total = int.parse(result['total'].toString());
//            int _count = int.parse(result['count'].toString());
//            for (var commentData in _topics) {
//                commentList.add(CommentAPI.createComment(commentData['reply']));
//                idList.add(commentData['id']);
//            }
//            _commentList.addAll(commentList);
//            _idList.addAll(idList);
//
//            if (mounted) {
//                setState(() {
//                    _showLoading = false;
//                    _firstLoadComplete = true;
//                    _isLoading = false;
//                    _canLoadMore = _idList.length < _total && (_count != 0 && _count != "0");
//                    _lastValue = _idList.isEmpty ? 0 : widget._commentController.lastValue(_idList.last);
//
//                });
//            }
//        }
//    }
//}


class TeamCommentListInPostController {
    _TeamCommentListInPostState _commentListInPostState;

    void reload() {
        _commentListInPostState?._refreshData();
    }
}

class TeamCommentListInPost extends StatefulWidget {
    final Post post;
    final TeamCommentListInPostController controller;

    TeamCommentListInPost(this.post, this.controller, {Key key}) : super(key: key);

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
            Map<String, dynamic> response = (await TeamCommentAPI.getCommentInPostList(
                id: widget.post.id,
            ))?.data;

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
                setState(() { _comments.addAll(comments); });
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
        setState(() { isLoading = true; });
        try {
            Map<String, dynamic> response = (await TeamCommentAPI.getCommentInPostList(
                id: widget.post.id,
            ))?.data;

            List<dynamic> list = response['data'];
            int total = response['total'] as int;
            if (response['count'] as int < total) canLoadMore = true;

            List<Comment> comments = [];
            list.forEach((comment) {
                comments.add(TeamCommentAPI.createCommentInPost(comment));
            });

            if (this.mounted) {
                setState(() {
                    Constants.eventBus.fire(new CommentInPostUpdatedEvent(widget.post.id, total));
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
                margin: EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0), vertical: Constants.suSetSp(10.0)),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFECECEC),
                    image: DecorationImage(
                        image: UserUtils.getAvatarProvider(uid: comment.fromUserUid),
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
                if (widget.post.uid == comment.fromUserUid) Container(
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
        if (
            int.parse(_commentTime.substring(0, 2)) == now.month
                &&
            int.parse(_commentTime.substring(3, 5)) == now.day
        ) {
            _commentTime = "${_commentTime.substring(5, 11)}";
        } else if (
            int.parse(_commentTime.substring(0, 2)) != now.month
                &&
            int.parse(_commentTime.substring(3, 5)) != now.day
        ) {
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
                    TextSpan(text: "　", style: TextStyle(fontSize: Constants.suSetSp(12.0))),
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
                    SearchPage.search(context, text.substring(1, text.length-1));
                } else if (text.startsWith("@")) {
                    UserPage.jump(context, data['uid']);
                } else if (text.startsWith(Api.wbHost)) {
                    CommonWebPage.jump(context, text, "网页链接");
                } else if (text.startsWith("|")) {
                    int imageID = data['image'];
                    String imageUrl = Api.commentImageUrl(imageID, "o");
                    Navigator.of(context).push(CupertinoPageRoute(builder: (_) {
                        return ImageViewer(
                            0, [ImageBean(imageID, imageUrl, null)],
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
                children: <Widget>[

                ],
            )
        );
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
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.zero,
                child: firstLoadComplete ? ListView.separated(
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
                                                child: Platform.isAndroid ? CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                ) : CupertinoActivityIndicator(),
                                            ),
                                            Text("　正在加载", style: TextStyle(fontSize: Constants.suSetSp(14.0))),
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
                                            children: <Widget>[Center(
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                        if (
                                                        _c.fromUserUid == UserUtils.currentUser.uid
                                                                ||
                                                                widget.post.uid == UserUtils.currentUser.uid
                                                        ) Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                                IconButton(
                                                                    icon: Icon(Icons.delete, size: Constants.suSetSp(36.0), color: Colors.white),
                                                                    padding: EdgeInsets.all(Constants.suSetSp(6.0)),
                                                                    onPressed: () {
                                                                        showPlatformDialog(
                                                                            context: context,
                                                                            builder: (_) => DeleteDialog("评论", comment: _c),
                                                                        );
                                                                    },
                                                                ),
                                                                Text("删除评论", style: TextStyle(fontSize: Constants.suSetSp(16.0), color: Colors.white)),
                                                            ],
                                                        ),
                                                        Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                                IconButton(
                                                                    icon: Icon(Icons.content_copy, size: Constants.suSetSp(36.0), color: Colors.white),
                                                                    padding: EdgeInsets.all(Constants.suSetSp(6.0)),
                                                                    onPressed: () {
                                                                        Clipboard.setData(ClipboardData(
                                                                            text: replaceMentionTag(_c.content),
                                                                        ));
                                                                        showShortToast("已复制到剪贴板");
                                                                        Navigator.of(context).pop();
                                                                    },
                                                                ),
                                                                Text("复制评论", style: TextStyle(fontSize: Constants.suSetSp(16.0), color: Colors.white)),
                                                            ],
                                                        ),
                                                    ],
                                                ),
                                            )],
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
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    builder: (BuildContext context) => CommentPositioned(
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

