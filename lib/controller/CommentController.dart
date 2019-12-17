import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_list/extended_list.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/cards/CommentCard.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';

class CommentController {
  final String commentType;
  final bool isMore;
  final Function lastValue;
  final Map<String, dynamic> additionAttrs;

  CommentController({
    @required this.commentType,
    @required this.isMore,
    @required this.lastValue,
    this.additionAttrs,
  });

  _CommentListState _commentListState;

  void reload() {
    _commentListState._refreshData();
  }

  int getCount() {
    return _commentListState._commentList.length;
  }
}

class CommentList extends StatefulWidget {
  final CommentController _commentController;
  final bool needRefreshIndicator;

  CommentList(this._commentController,
      {Key key, this.needRefreshIndicator = true})
      : super(key: key);

  @override
  State createState() => _CommentListState();
}

class _CommentListState extends State<CommentList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  num _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  var _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  Widget _body = Center(child: PlatformProgressIndicator());

  List<Comment> _commentList = [];
  List<int> _idList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget._commentController._commentListState = this;
    Instances.eventBus.on<ScrollToTopEvent>().listen((event) {
      if (this.mounted &&
          ((event.tabIndex == 0 &&
                  widget._commentController.commentType == "square") ||
              (event.type == "Post"))) {
        _scrollController.animateTo(0,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
    });

    _emptyChild = GestureDetector(
      onTap: () {},
      child: Container(
        child: Center(
          child: Text(
            '这里空空如也~',
            style: TextStyle(color: currentThemeColor),
          ),
        ),
      ),
    );

    _errorChild = GestureDetector(
      onTap: () {
        setState(() {
          _isLoading = false;
          _showLoading = true;
          _refreshData();
        });
      },
      child: Container(
        child: Center(
          child: Text(
            '加载失败，轻触重试',
            style: TextStyle(color: currentThemeColor),
          ),
        ),
      ),
    );

    _refreshData();
  }

  Future<Null> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      Map result = (await CommentAPI.getCommentList(
        widget._commentController.commentType,
        true,
        _lastValue,
        additionAttrs: widget._commentController.additionAttrs,
      ))
          .data;

      List<Comment> commentList = [];
      List _topics = result['replylist'];
      int _total = int.parse(result['total'].toString());
      int _count = int.parse(result['count'].toString());

      for (var commentData in _topics) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": commentData['reply']['user']['uid'].toString(),
          "username": commentData['reply']['user']['nickname'],
        }))) {
          commentList.add(CommentAPI.createComment(commentData['reply']));
          _idList.add(commentData['id']);
        }
      }
      _commentList.addAll(commentList);

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _idList.length < _total && _count != 0;
          _lastValue = _idList.isEmpty
              ? 0
              : widget._commentController.lastValue(_idList.last);
        });
      }
    }
  }

  Future<Null> _refreshData() async {
    if (!_isLoading) {
      _isLoading = true;
      _commentList.clear();

      _lastValue = 0;

      Map result = (await CommentAPI.getCommentList(
        widget._commentController.commentType,
        false,
        _lastValue,
        additionAttrs: widget._commentController.additionAttrs,
      ))
          .data;

      List<Comment> commentList = [];
      List<int> idList = [];
      List _topics = result['replylist'];
      int _total = int.parse(result['total'].toString());
      int _count = int.parse(result['count'].toString());

      for (var commentData in _topics) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": commentData['reply']['user']['uid'].toString(),
          "username": commentData['reply']['user']['nickname'],
        }))) {
          commentList.add(CommentAPI.createComment(commentData['reply']));
          idList.add(commentData['id']);
        }
      }
      _commentList.addAll(commentList);
      _idList.addAll(idList);

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _idList.length < _total && _count != 0;
          _lastValue = _idList.isEmpty
              ? 0
              : widget._commentController.lastValue(_idList.last);
        });
      }
    }
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      if (_firstLoadComplete) {
        _itemList = ExtendedListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: suSetHeight(4.0),
          ),
          controller: widget._commentController.commentType == "mention"
              ? null
              : _scrollController,
          itemCount: _commentList.length + 1,
          itemBuilder: (context, index) {
            if (index == _commentList.length - 1) {
              _loadData();
            }
            if (index == _commentList.length) {
              return LoadMoreIndicator(canLoadMore: _canLoadMore);
            } else {
              return CommentCard(_commentList[index]);
            }
          },
        );

        if (widget.needRefreshIndicator) {
          _body = RefreshIndicator(
            color: currentThemeColor,
            onRefresh: _refreshData,
            child: _commentList.isEmpty
                ? (error ? _errorChild : _emptyChild)
                : _itemList,
          );
        } else {
          _body = _commentList.isEmpty
              ? (error ? _errorChild : _emptyChild)
              : _itemList;
        }
      }
      return _body;
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class CommentListInPostController {
  CommentListInPostState _commentListInPostState;

  void reload() {
    _commentListInPostState?._refreshData();
  }
}

class CommentListInPost extends StatefulWidget {
  final Post post;
  final CommentListInPostController commentInPostController;

  CommentListInPost(
    this.post,
    this.commentInPostController, {
    Key key,
  }) : super(key: key);

  @override
  State createState() => CommentListInPostState();
}

