import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

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

  final ScrollController _scrollController = new ScrollController();

  Widget _forwardsList;
  Widget _commentsList;
  Widget _praisesList;
//  Comment _replyToComment;
//  String _replyToPrefix;

  int _tabIndex = 1;
  Widget _post;
  bool isLike;
  int forwards, comments, praises;
  bool _forwarding = false;
  bool _commenting = false;
  bool _forwardVisible = false;
  bool _commentVisible = false;
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

  Color forwardsColor, commentsColor, praisesColor;
  Color activeColor = ThemeUtils.currentColorTheme;
  Color inActiveColor = ThemeUtils.currentCardColor;


  TextEditingController _forwardController = new TextEditingController();
  TextEditingController _commentController = new TextEditingController();
  String _forwardContent = "";
  String _commentContent = "";

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

    _forwardController..addListener(() {
      setState(() {
        _forwardContent = _forwardController.text;
      });
    });
    _commentController..addListener(() {
      setState(() {
        _commentContent = _commentController.text;
      });
    });

    PostAPI.glancePost(widget.post.id);
    setCurrentTabActive(1, "comments");
    _post = new PostCard(widget.post, isDetail: true);
  }

  @override
  void dispose() {
    super.dispose();
    _forwardController.dispose();
    _commentController.dispose();
    _post = null;
  }

  void _requestData() {
    setState(() {
      _forwardsList = new PostInPostList(widget.post);
      _commentsList = new CommentInPostList(widget.post);
      _praisesList = new PraiseInPostList(widget.post);
    });
  }

//  void initialReplyToComment(Comment comment) {
//    setState(() {
//      _replyToComment = comment;
//      _replyToPrefix = "回复:@${comment.fromUserName} ";
//    });
//  }

//  void replyToComment(Comment comment) {
//    print("回复:<M ${comment.fromUserUid}>@${comment.fromUserName}</M> ");
//  }

  void setTabIndex(index) {
    setState(() {
      this._tabIndex = index;
    });
  }

  void setCurrentTabActive(index, tab) {
    setState(() {
      _tabIndex = index;

      forwardsColor = tab == "forwards" ? activeColor : inActiveColor;
      commentsColor = tab == "comments" ? activeColor : inActiveColor;
      praisesColor  = tab == "praises" ? activeColor : inActiveColor;

      forwardsStyle = tab == "forwards" ? textActiveStyle : textInActiveStyle;
      commentsStyle = tab == "comments" ? textActiveStyle : textInActiveStyle;
      praisesStyle  = tab == "praises" ? textActiveStyle : textInActiveStyle;
    });
  }

  Widget actionLists() {
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
                    onPressed: () { setCurrentTabActive(0, "forwards"); },
                  ),
                  MaterialButton(
                    color: commentsColor,
                    minWidth: 10.0,
                    elevation: 0,
                    child: Text("评论 $comments", style: commentsStyle),
                    onPressed: () { setCurrentTabActive(1, "comments"); },
                  ),
                  Expanded(child: Container()),
                  MaterialButton(
                    color: praisesColor,
                    minWidth: 10.0,
                    elevation: 0,
                    child: Text("赞 $praises", style: praisesStyle),
                    onPressed: () { setCurrentTabActive(2, "praises"); },
                  ),
                ]
            )
          ],
        )
    );
  }

  void _requestForward() {
    setState(() {
      _forwarding = true;
    });
    PostAPI.postForward(
        _forwardController.text,
        widget.post.id,
        commentAtTheMeanTime
    ).then((response) {
      showShortToast("转发成功");
      setState(() {
        forwards++;
        _forwarding = false;
        _forwardVisible = false;
        _forwardsList = new Container();
        new Timer(const Duration(milliseconds: 50), () {
          _forwardsList = new PostInPostList(widget.post);
        });
      });
    });
  }

  void _requestComment() {
    setState(() {
      _commenting = true;
    });
    CommentAPI.postComment(
        _commentController.text,
        widget.post.id,
        forwardAtTheMeanTime
    ).then((response) {
      showShortToast("评论成功");
      setState(() {
        comments++;
        _commenting = false;
        _commentVisible = false;
        _commentsList = new Container();
        new Timer(const Duration(milliseconds: 50), () {
          _commentsList = new CommentInPostList(widget.post);
        });
      });
    });
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
                          color: ThemeUtils.currentCardColor,
                          child: FlatButton.icon(
                            onPressed: () {
                              setState(() {
                                _forwardVisible = true;
                              });
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
                          color: ThemeUtils.currentCardColor,
                          child: FlatButton.icon(
                            onPressed: () {
                              setState(() {
                                _commentVisible = true;
                              });
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
                          color: ThemeUtils.currentCardColor,
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
                  color: ThemeUtils.currentCardColor
              )
            ]
        )
    );
  }
  Positioned forwardTextField() {
    return Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Visibility(
            visible: _forwardVisible,
            child: Container(
                padding: EdgeInsets.all(10.0),
                color: ThemeUtils.currentCardColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                        controller: _forwardController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_forwarding,
                        style: TextStyle(fontSize: 18.0),
                        autofocus: true,
                        maxLines: 3,
                        maxLength: 140
                    ),
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
                              onPressed: _forwardContent.length > 0 ? _requestForward : null,
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
    );
  }
  Positioned commentTextField() {
    return Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Visibility(
            visible: _commentVisible,
            child: Container(
                padding: EdgeInsets.all(10.0),
                color: ThemeUtils.currentCardColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          border: OutlineInputBorder(),
//                          prefixText: _replyToPrefix ?? null
                        ),
                        enabled: !_commenting,
                        style: TextStyle(fontSize: 18.0),
                        cursorColor: ThemeUtils.currentColorTheme,
                        autofocus: true,
                        maxLines: 3,
                        maxLength: 140
                    ),
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
                                  onPressed: _commentContent.length > 0 ? _requestComment : null,
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
    );
  }
  Positioned backdrop() {
    return Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        height: MediaQuery.of(context).size.height,
        child: Visibility(
            visible: _forwardVisible || _commentVisible,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    _forwardVisible = false;
                    _commentVisible = false;
                  });
                },
                child: Container(
                  color: Color.fromRGBO(0,0,0,0.5),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                )
            )
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
//          RefreshIndicator(
            SingleChildScrollView(
//                controller: _scrollController,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _post,
                                actionLists(),
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
//            onRefresh: () {},
          ),
          toolbar(context),
          backdrop(),
          forwardTextField(),
          commentTextField(),
        ],
      ),
    );
  }
}
