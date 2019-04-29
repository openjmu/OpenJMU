import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/cards/CommentCard.dart';

class CommentController {
  final String commentType;
  final bool isMore;
  final Function lastValue;
  final Map<String, dynamic> additionAttrs;

  CommentController({
    @required this.commentType,
    @required this.isMore,
    @required this.lastValue,
    this.additionAttrs
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

  CommentList(this._commentController, {
    Key key, this.needRefreshIndicator = true
  }) : super(key: key);

  @override
  State createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = new ScrollController();
  Color currentColorTheme = ThemeUtils.currentColorTheme;

  num _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  var _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  Widget _body = Center(
    child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme)
    ),
  );

  List<Comment> _commentList = [];
  List<int> _idList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget._commentController._commentListState = this;
    Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
      if (
      this.mounted
          &&
          ((event.tabIndex == 0 && widget._commentController.commentType == "square") || (event.type == "Post"))
      ) {
        _scrollController.animateTo(0, duration: new Duration(milliseconds: 500), curve: Curves.ease);
      }
    });

    _emptyChild = GestureDetector(
      onTap: () {
      },
      child: Container(
        child: Center(
          child: Text('这里空空如也~', style: TextStyle(color: ThemeUtils.currentColorTheme),),
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
          child: Text('加载失败，轻触重试', style: TextStyle(color: ThemeUtils.currentColorTheme)),
        ),
      ),
    );

    _refreshData();
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      if (_firstLoadComplete) {
        _itemList = ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          itemBuilder: (context, index) {
            if (index == _commentList.length) {
              if (this._canLoadMore) {
                _loadData();
                return Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                            width: 15.0,
                            height: 15.0,
                            child: Platform.isAndroid
                                ? CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(currentColorTheme)
                            )
                                : CupertinoActivityIndicator()
                        ),
                        Text("　正在加载", style: TextStyle(fontSize: 14.0))
                      ],
                    )
                );
              } else {
                return Container(height: 40.0, child: Center(child: Text("没有更多了~")));
              }
            } else {
              return CommentCard(_commentList[index]);
            }
          },
          itemCount: _commentList.length + 1,
          controller: widget._commentController.commentType == "mention" ? null : _scrollController,
        );

        if (widget.needRefreshIndicator) {
          _body = RefreshIndicator(
            color: currentColorTheme,
            onRefresh: _refreshData,
            child: _commentList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList,
          );
        } else {
          _body = _commentList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList;
        }
      }
      return _body;
    } else {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(currentColorTheme)
          ),
        ),
      );
    }
  }

  Future<Null> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      var result = await CommentAPI.getCommentList(
          widget._commentController.commentType,
          true,
          _lastValue,
          additionAttrs: widget._commentController.additionAttrs
      );
      List<Comment> commentList = [];
      List _topics = jsonDecode(result)['replylist'];
      for (var commentData in _topics) {
        commentList.add(CommentAPI.createComment(commentData['reply']));
        _idList.add(commentData['id']);
      }
      _commentList.addAll(commentList);

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _topics.length == 20;
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

      var result = await CommentAPI.getCommentList(
          widget._commentController.commentType,
          false,
          _lastValue,
          additionAttrs: widget._commentController.additionAttrs
      );
      List<Comment> commentList = [];
      List<int> idList = [];
      List _topics = jsonDecode(result)['replylist'];
      for (var commentData in _topics) {
        commentList.add(CommentAPI.createComment(commentData['reply']));
        idList.add(commentData['id']);
      }
      _commentList.addAll(commentList);
      _idList.addAll(idList);

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _topics.length == 20;
          _lastValue = _idList.isEmpty
              ? 0
              : widget._commentController.lastValue(_idList.last);

        });
      }
    }
  }
}


class CommentInPostController {
  _CommentInPostListState _commentInPostListState;

  void reload() {
    _commentInPostListState?._refreshData();
  }
}

class CommentInPostList extends StatefulWidget {
  final Post post;
  final CommentInPostController commentInPostController;

  CommentInPostList(this.post, this.commentInPostController, {Key key}) : super(key: key);

  @override
  State createState() => _CommentInPostListState();
}

class _CommentInPostListState extends State<CommentInPostList> {
  List<Comment> _comments = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.commentInPostController._commentInPostListState = this;
    _getCommentList();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      _comments = [];
    });
    _getCommentList();
  }

  Future<Null> _getCommentList() async {
    var list = await CommentAPI.getCommentInPostList(widget.post.id);
    List<dynamic> response = jsonDecode(list)['replylist'];
    List<Comment> comments = [];
    response.forEach((comment) {
      comments.add(CommentAPI.createCommentInPost(comment['reply']));
    });
    if (this.mounted) {
      setState(() {
        Constants.eventBus.fire(new CommentInPostUpdatedEvent(widget.post.id, comments.length));
        isLoading = false;
        _comments = comments;
      });
    }
  }

  Widget commentList() {
    return isLoading
        ? Center(child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme)
    ))
        : CommentCardInPost(widget.post, _comments);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Theme.of(context).cardColor,
        width: MediaQuery.of(context).size.width,
        padding: isLoading
            ? EdgeInsets.symmetric(vertical: 42)
            : EdgeInsets.zero,
        child: commentList()
    );
  }

}