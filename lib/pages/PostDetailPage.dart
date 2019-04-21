import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/model/PraiseController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/cards/PostCard.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  PostDetailPage(this.post, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PostDetailPageState();
  }
}

class PostDetailPageState extends State<PostDetailPage> {
  Timer deleteTimer;

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
      fontWeight: FontWeight.bold
  );
  TextStyle textInActiveStyle = TextStyle(
      color: Colors.grey,
      fontSize: 16.0
  );

  Color forwardsColor, commentsColor = ThemeUtils.currentColorTheme, praisesColor;
  Color activeColor = ThemeUtils.currentColorTheme;

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

    PostAPI.glancePost(widget.post.id);
    _post = new PostCard(widget.post, isDetail: true);

    Constants.eventBus.on<PostDeletedEvent>().listen((event) {
      if (event.postId == widget.post.id) {
        deleteTimer = Timer(Duration(milliseconds: 2100), () { Navigator.of(context).pop(); });
      }
    });
  }

  @override
  void dispose() {
    _post = null;
    deleteTimer?.cancel();
    super.dispose();
  }

  void _requestData() {
    setState(() {
      _forwardsList = new ForwardInPostList(widget.post);
      _commentsList = new CommentInPostList(widget.post);
      _praisesList = new PraiseInPostList(widget.post);
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
                ]
            )
          ],
        )
    );
  }

  void _requestPraise() {
    bool _l = isLike;
    setState(() {
      if (isLike) {
        praises--;
      } else {
        praises++;
      }
      this.isLike = !isLike;
    });
    PraiseAPI.requestPraise(widget.post.id, !_l).catchError((e) {
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

  Positioned toolbar(context) {
    return Positioned(
        bottom: MediaQuery.of(context).padding.bottom ?? 0,
        left: 0.0,
        right: 0.0,
        child: Column(
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
                                builder: (BuildContext context) => ForwardPositioned(widget.post)
                              );
                            },
                            icon: Icon(
                              Icons.launch,
                              color: Theme.of(context).textTheme.title.color,
                              size: 24,
                            ),
                            label: Text("转发", style: TextStyle(
                                color: Theme.of(context).textTheme.title.color
                            )),
                            splashColor: Colors.grey,
                          )
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          color: Theme.of(context).cardColor,
                          child: FlatButton.icon(
                            onPressed: () {
                              showDialog<Null>(
                                  context: context,
                                  builder: (BuildContext context) => CommentPositioned(widget.post)
                              );
                            },
                            icon: Icon(
                              Icons.comment,
                              color: Theme.of(context).textTheme.title.color,
                              size: 24,
                            ),
                            label: Text("评论", style: TextStyle(
                              color: Theme.of(context).textTheme.title.color,
                            )),
                            splashColor: Colors.grey,
                          )
                      )
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                          color: Theme.of(context).cardColor,
                          child: FlatButton.icon(
                            onPressed: _requestPraise,
                            icon: Icon(
                              Icons.thumb_up,
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
                          )
                      )
                  ),
                ],
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).padding.bottom ?? 0,
                color: Theme.of(context).cardColor,
              )
            ]
        )
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
                fontSize: Theme.of(context).textTheme.title.fontSize
            )
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
            RefreshIndicator(
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
                            )
                        )
                      ],
                    ),
                    Container(height: 56.0),
                  ],
                ),
          ),
          toolbar(context),
        ],
      ),
    );
  }
}

class ForwardPositioned extends StatefulWidget {
  final Post post;

  ForwardPositioned(this.post, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ForwardPositionedState();

}

class ForwardPositionedState extends State<ForwardPositioned> {
  final TextEditingController _forwardController = new TextEditingController();

  bool _forwarding = false;
  bool commentAtTheMeanTime = false;

  @override
  void dispose() {
    super.dispose();
    _forwardController?.dispose();
  }

