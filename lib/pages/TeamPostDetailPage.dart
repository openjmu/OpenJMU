import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';

import 'package:OpenJMU/api/PraiseAPI.dart';
import 'package:OpenJMU/api/TeamAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/TeamCommentController.dart';
import 'package:OpenJMU/model/TeamPraiseController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/cards/TeamPostCard.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';


class TeamPostDetailPage extends StatefulWidget {
    final Post post;
    final int index;
    final String fromPage;
    final BuildContext beforeContext;
    TeamPostDetailPage(this.post, {this.index, this.fromPage, this.beforeContext, Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => TeamPostDetailPageState();
}

class TeamPostDetailPageState extends State<TeamPostDetailPage> {
    Map<String, dynamic> _detail;
    Widget _commentsList;
    Widget _praisesList;

    int _tabIndex = 0;
    Widget _post;
    bool isLike;
    int comments, praises;
    bool commentAtTheMeanTime = false;

    TextStyle commentsStyle, praisesStyle;

    TextStyle textActiveStyle = TextStyle(
        color: Colors.white,
        fontSize: Constants.suSetSp(16.0),
        fontWeight: FontWeight.bold,
    );
    TextStyle textInActiveStyle = TextStyle(
        color: Colors.grey,
        fontSize: Constants.suSetSp(16.0),
    );

    double iconSize = 20.0;
    double actionFontSize = 17.0;

    Color commentsColor = ThemeUtils.currentThemeColor;
    Color praisesColor;
    Color activeColor = ThemeUtils.currentThemeColor;

    TeamCommentListInPostController _controller = TeamCommentListInPostController();

    @override
    void initState() {
        super.initState();
        setState(() {
            comments = widget.post.comments;
            praises = widget.post.praises;
            isLike = widget.post.isLike;
        });
        _requestData();
        setCurrentTabActive(widget.beforeContext, 0, "comments");
        _post = TeamPostCard(widget.post, index: widget.index, fromPage: widget.fromPage, isDetail: true);

//        Constants.eventBus
//            ..on<PostDeletedEvent>().listen((event) {
//                if (this.mounted && event.postId == widget.post.id) {
//                    Future.delayed(Duration(milliseconds: 2200), () { Navigator.of(context).pop(); });
//                }
//            })
//            ..on<PostCommentedEvent>().listen((event) {
//                if (this.mounted && event.postId == widget.post.id && this.comments != null) {
//                    setState(() { this.comments++; });
//                    commentListInPostController.reload();
//                }
//            })
//            ..on<PostCommentDeletedEvent>().listen((event) {
//                if (this.mounted && event.postId == widget.post.id && this.comments != null) {
//                    setState(() { this.comments--; });
//                    commentListInPostController.reload();
//                }
//            })
//            ..on<CommentInPostUpdatedEvent>().listen((event) {
//                if (this.mounted && event.postId == widget.post.id && this.comments != null) {
//                    setState(() { this.comments = event.count; });
//                }
//            })
//            ..on<PraiseInPostUpdatedEvent>().listen((event) {
//                if (this.mounted && event.postId == widget.post.id && this.praises != null) {
//                    setState(() { this.praises = event.count; });
//                }
//            });
    }

    @override
    void dispose() {
        super.dispose();
        _post = null;
    }

    Future _requestData() async {
        setState(() {
            _commentsList = Container();
            _praisesList = Container();
        });

        _detail = (await TeamPostAPI.getPostDetail(id: widget.post.id))?.data;

        setState(() {
            _commentsList = TeamCommentListInPost(widget.post, _controller);
            _praisesList = TeamPraiseListInPost(_detail['praisor']);
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

            commentsColor = tab == "comments" ? activeColor : Theme.of(context).cardColor;
            praisesColor  = tab == "praises" ? activeColor : Theme.of(context).cardColor;

            commentsStyle = tab == "comments" ? textActiveStyle : textInActiveStyle;
            praisesStyle  = tab == "praises" ? textActiveStyle : textInActiveStyle;
        });
    }

    Widget actionLists(context) {
        return new Container(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.only(top: Constants.suSetSp(4.0)),
            padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0)),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Row(
                        children: <Widget>[
                            MaterialButton(
                                color: commentsColor,
                                minWidth: Constants.suSetSp(10.0),
                                elevation: 0,
                                child: Text("评论 $comments", style: commentsStyle),
                                onPressed: () { setCurrentTabActive(context, 0, "comments"); },
                            ),
                            Expanded(child: Container()),
                            MaterialButton(
                                color: praisesColor,
                                minWidth: Constants.suSetSp(10.0),
                                elevation: 0,
                                child: Text("赞 $praises", style: praisesStyle),
                                onPressed: () { setCurrentTabActive(context, 1, "praises"); },
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
                                                builder: (BuildContext context) => CommentPositioned(widget.post),
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
                                        countBuilder: (int count, bool isLiked, String text) => Text(
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
        final Completer<bool> completer = new Completer<bool>();
        int id = widget.post.id;

        widget.post.isLike = !widget.post.isLike;
        !isLiked ? widget.post.praises++ : widget.post.praises--;
        completer.complete(!isLiked);

        PraiseAPI.requestPraise(id, !isLiked).then((response) {
            Constants.eventBus.fire(PraiseInPostUpdatedEvent(
                id: widget.post.id,
                count: praises,
                type: "team",
                isLike: !isLiked,
            ));
        }).catchError((e) {
            setState(() {
                isLiked ? widget.post.praises++ : widget.post.praises--;
            });
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
                                Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                        Expanded(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                    _post,
                                                    actionLists(context),
                                                    IndexedStack(
                                                        children: <Widget>[
                                                            _commentsList,
                                                            _praisesList,
                                                        ],
                                                        index: _tabIndex,
                                                    )
                                                ],
                                            ),
                                        ),
                                    ],
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