class CommentListInPostState extends State<CommentListInPost>
    with AutomaticKeepAliveClientMixin {
  final _comments = <Comment>[];

  bool isLoading = true;
  bool canLoadMore = false;
  bool firstLoadComplete = false;

  int lastValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    widget.commentInPostController._commentListInPostState = this;
    _refreshList();
    super.initState();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      _comments.clear();
    });
    _refreshList();
  }

  Future<Null> _loadList() async {
    isLoading = true;
    try {
      final response = (await CommentAPI.getCommentInPostList(
        widget.post.id,
        isMore: true,
        lastValue: lastValue,
      ))
          ?.data;
      final list = response['replylist'];
      final total = response['total'] as int;
      if (_comments.length + response['count'] as int < total) {
        canLoadMore = true;
      } else {
        canLoadMore = false;
      }

      list.forEach((comment) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": comment['reply']['user']['uid'].toString(),
          "username": comment['reply']['user']['nickname']
        }))) {
          comment['reply']['post'] = widget.post;
          _comments.add(CommentAPI.createCommentInPost(comment['reply']));
        }
      });

      isLoading = false;
      lastValue = _comments.isEmpty ? 0 : _comments.last.id;
      if (this.mounted) setState(() {});
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
    _comments.clear();
    try {
      final response =
          (await CommentAPI.getCommentInPostList(widget.post.id))?.data;
      final list = response['replylist'];
      final total = response['total'] as int;
      if (response['count'] as int < total) canLoadMore = true;

      list.forEach((comment) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": comment['reply']['user']['uid'].toString(),
          "username": comment['reply']['user']['nickname']
        }))) {
          comment['reply']['post'] = widget.post;
          _comments.add(CommentAPI.createCommentInPost(comment['reply']));
        }
      });

      isLoading = false;
      firstLoadComplete = true;
      lastValue = _comments.isEmpty ? 0 : _comments.last.id;

      if (this.mounted) setState(() {});
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

  Widget getCommentNickname(context, comment) {
    return Text(
      comment.fromUserName,
      style: TextStyle(
        color: Theme.of(context).textTheme.title.color,
        fontSize: suSetSp(21.0),
      ),
    );
  }

  Widget getCommentTime(context, comment) {
    String _commentTime = comment.commentTime;
    DateTime now = DateTime.now();
    if (int.parse(_commentTime.substring(0, 4)) == now.year) {
      _commentTime = _commentTime.substring(5, 16);
    }
    if (int.parse(_commentTime.substring(0, 2)) == now.month &&
        int.parse(_commentTime.substring(3, 5)) == now.day) {
      _commentTime = "${_commentTime.substring(5, 11)}";
    }
    return Text(
      _commentTime,
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(16.0),
          ),
    );
  }

  Widget getExtendedText(context, content) {
    return ExtendedText(
      content != null ? "$content " : null,
      style: TextStyle(fontSize: suSetSp(19.0)),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(
        widgetType: WidgetType.comment,
      ),
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

  void showActions(int index) {
    showDialog<Null>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        backgroundColor: currentThemeColor,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (_comments[index].fromUserUid == UserAPI.currentUser.uid ||
                  widget.post.uid == UserAPI.currentUser.uid)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showPlatformDialog(
                      context: context,
                      builder: (_) => DeleteDialog(
                        "评论",
                        comment: _comments[index],
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(suSetWidth(6.0)),
                        child: Icon(
                          Icons.delete,
                          size: suSetWidth(36.0),
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "删除评论",
                        style: TextStyle(
                          fontSize: suSetSp(16.0),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: replaceMentionTag(_comments[index].content),
                  ));
                  showShortToast("已复制到剪贴板");
                  Navigator.of(context).pop();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(suSetWidth(6.0)),
                      child: Icon(
                        Icons.content_copy,
                        size: suSetWidth(36.0),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "复制评论",
                      style: TextStyle(
                        fontSize: suSetSp(16.0),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? Center(child: PlatformProgressIndicator())
        : firstLoadComplete
            ? ExtendedListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => Container(
                  color: Theme.of(context).dividerColor,
                  height: 1.0,
                ),
                itemCount: _comments.length + 1,
                itemBuilder: (context, index) {
                  if (index == _comments.length - 1 && canLoadMore) {
                    _loadList();
                  }
                  if (index == _comments.length) {
                    return LoadMoreIndicator(
                      canLoadMore: canLoadMore && !isLoading,
                    );
                  } else if (index < _comments.length) {
                    if (_comments[index] == null) {
                      return SizedBox.shrink();
                    }
                    return InkWell(
                      onTap: () => showActions(index),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: suSetWidth(20.0),
                              vertical: suSetHeight(12.0),
                            ),
                            child: UserAPI.getAvatar(
                              uid: _comments[index].fromUserUid,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: suSetHeight(10.0)),
                                Row(
                                  children: <Widget>[
                                    getCommentNickname(
                                      context,
                                      _comments[index],
                                    ),
                                    if (Constants.developerList
                                        .contains(_comments[index].fromUserUid))
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: suSetWidth(14.0),
                                        ),
                                        child: DeveloperTag(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: suSetWidth(8.0),
                                            vertical: suSetHeight(4.0),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: suSetHeight(4.0)),
                                getExtendedText(
                                  context,
                                  _comments[index].content,
                                ),
                                SizedBox(height: suSetHeight(6.0)),
                                getCommentTime(context, _comments[index]),
                                SizedBox(height: suSetHeight(10.0)),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.reply,
                              color: Colors.grey,
                              size: suSetWidth(28.0),
                            ),
                            onPressed: () {
                              if (_comments.length >= index &&
                                  _comments[index] != null) {
                                navigatorState.pushNamed(
                                  "openjmu://add-comment",
                                  arguments: {
                                    "post": widget.post,
                                    "comment":
                                        _comments?.elementAt(index) ?? null,
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              )
            : LoadMoreIndicator(canLoadMore: false);
  }
}
