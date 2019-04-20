import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/cards/CommentCard.dart';

class CommentAPI {
  static getCommentList(String commentType, bool isMore, int lastValue, {additionAttrs}) async {
    String _commentUrl;
    switch (commentType) {
      case "reply":
        if (isMore) {
          _commentUrl = "${Api.commentListByReply}/id_max/$lastValue";
        } else {
          _commentUrl = "${Api.commentListByReply}";
        }
        break;
      case "mention":
        if (isMore) {
          _commentUrl = "${Api.commentListByMention}/id_max/$lastValue";
        } else {
          _commentUrl = "${Api.commentListByMention}";
        }
        break;
    }
    return NetUtils.getWithCookieAndHeaderSet(_commentUrl);
  }
  static getCommentInPostList(int id) async {
    return NetUtils.getWithCookieAndHeaderSet("${Api.postCommentsList}$id");
  }

  static postComment(String content, int postId, bool forwardAtTheMeanTime, {int replyToId}) async {
    Map<String, dynamic> data = {
      "content": Uri.encodeFull(content),
      "reflag": 0,
      "relay": forwardAtTheMeanTime ? 1 : 0
    };
    String url;
    if (replyToId != null) {
      url = "${Api.postRequestCommentTo}$postId/rid/$replyToId";
      data["without_mention"] = 1;
    } else {
      url = "${Api.postRequestComment}$postId";
    }
    return NetUtils.postWithCookieAndHeaderSet(url, data: data);
  }

  static Comment createComment(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f100";
    String _commentTime = new DateTime.fromMillisecondsSinceEpoch(itemData['post_time'] * 1000)
        .toString()
        .substring(0,16);
    bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
    bool topicExist = itemData['to_topic']['exists'] == 1 ? true : false;
    Comment _comment = new Comment(
      itemData['rid'],
      itemData['user']['uid'],
      itemData['user']['nickname'],
      _avatar,
      itemData['content'],
      _commentTime,
      itemData['from_string'],
      replyExist,
      replyExist ? itemData['to_reply']['reply']['user']['uid'] : 0,
      replyExist ? itemData['to_reply']['reply']['user']['nickname'] : null,
      replyExist ? itemData['to_reply']['reply']['content'] : null,
      topicExist,
      topicExist ? int.parse(itemData['to_topic']['topic']['user']['uid']) : 0,
      topicExist ? itemData['to_topic']['topic']['user']['nickname'] : null,
      topicExist
          ?
            itemData['to_topic']['topic']['article']
              ??
            itemData['to_topic']['topic']['content']
          : null,

    );
    return _comment;
  }
  static Comment createCommentInPost(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f100";
    String _commentTime = new DateTime.fromMillisecondsSinceEpoch(itemData['post_time'] * 1000)
        .toString()
        .substring(0,16);
    bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
    Comment _comment = new Comment(
      itemData['rid'],
      itemData['user']['uid'],
      itemData['user']['nickname'],
      _avatar,
      itemData['content'],
      _commentTime,
      itemData['from_string'],
      replyExist,
      replyExist ? itemData['to_reply']['reply']['user']['uid'] : 0,
      replyExist ? itemData['to_reply']['reply']['user']['nickname'] : null,
      replyExist ? itemData['to_reply']['reply']['content'] : null,
      false,
      0,
      null,
      null,
    );
    return _comment;
  }

}

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (!_showLoading) {
      if (_firstLoadComplete) {
        _itemList = ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          itemBuilder: (context, index) {
            if (index == _commentList.length - 1) {
              _loadData();
            }
            return CommentCard(_commentList[index]);
          },
          itemCount: _commentList.length,
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
      }
      _commentList.addAll(commentList);
//      error = !result['success'];

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _topics.isNotEmpty;
          _lastValue = _commentList.isEmpty
              ? 0
              : widget._commentController.lastValue(_commentList.last);
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
      List _topics = jsonDecode(result)['replylist'];
      for (var commentData in _topics) {
        commentList.add(CommentAPI.createComment(commentData['reply']));
      }
      _commentList.addAll(commentList);
//      error = !result['success'] ?? false;

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _topics.isNotEmpty;
          _lastValue = _commentList.isEmpty
              ? 0
              : widget._commentController.lastValue(_commentList.last);

        });
      }
    }
  }
}

class CommentInPostList extends StatefulWidget {
  final Post post;

  CommentInPostList(this.post, {Key key}) : super(key: key);

  @override
  State createState() => _CommentInPostListState();
}

class _CommentInPostListState extends State<CommentInPostList> {
  List<Comment> _comments = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
        isLoading = false;
        _comments = comments;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Theme.of(context).cardColor,
        width: MediaQuery.of(context).size.width,
        padding: isLoading
            ? EdgeInsets.symmetric(vertical: 42)
            : EdgeInsets.zero,
        child: isLoading
            ? Center(child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme)
        ))
            : CommentCardInPost(widget.post, _comments)
    );
  }

}