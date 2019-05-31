import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:extended_text/extended_text.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/cards/PostCard.dart';

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
    GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    final ScrollController _scrollController = ScrollController();
    Color currentColorTheme = ThemeUtils.currentColorTheme;

    int _lastValue = 0;
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
                _scrollController.jumpTo(0.0);
                Future.delayed(Duration(milliseconds: 50), () {
                    refreshIndicatorKey.currentState.show();
                });
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
        Constants.eventBus
            ..on<ChangeThemeEvent>().listen((event) {
                if (mounted) {
                    setState(() {
                        currentColorTheme = event.color;
                    });
                }
            })
            ..on<PostDeletedEvent>().listen((event) {
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
                        key: refreshIndicatorKey,
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

            Map result = (await PostAPI.getPostList(
                widget._postController.postType,
                widget._postController.isFollowed, true, _lastValue,
                additionAttrs: widget._postController.additionAttrs,
            )).data;
            List<Post> postList = [];
            List _topics = result['topics'];
            var _total = result['total'], _count = result['count'];
            if (_total is String) _total = int.parse(_total);
            if (_count is String) _count = int.parse(_count);
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
                    _canLoadMore = _idList.length < _total && (_count != 0 && _count != "0");
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

            Map result = (await PostAPI.getPostList(
                widget._postController.postType,
                widget._postController.isFollowed, false, _lastValue,
                additionAttrs: widget._postController.additionAttrs,
            )).data;
            List<Post> postList = [];
            List<int> idList = [];
            List _topics = result['topics'];
            var _total = result['total'], _count = result['count'];
            if (_total is String) _total = int.parse(_total);
            if (_count is String) _count = int.parse(_count);
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
                if (idList.toString() != _idList.toString()) {
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
                    _canLoadMore = _idList.length < _total && (_count != 0 && _count != "0");
                    _lastValue = _idList.isEmpty
                            ? 0
                            : widget._postController.lastValue(_idList.last);
                });
            }
        }
    }
}

class ForwardListInPostController {
    _ForwardListInPostState _forwardInPostListState;

    void reload() {
        _forwardInPostListState?._refreshData();
    }
}

class ForwardListInPost extends StatefulWidget {
    final Post post;
    final ForwardListInPostController forwardInPostController;

    ForwardListInPost(this.post, this.forwardInPostController, {Key key}) : super(key: key);

    @override
    State createState() => _ForwardListInPostState();
}

class _ForwardListInPostState extends State<ForwardListInPost> {
    List<Post> _posts = [];

    bool isLoading = true;
    bool canLoadMore = false;
    bool firstLoadComplete = false;

    int lastValue;

    @override
    void initState() {
        super.initState();
        _refreshList();
    }

    void _refreshData() {
        setState(() {
            isLoading = true;
            _posts = [];
        });
        _refreshList();
    }

    Future<Null> _loadList() async {
        isLoading = true;
        try {
            Map<String, dynamic> response = (await PostAPI.getForwardListInPost(
                widget.post.id,
                isMore: true,
                lastValue: lastValue
            ))?.data;
            List<dynamic> list = response['topics'];
            int total = response['total'] as int;
            if (_posts.length + response['count'] as int < total) {
                canLoadMore = true;
            } else {
                canLoadMore = false;
            }
            List<Post> posts = [];
            list.forEach((post) {
                posts.add(PostAPI.createPost(post['topic']));
            });
            if (this.mounted) {
                setState(() { _posts.addAll(posts); });
                isLoading = false;
                lastValue = _posts.last.id;
            }
        } on DioError catch (e) {
            if (e.response != null) {
                print(e.response.data);
            } else {
                print(e.request);
                print(e.message);
            }
            return;
        }
    }

    Future<Null> _refreshList() async {
        setState(() { isLoading = true; });
        try {
            Map<String, dynamic> response = (await PostAPI.getForwardListInPost(widget.post.id))?.data;
            List<dynamic> list = response['topics'];
            int total = response['total'] as int;
            if (response['count'] as int < total) canLoadMore = true;
            List<Post> posts = [];
            list.forEach((post) {
                posts.add(PostAPI.createPost(post['topic']));
            });
            if (this.mounted) {
                setState(() {
                    Constants.eventBus.fire(new ForwardInPostUpdatedEvent(widget.post.id, total));
                    _posts = posts;
                    isLoading = false;
                    firstLoadComplete = true;
                });
                lastValue = _posts.last.id;
            }
        } on DioError catch (e) {
            if (e.response != null) {
                print(e.response.data);
            } else {
                print(e.request);
                print(e.message);
            }
            return;
        }
    }

    GestureDetector getPostAvatar(context, post) {
        return GestureDetector(
            child: Container(
                width: 40.0,
                height: 40.0,
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFECECEC),
                    image: DecorationImage(image: UserUtils.getAvatarProvider(post.uid), fit: BoxFit.cover),
                ),
            ),
            onTap: () {
                return UserPage.jump(context, post.uid);
            },
        );
    }

    Text getPostNickname(context, post) => Text(
        post.nickname,
        style: TextStyle(
            color: Theme.of(context).textTheme.title.color,
            fontSize: 16.0,
        ),
    );

    Text getPostTime(context, post) {
        String _postTime = post.postTime;
        DateTime now = DateTime.now();
        if (int.parse(_postTime.substring(0, 4)) == now.year) {
            _postTime = _postTime.substring(5, 16);
        }
        if (int.parse(_postTime.substring(0, 2)) == now.month && int.parse(_postTime.substring(3, 5)) == now.day) {
            _postTime = "${_postTime.substring(5, 11)}";
        }
        return Text(_postTime, style: Theme.of(context).textTheme.caption);
    }

    Widget getExtendedText(context, content) => ExtendedText(
        content != null ? "$content " : null,
        style: TextStyle(fontSize: 16.0),
        onSpecialTextTap: (dynamic data) {
            String text = data['content'];
            if (text.startsWith("#")) {
                return SearchPage.search(context, text.substring(1, text.length - 1));
            } else if (text.startsWith("@")) {
                return UserPage.jump(context, data['uid']);
            } else if (text.startsWith("https://wb.jmu.edu.cn")) {
                return CommonWebPage.jump(context, text, "网页链接");
            }
        },
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
    );

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Theme.of(context).cardColor,
            width: MediaQuery.of(context).size.width,
            padding: isLoading ? EdgeInsets.symmetric(vertical: 42) : EdgeInsets.zero,
            child: isLoading
                    ? Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
            ))
                    : Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.zero,
                child: firstLoadComplete ? ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Container(
                        color: Theme.of(context).dividerColor,
                        height: 1.0,
                    ),
                    itemCount: _posts.length + 1,
                    itemBuilder: (context, index) {
                        if (index == _posts.length) {
                            if (canLoadMore && !isLoading) {
                                _loadList();
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
                                                        ThemeUtils.currentColorTheme,
                                                    ),
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
                        } else if (index < _posts.length) {
                            return Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    getPostAvatar(context, _posts[index]),
                                    Expanded(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Container(height: 10.0),
                                                getPostNickname(context, _posts[index]),
                                                Container(height: 4.0),
                                                getExtendedText(context, _posts[index].content),
                                                Container(height: 6.0),
                                                getPostTime(context, _posts[index]),
                                                Container(height: 10.0),
                                            ],
                                        ),
                                    ),
                                ],
                            );
                        } else {
                            return Container();
                        }
                    },
                )
                        : Container(
                    height: 120.0,
                    child: Center(
                        child: Text("暂无内容", style: TextStyle(color: Colors.grey, fontSize: 18.0)),
                    ),
                ),
            ),
        );
    }
}
