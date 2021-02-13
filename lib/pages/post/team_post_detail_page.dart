///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-19 10:04
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/team_post_card.dart';
import 'package:openjmu/widgets/cards/team_comment_preview_card.dart';
import 'package:openjmu/widgets/cards/team_post_comment_preview_card.dart';
import 'package:openjmu/widgets/dialogs/mention_people_dialog.dart';

@FFRoute(
  name: 'openjmu://team-post-detail',
  routeName: '小组动态详情页',
  argumentImports: <String>[
    'import \'providers/providers.dart\';',
  ],
)
class TeamPostDetailPage extends StatefulWidget {
  const TeamPostDetailPage({
    Key key,
    @required this.type,
    this.provider,
    this.postId,
  }) : super(key: key);

  final TeamPostProvider provider;
  final TeamPostType type;
  final int postId;

  @override
  TeamPostDetailPageState createState() => TeamPostDetailPageState();
}

class TeamPostDetailPageState extends State<TeamPostDetailPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Set<TeamPost> comments = <TeamPost>{};
  final Set<TeamPostComment> postComments = <TeamPostComment>{};

  List<Map<String, dynamic>> get extendedFeature {
    return <Map<String, dynamic>>[
      // <String, dynamic>{
      //   'name': '添加图片',
      //   'icon': Icons.add_photo_alternate,
      //   'color': Colors.blueAccent,
      //   'action': () {},
      // },
      <String, dynamic>{
        'name': '提到某人',
        'icon': R.ASSETS_ICONS_PUBLISH_MENTION_SVG,
        'action': mentionPeople,
      },
      <String, dynamic>{
        'name': '插入话题',
        'icon': R.ASSETS_ICONS_PUBLISH_ADD_TOPIC_SVG,
        'action': addTopic,
      },
    ];
  }

  TeamPostProvider provider;

  int commentPage = 1, total, currentOffset;
  bool loading, canLoadMore = true, canSend = false, sending = false;
  final ValueNotifier<bool> showExtendedPad = ValueNotifier<bool>(false),
      showEmoticonPad = ValueNotifier<bool>(false);
  String replyHint;
  double _keyboardHeight = EmotionPad.emoticonPadDefaultHeight;
  TeamPost replyToPost;
  TeamPostComment replyToComment;

  @override
  void initState() {
    super.initState();
    provider = widget.provider;
    canLoadMore = (provider.post?.repliesCount ?? -1) >
        (widget.type == TeamPostType.comment ? 50 : 30);
    loading = (provider.post?.repliesCount ?? -1) > 0;
    initialLoad();

    _textEditingController.addListener(() {
      final bool _canSend = _textEditingController.text.isNotEmpty;
      if (mounted && canSend != _canSend) {
        setState(() {
          canSend = _canSend;
        });
      }
    });

    _focusNode.addListener(() {
      if (mounted && _focusNode.hasFocus) {
        showExtendedPad.value = false;
      }
    });

    Instances.eventBus
      ..on<TeamCommentDeletedEvent>().listen((TeamCommentDeletedEvent event) {
        if (event.topPostId == provider.post.tid) {
          comments.removeWhere((TeamPost item) => item.tid == event.postId);
          if (mounted) {
            setState(() {});
          }
        }
        initialLoad();
      })
      ..on<TeamPostCommentDeletedEvent>().listen(
        (TeamPostCommentDeletedEvent event) {
          if (event.topPostId == provider.post.tid) {
            postComments.removeWhere(
              (TeamPostComment item) => item.rid == event.commentId,
            );
            if (mounted) {
              setState(() {});
            }
          }
        },
      );
  }

  Future<void> initialLoad({bool loadMore = false}) async {
    if (!loadMore) {
      switch (widget.type) {
        case TeamPostType.post:
          comments.clear();
          break;
        case TeamPostType.comment:
          postComments.clear();
          break;
      }
      if (provider.post == null) {
        final Map<String, dynamic> data = (await TeamPostAPI.getPostDetail(
          id: widget.postId,
          postType: 7,
        ))
            .data;
        final TeamPost post = TeamPost.fromJson(data);
        provider = TeamPostProvider(post);
      }
    }
    if (loadMore) {
      ++commentPage;
    }
    if (provider.post.repliesCount > 0) {
      TeamCommentAPI.getCommentInPostList(
        id: provider.post.tid,
        page: commentPage,
        isComment: widget.type == TeamPostType.comment,
      ).then((Response<Map<String, dynamic>> response) {
        final Map<String, dynamic> data = response.data;
        total = data['total'].toString().toInt();
        canLoadMore = data['count'].toString().toInt() >
            (widget.type == TeamPostType.comment ? 50 : 30);
        Set<dynamic> list;
        switch (widget.type) {
          case TeamPostType.post:
            list = comments;
            break;
          case TeamPostType.comment:
            list = postComments;
            break;
        }
        if (total != 0) {
          if (!loadMore) {
            list.clear();
          }
          data['data'].forEach((dynamic post) {
            dynamic _post;
            switch (widget.type) {
              case TeamPostType.post:
                _post = TeamPost.fromJson(post as Map<String, dynamic>);
                break;
              case TeamPostType.comment:
                _post = TeamPostComment.fromJson(post as Map<String, dynamic>);
                break;
            }
            list.add(_post);
          });
        }
        loading = false;
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      total = 0;
      canLoadMore = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void setReplyToTop() {
    replyToPost = null;
    replyToComment = null;
    replyHint = null;
    if (mounted) {
      setState(() {});
    }
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      InputUtils.showKeyboard();
    }
  }

  void setReplyToPost(TeamPost post) {
    replyToPost = post;
    replyHint = '回复@${post.nickname}:';
    if (mounted) {
      setState(() {});
    }
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      InputUtils.showKeyboard();
    }
  }

  void setReplyToComment(TeamPostComment comment) {
    replyToComment = comment;
    replyHint = '回复@${comment.userInfo['nickname']}:';
    if (mounted) {
      setState(() {});
    }
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      InputUtils.showKeyboard();
    }
  }

  Future<void> confirmDelete(
    BuildContext context,
    TeamPostProvider provider,
  ) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除动态',
      content: '是否删除该条动态?',
      showConfirm: true,
    );
    if (confirm) {
      delete(provider);
    }
  }

  void delete(TeamPostProvider provider) {
    TeamPostAPI.deletePost(postId: provider.post.tid, postType: 7).then(
      (dynamic _) {
        showToast('删除成功');
        switch (widget.type) {
          case TeamPostType.post:
            Instances.eventBus
                .fire(TeamPostDeletedEvent(postId: provider.post.tid));
            break;
          case TeamPostType.comment:
            Instances.eventBus
                .fire(TeamCommentDeletedEvent(postId: provider.post.tid));
            break;
        }
        navigatorState.pop();
      },
    );
  }

  void triggerEmoticonPad() {
    if (showEmoticonPad.value && _focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }

    if (context.bottomInsets > 0) {
      InputUtils.hideKeyboard();
    }
    showEmoticonPad.value = !showEmoticonPad.value;
    if (showEmoticonPad.value) {
      showExtendedPad.value = false;
    }
  }

  void triggerExtendedPad() {
    showExtendedPad.value = !showExtendedPad.value;
    if (showExtendedPad.value) {
      showEmoticonPad.value = false;
    }
  }

  /// Method to add `##`(topic) into text field.
  /// 输入区域内插入`##`（话题）的方法
  void addTopic() {
    InputUtils.insertText(
      text: '##',
      controller: _textEditingController,
      selectionOffset: 1,
    );
  }

  void mentionPeople() {
    currentOffset = _textEditingController.selection.extentOffset;
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((dynamic result) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
      if (result != null) {
        LogUtils.d('Mentioned User: ${result.toString()}');
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (_focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
          InputUtils.insertText(
            text: '<M ${result.id}>@${result.nickname}<\/M>',
            controller: _textEditingController,
          );
        });
      }
    });
  }

  void send() {
    setState(() {
      sending = true;
    });
    String prefix;
    int postId;
    int postType;
    int regionType;
    switch (widget.type) {
      case TeamPostType.post:
        if (replyHint == null) {
          postId = provider.post?.tid;
          postType = 7;
          regionType = 128;
        } else {
          postId = replyToPost?.tid;
          postType = 8;
          regionType = 256;
        }
        break;
      case TeamPostType.comment:
        if (replyHint != null) {
          prefix = replyHint;
        }
        postId = replyToComment?.originId ?? provider.post?.tid;
        postType = 8;
        regionType = 256;
        break;
    }
    TeamPostAPI.publishPost(
      content: '${prefix ?? ''}${_textEditingController.text}',
      postType: postType,
      regionId: postId,
      regionType: regionType,
    ).then((dynamic response) {
      provider.replied();
      _focusNode.unfocus();
      _textEditingController.clear();
      replyHint = null;
      showToast('发送成功');
      initialLoad();
    }).catchError((dynamic e) {
      LogUtils.e('Reply failed: $e');
      showErrorToast('发送失败');
    }).whenComplete(() {
      sending = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget get deleteButton {
    return Tapper(
      onTap: () => confirmDelete(context, provider),
      child: Container(
        width: 48.w,
        height: 48.w,
        alignment: Alignment.center,
        child: SizedBox.fromSize(
          size: Size.square(30.w),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(
              R.ASSETS_ICONS_POST_ACTIONS_DELETE_SVG,
              color: context.textTheme.bodyText2.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget get textField {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(minHeight: 52.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: context.theme.canvasColor,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ExtendedTextField(
                controller: _textEditingController,
                focusNode: _focusNode,
                specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
                enabled: !sending,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                  ),
                  prefixText: replyHint,
                  hintText: replyHint == null ? ' 与对方聊聊...' : null,
                ),
                cursorColor: currentThemeColor,
                style: context.textTheme.bodyText2.copyWith(
                  height: 1.2,
                  fontSize: 18.sp,
                  textBaseline: TextBaseline.alphabetic,
                ),
                maxLines: null,
              ),
            ),
            emoticonButton,
          ],
        ),
      ),
    );
  }

  Widget get extendedPadButton {
    return Tapper(
      onTap: triggerExtendedPad,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: context.theme.canvasColor,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          R.ASSETS_ICONS_POST_ACTIONS_EXTEND_SVG,
          width: 24.w,
          height: 24.w,
          color: context.textTheme.bodyText2.color,
        ),
      ),
    );
  }

  Widget get sendButton {
    return Tapper(
      onTap: !sending && canSend ? send : null,
      child: Container(
        width: 75.w,
        height: 52.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: currentThemeColor.withOpacity(canSend ? 1 : 0.3),
        ),
        alignment: Alignment.center,
        child: sending
            ? const PlatformProgressIndicator(color: Colors.white)
            : Text(
                '发送',
                style: TextStyle(
                  color: adaptiveButtonColor(),
                  height: 1.2,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget get extendedPad {
    return ValueListenableBuilder<bool>(
      valueListenable: showExtendedPad,
      builder: (_, bool value, Widget child) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        width: Screens.width,
        height: value ? 74.w + Screens.bottomSafeHeight : 0.0,
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
        ).copyWith(bottom: Screens.bottomSafeHeight),
        color: context.theme.cardColor,
        child: child,
      ),
      child: Wrap(
        children: List<Widget>.generate(
          extendedFeature.length,
          (int index) => GestureDetector(
            onTap: extendedFeature[index]['action'] as VoidCallback,
            child: Container(
              height: 60.w,
              margin: EdgeInsets.symmetric(
                horizontal: 8.w,
              ).copyWith(bottom: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: context.theme.canvasColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(
                    extendedFeature[index]['icon'] as String,
                    width: 20.w,
                    height: 20.w,
                    color: context.textTheme.bodyText2.color,
                  ),
                  Gap(10.w),
                  Text(
                    extendedFeature[index]['name'] as String,
                    style: TextStyle(height: 1.2, fontSize: 19.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get emoticonButton {
    return Tapper(
      onTap: triggerEmoticonPad,
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        alignment: Alignment.center,
        child: ValueListenableBuilder<bool>(
          valueListenable: showEmoticonPad,
          builder: (_, bool value, __) => SvgPicture.asset(
            R.ASSETS_ICONS_PUBLISH_EMOJI_SVG,
            width: 24.w,
            height: 24.w,
            color:
                value ? currentThemeColor : context.textTheme.bodyText2.color,
          ),
        ),
      ),
    );
  }

  Widget get emoticonPad {
    return ValueListenableBuilder<bool>(
      valueListenable: showEmoticonPad,
      builder: (_, bool value, __) => EmotionPad(
        active: value,
        height: _keyboardHeight,
        controller: _textEditingController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<dynamic> list =
        widget.type == TeamPostType.post ? comments : postComments;

    final double kh = MediaQuery.of(context).viewInsets.bottom;
    if (kh > 0 && kh >= _keyboardHeight) {
      showEmoticonPad.value = false;
    }
    _keyboardHeight = math.max(kh, _keyboardHeight ?? 0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          title: const Text('集市详情'),
          centerTitle: true,
          actions: <Widget>[
            if (provider.post?.uid == currentUser.uid) deleteButton,
          ],
          actionsPadding: EdgeInsets.only(right: 16.w),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Listener(
                onPointerDown: (_) {
                  if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
                    InputUtils.hideKeyboard();
                  }
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    if (provider.post != null)
                      SliverToBoxAdapter(
                        child: TeamPostCard(
                          post: provider.post,
                          detailPageState: this,
                        ),
                      ),
                    if (!loading)
                      if (list != null) ...<Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.w,
                            ),
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  width: 1.w,
                                  color: context.theme.dividerColor,
                                ),
                              ),
                            ),
                            child: Text(
                              '评论',
                              style: TextStyle(
                                color: context.textTheme.bodyText2.color
                                    .withOpacity(0.625),
                                height: 1.2,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, int index) {
                              if (index == list.length - 1 && canLoadMore) {
                                initialLoad(loadMore: true);
                              }
                              if (index == list.length) {
                                return LoadMoreIndicator(
                                  canLoadMore: canLoadMore,
                                );
                              }
                              Widget item;
                              switch (widget.type) {
                                case TeamPostType.post:
                                  item = ChangeNotifierProvider<
                                      TeamPostProvider>.value(
                                    value: TeamPostProvider(
                                      list.elementAt(index) as TeamPost,
                                    ),
                                    child: TeamCommentPreviewCard(
                                      topPost: provider.post,
                                      detailPageState: this,
                                    ),
                                  );
                                  break;
                                case TeamPostType.comment:
                                  item = TeamPostCommentPreviewCard(
                                    comment: list.elementAt(index)
                                        as TeamPostComment,
                                    topPost: provider.post,
                                    detailPageState: this,
                                  );
                                  break;
                              }
                              return item;
                            },
                            childCount: list.length + 1,
                          ),
                        ),
                      ] else
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 300.w,
                            child: const Center(child: Text('暂无内容')),
                          ),
                        )
                    else
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 300.h,
                          child: const Center(
                            child: LoadMoreSpinningIcon(isRefreshing: true),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1.w, height: 1.w),
            Container(
              padding: EdgeInsets.all(16.w),
              color: context.theme.colorScheme.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  textField,
                  Gap(12.w),
                  extendedPadButton,
                  Gap(12.w),
                  sendButton,
                ],
              ),
            ),
            extendedPad,
            emoticonPad,
            ValueListenableBuilder<bool>(
              valueListenable: showEmoticonPad,
              builder: (_, bool value, __) => SizedBox(
                height: value ? 0 : context.bottomInsets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
