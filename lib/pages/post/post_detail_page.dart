import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/post_card.dart';

@FFRoute(
  name: "openjmu://post-detail",
  routeName: "动态详情页",
  argumentNames: ["post", "index", "fromPage", "parentContext"],
)
class PostDetailPage extends StatefulWidget {
  final Post post;
  final int index;
  final String fromPage;
  final BuildContext parentContext;

  const PostDetailPage({
    @required this.post,
    this.index,
    this.fromPage,
    this.parentContext,
  });

  @override
  State<StatefulWidget> createState() {
    return PostDetailPageState();
  }
}

class PostDetailPageState extends State<PostDetailPage> {
  final forwardListInPostController = ForwardListInPostController();
  final commentListInPostController = CommentListInPostController();

  final iconSize = 26.0;
  final actionFontSize = 20.0;
  final sectionButtonWidth = 92.0;
  final activeColor = currentThemeColor;

  TextStyle get textActiveStyle => TextStyle(
        color: Colors.white,
        fontSize: suSetSp(20.0),
        fontWeight: FontWeight.bold,
      );
  TextStyle get textInActiveStyle => TextStyle(
        color: Colors.grey,
        fontSize: suSetSp(18.0),
      );
  ShapeBorder get sectionButtonShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(suSetWidth(10.0)),
      );

  int _tabIndex = 1;
  bool isLike;
  int forwards, comments, praises;
  bool forwardAtTheMeanTime = false;
  bool commentAtTheMeanTime = false;

  TextStyle forwardsStyle, commentsStyle, praisesStyle;

  Color forwardsColor, commentsColor = currentThemeColor, praisesColor;

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
      ..on<PostDeletedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id) {
          Future.delayed(const Duration(milliseconds: 2200), () {
            Navigator.of(context).pop();
          });
        }
      })
      ..on<PostForwardedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id && this.forwards != null) {
          setState(() {
            this.forwards++;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostForwardDeletedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id && this.forwards != null) {
          setState(() {
            this.forwards--;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostCommentedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id && this.comments != null) {
          setState(() {
            this.comments++;
          });
          commentListInPostController.reload();
        }
      })
      ..on<PostCommentDeletedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id && this.comments != null) {
          setState(() {
            this.comments--;
          });
          commentListInPostController.reload();
        }
      })
      ..on<ForwardInPostUpdatedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id && this.forwards != null) {
          if (event.count < this.forwards) {
            Instances.eventBus.fire(PostForwardDeletedEvent(widget.post.id, event.count));
          }
          setState(() {
            this.forwards = event.count;
          });
        }
      })
      ..on<CommentInPostUpdatedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id && this.comments != null) {
          setState(() {
            this.comments = event.count;
          });
        }
      })
      ..on<PraiseInPostUpdatedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id && this.praises != null) {
          setState(() {
            this.praises = event.count;
          });
        }
      });
  }

  void setTabIndex(index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void setCurrentTabActive(context, index, tab) {
    setState(() {
      _tabIndex = index;

      forwardsColor = tab == 'forwards' ? activeColor : Theme.of(context).cardColor;
      commentsColor = tab == 'comments' ? activeColor : Theme.of(context).cardColor;
      praisesColor = tab == 'praises' ? activeColor : Theme.of(context).cardColor;

      forwardsStyle = tab == 'forwards' ? textActiveStyle : textInActiveStyle;
      commentsStyle = tab == 'comments' ? textActiveStyle : textInActiveStyle;
      praisesStyle = tab == 'praises' ? textActiveStyle : textInActiveStyle;
    });
  }

  Widget get postCard => PostCard(
        widget.post,
        index: widget.index,
        fromPage: widget.fromPage,
        isDetail: true,
        parentContext: widget.parentContext,
        key: ValueKey('post-key-${widget.post.id}'),
      );

  Widget get deleteButton => IconButton(
        icon: Icon(Icons.delete_outline, size: suSetWidth(30.0)),
        onPressed: () => confirmDelete(context),
      );

  Widget get postActionButton => IconButton(
        icon: Icon(Icons.more_horiz, size: suSetWidth(30.0)),
        onPressed: () => postExtraActions(context),
      );

  void confirmDelete(context) async {
    final confirm = await ConfirmationDialog.show(
      context,
      title: '删除动态',
      content: '是否确认删除这条动态?',
      showConfirm: true,
    );
    if (confirm) {
      final _loadingDialogController = LoadingDialogController();
      LoadingDialog.show(
        context,
        controller: _loadingDialogController,
        text: '正在删除动态',
        isGlobal: false,
      );
      PostAPI.deletePost(widget.post.id).then((response) {
        _loadingDialogController.changeState('success', '动态删除成功');
        Instances.eventBus.fire(PostDeletedEvent(widget.post.id, widget.fromPage, widget.index));
      }).catchError((e) {
        debugPrint(e.toString());
        debugPrint(e.response?.toString());
        _loadingDialogController.changeState('failed', '动态删除失败');
      });
    }
  }

  void postExtraActions(context) {
    ConfirmationBottomSheet.show(
      context,
      children: <Widget>[
        ConfirmationBottomSheetAction(
          icon: Icon(Icons.visibility_off),
          text: '屏蔽此人',
          onTap: () => confirmBlock(context),
        ),
        ConfirmationBottomSheetAction(
          icon: Icon(Icons.report),
          text: '举报动态',
          onTap: () => confirmReport(context),
        ),
      ],
    );
  }

  void confirmBlock(context) async {
    final confirm = await ConfirmationDialog.show(
      context,
      title: '屏蔽此人',
      content: '确定屏蔽此人吗',
      showConfirm: true,
    );
    if (confirm) {
      UserAPI.fAddToBlacklist(uid: widget.post.uid, name: widget.post.nickname);
    }
  }

  void confirmReport(context) async {
    final confirm = await ConfirmationDialog.show(
      context,
      title: '举报动态',
      content: '确定举报该条动态吗?',
      showConfirm: true,
    );
    if (confirm) {
      final provider = Provider.of<ReportRecordsProvider>(context, listen: false);
      final canReport = await provider.addRecord(widget.post.id);
      if (canReport) {
        PostAPI.reportPost(widget.post);
        showToast('举报成功');
        navigatorState.pop();
      }
    }
  }

  Widget get actionLists => Container(
        width: Screens.width,
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.symmetric(horizontal: suSetSp(16.0)),
        child: Row(
          children: <Widget>[
            MaterialButton(
              color: forwardsColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              minWidth: suSetWidth(sectionButtonWidth),
              shape: sectionButtonShape,
              child: Text('转发 $forwards', style: forwardsStyle),
              onPressed: () {
                setCurrentTabActive(context, 0, 'forwards');
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            MaterialButton(
              color: commentsColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              minWidth: suSetWidth(sectionButtonWidth),
              shape: sectionButtonShape,
              child: Text('评论 $comments', style: commentsStyle),
              onPressed: () {
                setCurrentTabActive(context, 1, 'comments');
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(child: Container()),
            MaterialButton(
              color: praisesColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              minWidth: suSetWidth(sectionButtonWidth),
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

  Widget get toolbar => Container(
        height: Screens.bottomSafeHeight + suSetHeight(70.0),
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
                    Routes.OPENJMU_ADD_FORWARD,
                    arguments: {'post': widget.post},
                  );
                },
                icon: SvgPicture.asset(
                  'assets/icons/postActions/forward-fill.svg',
                  color: Theme.of(context).textTheme.body1.color,
                  width: suSetWidth(iconSize),
                ),
                label: Text(
                  '转发',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: suSetSp(actionFontSize),
                      ),
                ),
                splashColor: Colors.grey,
              ),
            ),
            Expanded(
              child: FlatButton.icon(
                onPressed: () {
                  navigatorState.pushNamed(
                    Routes.OPENJMU_ADD_COMMENT,
                    arguments: {'post': widget.post},
                  );
                },
                icon: SvgPicture.asset(
                  'assets/icons/postActions/comment-fill.svg',
                  color: Theme.of(context).textTheme.body1.color,
                  width: suSetWidth(iconSize),
                ),
                label: Text(
                  '评论',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: suSetSp(actionFontSize),
                      ),
                ),
                splashColor: Colors.grey,
              ),
            ),
            Expanded(
              child: LikeButton(
                size: suSetWidth(iconSize),
                circleColor: CircleColor(
                  start: currentThemeColor,
                  end: currentThemeColor,
                ),
                countBuilder: (int count, bool isLiked, String text) => Text(
                  count > 0 ? text : '赞',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        color:
                            isLiked ? currentThemeColor : Theme.of(context).textTheme.body1.color,
                        fontSize: suSetSp(actionFontSize),
                      ),
                ),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: currentThemeColor,
                  dotSecondaryColor: currentThemeColor,
                ),
                likeBuilder: (bool isLiked) => SvgPicture.asset(
                  'assets/icons/postActions/praise-fill.svg',
                  color: isLiked ? currentThemeColor : Theme.of(context).textTheme.body1.color,
                  width: suSetWidth(iconSize),
                ),
                likeCount: widget.post.isLike ? moreThanOne(praises) : moreThanZero(praises),
                likeCountAnimationType: LikeCountAnimationType.none,
                likeCountPadding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(10.0),
                  vertical: suSetHeight(12.0),
                ),
                isLiked: widget.post.isLike,
                onTap: onLikeButtonTap,
              ),
            ),
          ],
        ),
      );

  Future<bool> onLikeButtonTap(bool isLiked) {
    final Completer<bool> completer = Completer<bool>();
    int id = widget.post.id;

    widget.post.isLike = !widget.post.isLike;
    !isLiked ? widget.post.praises++ : widget.post.praises--;
    completer.complete(!isLiked);

    PraiseAPI.requestPraise(id, !isLiked).then((response) {
      Instances.eventBus.fire(PraiseInPostUpdatedEvent(
        postId: widget.post.id,
        count: praises,
        type: 'square',
        isLike: !isLiked,
      ));
    }).catchError((e) {
      isLiked ? widget.post.praises++ : widget.post.praises--;
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: Text('动态正文'),
            actions: <Widget>[
              widget.post.uid == currentUser.uid ? deleteButton : postActionButton,
            ],
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: NestedScrollView(
                physics: const ClampingScrollPhysics(),
                headerSliverBuilder: (_, __) => [
                  SliverToBoxAdapter(child: _post),
                  SliverPersistentHeader(
                    delegate: CommonSliverPersistentHeaderDelegate(
                      child: actionLists,
                      height: suSetHeight(74.0),
                    ),
                    pinned: true,
                  ),
                ],
                body: IndexedStack(
                  index: _tabIndex,
                  children: <Widget>[_forwardsList, _commentsList, _praisesList],
                ),
              ),
            ),
          ),
          toolbar,
        ],
      ),
    );
  }
}

class CommonSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  CommonSliverPersistentHeaderDelegate({
    @required this.child,
    @required this.height,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(CommonSliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
