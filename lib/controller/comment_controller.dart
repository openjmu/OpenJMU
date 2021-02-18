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
  final List<Comment> _commentList = <Comment>[];
  final List<int> _idList = <int>[];

  int _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  Widget _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.commentController._commentListState = this;

    _emptyChild = const Center(child: Text('无评论信息'));

    _errorChild = Tapper(
      onTap: () {
        setState(() {
          _isLoading = false;
          _showLoading = true;
          _refreshData();
        });
      },
      child: const Center(child: Text('加载失败，轻触重试')),
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
          commentList.add(
            CommentAPI.createComment(
              commentData['reply'] as Map<String, dynamic>,
            ),
          );
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
          padding: EdgeInsets.symmetric(vertical: 6.w),
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

        _body = DefaultTextStyle.merge(
          style: context.textTheme.caption.copyWith(
            fontSize: 20.sp,
          ),
          child: _commentList.isEmpty
              ? (error ? _errorChild : _emptyChild)
              : _itemList,
        );
        if (widget.needRefreshIndicator) {
          _body = RefreshIndicator(
            color: currentThemeColor,
            onRefresh: _refreshData,
            child: _body,
          );
        }
      }
      return _body;
    } else {
      return const Center(
        child: LoadMoreSpinningIcon(isRefreshing: true),
      );
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
        LogUtils.e(e.toString());
        _loadingDialogController.changeState('failed', '评论删除失败');
      }
    }
  }

  void replyTo(Comment comment) {
    PostActionDialog.show(
      context: context,
      post: widget.post,
      type: PostActionType.reply,
      comment: comment,
    );
  }

  void showActions(BuildContext context, Comment comment) {
    ConfirmationBottomSheet.show(
      context,
      actions: <ConfirmationBottomSheetAction>[
        if (comment.fromUserUid == currentUser.uid ||
            widget.post.uid == currentUser.uid)
          ConfirmationBottomSheetAction(
            text: '删除评论',
            onTap: () => confirmDelete(context, comment),
          ),
        ConfirmationBottomSheetAction(
          text: '回复评论',
          onTap: () => replyTo(comment),
        ),
        ConfirmationBottomSheetAction(
          text: '复制评论',
          onTap: () {
            Clipboard.setData(ClipboardData(
              text: replaceMentionTag(comment.content),
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
      if (mounted) {
        setState(() {});
      }
    } on DioError catch (e) {
      if (e.response != null) {
        LogUtils.e('${e.response.data}');
      } else {
        LogUtils.e('${e.request}');
        LogUtils.e(e.message);
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
      if (response['count'] as int < total) {
        canLoadMore = true;
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
      firstLoadComplete = true;
      lastValue = _comments.isEmpty ? 0 : _comments.last.id;

      if (mounted) {
        setState(() {});
      }
    } on DioError catch (e) {
      if (e.response != null) {
        LogUtils.e('${e.response.data}');
      } else {
        LogUtils.e('${e.request}');
        LogUtils.e(e.message);
      }
      return;
    }
  }

  Widget getCommentNickname(BuildContext context, Comment comment) {
    return Text(
      comment.fromUserName,
      style: context.textTheme.bodyText2.copyWith(
        height: 1.2,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget getCommentTime(BuildContext context, Comment comment) {
    return Text(
      PostAPI.postTimeConverter(comment.commentTime),
      style: context.textTheme.caption.copyWith(
        height: 1.2,
        fontSize: 16.sp,
      ),
    );
  }

  Widget getExtendedText(BuildContext context, String content) {
    return ExtendedText(
      content != null ? '$content ' : null,
      style: TextStyle(height: 1.2, fontSize: 17.sp),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
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

  Widget _itemBuilder(BuildContext context, Comment comment) {
    return ColoredBox(
      color: context.theme.cardColor,
      child: Tapper(
        onTap: () => showActions(context, comment),
        onLongPress: () {
          Clipboard.setData(ClipboardData(
            text: replaceMentionTag(comment.content),
          ));
          showToast('已复制到剪贴板');
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: UserAvatar(
                  uid: comment.fromUserUid,
                  isSysAvatar: comment.user.sysAvatar,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        getCommentNickname(context, comment),
                        if (Constants.developerList
                            .contains(comment.fromUserUid))
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: const DeveloperTag(),
                          ),
                        Gap(6.w),
                        getCommentTime(context, comment),
                      ],
                    ),
                    VGap(12.w),
                    getExtendedText(context, comment.content),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) {
      return const Center(
        child: LoadMoreSpinningIcon(isRefreshing: true),
      );
    }
    if (!firstLoadComplete) {
      return const LoadMoreIndicator(canLoadMore: false);
    }
    return ExtendedListView.separated(
      padding: EdgeInsets.zero,
      extendedListDelegate: const ExtendedListDelegate(),
      separatorBuilder: (_, __) => const LineDivider(),
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
          return _itemBuilder(context, _comments[index]);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
