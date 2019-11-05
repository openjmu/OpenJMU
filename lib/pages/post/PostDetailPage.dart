import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/cards/PostCard.dart';
import 'package:OpenJMU/widgets/dialogs/ForwardPositioned.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final int index;
  final String fromPage;
  final BuildContext parentContext;

  const PostDetailPage(
    this.post, {
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

  final textActiveStyle = TextStyle(
    color: Colors.white,
    fontSize: Constants.suSetSp(16.0),
    fontWeight: FontWeight.bold,
  );
  final textInActiveStyle = TextStyle(
    color: Colors.grey,
    fontSize: Constants.suSetSp(16.0),
  );

  Widget _forwardsList;
  Widget _commentsList;
  Widget _praisesList;

  int _tabIndex = 1;
  Widget _post;
  bool isLike;
  int forwards, comments, praises;
  bool forwardAtTheMeanTime = false;
  bool commentAtTheMeanTime = false;

  TextStyle forwardsStyle, commentsStyle, praisesStyle;

  double iconSize = 20.0;
  double actionFontSize = 17.0;

  Color forwardsColor,
      commentsColor = ThemeUtils.currentThemeColor,
      praisesColor;
  Color activeColor = ThemeUtils.currentThemeColor;

  @override
  void initState() {
    super.initState();
    setState(() {
      forwards = widget.post.forwards;
      comments = widget.post.comments;
      praises = widget.post.praises;
      isLike = widget.post.isLike;
    });
    _requestData();
    setCurrentTabActive(widget.parentContext, 1, "comments");
    PostAPI.glancePost(widget.post.id);
    _post = PostCard(
      widget.post,
      index: widget.index,
      fromPage: widget.fromPage,
      isDetail: true,
      parentContext: widget.parentContext,
      key: ValueKey("post-key-${widget.post.id}"),
    );

    Instances.eventBus
      ..on<PostDeletedEvent>().listen((event) {
        if (this.mounted && event.postId == widget.post.id) {
          Future.delayed(Duration(milliseconds: 2200), () {
            Navigator.of(context).pop();
          });
        }
      })
      ..on<PostForwardedEvent>().listen((event) {
        if (this.mounted &&
            event.postId == widget.post.id &&
            this.forwards != null) {
          setState(() {
            this.forwards++;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostForwardDeletedEvent>().listen((event) {
        if (this.mounted &&
            event.postId == widget.post.id &&
            this.forwards != null) {
          setState(() {
            this.forwards--;
          });
          forwardListInPostController.reload();
        }
      })
      ..on<PostCommentedEvent>().listen((event) {
        if (this.mounted &&
            event.postId == widget.post.id &&
            this.comments != null) {
          setState(() {
            this.comments++;
          });
          commentListInPostController.reload();
        }
      })
      ..on<PostCommentDeletedEvent>().listen((event) {
        if (this.mounted &&
            event.postId == widget.post.id &&
            this.comments != null) {
          setState(() {
            this.comments--;
          });
          commentListInPostController.reload();
        }
      })
      ..on<ForwardInPostUpdatedEvent>().listen((event) {
        if (this.mounted &&
            event.postId == widget.post.id &&
            this.forwards != null) {
          if (event.count < this.forwards) {
            Instances.eventBus
                .fire(PostForwardDeletedEvent(widget.post.id, event.count));
          }
          setState(() {
            this.forwards = event.count;
          });
        }
      })
      ..on<CommentInPostUpdatedEvent>().listen((event) {
        if (this.mounted &&
            event.postId == widget.post.id &&
            this.comments != null) {
          setState(() {
            this.comments = event.count;
          });
        }
      })
      ..on<PraiseInPostUpdatedEvent>().listen((event) {
        if (this.mounted &&
            event.postId == widget.post.id &&
            this.praises != null) {
          setState(() {
            this.praises = event.count;
          });
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
    _post = null;
  }

  void _requestData() {
    setState(() {
      _forwardsList =
          ForwardListInPost(widget.post, forwardListInPostController);
      _commentsList =
          CommentListInPost(widget.post, commentListInPostController);
      _praisesList = PraiseListInPost(widget.post);
    });
  }

  void setTabIndex(index) {
    setState(() {
      this._tabIndex = index;
    });
  }

  void setCurrentTabActive(context, index, tab) {
    setState(() {
      _tabIndex = index;

      forwardsColor =
          tab == "forwards" ? activeColor : Theme.of(context).cardColor;
      commentsColor =
          tab == "comments" ? activeColor : Theme.of(context).cardColor;
      praisesColor =
          tab == "praises" ? activeColor : Theme.of(context).cardColor;

      forwardsStyle = tab == "forwards" ? textActiveStyle : textInActiveStyle;
      commentsStyle = tab == "comments" ? textActiveStyle : textInActiveStyle;
      praisesStyle = tab == "praises" ? textActiveStyle : textInActiveStyle;
    });
  }

  Widget actionLists(context) {
    return Container(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.only(top: Constants.suSetSp(4.0)),
      padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              MaterialButton(
                color: forwardsColor,
                minWidth: Constants.suSetSp(10.0),
                elevation: 0,
                child: Text("转发 $forwards", style: forwardsStyle),
                onPressed: () {
                  setCurrentTabActive(context, 0, "forwards");
                },
              ),
              MaterialButton(
                color: commentsColor,
                minWidth: Constants.suSetSp(10.0),
                elevation: 0,
                child: Text("评论 $comments", style: commentsStyle),
                onPressed: () {
                  setCurrentTabActive(context, 1, "comments");
                },
              ),
              Expanded(child: Container()),
              MaterialButton(
                color: praisesColor,
                minWidth: Constants.suSetSp(10.0),
                elevation: 0,
                child: Text("赞 $praises", style: praisesStyle),
                onPressed: () {
                  setCurrentTabActive(context, 2, "praises");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget toolbar(context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: FlatButton.icon(
                    onPressed: () {
                      showDialog<Null>(
                        context: context,
                        builder: (BuildContext context) =>
                            ForwardPositioned(widget.post),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/postActions/forward-line.svg",
                      color: Theme.of(context).textTheme.body1.color,
                      width: Constants.suSetSp(iconSize),
                      height: Constants.suSetSp(iconSize),
                    ),
                    label: Text(
                      "转发",
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: Constants.suSetSp(actionFontSize),
                          ),
                    ),
                    splashColor: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: FlatButton.icon(
                    onPressed: () {
                      showDialog<Null>(
                        context: context,
                        builder: (BuildContext context) => CommentPositioned(
                          post: widget.post,
                          postType: PostType.square,
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/postActions/comment-line.svg",
                      color: Theme.of(context).textTheme.body1.color,
                      width: Constants.suSetSp(iconSize),
                      height: Constants.suSetSp(iconSize),
                    ),
                    label: Text(
                      "评论",
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: Constants.suSetSp(actionFontSize),
                          ),
                    ),
                    splashColor: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: LikeButton(
                    size: Constants.suSetSp(iconSize),
                    circleColor: CircleColor(
                      start: ThemeUtils.currentThemeColor,
                      end: ThemeUtils.currentThemeColor,
                    ),
                    countBuilder: (int count, bool isLiked, String text) =>
                        Text(
                      count == 0 ? "赞" : text,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            color: isLiked
                                ? ThemeUtils.currentThemeColor
                                : Theme.of(context).textTheme.body1.color,
                            fontSize: Constants.suSetSp(actionFontSize),
                          ),
                    ),
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: ThemeUtils.currentThemeColor,
                      dotSecondaryColor: ThemeUtils.currentThemeColor,
                    ),
                    likeBuilder: (bool isLiked) => SvgPicture.asset(
                      "assets/icons/postActions/thumbUp-${isLiked ? "fill" : "line"}.svg",
                      color: isLiked
                          ? ThemeUtils.currentThemeColor
                          : Theme.of(context).textTheme.body1.color,
                      width: Constants.suSetSp(iconSize),
                      height: Constants.suSetSp(iconSize),
                    ),
                    likeCount: praises,
                    likeCountAnimationType: LikeCountAnimationType.none,
                    likeCountPadding: EdgeInsets.symmetric(
                      horizontal: Constants.suSetSp(4.0),
                      vertical: Constants.suSetSp(12.0),
                    ),
                    isLiked: widget.post.isLike,
                    onTap: onLikeButtonTap,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).padding.bottom ?? 0,
            color: Theme.of(context).cardColor,
          ),
        ],
      ),
    );
  }

  Future<bool> onLikeButtonTap(bool isLiked) {
    final Completer<bool> completer = Completer<bool>();
    int id = widget.post.id;

    widget.post.isLike = !widget.post.isLike;
    !isLiked ? widget.post.praises++ : widget.post.praises--;
    completer.complete(!isLiked);

    PraiseAPI.requestPraise(id, !isLiked).then((response) {
      Instances.eventBus.fire(PraiseInPostUpdatedEvent(
        id: widget.post.id,
        count: praises,
        type: "square",
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
      appBar: AppBar(
        title: Text(
          "动态正文",
          style: Theme.of(context).textTheme.title.copyWith(
                fontSize: Constants.suSetSp(21.0),
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                _post,
                actionLists(context),
                IndexedStack(
                  children: <Widget>[
                    _forwardsList,
                    _commentsList,
                    _praisesList,
                  ],
                  index: _tabIndex,
                ),
              ],
            ),
          ),
          toolbar(context),
        ],
      ),
    );
  }
}