  Widget textField() {
    return TextField(
        controller: _forwardController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12.0),
          border: OutlineInputBorder(),
        ),
        enabled: !_forwarding,
        style: TextStyle(fontSize: 18.0),
        cursorColor: ThemeUtils.currentColorTheme,
        autofocus: true,
        maxLines: 3,
        maxLength: 140
    );
  }

  void _requestForward(context) {
    setState(() {
      _forwarding = true;
    });
    String _content;
    if (_forwardController.text.length == 0) {
      _content = "转发";
    } else {
      _content = _forwardController.text;
    }
    PostAPI.postForward(
        _content,
        widget.post.id,
        commentAtTheMeanTime
    ).then((response) {
      showShortToast("转发成功");
      setState(() {
        _forwarding = false;
      });
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Stack(
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.of(context).pop()),
          Positioned(
            /// viewInsets for keyboard pop up, padding bottom for iOS navigator.
              bottom: MediaQuery.of(context).viewInsets.bottom ?? MediaQuery.of(context).padding.bottom ?? 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      textField(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                  activeColor: ThemeUtils.currentColorTheme,
                                  value: commentAtTheMeanTime,
                                  onChanged: (value) {
                                    setState(() {
                                      commentAtTheMeanTime = value;
                                    });
                                  }
                              ),
                              Text("同时评论到微博", style: TextStyle(fontSize: 16.0)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              new IconButton(
                                  onPressed: null,
                                  icon: new Icon(Icons.alternate_email)
                              ),
                              new IconButton(
                                  onPressed: null,
                                  icon: new Icon(Icons.mood)
                              ),
                              !_forwarding
                                  ? IconButton(
                                icon: Icon(Icons.send),
                                color: ThemeUtils.currentColorTheme,
                                onPressed: () => _requestForward(context),
                              )
                                  : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                                  child: SizedBox(
                                      width: 18.0,
                                      height: 18.0,
                                      child: CircularProgressIndicator(strokeWidth: 2.0)
                                  )
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  )
              )
          )
        ],
      ),
    );
  }
}

class CommentPositioned extends StatefulWidget {
  final Post post;
  final Comment comment;

  CommentPositioned(this.post, {this.comment, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CommentPositionedState();

}

class CommentPositionedState extends State<CommentPositioned> {
  final TextEditingController _commentController = new TextEditingController();

  Comment toComment;

  bool _commenting = false;
  bool forwardAtTheMeanTime = false;

  String commentContent = "";

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) setState(() {
      toComment = widget.comment;
    });
    _commentController..addListener(() {
      setState(() {
        commentContent = _commentController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _commentController?.dispose();
  }

  Widget textField() {
    String _prefixText;
    toComment != null ? _prefixText = "回复:@${toComment.fromUserName} " : _prefixText = null;
    return TextField(
        controller: _commentController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12.0),
          border: OutlineInputBorder(),
          prefixText: _prefixText
        ),
        enabled: !_commenting,
        style: TextStyle(fontSize: 18.0),
        cursorColor: ThemeUtils.currentColorTheme,
        autofocus: true,
        maxLines: 3,
        maxLength: 140
    );
  }

  void _requestComment(context) {
    if (commentContent.length <= 0) {
      showCenterErrorShortToast("内容不能为空！");
    } else {
      setState(() {
        _commenting = true;
      });
      if (toComment != null) {
        Comment _c = widget.comment;
        CommentAPI.postComment(
            "回复:<M ${_c.fromUserUid}>@${_c.fromUserName}</M> ${_commentController.text}",
            widget.post.id,
            forwardAtTheMeanTime,
            replyToId: _c.id
        ).then((response) {
          showShortToast("评论成功");
          setState(() {
            _commenting = false;
          });
          Navigator.of(context).pop();
        });
      } else {
        CommentAPI.postComment(
            _commentController.text,
            widget.post.id,
            forwardAtTheMeanTime
        ).then((response) {
          showShortToast("评论成功");
          setState(() {
            _commenting = false;
          });
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Stack(
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.of(context).pop()),
          Positioned(
            /// viewInsets for keyboard pop up, padding bottom for iOS navigator.
              bottom: MediaQuery.of(context).viewInsets.bottom ?? MediaQuery.of(context).padding.bottom ?? 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      textField(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                  activeColor: ThemeUtils.currentColorTheme,
                                  value: forwardAtTheMeanTime,
                                  onChanged: (value) {
                                    setState(() {
                                      forwardAtTheMeanTime = value;
                                    });
                                  }
                              ),
                              Text("同时转发到微博", style: TextStyle(fontSize: 16.0)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              new IconButton(
                                  onPressed: null,
                                  icon: new Icon(Icons.alternate_email)
                              ),
                              new IconButton(
                                  onPressed: null,
                                  icon: new Icon(Icons.mood)
                              ),
                              !_commenting
                                  ? IconButton(
                                icon: Icon(Icons.send),
                                color: ThemeUtils.currentColorTheme,
                                onPressed: () => _requestComment(context),
                              )
                                  : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                                  child: SizedBox(
                                      width: 18.0,
                                      height: 18.0,
                                      child: CircularProgressIndicator(strokeWidth: 2.0)
                                  )
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  )
              )
          )
        ],
      ),
    );
  }
}
