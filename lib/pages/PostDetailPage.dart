import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/model/PraiseController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
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
  int _tabIndex = 1;
  Widget _post;
  int forwards, comments, praises;
  bool _commentVisible = false;

  TextStyle forwardsStyle, commentsStyle, praisesStyle;

  TextStyle textActiveStyle = TextStyle(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.bold
  );
  TextStyle textInActiveStyle = TextStyle(
      color: Colors.grey,
      fontSize: 18.0
  );

  Color forwardsColor, commentsColor, praisesColor;
  Color activeColor = ThemeUtils.currentColorTheme;
  Color inActiveColor = ThemeUtils.currentCardColor;

  @override
  void initState() {
    super.initState();
    PostAPI.glancePost(widget.post.id);
    setCurrentTabActive(1, "comments");
    setState(() {
      forwards = widget.post.forwards;
      comments = widget.post.comments;
      praises = widget.post.praises;
    });
    _post = new PostCard(widget.post, isDetail: true);
  }

  @override
  void dispose() {
    super.dispose();
    _post = null;
  }

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

  @override
  Widget build(BuildContext context) {
    Color _praisesColor = widget.post.isLike
        ? ThemeUtils.currentColorTheme
        : Theme.of(context).textTheme.title.color
    ;
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: ThemeUtils.currentColorTheme,
        title: new Text(
            "动态正文",
            style: TextStyle(
                color: Colors.white,
                fontSize: Theme.of(context).textTheme.title.fontSize
            )
        ),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new ListView(
            children: <Widget>[
              new Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Expanded(
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _post,
                          actionLists(),
                          new IndexedStack(
                            children: <Widget>[
                              PostInPostList(widget.post),
                              CommentInPostList(widget.post),
                              PraiseInPostList(widget.post),
                            ],
                            index: _tabIndex,
                          )
                        ],
                      )
                  )
                ],
              ),
              Container(
                  height: 56.0
              ),
            ],
          ),
          Positioned(
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
                              onPressed: null,
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
                                  _commentVisible = !_commentVisible;
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
                              onPressed: null,
                              icon: Icon(
                                Icons.thumb_up,
                                color: _praisesColor,
                                size: 24,
                              ),
                              label: Text("赞", style: TextStyle(
                                  color: _praisesColor
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
          ),
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Visibility(visible: _commentVisible, child: TextField(
                autofocus: true,
              ))
          )
        ],
      ),
    );
  }
}
