import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';
import 'package:extended_text/extended_text.dart';
import 'package:dio/dio.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/api/UserAPI.dart';
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

  Future reload() => _postListState._refreshData();
}

class PostList extends StatefulWidget {
  final PostController _postController;
  final bool needRefreshIndicator;

  PostList(this._postController, {Key key, this.needRefreshIndicator = true})
      : super(key: key);

  @override
  State createState() => _PostListState();

  PostList newController(_controller) => PostList(_controller);
}

class _PostListState extends State<PostList>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  Color currentColorTheme = ThemeUtils.currentThemeColor;

  int _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  Widget _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  Widget _body = Center(
    child: Constants.progressIndicator(),
  );

  List<int> _idList = [];
  List<Post> _postList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    widget._postController._postListState = this;
    Instances.eventBus
      ..on<ScrollToTopEvent>().listen((event) {
        if (this.mounted &&
            ((event.tabIndex == 0 &&
                    widget._postController.postType == "square") ||
                (event.type == "首页"))) {
          if (_postList.length > 20) _postList = _postList.sublist(0, 20);
          _scrollController.animateTo(
            0.0,
            curve: Curves.fastOutSlowIn,
            duration: kTabScrollDuration,
          );
          Future.delayed(Duration(milliseconds: 50), () {
            refreshIndicatorKey.currentState.show();
          });
          Future.delayed(Duration(milliseconds: 500), () {
            _refreshData(needLoader: true);
          });
        }
      })
      ..on<PostChangeEvent>().listen((event) {
        if (event.remove) {
          _postList.removeWhere((post) => event.post.id == post.id);
        } else {
          int index = _postList.indexOf(event.post);
          _postList.replaceRange(index, index + 1, [event.post.copy()]);
        }
        if (mounted) setState(() {});
      })
      ..on<ChangeThemeEvent>().listen((event) {
        currentColorTheme = event.color;
        if (mounted) setState(() {});
      })
      ..on<PostDeletedEvent>().listen((event) {
        debugPrint(
            "PostDeleted: ${event.postId} / ${event.page} / ${event.index}");
        if ((event.page == widget._postController.postType) &&
            event.index != null) {
          _idList.removeAt(event.index);
          _postList.removeAt(event.index);
        }
        if (mounted) setState(() {});
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
    super.initState();
  }

  Future<Null> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      Map result = (await PostAPI.getPostList(
        widget._postController.postType,
        widget._postController.isFollowed,
        true,
        _lastValue,
        additionAttrs: widget._postController.additionAttrs,
      ))
          .data;

      List<Post> postList = [];
      List _topics = result['topics'];
      int _total = int.parse(result['total'].toString());
      int _count = int.parse(result['count'].toString());

      for (var postData in _topics) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": postData['topic']['user']['uid'].toString(),
          "username": postData['topic']['user']['nickname'],
        }))) {
          postList.add(Post.fromJson(postData['topic']));
          _idList.add(
            postData['id'] is String
                ? int.parse(postData['id'])
                : postData['id'],
          );
        }
      }
      _postList.addAll(postList);

      _showLoading = false;
      _firstLoadComplete = true;
      _isLoading = false;
      _canLoadMore = _idList.length < _total && _count != 0;
      _lastValue =
          _idList.isEmpty ? 0 : widget._postController.lastValue(_idList.last);
      if (mounted) setState(() {});
    }
  }

  Future<Null> _refreshData({bool needLoader = false}) async {
    if (!_isLoading) {
      _isLoading = true;
      _lastValue = 0;

      Map result = (await PostAPI.getPostList(
        widget._postController.postType,
        widget._postController.isFollowed,
        false,
        _lastValue,
        additionAttrs: widget._postController.additionAttrs,
      ))
          .data;

      List<Post> postList = [];
      List<int> idList = [];
      List _topics = result['topics'] ?? result['data'];
      int _total = int.parse(result['total'].toString());
      int _count = int.parse(result['count'].toString());

      for (var postData in _topics) {
        if (postData['topic'] != null && postData != "") {
          if (!UserAPI.blacklist.contains(jsonEncode({
            "uid": postData['topic']['user']['uid'].toString(),
            "username": postData['topic']['user']['nickname'],
          }))) {
            postList.add(Post.fromJson(postData['topic']));
            idList.add(
              postData['id'] is String
                  ? int.parse(postData['id'])
                  : postData['id'],
            );
          }
        }
      }
      _postList = postList;

      if (needLoader) {
        if (idList.toString() != _idList.toString()) {
          _idList = idList;
        }
      } else {
        _idList = idList;
      }

      _showLoading = false;
      _firstLoadComplete = true;
      _isLoading = false;
      _canLoadMore = _idList.length < _total && _count != 0;
      _lastValue =
          _idList.isEmpty ? 0 : widget._postController.lastValue(_idList.last);
      if (mounted) setState(() {});
    }
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      if (_firstLoadComplete) {
        _itemList = ExtendedListView.separated(
          padding: EdgeInsets.zero,
          extendedListDelegate: ExtendedListDelegate(
            collectGarbage: (List<int> garbage) {
              garbage.forEach((index) {
                if (_postList.length >= index + 1) {
                  final element = _postList.elementAt(index);
                  final pics = element.pics;
                  if (pics != null) {
                    pics.forEach((pic) {
                      final thumbProvider = ExtendedNetworkImageProvider(
                        pic['image_thumb'],
                      );
                      final middleProvider = ExtendedNetworkImageProvider(
                        pic['image_middle'],
                      );
                      final originalProvider = ExtendedNetworkImageProvider(
                        pic['image_original'],
                      );
                      thumbProvider.evict();
                      middleProvider.evict();
                      originalProvider.evict();
                    });
                  }
                }
              });
            },
          ),
          controller: widget._postController.postType == "user"
              ? null
              : _scrollController,
          separatorBuilder: (context, index) => Divider(
            thickness: suSetSp(8.0),
            height: suSetSp(8.0),
          ),
          itemCount: _postList.length + 1,
          itemBuilder: (context, index) {
            if (index == _postList.length - 1 && _canLoadMore) {
              _loadData();
            }
            if (index == _postList.length) {
              return Constants.loadMoreIndicator(canLoadMore: _canLoadMore);
            } else if (index < _postList.length) {
              return PostCard(
                _postList[index],
                fromPage: widget._postController.postType,
                index: index,
                isDetail: false,
                parentContext: context,
                key: ValueKey("post-key-${_postList[index].id}"),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        );
        _body =
            _postList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList;

        if (widget.needRefreshIndicator) {
          _body = RefreshIndicator(
            key: refreshIndicatorKey,
            color: currentColorTheme,
            onRefresh: _refreshData,
            child: _body,
          );
        }
      }
      return _body;
    } else {
      return Container(
        child: Center(
          child: Constants.progressIndicator(),
        ),
      );
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

  ForwardListInPost(this.post, this.forwardInPostController, {Key key})
      : super(key: key);

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
    _refreshList();
    super.initState();
  }

  void _refreshData() {
    isLoading = true;
    _posts = [];
    if (mounted) setState(() {});
    _refreshList();
  }

  Future<Null> _loadList() async {
    isLoading = true;
    try {
      Map<String, dynamic> response = (await PostAPI.getForwardListInPost(
        widget.post.id,
        isMore: true,
        lastValue: lastValue,
      ))
          ?.data;
      List<dynamic> list = response['topics'];
      int total = response['total'] as int;
      if (_posts.length + response['count'] as int < total) {
        canLoadMore = true;
      } else {
        canLoadMore = false;
      }
      List<Post> posts = [];
      list.forEach((post) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": post['topic']['user']['uid'].toString(),
          "username": post['topic']['user']['nickname'],
        }))) {
          posts.add(Post.fromJson(post['topic']));
        }
      });
      _posts.addAll(posts);
      isLoading = false;
      lastValue = _posts.isEmpty ? 0 : _posts.last.id;
      if (this.mounted) setState(() {});
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint("${e.response.data}");
      } else {
        debugPrint("${e.request}");
        debugPrint("${e.message}");
      }
      return;
    }
  }

  Future<Null> _refreshList() async {
    isLoading = true;
    if (mounted) setState(() {});
    try {
      Map<String, dynamic> response =
          (await PostAPI.getForwardListInPost(widget.post.id))?.data;
      List<dynamic> list = response['topics'];
      int total = response['total'] as int;
      if (response['count'] as int < total) canLoadMore = true;
      List<Post> posts = [];
      list.forEach((post) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": post['topic']['user']['uid'].toString(),
          "username": post['topic']['user']['nickname'],
        }))) {
          posts.add(Post.fromJson(post['topic']));
        }
      });
      Instances.eventBus.fire(ForwardInPostUpdatedEvent(widget.post.id, total));
      _posts = posts;
      isLoading = false;
      firstLoadComplete = true;
      lastValue = _posts.isEmpty ? 0 : _posts.last.id;
      if (this.mounted) setState(() {});
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint("${e.response.data}");
      } else {
        debugPrint("${e.request}");
        debugPrint("${e.message}");
      }
      return;
    }
  }

  Widget getPostAvatar(context, post) {
    return GestureDetector(
      child: Container(
        width: suSetSp(40.0),
        height: suSetSp(40.0),
        margin: EdgeInsets.symmetric(
          horizontal: suSetSp(16.0),
          vertical: suSetSp(10.0),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFECECEC),
          image: DecorationImage(
            image: UserAPI.getAvatarProvider(uid: post.uid),
            fit: BoxFit.cover,
          ),
        ),
      ),
      onTap: () {
        return UserPage.jump(post.uid);
      },
    );
  }

  Text getPostNickname(context, post) => Text(
        post.nickname,
        style: TextStyle(
          color: Theme.of(context).textTheme.title.color,
          fontSize: suSetSp(18.0),
        ),
      );

  Text getPostTime(context, post) {
    String _postTime = post.postTime;
    DateTime now = DateTime.now();
    if (int.parse(_postTime.substring(0, 4)) == now.year) {
      _postTime = _postTime.substring(5, 16);
    }
    if (int.parse(_postTime.substring(0, 2)) == now.month &&
        int.parse(_postTime.substring(3, 5)) == now.day) {
      _postTime = "${_postTime.substring(5, 11)}";
    }
    return Text(
      _postTime,
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(14.0),
          ),
    );
  }

  Widget getExtendedText(context, content) => ExtendedText(
        content != null ? "$content " : null,
        style: TextStyle(fontSize: suSetSp(17.0)),
        onSpecialTextTap: specialTextTapRecognizer,
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      width: Screen.width,
      padding: isLoading
          ? EdgeInsets.symmetric(
              vertical: suSetSp(42),
            )
          : EdgeInsets.zero,
      child: isLoading
          ? Center(
              child: SizedBox(
                child: Constants.progressIndicator(),
              ),
            )
          : Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.zero,
              child: firstLoadComplete
                  ? ExtendedListView.separated(
                      extendedListDelegate: ExtendedListDelegate(
                        collectGarbage: (List<int> garbage) {},
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(
                        height: suSetSp(1.0),
                      ),
                      itemCount: _posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _posts.length - 1) {
                          _loadList();
                        }
                        if (index == _posts.length) {
                          return Constants.loadMoreIndicator(
                            canLoadMore: canLoadMore && !isLoading,
                          );
                        } else if (index < _posts.length) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              getPostAvatar(context, _posts[index]),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: suSetSp(10.0)),
                                    Row(
                                      children: <Widget>[
                                        getPostNickname(context, _posts[index]),
                                        if (Constants.developerList
                                            .contains(_posts[index].uid))
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: suSetWidth(14.0),
                                            ),
                                            child: Constants.developerTag(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: suSetWidth(8.0),
                                                vertical: suSetHeight(4.0),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: suSetSp(4.0)),
                                    getExtendedText(
                                        context, _posts[index].content),
                                    SizedBox(height: suSetSp(6.0)),
                                    getPostTime(context, _posts[index]),
                                    SizedBox(height: suSetSp(10.0)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    )
                  : Container(
                      height: suSetSp(120.0),
                      child: Center(
                        child: Text(
                          "暂无内容",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: suSetSp(18.0),
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }
}
