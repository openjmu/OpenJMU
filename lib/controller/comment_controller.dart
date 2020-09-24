import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_list/extended_list.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/comment_card.dart';

class CommentController {
  CommentController({
    @required this.commentType,
    @required this.isMore,
    @required this.lastValue,
    this.additionAttrs,
  });

  final String commentType;
  final bool isMore;
  final int Function(int) lastValue;
  final Map<String, dynamic> additionAttrs;

  _CommentListState _commentListState;

  void reload() {
    _commentListState._refreshData();
  }

  int getCount() {
    return _commentListState._commentList.length;
  }
}

class CommentList extends StatefulWidget {
  const CommentList(
    this.commentController, {
    Key key,
    this.needRefreshIndicator = true,
  }) : super(key: key);

  final CommentController commentController;
  final bool needRefreshIndicator;

  @override
  State createState() => _CommentListState();
}

class _CommentListState extends State<CommentList>
    with AutomaticKeepAliveClientMixin {
  int _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  Widget _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  final List<Comment> _commentList = <Comment>[];
  final List<int> _idList = <int>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.commentController._commentListState = this;

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

  Future<void> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      final Map<String, dynamic> result = (await CommentAPI.getCommentList(
        widget.commentController.commentType,
        true,
        _lastValue,
        additionAttrs: widget.commentController.additionAttrs,
      ))
          .data;

      final List<Comment> commentList = <Comment>[];
      final List<dynamic> _topics = result['replylist'] as List<dynamic>;
      final int _total = int.parse(result['total'].toString());
      final int _count = int.parse(result['count'].toString());

      for (final dynamic data in _topics) {
        final Map<String, dynamic> commentData = data as Map<String, dynamic>;
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': commentData['reply']['user']['uid'].toString(),
            'username': commentData['reply']['user']['nickname'],
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
          commentList.add(CommentAPI.createComment(
              commentData['reply'] as Map<String, dynamic>));
          _idList.add(commentData['id'] as int);
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
              : widget.commentController.lastValue(_idList.last);
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (!_isLoading) {
      _isLoading = true;
      _commentList.clear();

      _lastValue = 0;

      final Map<String, dynamic> result = (await CommentAPI.getCommentList(
        widget.commentController.commentType,
        false,
        _lastValue,
        additionAttrs: widget.commentController.additionAttrs,
      ))
          .data;

      final List<Comment> commentList = <Comment>[];
      final List<int> idList = <int>[];
      final List<dynamic> _topics = result['replylist'] as List<dynamic>;
      final int _total = result['total'].toString().toInt();
      final int _count = result['count'].toString().toInt();

      for (final dynamic data in _topics) {
        final Map<String, dynamic> commentData = data as Map<String, dynamic>;
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': commentData['reply']['user']['uid'].toString(),
            'username': commentData['reply']['user']['nickname'],
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
          commentList.add(CommentAPI.createComment(
              commentData['reply'] as Map<String, dynamic>));
          idList.add(commentData['id'] as int);
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
              : widget.commentController.lastValue(_idList.last);
        });
      }
    }
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      Widget _body;
      if (_firstLoadComplete) {
        _itemList = ExtendedListView.builder(
          padding: EdgeInsets.symmetric(vertical: suSetWidth(6.0)),
          extendedListDelegate: const ExtendedListDelegate(),
          itemCount: _commentList.length + 1,
          itemBuilder: (BuildContext _, int index) {
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
      return const SpinKitWidget();
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
  const CommentListInPost(
    this.post,
    this.commentInPostController, {
    Key key,
  }) : super(key: key);

  final Post post;
  final CommentListInPostController commentInPostController;

  @override
  State createState() => CommentListInPostState();
}

class CommentListInPostState extends State<CommentListInPost>
    with AutomaticKeepAliveClientMixin {
  final List<Comment> _comments = <Comment>[];

  bool isLoading = true;
  bool canLoadMore = false;
  bool firstLoadComplete = false;

  int lastValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.commentInPostController._commentListInPostState = this;
    _refreshList();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      _comments.clear();
    });
    _refreshList();
  }

  Future<void> confirmDelete(BuildContext context, Comment comment) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除评论',
      content: '是否确认删除这条评论?',
      showConfirm: true,
    );
    if (confirm) {
      final LoadingDialogController _loadingDialogController =
          LoadingDialogController();
      LoadingDialog.show(
        context,
        text: '正在删除评论',
        controller: _loadingDialogController,
        isGlobal: false,
      );
      try {
        await CommentAPI.deleteComment(comment.post.id, comment.id);
        _loadingDialogController.changeState('success', '评论删除成功');
        Instances.eventBus.fire(PostCommentDeletedEvent(comment.post.id));
      } catch (e) {
        trueDebugPrint(e.toString());
        _loadingDialogController.changeState('failed', '评论删除失败');
      }
    }
  }

  void replyTo(int index) {
    if (_comments.length >= index && _comments[index] != null) {
      navigatorState.pushNamed(
        Routes.openjmuAddComment,
        arguments: <String, dynamic>{
          'post': widget.post,
          'comment': _comments?.elementAt(index),
        },
      );
    }
  }

  void showActions(BuildContext context, int index) {
    ConfirmationBottomSheet.show(
      context,
      children: <Widget>[
        if (_comments[index].fromUserUid == currentUser.uid ||
            widget.post.uid == currentUser.uid)
          ConfirmationBottomSheetAction(
            icon: const Icon(Icons.delete),
            text: '删除评论',
            onTap: () => confirmDelete(context, _comments[index]),
          ),
        ConfirmationBottomSheetAction(
          icon: const Icon(Icons.reply),
          text: '回复评论',
          onTap: () => replyTo(index),
        ),
        ConfirmationBottomSheetAction(
          icon: const Icon(Icons.report),
          text: '复制评论',
          onTap: () {
            Clipboard.setData(ClipboardData(
              text: replaceMentionTag(_comments[index].content),
            ));
            showToast('已复制到剪贴板');
          },
        ),
      ],
    );
  }

  Future<void> _loadList() async {
    isLoading = true;
    try {
      final Map<String, dynamic> response =
          (await CommentAPI.getCommentInPostList(
        widget.post.id,
        isMore: true,
        lastValue: lastValue,
      ))
              ?.data;
      final List<Map<dynamic, dynamic>> list =
          (response['replylist'] as List<dynamic>)
              .cast<Map<dynamic, dynamic>>();
      final int total = response['total'] as int;
      if (_comments.length + (response['count'] as int) < total) {
        canLoadMore = true;
      } else {
        canLoadMore = false;
      }

      for (final Map<dynamic, dynamic> comment in list) {
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': comment['reply']['user']['uid'].toString(),
            'username': comment['reply']['user']['nickname']
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
          comment['reply']['post'] = widget.post;
          _comments.add(CommentAPI.createCommentInPost(
              comment['reply'] as Map<String, dynamic>));
        }
      }

      isLoading = false;
      lastValue = _comments.isEmpty ? 0 : _comments.last.id;
      if (mounted) setState(() {});
    } on DioError catch (e) {
      if (e.response != null) {
        trueDebugPrint('${e.response.data}');
      } else {
        trueDebugPrint('${e.request}');
        trueDebugPrint(e.message);
      }
      return;
    }
  }

  Future<void> _refreshList() async {
    setState(() {
      isLoading = true;
    });
    _comments.clear();
    try {
      final Map<String, dynamic> response =
          (await CommentAPI.getCommentInPostList(widget.post.id))?.data;
      final List<Map<dynamic, dynamic>> list =
          (response['replylist'] as List<dynamic>)
              .cast<Map<dynamic, dynamic>>();
      final int total = response['total'] as int;
      if (response['count'] as int < total) canLoadMore = true;

      for (final Map<dynamic, dynamic> comment in list) {
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': comment['reply']['user']['uid'].toString(),
            'username': comment['reply']['user']['nickname']
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
          comment['reply']['post'] = widget.post;
          _comments.add(CommentAPI.createCommentInPost(
              comment['reply'] as Map<String, dynamic>));
        }
      }

      isLoading = false;
      firstLoadComplete = true;
      lastValue = _comments.isEmpty ? 0 : _comments.last.id;

      if (mounted) setState(() {});
    } on DioError catch (e) {
      if (e.response != null) {
        trueDebugPrint('${e.response.data}');
      } else {
        trueDebugPrint('${e.request}');
        trueDebugPrint(e.message);
      }
      return;
    }
  }

  Widget getCommentNickname(BuildContext context, Comment comment) {
    return Text(
      comment.fromUserName,
      style: TextStyle(fontSize: suSetSp(20.0)),
    );
  }

  Widget getCommentTime(BuildContext context, Comment comment) {
    return Text(
      PostAPI.postTimeConverter(comment.commentTime),
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(16.0),
          ),
    );
  }

  Widget getExtendedText(BuildContext context, String content) {
    return ExtendedText(
      content != null ? '$content ' : null,
      style: TextStyle(fontSize: suSetSp(19.0)),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder:
          StackSpecialTextSpanBuilder(widgetType: WidgetType.comment),
    );
  }

  String replaceMentionTag(String text) {
    final RegExp mTagStartReg = RegExp(r'<M?\w+.*?\/?>');
    final RegExp mTagEndReg = RegExp(r'<\/M?\w+.*?\/?>');
    final String commentText = text
        .replaceAllMapped(mTagStartReg, (_) => '')
        .replaceAllMapped(mTagEndReg, (_) => '');
    return commentText;
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? const SpinKitWidget()
        : firstLoadComplete
            ? ExtendedListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                extendedListDelegate: const ExtendedListDelegate(),
                separatorBuilder: (BuildContext _, int index) => Container(
                  color: Theme.of(context).dividerColor,
                  height: 1.0,
                ),
                itemCount: _comments.length + 1,
                itemBuilder: (BuildContext _, int index) {
                  if (index == _comments.length - 1 && canLoadMore) {
                    _loadList();
                  }
                  if (index == _comments.length) {
                    return LoadMoreIndicator(
                      canLoadMore: canLoadMore && !isLoading,
                    );
                  } else if (index < _comments.length) {
                    if (_comments[index] == null) {
                      return const SizedBox.shrink();
                    }
                    return InkWell(
                      onTap: () => showActions(context, index),
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
                            onPressed: () => replyTo(index),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            : const LoadMoreIndicator(canLoadMore: false);
  }
}
