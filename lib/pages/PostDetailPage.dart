import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/model/PraiseController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/cards/PostCard.dart';
import 'package:OpenJMU/widgets/dialogs/ForwardPositioned.dart';
import 'package:OpenJMU/widgets/dialogs/CommentPositioned.dart';


class PostDetailPage extends StatefulWidget {
    final Post post;
    final int index;
    final String fromPage;
    final BuildContext beforeContext;
    PostDetailPage(this.post, {this.index, this.fromPage, this.beforeContext, Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() {
        return new PostDetailPageState();
    }
}

class PostDetailPageState extends State<PostDetailPage> {
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

    TextStyle textActiveStyle = TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
    );
    TextStyle textInActiveStyle = TextStyle(
        color: Colors.grey,
        fontSize: 16.0,
    );

    Color forwardsColor, commentsColor = ThemeUtils.currentColorTheme, praisesColor;
    Color activeColor = ThemeUtils.currentColorTheme;

    ForwardInPostController forwardInPostController = new ForwardInPostController();
    CommentInPostController commentInPostController = new CommentInPostController();
    PraiseInPostController praiseInPostController = new PraiseInPostController();

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
        setCurrentTabActive(widget.beforeContext, 1, "comments");
        PostAPI.glancePost(widget.post.id);
        _post = new PostCard(widget.post, index: widget.index, fromPage: widget.fromPage, isDetail: true);

        Constants.eventBus.on<PostDeletedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id) {
                Future.delayed(Duration(milliseconds: 2200), () { Navigator.of(context).pop(); });
            }
        });
        Constants.eventBus.on<PostForwardedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id && this.forwards != null) {
                setState(() { this.forwards++; });
                forwardInPostController.reload();
            }
        });
        Constants.eventBus.on<PostForwardDeletedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id && this.forwards != null) {
                setState(() { this.forwards--; });
                forwardInPostController.reload();
            }
        });
        Constants.eventBus.on<PostCommentedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id && this.comments != null) {
                setState(() { this.comments++; });
                commentInPostController.reload();
            }
        });
        Constants.eventBus.on<PostCommentDeletedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id && this.comments != null) {
                setState(() { this.comments--; });
                commentInPostController.reload();
            }
        });
        Constants.eventBus.on<ForwardInPostUpdatedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id && this.forwards != null) {
                if (event.count < this.forwards) {
                    Constants.eventBus.fire(new PostForwardDeletedEvent(widget.post.id, event.count));
                }
                setState(() { this.forwards = event.count; });
            }
        });
        Constants.eventBus.on<CommentInPostUpdatedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id && this.comments != null) {
                setState(() { this.comments = event.count; });
            }
        });
        Constants.eventBus.on<PraiseInPostUpdatedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id && this.praises != null) {
                setState(() { this.praises = event.count; });
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
            _forwardsList = new ForwardInPostList(widget.post, forwardInPostController);
            _commentsList = new CommentInPostList(widget.post, commentInPostController);
            _praisesList = new PraiseInPostList(widget.post, praiseInPostController);
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

            forwardsColor = tab == "forwards" ? activeColor : Theme.of(context).cardColor;
            commentsColor = tab == "comments" ? activeColor : Theme.of(context).cardColor;
            praisesColor  = tab == "praises" ? activeColor : Theme.of(context).cardColor;

            forwardsStyle = tab == "forwards" ? textActiveStyle : textInActiveStyle;
            commentsStyle = tab == "comments" ? textActiveStyle : textInActiveStyle;
            praisesStyle  = tab == "praises" ? textActiveStyle : textInActiveStyle;
        });
    }

    Widget actionLists(context) {
        return new Container(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.only(top: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Row(
                        children: <Widget>[
                            MaterialButton(
                                color: forwardsColor,
                                minWidth: 10.0,
                                elevation: 0,
                                child: Text("转发 $forwards", style: forwardsStyle),
                                onPressed: () { setCurrentTabActive(context, 0, "forwards"); },
                            ),
                            MaterialButton(
                                color: commentsColor,
                                minWidth: 10.0,
                                elevation: 0,
                                child: Text("评论 $comments", style: commentsStyle),
                                onPressed: () { setCurrentTabActive(context, 1, "comments"); },
                            ),
                            Expanded(child: Container()),
                            MaterialButton(
                                color: praisesColor,
                                minWidth: 10.0,
                                elevation: 0,
                                child: Text("赞 $praises", style: praisesStyle),
                                onPressed: () { setCurrentTabActive(context, 2, "praises"); },
                            ),
                        ],
                    ),
                ],
            ),
        );
    }

    void _requestPraise() {
        print("Request praise: ${widget.post.id}");
        bool _l = isLike;
        setState(() {
            if (isLike) {
                praises--;
            } else {
                praises++;
            }
            this.isLike = !isLike;
        });
        PraiseAPI.requestPraise(widget.post.id, !_l).then((response) {
            Constants.eventBus.fire(
                new PraiseInPostUpdatedEvent(
                    widget.post.id,
                    praises,
                    isLike: !_l,
                ),
            );
        }).catchError((e) {
            setState(() {
                if (isLike) {
                    praises++;
                } else {
                    praises--;
                }
                this.isLike = _l;
            });
        });
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
                                flex: 1,
                                child: Container(
                                    color: Theme.of(context).cardColor,
                                    child: FlatButton.icon(
                                        onPressed: () {
                                            showDialog<Null>(
                                                context: context,
                                                builder: (BuildContext context) => ForwardPositioned(widget.post),
                                            );
                                        },
                                        icon: Icon(
                                            Icons.launch,
                                            color: Theme.of(context).textTheme.title.color,
                                            size: 24,
                                        ),
                                        label: Text("转发", style: TextStyle(
                                            color: Theme.of(context).textTheme.title.color,
                                        )),
                                        splashColor: Colors.grey,
                                    ),
                                ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    color: Theme.of(context).cardColor,
                                    child: FlatButton.icon(
                                        onPressed: () {
                                            showDialog<Null>(
                                                context: context,
                                                builder: (BuildContext context) => CommentPositioned(widget.post),
                                            );
                                        },
                                        icon: Icon(
                                            Platform.isAndroid ? Icons.comment : Foundation.getIconData("comment"),
                                            color: Theme.of(context).textTheme.title.color,
                                            size: 24,
                                        ),
                                        label: Text("评论", style: TextStyle(
                                            color: Theme.of(context).textTheme.title.color,
                                        )),
                                        splashColor: Colors.grey,
                                    ),
                                ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    color: Theme.of(context).cardColor,
                                    child: FlatButton.icon(
                                        onPressed: _requestPraise,
                                        icon: Icon(
                                            Platform.isAndroid ? Icons.thumb_up : Ionicons.getIconData("ios-thumbs-up"),
                                            color: isLike
                                                    ? ThemeUtils.currentColorTheme
                                                    : Theme.of(context).textTheme.title.color,
                                            size: 24,
                                        ),
                                        label: Text("赞", style: TextStyle(
                                            color: isLike
                                                    ? ThemeUtils.currentColorTheme
                                                    : Theme.of(context).textTheme.title.color,
                                        )),
                                        splashColor: Colors.grey,
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

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: ThemeUtils.currentColorTheme,
                title: Text(
                    "动态正文",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Theme.of(context).textTheme.title.fontSize,
                    ),
                ),
                centerTitle: true,
            ),
            body: Column(
                children: <Widget>[
                    Expanded(
                        child: RefreshIndicator(
                            onRefresh: () {},
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
                                                                _forwardsList,
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
                    ),
                    toolbar(context),
                ],
            ),
        );
    }
}
