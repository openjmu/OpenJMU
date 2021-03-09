import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as ex;
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/post_card.dart';

@FFRoute(
  name: 'openjmu://post-detail',
  routeName: '动态详情页',
  argumentImports: <String>[
    'import \'package:flutter/widgets.dart\';',
  ],
)
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    @required this.post,
    this.index,
    this.fromPage,
    this.toComment = false,
  })  : assert(post != null),
        assert(toComment != null);

  final Post post;
  final int index;
  final String fromPage;
  final bool toComment;

  @override
  PostDetailPageState createState() => PostDetailPageState();
}

class PostDetailPageState extends State<PostDetailPage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  final ForwardListInPostController forwardListInPostController =
      ForwardListInPostController();
  final CommentListInPostController commentListInPostController =
      CommentListInPostController();

  final double iconSize = 26.0;
  final double sectionButtonWidth = 92.0;

  double get tabHeight => 68.w;

  TabController _tabController;

  int get forwards => widget.post.forwards;

  int get comments => widget.post.comments;

  int get praises => widget.post.praises;

  bool get isLike => widget.post.isLike;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.toComment ? Screens.height * 2 : 0,
    );
    _tabController = TabController(length: 3, initialIndex: 1, vsync: this);

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
            widget.post.forwards++;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostForwardDeletedEvent>().listen((PostForwardDeletedEvent event) {
        if (mounted && event.postId == widget.post.id && forwards != null) {
          setState(() {
            widget.post.forwards--;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostCommentedEvent>().listen((PostCommentedEvent event) {
        if (mounted && event.postId == widget.post.id && comments != null) {
          setState(() {
            widget.post.comments++;
          });
          commentListInPostController.reload();
        }
      })
      ..on<PostCommentDeletedEvent>().listen((PostCommentDeletedEvent event) {
        if (mounted && event.postId == widget.post.id && comments != null) {
          setState(() {
            widget.post.comments--;
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
            widget.post.forwards = event.count;
          });
        }
      })
      ..on<CommentInPostUpdatedEvent>()
          .listen((CommentInPostUpdatedEvent event) {
        if (mounted && event.postId == widget.post.id && comments != null) {
          setState(() {
            widget.post.comments = event.count;
          });
        }
      })
      ..on<PraiseInPostUpdatedEvent>().listen((PraiseInPostUpdatedEvent event) {
        if (mounted && event.postId == widget.post.id && praises != null) {
          setState(() {
            widget.post.praises = event.count;
          });
        }
      });
  }

  /// Build current scroll view key for specific scroll view.
  ValueKey<String> innerScrollPositionKeyBuilder() {
    return ValueKey<String>('Detail-List-Key-${_tabController.index}');
  }

  Widget get postCard {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.w),
      child: PostCard(
        widget.post,
        index: widget.index,
        fromPage: widget.fromPage,
        isDetail: true,
        key: ValueKey<String>('post-key-${widget.post.id}'),
      ),
    );
  }

  Widget deleteButton(BuildContext context) {
    return Tapper(
      onTap: () => confirmDelete(context),
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

  Widget postActionButton(BuildContext context) {
    return Tapper(
      onTap: () => postExtraActions(context),
      child: Container(
        width: 48.w,
        height: 48.w,
        alignment: Alignment.center,
        child: SizedBox.fromSize(
          size: Size.square(30.w),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(
              R.ASSETS_ICONS_POST_ACTIONS_MORE_SVG,
              color: context.textTheme.bodyText2.color,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> confirmDelete(BuildContext context) async {
    if (await ConfirmationDialog.show(
      context,
      title: '删除动态',
      content: '您正在删除您的动态，请确认操作',
      showConfirm: true,
    )) {
      if (await ConfirmationDialog.show(
        context,
        title: '确认删除动态',
        content: '删除后的动态无法恢复，请确认操作',
        showConfirm: true,
      )) {
        final LoadingDialogController _ldc = LoadingDialogController();
        LoadingDialog.show(context, controller: _ldc, title: '正在删除动态 ...');
        try {
          await PostAPI.deletePost(widget.post.id);
          _ldc.changeState('success', title: '动态已删除');
          Instances.eventBus.fire(
            PostDeletedEvent(widget.post.id, widget.fromPage, widget.index),
          );
        } catch (e) {
          LogUtils.e(e.toString());
          LogUtils.e(e.response?.toString());
          _ldc.changeState(
            'failed',
            title: '动态删除失败',
            text: '该动态无法删除。可能问题：动态已被删除但未刷新、网络连接较差',
          );
        }
      }
    }
  }

  void postExtraActions(BuildContext context) {
    ConfirmationBottomSheet.show(
      context,
      actions: <ConfirmationBottomSheetAction>[
        if (!UserAPI.blacklist.contains(BlacklistUser(
          uid: widget.post.uid,
          username: widget.post.nickname,
        )))
          ConfirmationBottomSheetAction(
            text: '${UserAPI.blacklist.contains(
              BlacklistUser(
                uid: widget.post.uid,
                username: widget.post.nickname,
              ),
            ) ? '移出' : '加入'}黑名单',
            onTap: () => UserAPI.confirmBlock(
              context,
              BlacklistUser(
                uid: widget.post.uid,
                username: widget.post.nickname,
              ),
            ),
          ),
        ConfirmationBottomSheetAction(
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
      content: '您正在举报一条动态，请确认操作',
      showConfirm: true,
    );
    if (confirm) {
      final ReportRecordsProvider provider = Provider.of<ReportRecordsProvider>(
        context,
        listen: false,
      );
      final bool canReport = await provider.addRecord(widget.post.id);
      if (canReport) {
        PostAPI.reportPost(widget.post);
        showToast('举报成功');
        navigatorState.pop();
      }
    }
  }

  Widget actionLists(BuildContext context) {
    return Container(
      height: tabHeight,
      color: context.surfaceColor,
      child: Column(
        children: <Widget>[
          const LineDivider(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: <Tab>[
                        Tab(text: '转发 ${moreThanZero(forwards)}'),
                        Tab(text: '评论 ${moreThanZero(comments)}'),
                        Tab(text: '赞 ${moreThanZero(praises)}'),
                      ],
                      indicatorWeight: 4.w,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: currentThemeColor,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.w,
                      ).copyWith(bottom: 0),
                      labelStyle: TextStyle(
                        height: 1.2,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ),
                  Text(
                    '浏览${widget.post.glances}次',
                    style: context.textTheme.caption.copyWith(
                      height: 1.2,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const LineDivider(),
        ],
      ),
    );
  }

  Widget toolbar(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        height: 1.2,
        fontSize: 19.sp,
        fontWeight: FontWeight.normal,
      ),
      child: Container(
        height: Screens.bottomSafeHeight + 72.w,
        padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
        decoration: BoxDecoration(
          border: Border(top: dividerBS(context)),
          color: context.surfaceColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Tapper(
                onTap: () {
                  PostActionDialog.show(
                    context: context,
                    post: widget.post,
                    type: PostActionType.forward,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      R.ASSETS_ICONS_POST_ACTIONS_FORWARD_FILL_SVG,
                      color: context.theme.iconTheme.color,
                      width: iconSize.w,
                    ),
                    Gap(8.w),
                    const Text('转发'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Tapper(
                onTap: () {
                  PostActionDialog.show(
                    context: context,
                    post: widget.post,
                    type: PostActionType.reply,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      R.ASSETS_ICONS_POST_ACTIONS_COMMENT_FILL_SVG,
                      color: context.theme.iconTheme.color,
                      width: iconSize.w,
                    ),
                    Gap(8.w),
                    const Text('评论'),
                  ],
                ),
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
                  style: TextStyle(
                    color: isLiked ? currentThemeColor : null,
                  ),
                ),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: currentThemeColor,
                  dotSecondaryColor: currentThemeColor,
                ),
                likeBuilder: (bool isLiked) => SvgPicture.asset(
                  R.ASSETS_ICONS_POST_ACTIONS_PRAISE_FILL_SVG,
                  color: isLiked
                      ? currentThemeColor
                      : context.theme.iconTheme.color,
                  width: iconSize.w,
                ),
                likeCount: widget.post.isLike
                    ? moreThanOne(praises)
                    : moreThanZero(praises),
                likeCountAnimationType: LikeCountAnimationType.none,
                likeCountPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 12.w,
                ),
                isLiked: widget.post.isLike,
                onTap: onLikeButtonTap,
              ),
            ),
          ],
        ),
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
              deleteButton(context)
            else
              postActionButton(context),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: ex.NestedScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  pinnedHeaderSliverHeightBuilder: () => tabHeight,
                  innerScrollPositionKeyBuilder: innerScrollPositionKeyBuilder,
                  headerSliverBuilder: (_, __) => <Widget>[
                    SliverToBoxAdapter(child: postCard),
                    SliverPersistentHeader(
                      delegate: _SliverDelegate(
                        child: actionLists(context),
                        height: tabHeight,
                      ),
                      pinned: true,
                    ),
                  ],
                  body: ExtendedTabBarView(
                    cacheExtent: 3,
                    controller: _tabController,
                    children: <Widget>[
                      ex.NestedScrollViewInnerScrollPositionKeyWidget(
                        const Key('Detail-List-Key-0'),
                        ForwardListInPost(
                          widget.post,
                          forwardListInPostController,
                        ),
                      ),
                      ex.NestedScrollViewInnerScrollPositionKeyWidget(
                        const Key('Detail-List-Key-1'),
                        CommentListInPost(
                          widget.post,
                          commentListInPostController,
                        ),
                      ),
                      ex.NestedScrollViewInnerScrollPositionKeyWidget(
                        const Key('Detail-List-Key-2'),
                        PraiseListInPost(widget.post),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            toolbar(context),
          ],
        ),
      ),
    );
  }
}

class _SliverDelegate extends SliverPersistentHeaderDelegate {
  _SliverDelegate({
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
  bool shouldRebuild(_SliverDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
