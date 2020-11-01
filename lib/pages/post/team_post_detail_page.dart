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
  argumentNames: <String>['provider', 'type', 'postId'],
)
class TeamPostDetailPage extends StatefulWidget {
  const TeamPostDetailPage({
    this.provider,
    @required this.type,
    this.postId,
    Key key,
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
        'icon': Icons.alternate_email,
        'color': Colors.teal,
        'action': mentionPeople,
      },
      <String, dynamic>{
        'name': '插入话题',
        'icon': Icons.create,
        'color': Colors.deepOrangeAccent,
        'action': addTopic,
      },
    ];
  }

  TeamPostProvider provider;

  int commentPage = 1, total, currentOffset;
  bool loading, canLoadMore = true, canSend = false, sending = false;
  bool showExtendedPad = false, showEmoticonPad = false;
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
        setState(() {
          showExtendedPad = false;
        });
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
          data['data'].forEach((Map<String, dynamic> post) {
            dynamic _post;
            switch (widget.type) {
              case TeamPostType.post:
                _post = TeamPost.fromJson(post);
                break;
              case TeamPostType.comment:
                _post = TeamPostComment.fromJson(post);
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
    if (showEmoticonPad && _focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }

    final VoidCallback change = () {
      showEmoticonPad = !showEmoticonPad;
      if (showEmoticonPad) {
        showExtendedPad = false;
      }
      if (mounted) {
        setState(() {});
      }
    };

    if (showEmoticonPad) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        InputUtils.hideKeyboard().whenComplete(
          () {
            Future<void>.delayed(300.milliseconds, null).whenComplete(change);
          },
        );
      } else {
        change();
      }
    }
  }

  void triggerExtendedPad() {
    if (!showExtendedPad) {
      _focusNode.unfocus();
    }
    setState(() {
      showExtendedPad = !showExtendedPad;
      if (showExtendedPad) {
        showEmoticonPad = false;
      }
    });
  }

  /// Method to add `##`(topic) into text field.
  /// 输入区域内插入`##`（话题）的方法
  void addTopic() {
    InputUtils.insertText(
      text: '##',
      state: this,
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
        trueDebugPrint('Mentioned User: ${result.toString()}');
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (_focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
          InputUtils.insertText(
            text: '<M ${result.id}>@${result.nickname}<\/M>',
            state: this,
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
      trueDebugPrint('Reply failed: $e');
      showErrorToast('发送失败');
    }).whenComplete(() {
      sending = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget get deleteButton => SizedBox.fromSize(
        size: Size.square(48.w),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.delete_outline),
          iconSize: 32.w,
          onPressed: () {
            confirmDelete(context, provider);
          },
        ),
      );

  Widget get textField => Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetWidth(50.0)),
            color: Theme.of(context).canvasColor.withOpacity(0.5),
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
                      horizontal: suSetWidth(20.0),
                      vertical: suSetHeight(10.0),
                    ),
                    prefixText: replyHint,
                    hintText: replyHint == null ? '给你一个神评的机会...' : null,
                  ),
                  cursorColor: currentThemeColor,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        fontSize: suSetSp(20.0),
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

  Widget get extendedPadButton => Container(
        padding: EdgeInsets.only(left: suSetWidth(12.0)),
        height: suSetHeight(46.0),
        child: MaterialButton(
          elevation: 0.0,
          highlightElevation: canSend ? 2.0 : 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(suSetWidth(50.0)),
          ),
          minWidth: suSetWidth(60.0),
          color: currentThemeColor,
          child: Center(
            child: Icon(
              Icons.add_circle_outline,
              color: adaptiveButtonColor(),
              size: suSetWidth(28.0),
            ),
          ),
          onPressed: triggerExtendedPad,
        ),
      );

  Widget get sendButton => Container(
        padding: EdgeInsets.only(left: suSetWidth(12.0)),
        height: suSetHeight(46.0),
        child: MaterialButton(
          elevation: 0.0,
          highlightElevation: canSend ? 2.0 : 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(suSetWidth(50.0)),
          ),
          minWidth: suSetWidth(60.0),
          disabledColor: currentThemeColor.withOpacity(sending ? 1 : 0.3),
          color: currentThemeColor.withOpacity(canSend ? 1 : 0.3),
          child: Center(
            child: SizedBox.fromSize(
              size: Size.square(suSetWidth(28.0)),
              child: sending
                  ? const PlatformProgressIndicator()
                  : Icon(
                      Icons.send,
                      color: adaptiveButtonColor(),
                      size: suSetWidth(28.0),
                    ),
            ),
          ),
          onPressed: !sending && canSend ? send : null,
        ),
      );

  Widget get extendedPad => AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
        width: Screens.width,
        height: showExtendedPad ? Screens.width / 4 : 0.0,
        child: Center(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.8,
            ),
            itemCount: extendedFeature.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                splashFactory: InkSplash.splashFactory,
                onTap: extendedFeature[index]['action'] as VoidCallback,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: suSetHeight(12.0)),
                      padding: EdgeInsets.all(suSetWidth(14.0)),
                      decoration: BoxDecoration(
                        color: extendedFeature[index]['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        extendedFeature[index]['icon'] as IconData,
                        size: suSetWidth(26.0),
                        color: adaptiveButtonColor(),
                      ),
                    ),
                    Text(
                      extendedFeature[index]['name'] as String,
                      style: TextStyle(fontSize: suSetSp(19.0)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget get emoticonButton => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: triggerEmoticonPad,
        child: Container(
          margin: EdgeInsets.only(right: suSetWidth(12.0)),
          child: Center(
            child: Icon(
              Icons.insert_emoticon,
              color: showEmoticonPad ? currentThemeColor : null,
              size: suSetWidth(30.0),
            ),
          ),
        ),
      );

  Widget get emoticonPad => EmotionPad(
        active: showEmoticonPad,
        height: _keyboardHeight,
        route: 'publish',
        controller: _textEditingController,
      );

  @override
  Widget build(BuildContext context) {
    final Set<dynamic> list =
        widget.type == TeamPostType.post ? comments : postComments;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      showEmoticonPad = false;
    }
    _keyboardHeight = math.max(_keyboardHeight, keyboardHeight);
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: const Text('集市动态'),
            centerTitle: true,
            actions: <Widget>[
              if (provider.post?.uid == currentUser.uid ?? false) deleteButton,
            ],
          ),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TeamPostCard(
                            post: provider.post,
                            detailPageState: this,
                          ),
                          Divider(
                            color: Theme.of(context).canvasColor,
                            height: suSetHeight(10.0),
                            thickness: suSetHeight(10.0),
                          ),
                        ],
                      ),
                    ),
                  if (!loading)
                    if (list != null)
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
                                  comment:
                                      list.elementAt(index) as TeamPostComment,
                                  topPost: provider.post,
                                  detailPageState: this,
                                );
                                break;
                            }
                            return Padding(
                              padding: EdgeInsets.all(suSetSp(4.0)),
                              child: item,
                            );
                          },
                          childCount: list.length + 1,
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: suSetHeight(300.0),
                          child: const Center(child: Text('Nothing here.')),
                        ),
                      )
                  else
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: suSetHeight(300.0),
                        child: const Center(child: SpinKitWidget()),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(suSetWidth(16.0)),
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.of(context).dividerColor.withOpacity(0.03),
                      offset: Offset(0, -suSetHeight(2.0)),
                      blurRadius: suSetHeight(2.0),
                    ),
                  ],
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    textField,
                    extendedPadButton,
                    sendButton,
                  ],
                ),
              ),
              extendedPad,
              emoticonPad,
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ],
      ),
    );
  }
}
