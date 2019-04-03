//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
//import 'dart:async';
//import 'package:OpenJMU/model/Bean.dart';
//
//
//class PostContentPage extends StatefulWidget {
//  final int id;
//  final bool scrollToComments;
//
//  PostContentPage(this.id, {Key key, this.scrollToComments = false}) : super(key: key);
//
//  @override
//  State createState() => _PostContentState();
//}
//
//class _PostContentState extends State<PostContentPage> {
//  Post _post;
//  Widget _body = Center(
//    child: CircularProgressIndicator(),
//  );
//  RichTextView _richTextView;
//  Widget _userInfoLayer;
//  Widget _commentWidget = Text('');
//  Widget _commentLayer;
//  GlobalKey _rtKey;
//  GlobalKey _userKey;
//  GlobalKey _commentKey;
//
//  TextEditingController _textController;
//
//  List<PostComment> comments = [];
//
//  bool _commentLayerVisible = false;
//  Map<String, dynamic> _commentLayerInfo = {
//    'hintText': '评论',
//    'commentId': 0,
//    'uid': 0
//  };
//  Map<int, String> _tempInputComments = {};
//
//  ScrollController _scrollController;
//
//  double _scrollOffset = 0.0;
//
//  List<Widget> _actions = <Widget>[];
//
//  BuildContext _context;
//
//  @override
//  void initState() {
//    super.initState();
//
//    _fetchPostContent(widget.id);
//    _commentLayer = Container(width: 0, height: 0,);
//    _textController = TextEditingController();
//
//    _textController.addListener(() {
//      if (_textController.text != '') {
//        _tempInputComments.addAll({
//          _commentLayerInfo['commentId']: _textController.text
//        });
//      } else {
//        _tempInputComments.remove( _commentLayerInfo['commentId']);
//      }
//    });
//
//    // 监听绘制完毕并进行滚动
//    _rtKey = GlobalKey();
//    _userKey = GlobalKey();
//    _commentKey = GlobalKey();
//    if (widget.scrollToComments) {
//      WidgetsBinding.instance.addPostFrameCallback((duration) {
//        WidgetsBinding.instance.addPersistentFrameCallback((duration) {
//          if (_scrollOffset == 0.0 &&
//              _rtKey.currentContext != null && _userKey.currentContext != null &&
//              _commentKey.currentContext != null) {
//            _scrollOffset = _rtKey.currentContext.size.height + _userKey.currentContext.size.height;
//
//            _scrollController.jumpTo(_scrollOffset);
//
//          }
//          WidgetsBinding.instance.scheduleFrame();
//        });
//      });
//    }
//
//    _initActions();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (_context == null) {
//      _context = context;
//    }
//    var thumbUpColor = _post?.isLike ?? false ? PrimaryColorScheme().secondary : Colors.grey;
//    var collectColor = _post?.isCollect ?? false ? PrimaryColorScheme().secondary : Colors.grey;
//
//    if (_commentLayerVisible) {
//      _textController.text = _tempInputComments[_commentLayerInfo['commentId']];
//      _commentLayer = WillPopScope(
//        onWillPop: () async {
//          _cancelCommentLayer();
//        },
//        child: GestureDetector(
//          onTap: _cancelCommentLayer,
//          child: Scaffold(
//            backgroundColor: Color(0x7F000000),
//            body: Column(
//              children: <Widget>[
//
//                Flexible(
//                    child: Container()
//                ),
//
//                Container(
//                  child: Card(
//                    child: Column(
//                      children: <Widget>[
//
//                        Row(
//                          mainAxisSize: MainAxisSize.max,
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          children: <Widget>[
//
//                            Padding(
//                              padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
//                              child: Text('回复', style: TextStyle(color: Colors.black87, fontSize: 16),),
//                            ),
//
//                            Expanded(flex: 1, child: Container(),),
//
//                            RawMaterialButton(
//                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                              constraints: BoxConstraints(minHeight: 0, minWidth: 0),
//                              padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
//                              splashColor: Colors.grey[350],
//                              child: Text('发送',
//                                style: TextStyle(color: PrimaryColorScheme().primaryVariant, fontSize: 16),),
//                              onPressed: () {
//                                var text = _textController.text;
//                                if (text.isEmpty) {
//                                  Fluttertoast.showToast(msg: '内容不能为空');
//                                } else {
//                                  _requestComment(_commentLayerInfo['commentId']);
//                                }
//                              },
//                            )
//
//                          ],
//                        ),
//
//                        TextField(
//                          controller: _textController,
//                          maxLines: 6,
//                          autofocus: true,
//                          cursorColor: PrimaryColorScheme().primaryVariant,
//                          decoration: InputDecoration(
//                            hintText: _commentLayerInfo['hintText'],
//                            border: InputBorder.none,
//                            contentPadding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
//                          ),
//                          style: TextStyle(fontSize: 14, color: Colors.grey),
//                        ),
//
//                        // 输入框快捷按钮
//                        Row(
//                          mainAxisSize: MainAxisSize.max,
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          children: <Widget>[
//
//                          ],
//                        )
//
//
//                      ],
//                    ),
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ),
//      );
//      _textController.selection =
//          TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
//    } else {
//      _commentLayer = Container(width: 0, height: 0,);
//    }
//
//    return Stack(
//      children: <Widget>[
//        Scaffold(
//            appBar: AppBar(
//              title: Text('浏览帖子'),
//              leading: IconButton(
//                  icon: Icon(
//                    Icons.arrow_back,
//                  ),
//                  onPressed: () {
//                    Navigator.pop(context);
//                  }),
//              centerTitle: false,
//              backgroundColor: PrimaryColorScheme().primaryVariant,
//              actions: _actions,
//            ),
//            body: _body,
//            bottomNavigationBar: SizedBox.fromSize(
//              child: Row(
//                mainAxisSize: MainAxisSize.max,
//                children: <Widget>[
//                  // 评论
//                  Expanded(
//                      flex: 1,
//                      child: RawMaterialButton(
//                        onPressed: () => _clickComment('评论帖子：${_post.title}', -1, _post.userId),
//
//                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                        constraints: BoxConstraints(minHeight: 48, minWidth: 0, maxHeight: 48),
//                        padding: EdgeInsets.only(left: 16, right: 16),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisSize: MainAxisSize.max,
//                          children: <Widget>[
//
//                            Icon(Icons.reply, color: Colors.grey,),
//                            Container(width: 8,),
//                            Text('评论(${_post?.comments ?? 0})', style: TextStyle(color: Colors.grey,),)
//
//                          ],
//                        ),
//                      )
//                  ),
//
//                  // 点赞
//                  Expanded(
//                      flex: 0,
//                      child: RawMaterialButton(
//                        onPressed: _clickThumpUp,
//
//                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                        constraints: BoxConstraints(minHeight: 48, minWidth: 0, maxHeight: 48),
//                        padding: EdgeInsets.only(left: 16, right: 16),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisSize: MainAxisSize.max,
//                          children: <Widget>[
//
//                            Icon(Icons.thumb_up, color: thumbUpColor, size: 18,),
//                            Container(width: 8,),
//                            Text('${_post?.thumpUps ?? 0}', style: TextStyle(color: thumbUpColor,),)
//
//                          ],
//                        ),
//                      )
//                  ),
//
//                  // 收藏
//                  Expanded(
//                      flex: 0,
//                      child: RawMaterialButton(
//                        onPressed: _clickCollect,
//
//                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                        constraints: BoxConstraints(minHeight: 48, minWidth: 0, maxHeight: 48),
//                        padding: EdgeInsets.only(left: 16, right: 16),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisSize: MainAxisSize.max,
//                          children: <Widget>[
//
//                            Icon(Icons.star, color: collectColor, size: 22,),
//                            Container(width: 8,),
//                            Text('${_post?.collects ?? 0}', style: TextStyle(color: collectColor,),)
//
//                          ],
//                        ),
//                      )
//                  ),
//                ],
//              ),
//              size: Size.fromHeight(48),
//            )
//        ),
//
//        _commentLayer,
//      ],
//    );
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//    _scrollController?.dispose();
//  }
//
//  Future<Null> _fetchPostContent(id) async {
//    _post = await PostAPI.getPostContent(id);
//    if (_post == null) {
//      if (mounted) {
//        setState(() {
//          _body = Container(
//            child: Center(
//              child: Text('获取信息出错', style: TextStyle(color: PrimaryColorScheme().primaryVariant),),
//            ),
//          );
//        });
//      }
//    } else {
//      _richTextView = RichTextView(_post.title, _post.content, key: _rtKey,);
//      comments = _post.postCommentList;
//
//      // 添加用户信息层
//      _userInfoLayer = Padding(
//        key: _userKey,
//        padding: EdgeInsets.only(top: 16, bottom: 0, left: 8, right: 8),
//        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            // 用户头像
//            IconButton(
//              icon: CircleAvatar(
//                radius: 20,
//                backgroundImage: (_post.avatar != null && _post.avatar != '')
//                    ? CachedNetworkImageProvider(_post.avatar, cacheManager: DefaultCacheManager())
//                    : AssetImage('assets/default_head.jpg'),
//              ),
//              padding: const EdgeInsets.all(0),
//              onPressed: () {
//                UserPage.jump(context, _post.userId);
//              },
//              splashColor: Color(0x00000000),
//            ),
//
//            Expanded(
//              flex: 1,
//              child: Padding(
//                padding: const EdgeInsets.only(left: 8, right: 8),
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    // 用户昵称
//                    Text(
//                      _post.nickname ?? _post.userId.toString(),
//                      style: TextStyle(
//                          fontSize: 16,
//                          color: PrimaryColorScheme().primary,
//                          fontWeight: FontWeight.normal),
//                      maxLines: 1,
//                      overflow: TextOverflow.ellipsis,
//                    ),
//
//                    SizedBox(
//                      width: 0,
//                      height: 4,
//                    ),
//
//                    // 发布时间
//                    Text(
//                      TimeConverter.getExpressionDate(_post.releaseTime),
//                      style: TextStyle(fontSize: 12, color: Colors.grey),
//                      maxLines: 1,
//                      overflow: TextOverflow.ellipsis,
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          ],
//        ),
//      );
//
//      _commentWidget = Column(
//        key: _commentKey,
//        children: <Widget>[
//          Container(height: 8, color: Colors.grey[350],)
//        ]..addAll(
//            comments.isNotEmpty ? comments.map((comment) {
//
//              // 所有父级评论
//              return PostCommentCard(
//                fatherComment: comment,
//                commentCallback: (comment) =>
//                    _clickComment('回复@${comment.userNickname}：${comment.content}'
//                        , comment.id, comment.userId),
//                postId: _post.id,
//              );
//            }).toList() : [
//              Container(
//                height: 300,
//                child: Center(
//                  child: Text('评论区空空如也~快来抢占沙发吧！', style: TextStyle(color: Colors.grey),),
//                ),
//              )
//            ]
//        ),
//      );
//
//      if (mounted) {
//        setState(() {
//          if (_scrollController == null) {
//            _scrollController = ScrollController();
//          }
//
//          _body = Scrollbar(
//            child: SingleChildScrollView(
//              controller: _scrollController,
//              child: Column(
//                children: <Widget>[
//                  _userInfoLayer,
//                  _richTextView,
//                  _commentWidget
//                ],
//              ),
//            ),
//          );
//        });
//      }
//    }
//  }
//
//  void _initActions() async {
//    if ((await UserAPI.getVerification()) & 1 == 1) {
//      if (mounted) {
//        setState(() {
//          _actions = [
//            IconButton(
//              icon: Icon(Icons.more_horiz),
//              onPressed: () => _clickMoreOptions(true),
//            )
//          ];
//        });
//      }
//    } else {
//      if (mounted) {
//        setState(() {
//          _actions = [
//            IconButton(
//              icon: Icon(Icons.more_horiz),
//              onPressed: () => _clickMoreOptions(_post.userId == UserAPI.curUser?.id ?? 0),
//            )
//          ];
//        });
//      }
//    }
//  }
//
//  void _clickThumpUp() async {
//    if (await UserAPI.isLogin()) {
//      await PostAPI.thumpUp(_post.id);
//      if (_post.isLike) {
//        _post.thumpUps--;
//      } else {
//        _post.thumpUps++;
//      }
//      if (mounted) {
//        setState(() {
//          _post.isLike = !_post.isLike;
//        });
//      }
//    }
//  }
//
//  void _clickCollect() async {
//    if (await UserAPI.isLogin()) {
//      await PostAPI.collect(_post.id);
//      if (_post.isCollect) {
//        _post.collects--;
//      } else {
//        _post.collects++;
//      }
//      if (mounted) {
//        setState(() {
//          _post.isCollect = !_post.isCollect;
//        });
//      }
//    }
//  }
//
//  void _clickComment(hintText, commentId, uid) async {
//    if (await UserAPI.isLogin()) {
//      setState(() {
//        _commentLayerInfo['commentId'] = commentId;
//        _commentLayerInfo['hintText'] = hintText;
//        _commentLayerInfo['uid'] = uid;
//        if (_tempInputComments[commentId] == null) {
//          _tempInputComments[commentId] = '';
//        }
//        _commentLayerVisible = true;
//      });
//    }
//  }
//
//  void _cancelCommentLayer() {
//    setState(() {
//      _commentLayerVisible = false;
//    });
//  }
//
//  void _requestComment(commentId) async {
//    var content = _tempInputComments[commentId];
//    var dialog = LoadingDialog(
//      message: '正在发送……',
//      cancelable: false,
//    );
//    showDialog(
//        context: context,
//        barrierDismissible: false,
//        builder: (context) => dialog
//    );
//
//    var result = await PostAPI.addComment(
//        content: content,
//        postId: _post.id,
//        fatherCommentId: commentId == 0 ? -1 : commentId,
//        time: DateTime.now().millisecondsSinceEpoch,
//        toUserId: _commentLayerInfo['uid']
//    );
//
//    if (result) {
//      await _fetchPostContent(widget.id);
//      Fluttertoast.showToast(msg: '发送成功');
//
//      _tempInputComments.remove(commentId);
//      _cancelCommentLayer();
//    } else {
//      Fluttertoast.showToast(msg: '发送失败');
//    }
//
//    dialog.dismiss();
//  }
//
//  void _clickMoreOptions(admin) async {
//    var buttons = <Widget>[]..add(ListTile(
//      title: Text('复制 @${_post.nickname}'),
//      onTap: () {
//        Clipboard.setData(ClipboardData(text: '@${_post.nickname}'));
//        Fluttertoast.showToast(msg: '复制成功');
//        Navigator.of(context).pop();
//      },
//    ))..add(ListTile(
//      title: Text('复制 ${_post.title}'),
//      onTap: () {
//        Clipboard.setData(ClipboardData(text: '${_post.title}'));
//        Fluttertoast.showToast(msg: '复制成功');
//        Navigator.of(context).pop();
//      },
//    ))..add(ListTile(
//      title: Text('复制帖子内容'),
//      onTap: () {
//        Clipboard.setData(ClipboardData(text: _richTextView.buildContent()));
//        Fluttertoast.showToast(msg: '复制成功');
//        Navigator.of(context).pop();
//      },
//    ));
//
//    if (admin) {
//      buttons..add(ListTile(
//        title: Text('删除帖子', style: TextStyle(color: Colors.red),),
//        onTap: () async {
//          Navigator.of(context).pop();
//
//          showDialog(
//              context: context,
//              builder: (context) => AlertDialog(
//                title: Text('删除帖子'),
//                content: Text('确定要删除帖子吗？该操作不可逆!'),
//                actions: <Widget>[
//
//                  FlatButton(
//                    child: Text('删除', style: TextStyle(color: Colors.red),),
//                    onPressed: () async {
//                      Navigator.of(context).pop();
//                      var res = await PostAPI.deletePost(_post);
//
//                      if (res) {
//                        Fluttertoast.showToast(msg: '删除成功');
//
//                        Navigator.of(_context).pop();
//                      } else {
//                        Fluttertoast.showToast(msg: '删除失败');
//                      }
//                    },
//                  ),
//
//                  FlatButton(
//                    child: Text('取消'),
//                    onPressed: () async {
//                      Navigator.of(context).pop();
//                    },
//                  )
//
//                ],
//              )
//          );
//
//
//        },
//      ));
//    }
//
//    showModalBottomSheet(
//        context: context,
//        builder: (context) => Column(
//          mainAxisSize: MainAxisSize.min,
//          children: buttons,
//        )
//    );
//  }
//}
