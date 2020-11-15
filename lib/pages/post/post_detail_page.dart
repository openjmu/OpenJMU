import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/post_card.dart';

@FFRoute(
  name: 'openjmu://post-detail',
  routeName: '动态详情页',
  argumentNames: <String>['post', 'index', 'fromPage', 'parentContext'],
)
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    @required this.post,
    this.index,
    this.fromPage,
    this.parentContext,
  });

  final Post post;
  final int index;
  final String fromPage;
  final BuildContext parentContext;

  @override
  State<StatefulWidget> createState() {
    return PostDetailPageState();
  }
}

class PostDetailPageState extends State<PostDetailPage> {
  final ForwardListInPostController forwardListInPostController =
      ForwardListInPostController();
  final CommentListInPostController commentListInPostController =
      CommentListInPostController();

  final double iconSize = 26.0;
  final double actionFontSize = 20.0;
  final double sectionButtonWidth = 92.0;
  final Color activeColor = currentThemeColor;

  TextStyle get textActiveStyle => TextStyle(
        color: adaptiveButtonColor(),
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      );

  TextStyle get textInActiveStyle => TextStyle(
        color: Colors.grey,
        fontSize: 18.sp,
      );

  ShapeBorder get sectionButtonShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.w),
      );

  int _tabIndex = 1;
  bool isLike;
  int forwards, comments, praises;
  bool forwardAtTheMeanTime = false;
  bool commentAtTheMeanTime = false;

  TextStyle forwardsStyle, commentsStyle, praisesStyle;

  Widget _post;
  Widget _forwardsList;
  Widget _commentsList;
  Widget _praisesList;

  @override
  void initState() {
    super.initState();
    _post = postCard;
    forwards = widget.post.forwards;
    comments = widget.post.comments;
    praises = widget.post.praises;
    isLike = widget.post.isLike;

    _forwardsList = ForwardListInPost(widget.post, forwardListInPostController);
    _commentsList = CommentListInPost(widget.post, commentListInPostController);
    _praisesList = PraiseListInPost(widget.post);

    setCurrentTabActive(widget.parentContext, 1, 'comments');
    PostAPI.glancePost(widget.post.id);

    Instances.eventBus
      ..on<PostDeletedEvent>().listen((PostDeletedEvent event) {
        if (mounted && event.postId == widget.post.id) {
          Future<void>.delayed(2200.milliseconds, () {
            navigatorState.pop(true);
          });
        }
      })
      ..on<PostForwardedEvent>().listen((PostForwardedEvent event) {
        if (mounted && event.postId == widget.post.id && forwards != null) {
          setState(() {
            forwards++;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostForwardDeletedEvent>().listen((PostForwardDeletedEvent event) {
        if (mounted && event.postId == widget.post.id && forwards != null) {
          setState(() {
            forwards--;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostCommentedEvent>().listen((PostCommentedEvent event) {
        if (mounted && event.postId == widget.post.id && comments != null) {
          setState(() {
            comments++;
          });
          commentListInPostController.reload();
        }
      })
      ..on<PostCommentDeletedEvent>().listen((PostCommentDeletedEvent event) {
        if (mounted && event.postId == widget.post.id && comments != null) {
          setState(() {
            comments--;
          });
          commentListInPostController.reload();
        }
      })
      ..on<ForwardInPostUpdatedEvent>()
          .listen((ForwardInPostUpdatedEvent event) {
        if (mounted && event.postId == widget.post.id && forwards != null) {
          if (event.count < forwards) {
            Instances.eventBus.fire(
              PostForwardDeletedEvent(widget.post.id, event.count),
            );
          }
          setState(() {
            forwards = event.count;
          });
        }
      })
      ..on<CommentInPostUpdatedEvent>()
          .listen((CommentInPostUpdatedEvent event) {
        if (mounted && event.postId == widget.post.id && comments != null) {
          setState(() {
            comments = event.count;
          });
        }
      })
      ..on<PraiseInPostUpdatedEvent>().listen((PraiseInPostUpdatedEvent event) {
        if (mounted && event.postId == widget.post.id && praises != null) {
          setState(() {
            praises = event.count;
          });
        }
      });
  }

  void setTabIndex(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void setCurrentTabActive(BuildContext context, int index, String tab) {
    setState(() {
      _tabIndex = index;

      forwardsStyle = tab == 'forwards' ? textActiveStyle : textInActiveStyle;
      commentsStyle = tab == 'comments' ? textActiveStyle : textInActiveStyle;
      praisesStyle = tab == 'praises' ? textActiveStyle : textInActiveStyle;
    });
  }

  Widget get postCard => Padding(
        padding: EdgeInsets.all(10.w),
        child: PostCard(
          widget.post,
          index: widget.index,
          fromPage: widget.fromPage,
          isDetail: true,
          parentContext: widget.parentContext,
          key: ValueKey<String>('post-key-${widget.post.id}'),
        ),
      );

  Widget get deleteButton => IconButton(
        icon: Icon(Icons.delete_outline, size: 30.w),
        onPressed: () => confirmDelete(context),
      );

  Widget get postActionButton => IconButton(
        icon: Icon(Icons.more_horiz, size: 30.w),
        onPressed: () => postExtraActions(context),
      );

  Future<void> confirmDelete(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除动态',
      content: '是否确认删除这条动态?',
      showConfirm: true,
    );
    if (confirm) {
      final LoadingDialogController _loadingDialogController =
          LoadingDialogController();
      LoadingDialog.show(
        context,
        controller: _loadingDialogController,
        text: '正在删除动态',
        isGlobal: false,
      );
      try {
        await PostAPI.deletePost(widget.post.id);
        _loadingDialogController.changeState('success', '动态删除成功');
        Instances.eventBus.fire(
            PostDeletedEvent(widget.post.id, widget.fromPage, widget.index));
      } catch (e) {
        trueDebugPrint(e.toString());
        trueDebugPrint(e.response?.toString());
        _loadingDialogController.changeState('failed', '动态删除失败');
      }
    }
  }

  void postExtraActions(BuildContext context) {
    ConfirmationBottomSheet.show(
      context,
      children: <Widget>[
        if (!UserAPI.blacklist.contains(BlacklistUser(
          uid: widget.post.uid,
          username: widget.post.nickname,
        )))
          ConfirmationBottomSheetAction(
            icon: const Icon(Icons.visibility_off),
            text: '${UserAPI.blacklist.contains(
              BlacklistUser(
                  uid: widget.post.uid, username: widget.post.nickname),
            ) ? '移出' : '加入'}黑名单',
            onTap: () => UserAPI.confirmBlock(
              context,
              BlacklistUser(
                  uid: widget.post.uid, username: widget.post.nickname),
            ),
          ),
        ConfirmationBottomSheetAction(
          icon: const Icon(Icons.report),
          text: '举报动态',
          onTap: () => confirmReport(context),
        ),
      ],
    );
  }

  Future<void> confirmReport(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '举报动态',
      content: '确定举报该条动态吗?',
      showConfirm: true,
    );
    if (confirm) {
      final ReportRecordsProvider provider = Provider.of<ReportRecordsProvider>(
        context,
        listen: false,
      );
      final bool canReport = await provider.addRecord(widget.post.id);
      if (canReport) {
        unawaited(PostAPI.reportPost(widget.post));
        showToast('举报成功');
        navigatorState.pop();
      }
    }
  }

  Widget get actionLists => Container(
        width: Screens.width,
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: <Widget>[
            MaterialButton(
              color: _tabIndex == 0 ? activeColor : Theme.of(context).cardColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              minWidth: sectionButtonWidth.w,
              shape: sectionButtonShape,
              child: Text('转发 ${moreThanZero(forwards)}', style: forwardsStyle),
              onPressed: () {
                setCurrentTabActive(context, 0, 'forwards');
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            MaterialButton(
              color: _tabIndex == 1 ? activeColor : Theme.of(context).cardColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              minWidth: sectionButtonWidth.w,
              shape: sectionButtonShape,
              child: Text('评论 ${moreThanZero(comments)}', style: commentsStyle),
              onPressed: () {
                setCurrentTabActive(context, 1, 'comments');
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(child: Container()),
            MaterialButton(
              color: _tabIndex == 2 ? activeColor : Theme.of(context).cardColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              minWidth: sectionButtonWidth.w,
              shape: sectionButtonShape,
              child: Text('赞 ${moreThanZero(praises)}', style: praisesStyle),
              onPressed: () {
                setCurrentTabActive(context, 2, 'praises');
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );

  Widget get toolbar {
    final TextStyle bodyTextStyle = Theme.of(context).textTheme.bodyText2;
    return Container(
      height: Screens.bottomSafeHeight + 70.h,
      padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FlatButton.icon(
              onPressed: () {
                navigatorState.pushNamed(
                  Routes.openjmuAddForward,
                  arguments: <String, dynamic>{'post': widget.post},
                );
              },
              icon: SvgPicture.asset(
                R.ASSETS_ICONS_POST_ACTIONS_FORWARD_FILL_SVG,
                color: bodyTextStyle.color,
                width: iconSize.w,
              ),
              label: Text(
                '转发',
                style: bodyTextStyle.copyWith(fontSize: actionFontSize.sp),
              ),
              splashColor: Colors.grey,
            ),
          ),
          Expanded(
            child: FlatButton.icon(
              onPressed: () {
                navigatorState.pushNamed(
                  Routes.openjmuAddComment,
                  arguments: <String, dynamic>{'post': widget.post},
                );
              },
              icon: SvgPicture.asset(
                R.ASSETS_ICONS_POST_ACTIONS_COMMENT_FILL_SVG,
                color: bodyTextStyle.color,
                width: iconSize.w,
              ),
              label: Text(
                '评论',
                style: bodyTextStyle.copyWith(fontSize: actionFontSize.sp),
              ),
              splashColor: Colors.grey,
            ),
          ),
          Expanded(
            child: LikeButton(
              size: iconSize.w,
              circleColor: CircleColor(
                start: currentThemeColor,
                end: currentThemeColor,
              ),
              countBuilder: (int count, bool isLiked, String text) => Text(
                count > 0 ? text : '赞',
                style: bodyTextStyle.copyWith(
                  color: isLiked ? currentThemeColor : bodyTextStyle.color,
                  fontSize: actionFontSize.sp,
                ),
              ),
              bubblesColor: BubblesColor(
                dotPrimaryColor: currentThemeColor,
                dotSecondaryColor: currentThemeColor,
              ),
              likeBuilder: (bool isLiked) => SvgPicture.asset(
                R.ASSETS_ICONS_POST_ACTIONS_PRAISE_FILL_SVG,
                color: isLiked ? currentThemeColor : bodyTextStyle.color,
                width: iconSize.w,
              ),
              likeCount: widget.post.isLike
                  ? moreThanOne(praises)
                  : moreThanZero(praises),
              likeCountAnimationType: LikeCountAnimationType.none,
              likeCountPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 12.h,
              ),
              isLiked: widget.post.isLike,
              onTap: onLikeButtonTap,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> onLikeButtonTap(bool isLiked) {
    final Completer<bool> completer = Completer<bool>();
    final int id = widget.post.id;

    widget.post.isLike = !widget.post.isLike;
    !isLiked ? widget.post.praises++ : widget.post.praises--;
    completer.complete(!isLiked);

    PraiseAPI.requestPraise(id, !isLiked).then(
      (Response<Map<String, dynamic>> response) {
        Instances.eventBus.fire(PraiseInPostUpdatedEvent(
          postId: widget.post.id,
          count: praises,
          type: 'square',
          isLike: !isLiked,
        ));
      },
    ).catchError((dynamic e) {
      isLiked ? widget.post.praises++ : widget.post.praises--;
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          title: const Text('动态正文'),
          actions: <Widget>[
            if (widget.post.uid == currentUser.uid)
              deleteButton
            else
              postActionButton,
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: NestedScrollView(
                  physics: const ClampingScrollPhysics(),
                  headerSliverBuilder: (_, __) => <Widget>[
                    SliverToBoxAdapter(child: _post),
                    SliverPersistentHeader(
                      delegate: CommonSliverPersistentHeaderDelegate(
                        child: actionLists,
                        height: 74.h,
                      ),
                      pinned: true,
                    ),
                  ],
                  body: IndexedStack(
                    index: _tabIndex,
                    children: <Widget>[
                      _forwardsList,
                      _commentsList,
                      _praisesList
                    ],
                  ),
                ),
              ),
            ),
            toolbar,
          ],
        ),
      ),
    );
  }
}

class CommonSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  CommonSliverPersistentHeaderDelegate({
    @required this.child,
    @required this.height,
  });

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(CommonSliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
