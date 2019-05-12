import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/cards/PostCard.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';

class PostController {
    final String postType;
    final bool isFollowed;
    final bool isMore;
    final Function lastValue;
    final Map<String, dynamic> additionAttrs;

    PostController({
        @required this.postType,
        @required this.isFollowed,
        @required this.isMore,
        @required this.lastValue,
        this.additionAttrs,
    });

    _PostListState _postListState;

    Future reload({bool needLoader}) => _postListState._refreshData();
}

class PostList extends StatefulWidget {
    final PostController _postController;
    final bool needRefreshIndicator;

    PostList(this._postController, {Key key, this.needRefreshIndicator = true}) : super(key: key);

    @override
    State createState() => _PostListState();

    PostList newController(_controller) => PostList(_controller);
}

class _PostListState extends State<PostList> with AutomaticKeepAliveClientMixin {
    final ScrollController _scrollController = ScrollController();
    LoadingDialogController _controller = LoadingDialogController();
    Color currentColorTheme = ThemeUtils.currentColorTheme;

    num _lastValue = 0;
    bool _isLoading = false;
    bool _canLoadMore = true;
    bool _firstLoadComplete = false;
    bool _showLoading = true;

    ListView _itemList;

    Widget _emptyChild;
    Widget _errorChild;
    bool error = false;

    Widget _body = Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        ),
    );

    List<int> _idList = [];
    List<Post> _postList = [];

    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        super.initState();
        widget._postController._postListState = this;
        Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
            if (
                this.mounted
                    &&
                ((event.tabIndex == 0 && widget._postController.postType == "square")
                    ||
                (event.type == "Post"))
            ) {
                _scrollController.animateTo(0.0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) => LoadingDialog("正在更新动态", _controller),
                );
                Future.delayed(Duration(milliseconds: 500), () {
                    _refreshData(needLoader: true);
                });
            }
        });
        Constants.eventBus.on<PostChangeEvent>().listen((event) {
            if (event.remove) {
                if (mounted) {
                    setState(() {
                        _postList.removeWhere((post) => event.post.id == post.id);
                    });
                }
            } else {
                if (mounted) {
                    setState(() {
                        var index = _postList.indexOf(event.post);
                        _postList.replaceRange(index, index + 1, [event.post.copy()]);
                    });
                }
            }
        });
        Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
            if (mounted) {
                setState(() {
                    currentColorTheme = event.color;
                });
            }
        });
        Constants.eventBus.on<PostDeletedEvent>().listen((event) {
            print("PostDeleted: ${event.postId} / ${event.page} / ${event.index}");
            if (mounted && (event.page == "user") && event.index != null) {
                setState(() {
                    _idList.removeAt(event.index);
                    _postList.removeAt(event.index);
                });
            }
        });

        _emptyChild = GestureDetector(
            onTap: () {},
            child: Container(
                child: Center(
                    child: Text('这里空空如也~', style: TextStyle(color: currentColorTheme)),
                ),
            ),
        );

        _errorChild = GestureDetector(
            onTap: () {
                setState(() {
                    _isLoading = false;
                    _showLoading = true;
                    _refreshData();
                });
            },
            child: Container(
                child: Center(
                    child: Text('加载失败，轻触重试', style: TextStyle(color: currentColorTheme)),
                ),
            ),
        );

        _refreshData();
    }

    @override
    Widget build(BuildContext context) {
        super.build(context);
        if (!_showLoading) {
            if (_firstLoadComplete) {
                _itemList = ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    itemBuilder: (context, index) {
                        if (index == _postList.length) {
                            if (this._canLoadMore) {
                                _loadData();
                                return Container(
                                    height: 40.0,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            SizedBox(
                                                width: 15.0,
                                                height: 15.0,
                                                child: Platform.isAndroid
                                                        ? CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                            currentColorTheme),
                                                )
                                                        : CupertinoActivityIndicator(),
                                            ),
                                            Text("　正在加载", style: TextStyle(fontSize: 14.0)),
                                        ],
                                    ),
                                );
                            } else {
                                return Container(height: 40.0, child: Center(child: Text("没有更多了~")));
                            }
                        } else if (index < _postList.length) {
                            return PostCard(_postList[index], fromPage: widget._postController.postType, index: index);
                        } else {
                            return Container();
                        }
                    },
                    itemCount: _postList.length + 1,
                    controller: widget._postController.postType == "user"
                            ? null
                            : _scrollController,
                );

                if (widget.needRefreshIndicator) {
                    _body = RefreshIndicator(
                        color: currentColorTheme,
                        onRefresh: _refreshData,
                        child: _postList.isEmpty
                                ? (error ? _errorChild : _emptyChild)
                                : _itemList,
                    );
                } else {
                    _body = _postList.isEmpty
                            ? (error ? _errorChild : _emptyChild)
                            : _itemList;
                }
            }
            return _body;
        } else {
            return Container(
                child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(currentColorTheme),
                    ),
                ),
            );
        }
    }

    Future<Null> _loadData() async {
        _firstLoadComplete = true;
        if (!_isLoading && _canLoadMore) {
            _isLoading = true;

            var result = await PostAPI.getPostList(
                widget._postController.postType,
                widget._postController.isFollowed, true, _lastValue,
                additionAttrs: widget._postController.additionAttrs,
            );
            List<Post> postList = [];
            List _topics = jsonDecode(result)['topics'];
            for (var postData in _topics) {
                postList.add(PostAPI.createPost(postData['topic']));
                _idList.add(
                    postData['id'] is String
                            ? int.parse(postData['id'])
                            : postData['id'],
                );
            }
            _postList.addAll(postList);

            if (mounted) {
                setState(() {
                    _showLoading = false;
                    _firstLoadComplete = true;
                    _isLoading = false;
                    _canLoadMore = _topics.length == 20;
                    _lastValue = _idList.isEmpty
                            ? 0
                            : widget._postController.lastValue(_idList.last);
                });
            }
        }
    }

    Future<Null> _refreshData({bool needLoader}) async {
        if (!_isLoading) {
            _isLoading = true;
            _postList.clear();
            _lastValue = 0;

            var result = await PostAPI.getPostList(
                widget._postController.postType,
                widget._postController.isFollowed, false, _lastValue,
                additionAttrs: widget._postController.additionAttrs,
            );
            List<Post> postList = [];
            List<int> idList = [];
            List _topics = jsonDecode(result)['topics'];
            for (var postData in _topics) {
                if (postData['topic'] != null && postData != "") {
                    postList.add(PostAPI.createPost(postData['topic']));
                    idList.add(
                        postData['id'] is String
                                ? int.parse(postData['id'])
                                : postData['id'],
                    );
                }
            }
            _postList = postList;
            if (needLoader != null && needLoader) {
                if (idList.toString() == _idList.toString()) {
                    _controller.changeState("success", "无更新内容");
                } else {
                    _controller.changeState("dismiss", "正在更新动态");
                    _idList = idList;
                }
            } else {
                _idList = idList;
            }

            if (mounted) {
                setState(() {
                    _showLoading = false;
                    _firstLoadComplete = true;
                    _isLoading = false;
                    _canLoadMore = _topics.length == 20;
                    _lastValue = _idList.isEmpty
                            ? 0
                            : widget._postController.lastValue(_idList.last);
                });
            }
        }
    }
}

