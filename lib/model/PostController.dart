import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/PostCard.dart';

/// 用于控制帖子的刷新和加载URL
class PostController {
  /// 帖子获取地址
  final String postType;

  /// 是否加载关注的人
  final bool isFollowed;

  /// 是否加载更多
  final bool isMore;

  /// 分页最后一个帖子的Value值
  /// 用于指定加载下一页的初始Value
  final Function lastValue;

  final Map<String, dynamic> additionAttrs;

  PostController(
      {@required this.postType,
        @required this.isFollowed,
        @required this.isMore,
        @required this.lastValue,
        this.additionAttrs});
}


class PostList extends StatefulWidget {
  final PostController _postController;
  final bool needRefreshIndicator;

  PostList(this._postController, {
    Key key,
    this.needRefreshIndicator = true
  })
      : super(key: key);

  @override
  State createState() => _PostListState();
}


class _PostListState extends State<PostList> with AutomaticKeepAliveClientMixin {
  num _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  var _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  Widget _body = Center(
    child: CircularProgressIndicator(),
  );

  List<Post> _postList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

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

    _emptyChild = GestureDetector(
      onTap: () {
      },
      child: Container(
        child: Center(
          child: Text('这里空空如也~', style: TextStyle(color: ThemeUtils.currentColorTheme),),
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
          child: Text('加载失败，轻触重试', style: TextStyle(color: ThemeUtils.currentColorTheme),),
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
          padding: EdgeInsets.all(4.0),
          itemBuilder: (context, index) {
            if (index == _postList.length - 1) {
              _loadData();
            }
            return PostCardItem(_postList[index]);
          },
          itemCount: _postList.length,
//            controller: _scrollController,
        );

        if (widget.needRefreshIndicator) {
          _body = RefreshIndicator(
            onRefresh: _refreshData,
            child: _postList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList,
          );
        } else {
          _body = _postList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList;
        }
      }
      return _body;
    } else {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
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
          widget._postController.isFollowed,
          widget._postController.isMore,
          _lastValue,
          additionAttrs: widget._postController.additionAttrs
      );
      List<Post> postList = [];
      List _topics = jsonDecode(result)['topics'];
      for (var post in _topics) {
        postList.add(PostAPI.createPost(post['topic']));
      }
      _postList.addAll(postList);
//      error = !result['success'];

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = result['list'].isNotEmpty;
          _lastValue = _postList.isEmpty
              ? 0
              : widget._postController.lastValue(_postList.last);
        });
      }
    }
  }

  Future<Null> _refreshData() async {
    if (!_isLoading) {
      _isLoading = true;
      _postList.clear();

      _lastValue = 0;

      var result = await PostAPI.getPostList(
          widget._postController.postType,
          widget._postController.isFollowed,
          widget._postController.isMore,
          _lastValue,
          additionAttrs: widget._postController.additionAttrs
      );
      List<Post> postList = [];
      List _topics = jsonDecode(result)['topics'];
      for (var post in _topics) {
        postList.add(PostAPI.createPost(post['topic']));
      }
      _postList.addAll(postList);
//      error = !result['success'] ?? false;

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = true;
          _lastValue = _postList.isEmpty
              ? 0
              : widget._postController.lastValue(_postList.last);

        });
      }
    }
  }
}

class PostAPI {
  static getPostList(String postType, bool isFollowed, bool isMore, int lastValue, {additionAttrs}) async {
    String _postUrl;
    if (postType == "square") {
      if (isMore) {
        if (!isFollowed) {
          _postUrl = Api.postList + "/id_max/$lastValue";
        } else {
          _postUrl = Api.postFollowedList + "/id_max/$lastValue";
        }
      } else {
        if (!isFollowed) {
          _postUrl = Api.postList;
        } else {
          _postUrl = Api.postFollowedList;
        }
      }
    } else if (postType == "user") {
      if (isMore) {
        _postUrl = "${Api.postListByUid}${additionAttrs['uid']}/id_max/$lastValue";
      } else {
        _postUrl = "${Api.postListByUid}${additionAttrs['uid']}";
      }
    }
    return NetUtils.getWithCookieAndHeaderSet(
      _postUrl,
      headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
      cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid)
    );
  }

  static Post createPost(itemData) {
    var _user = itemData['user'];
    String _avatar = "${Api.userAvatar}?uid=${_user['uid']}&size=f100";
    String _postTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(itemData['post_time']) * 1000)
        .toString()
        .substring(0,16);
    Post _post = new Post(
        int.parse(itemData['tid']),
        int.parse(_user['uid']),
        _user['nickname'],
        _avatar,
        _postTime,
        itemData['from_string'],
        int.parse(itemData['glances']),
        itemData['category'],
        itemData['category'] == "longtext" ? itemData['article'] : itemData['content'],
        itemData['image'],
        int.parse(itemData['forwards']),
        int.parse(itemData['replys']),
        int.parse(itemData['praises']),
        itemData['root_topic'],
        isLike: itemData['praised'] == 1 ? true : false
    );
    return _post;
  }

}