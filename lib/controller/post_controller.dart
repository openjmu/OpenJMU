import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';
import 'package:extended_text/extended_text.dart';
import 'package:dio/dio.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/post_card.dart';

class PostController {
  PostController({
    @required this.postType,
    @required this.isFollowed,
    @required this.isMore,
    @required this.lastValue,
    this.additionAttrs,
  });

  final String postType;
  final bool isFollowed;
  final bool isMore;
  final int Function(int) lastValue;
  final Map<String, dynamic> additionAttrs;

  _PostListState _postListState;

  Future<void> reload() => _postListState._refreshData();
}

class PostList extends StatefulWidget {
  const PostList(
    this.postController, {
    Key key,
    this.needRefreshIndicator = true,
  }) : super(key: key);

  final PostController postController;
  final bool needRefreshIndicator;

  @override
  State createState() => _PostListState();
}

class _PostListState extends State<PostList>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  int _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;

  Widget _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  List<int> _idList = <int>[];
  List<Post> _postList = <Post>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.postController._postListState = this;

    Instances.eventBus
      ..on<ScrollToTopEvent>().listen((ScrollToTopEvent event) {
        if (mounted &&
            ((event.tabIndex == 0 &&
                    widget.postController.postType == 'square') &&
                event.type == '广场') &&
            _scrollController != null) {
          if (_postList.length > 20) {
            _postList = _postList.sublist(0, 20);
          }
          _scrollController.animateTo(
            0.0,
            curve: Curves.fastOutSlowIn,
            duration: kTabScrollDuration,
          );
          Future<void>.delayed(50.milliseconds, () {
            refreshIndicatorKey.currentState.show();
          });
          Future<void>.delayed(500.milliseconds, () {
            _refreshData(needLoader: true);
          });
        }
      })
      ..on<PostChangeEvent>().listen((PostChangeEvent event) {
        if (event.remove) {
          _postList.removeWhere((Post post) => event.post.id == post.id);
        } else {
          final int index = _postList.indexOf(event.post);
          _postList.replaceRange(index, index + 1, <Post>[event.post]);
        }
        if (mounted) {
          setState(() {});
        }
      })
      ..on<PostDeletedEvent>().listen((PostDeletedEvent event) {
        LogUtils.d(
          'PostDeleted: ${event.postId} / ${event.page} / ${event.index}',
        );
        if ((event.page == widget.postController.postType) &&
            event.index != null) {
          _idList.removeAt(event.index);
          _postList.removeAt(event.index);
        }
        if (mounted) {
          setState(() {});
        }
      });

    _emptyChild = GestureDetector(
      onTap: _refreshData,
      child: Container(
        child: Center(
          child: Text(
            '这里空空如也~轻触重试',
            style: TextStyle(
              fontSize: 30.sp,
              color: currentThemeColor,
            ),
          ),
        ),
      ),
    );

    _errorChild = GestureDetector(
      onTap: _refreshData,
      child: Container(
        child: Center(
          child: Text(
            '加载失败，轻触重试',
            style: TextStyle(
              fontSize: 30.sp,
              color: currentThemeColor,
            ),
          ),
        ),
      ),
    );

    _refreshData();
  }

  Future<void> _loadData() async {
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;
    }
    final Map<String, dynamic> result = (await PostAPI.getPostList(
      widget.postController.postType,
      isFollowed: widget.postController.isFollowed,
      isMore: true,
      lastValue: _lastValue,
      additionAttrs: widget.postController.additionAttrs,
    ))
        .data;

    final List<Post> postList = <Post>[];
    final List<Map<String, dynamic>> _topics =
        (result['topics'] as List<dynamic>).cast<Map<String, dynamic>>();
    final int _total = result['total'].toString().toInt();
    final int _count = result['count'].toString().toInt();

    for (final Map<String, dynamic> postData in _topics) {
      final BlacklistUser user = BlacklistUser.fromJson(
        <String, dynamic>{
          'uid': postData['topic']['user']['uid'].toString(),
          'username': postData['topic']['user']['nickname'],
        },
      );
      if (!UserAPI.blacklist.contains(user)) {
        postList.add(Post.fromJson(postData['topic'] as Map<String, dynamic>));
        _idList.add(postData['id'].toString().toInt());
      }
    }
    _postList.addAll(postList);

    _isLoading = false;
    _canLoadMore = _idList.length < _total && _count != 0;
    _lastValue =
        _idList.isEmpty ? 0 : widget.postController.lastValue(_idList.last);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshData({bool needLoader = false}) async {
    if (!_isLoading) {
      _isLoading = true;
    } else {
      return;
    }
    error = false;
    _lastValue = 0;

    try {
      final Map<String, dynamic> result = (await PostAPI.getPostList(
        widget.postController.postType,
        isFollowed: widget.postController.isFollowed,
        isMore: false,
        lastValue: _lastValue,
        additionAttrs: widget.postController.additionAttrs,
      ))
          .data;

      final List<Post> postList = <Post>[];
      final List<int> idList = <int>[];
      final List<Map<String, dynamic>> _topics =
          ((result['topics'] ?? result['data']) as List<dynamic>)
              .cast<Map<String, dynamic>>();
      final int _total = result['total'].toString().toInt();
      final int _count = result['count'].toString().toInt();

      for (final dynamic postData in _topics) {
        if (postData['topic'] != null && postData != '') {
          final BlacklistUser user = BlacklistUser.fromJson(
            <String, dynamic>{
              'uid': postData['topic']['user']['uid'].toString(),
              'username': postData['topic']['user']['nickname'],
            },
          );
          if (!UserAPI.blacklist.contains(user)) {
            postList
                .add(Post.fromJson(postData['topic'] as Map<String, dynamic>));
            idList.add(postData['id'].toString().toInt());
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

      _canLoadMore = _idList.length < _total && _count != 0;
      _lastValue =
          _idList.isEmpty ? 0 : widget.postController.lastValue(_idList.last);
    } catch (e) {
      error = true;
      LogUtils.e('Failed when refresh post list: $e');
    }

    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    Widget _body;

    if (!_isLoading) {
      _itemList = ExtendedListView.builder(
        padding: EdgeInsets.symmetric(vertical: 6.w),
        extendedListDelegate: ExtendedListDelegate(
          collectGarbage: (List<int> garbage) {
            for (final int index in garbage) {
              if (_postList.length >= index + 1 && index < 4) {
                final Post element = _postList.elementAt(index);
                final List<Map<String, dynamic>> pics = element.pics;
                if (pics != null) {
                  for (final Map<String, dynamic> pic in pics) {
                    ExtendedNetworkImageProvider(pic['image_thumb'] as String)
                        .evict();
                    ExtendedNetworkImageProvider(pic['image_middle'] as String)
                        .evict();
                    ExtendedNetworkImageProvider(
                            pic['image_original'] as String)
                        .evict();
                  }
                }
              }
            }
          },
        ),
        controller: _scrollController,
        itemCount: _postList.length + 1,
        itemBuilder: (BuildContext _, int index) {
          if (index == _postList.length - 1 && _canLoadMore) {
            _loadData();
          }
          if (index == _postList.length) {
            return LoadMoreIndicator(canLoadMore: _canLoadMore);
          } else if (index < _postList.length) {
            return PostCard(
              _postList[index],
              fromPage: widget.postController.postType,
              index: index,
              isDetail: false,
              parentContext: context,
              key: ValueKey<String>('post-key-${_postList[index].id}'),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
      _body =
          _postList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList;

      if (widget.needRefreshIndicator) {
        _body = RefreshIndicator(
          key: refreshIndicatorKey,
          color: currentThemeColor,
          onRefresh: _refreshData,
          child: _body,
        );
      }
    } else {
      _body = const SpinKitWidget();
    }

    return AnimatedSwitcher(duration: 500.milliseconds, child: _body);
  }
}

class ForwardListInPostController {
  ForwardListInPostState _forwardInPostListState;

  void reload() {
    _forwardInPostListState?._refreshData();
  }
}

class ForwardListInPost extends StatefulWidget {
  const ForwardListInPost(
    this.post,
    this.forwardInPostController, {
    Key key,
  }) : super(key: key);

  final Post post;
  final ForwardListInPostController forwardInPostController;

  @override
  State createState() => ForwardListInPostState();
}

class ForwardListInPostState extends State<ForwardListInPost>
    with AutomaticKeepAliveClientMixin {
  List<Post> _posts = <Post>[];

  bool isLoading = true;
  bool canLoadMore = false;
  bool firstLoadComplete = false;

  int lastValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshData() {
    isLoading = true;
    _posts = <Post>[];
    if (mounted) {
      setState(() {});
    }
    _refreshList();
  }

  Future<void> _loadList() async {
    isLoading = true;
    try {
      final Map<String, dynamic> response = (await PostAPI.getForwardListInPost(
        widget.post.id,
        isMore: true,
        lastValue: lastValue,
      ))
          ?.data;
      final List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(response['topics'] as List<dynamic>);
      final int total = response['total'] as int;
      if (_posts.length + (response['count'] as int) < total) {
        canLoadMore = true;
      } else {
        canLoadMore = false;
      }
      for (final Map<String, dynamic> post in list) {
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': post['topic']['user']['uid'].toString(),
            'username': post['topic']['user']['nickname'],
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
          _posts.add(Post.fromJson(post['topic'] as Map<String, dynamic>));
        }
      }
      isLoading = false;
      lastValue = _posts.isEmpty ? 0 : _posts.last.id;
      if (mounted) {
        setState(() {});
      }
    } on DioError catch (e) {
      if (e.response != null) {
        LogUtils.e('${e.response.data}');
      } else {
        LogUtils.e('${e.request}');
        LogUtils.e(e.message);
      }
      return;
    } catch (e) {
      LogUtils.e('Error when loading post list: $e');
    }
  }

  Future<void> _refreshList() async {
    isLoading = true;
    _posts.clear();
    if (mounted) {
      setState(() {});
    }
    try {
      final Map<String, dynamic> response =
          (await PostAPI.getForwardListInPost(widget.post.id))?.data;
      final List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(response['topics'] as List<dynamic>);
      final int total = response['total'] as int;
      if (response['count'] as int < total) {
        canLoadMore = true;
      }
      for (final Map<String, dynamic> post in list) {
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': post['topic']['user']['uid'].toString(),
            'username': post['topic']['user']['nickname'],
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
          _posts.add(Post.fromJson(post['topic'] as Map<String, dynamic>));
        }
      }
      isLoading = false;
      firstLoadComplete = true;
      lastValue = _posts.isEmpty ? 0 : _posts.last.id;
      if (mounted) {
        setState(() {});
      }
    } on DioError catch (e) {
      if (e.response != null) {
        LogUtils.e('${e.response.data}');
      } else {
        LogUtils.e('${e.request}');
        LogUtils.e(e.message);
      }
      return;
    } catch (e) {
      LogUtils.e('Error when loading post list: $e');
    }
  }

  Text getPostNickname(BuildContext context, Post post) => Text(
        post.nickname,
        style: TextStyle(fontSize: 20.sp),
      );

  Text getPostTime(BuildContext context, Post post) {
    return Text(
      PostAPI.postTimeConverter(post.postTime),
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: 16.sp,
          ),
    );
  }

  Widget getExtendedText(BuildContext context, String content) => ExtendedText(
        content,
        style: TextStyle(fontSize: 19.sp),
        onSpecialTextTap: specialTextTapRecognizer,
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      );

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? const SpinKitWidget()
        : firstLoadComplete
            ? ExtendedListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                extendedListDelegate: const ExtendedListDelegate(),
                separatorBuilder: (BuildContext _, int index) => Container(
                  color: Theme.of(context).dividerColor,
                  height: 1.0,
                ),
                itemCount: _posts.length + 1,
                itemBuilder: (BuildContext _, int index) {
                  if (index == _posts.length - 1 && canLoadMore) {
                    _loadList();
                  }
                  if (index == _posts.length) {
                    return LoadMoreIndicator(
                      canLoadMore: canLoadMore && !isLoading,
                    );
                  } else if (index < _posts.length) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          child: UserAPI.getAvatar(
                            uid: _posts[index].uid,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              VGap(10.h),
                              Row(
                                children: <Widget>[
                                  getPostNickname(context, _posts[index]),
                                  if (Constants.developerList
                                      .contains(_posts[index].uid))
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 14.w,
                                      ),
                                      child: DeveloperTag(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              VGap(4.h),
                              getExtendedText(context, _posts[index].content),
                              VGap(6.h),
                              getPostTime(context, _posts[index]),
                              VGap(10.h),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            : const LoadMoreIndicator(canLoadMore: false);
  }
}