class ForwardInPostController {
    _ForwardInPostListState _forwardInPostListState;

    void reload() {
        _forwardInPostListState?._refreshData();
    }
}

class ForwardInPostList extends StatefulWidget {
    final Post post;
    final ForwardInPostController forwardInPostController;

    ForwardInPostList(this.post, this.forwardInPostController, {Key key}) : super(key: key);

    @override
    State createState() => _ForwardInPostListState();
}

class _ForwardInPostListState extends State<ForwardInPostList> {
    List<Post> _posts = [];

    bool isLoading = true;

    @override
    void initState() {
        super.initState();
        widget.forwardInPostController._forwardInPostListState = this;
        _getForwardList();
    }

    void _refreshData() {
        setState(() {
            isLoading = true;
            _posts = [];
        });
        _getForwardList();
    }

    Future<Null> _getForwardList() async {
        var list = await PostAPI.getForwardInPostList(widget.post.id);
        List<dynamic> response = jsonDecode(list)['topics'];
        List<Post> posts = [];
        response.forEach((post) {
            posts.add(PostAPI.createPost(post['topic']));
        });
        if (this.mounted) {
            setState(() {
                Constants.eventBus.fire(new ForwardInPostUpdatedEvent(widget.post.id, posts.length));
                isLoading = false;
                _posts = posts;
            });
        }
    }

    Widget forwardList() {
        return isLoading
                ? Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        ))
                : ForwardCardInPost(widget.post, _posts);
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Theme.of(context).cardColor,
            width: MediaQuery.of(context).size.width,
            padding: isLoading ? EdgeInsets.symmetric(vertical: 42) : EdgeInsets.zero,
            child: forwardList(),
        );
    }
}
