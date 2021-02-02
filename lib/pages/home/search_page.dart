import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/post_card.dart';

@FFRoute(name: 'openjmu://search', routeName: '搜索页')
class SearchPage extends StatefulWidget {
  const SearchPage({this.content});

  final String content;

  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final FocusNode _focusNode = FocusNode();
  TextEditingController _controller = TextEditingController();

  final List<User> userList = <User>[];
  List<Post> postList;

  bool _loaded = false,
      _loading = false,
      _canLoadMore = true,
      _canClear = false,
      _autoFocus = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(canClearListener);
  }

  @override
  void dispose() {
    _controller?.removeListener(canClearListener);
    _controller?.dispose();
    _focusNode
      ..unfocus()
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (widget.content?.trim()?.isNotEmpty ?? false) {
      _autoFocus = false;
      _controller?.removeListener(canClearListener);
      _controller = TextEditingController(text: widget.content);
      search(context, widget.content);
    }
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;

  void canClearListener() {
    _canClear = _controller.text.isNotEmpty;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getUsers(String searchQuery) async {
    await UserAPI.searchUser(searchQuery).then((Map<String, dynamic> response) {
      final List<dynamic> _us = response['data'] as List<dynamic>;
      userList?.clear();
      for (final dynamic user in _us) {
        final User u = User.fromJson(user as Map<String, dynamic>);
        userList.add(u);
      }
      if (userList != null && userList.length == 1) {
        navigatorState.pushReplacementNamed(
          Routes.openjmuUserPage.name,
          arguments: Routes.openjmuUserPage.d(uid: userList[0].id),
        );
      }
    }).catchError((dynamic e) {
      LogUtils.e('Error when get users: $e');
    });
  }

  Future<void> getPosts(String searchQuery) async {
    bool loadMore = false;
    if (postList != null && postList.isNotEmpty) {
      loadMore = true;
    }
    await PostAPI.getPostList(
      'search',
      isMore: loadMore,
      lastValue: loadMore ? postList.last.id : 0,
      additionAttrs: <String, dynamic>{'words': searchQuery},
    ).then((Response<Map<String, dynamic>> response) {
      final List<dynamic> _ps = response.data['topics'] as List<dynamic>;
      if (_ps.isEmpty) {
        _canLoadMore = false;
      }
      for (final dynamic post in _ps) {
        final Post p = Post.fromJson(post['topic'] as Map<String, dynamic>);
        postList ??= <Post>[];
        postList.add(p);
      }
    }).catchError((dynamic e) {
      LogUtils.e('Error when searching posts: $e');
    });
  }

  void search(BuildContext context, String content, {bool isMore = false}) {
    final String query = filteredSearchQuery(content);
    if (query?.isNotEmpty ?? false) {
      _focusNode.unfocus();
      _loading = true;
      if (!isMore) {
        _loaded = false;
        _canLoadMore = true;
        userList?.clear();
        postList = null;
        if (mounted) {
          setState(() {});
        }
      }
      Future.wait<void>(<Future<void>>[
        getUsers(content),
        getPosts(content),
      ]).then((dynamic _) {
        if (!_loaded) {
          _loaded = true;
        }
        _loading = false;
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      showToast('一定要搜点什么才行...');
    }
  }

  String filteredSearchQuery(String query) {
    String result;
    if (query?.isNotEmpty ?? false) {
      result = query
          .replaceAll('+', '')
          .replaceAll('-', '')
          .replaceAll('*', '')
          .replaceAll('/', '')
          .replaceAll('=', '')
          .replaceAll('\$', '')
          .trim();
    }
    return result;
  }

  Widget get searchButton => IconButton(
        icon: Icon(Icons.search, size: 30.w),
        onPressed: () {
          search(context, _controller.text);
        },
      );

  Widget get clearButton => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _controller.clear();
          _focusNode.requestFocus();
          SystemChannels.textInput.invokeMethod<void>('TextInput.show');
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Icon(
            Icons.clear,
            size: 24.w,
            color: context.iconTheme.color,
          ),
        ),
      );

  Widget searchTextField(BuildContext context, {String content}) {
    if (content != null) {
      _controller = TextEditingController(text: content);
    }
    return Container(
      height: kAppBarHeight.h / 1.3,
      padding: EdgeInsets.only(
        left: 16.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kAppBarHeight),
        color: Theme.of(context).canvasColor,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              autofocus: _autoFocus && !_loaded,
              controller: _controller,
              cursorColor: currentThemeColor,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '输入要搜索的内容...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  textBaseline: TextBaseline.alphabetic,
                ),
                isDense: true,
              ),
              focusNode: _focusNode,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.normal,
                textBaseline: TextBaseline.alphabetic,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (String text) {
                search(context, text);
              },
            ),
          ),
          if (_canClear) clearButton,
        ],
      ),
    );
  }

  Widget get userListView => (userList != null && userList.isNotEmpty)
      ? SizedBox(
          height: 150.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16.h, left: 12.w),
                child: Text(
                  '相关用户 (${userList.length})',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(fontSize: 19.sp),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: userList.length,
                  itemBuilder: (BuildContext _, int index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          UserAvatar(uid: userList[index].id, size: 56.0),
                          VGap(8.h),
                          Text(
                            userList[index].nickname,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 2.h),
            ],
          ),
        )
      : const SizedBox.shrink();

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kAppBarHeight),
        child: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: <Widget>[
                const BackButton(),
                Expanded(child: searchTextField(context)),
                searchButton,
              ],
            ),
          ),
        ),
      ),
      body: !_loading
          ? _loaded
              ? (postList != null && postList.isNotEmpty) ||
                      (userList != null && userList.isNotEmpty)
                  ? ListView.builder(
                      itemCount: 1 +
                          (postList?.length ?? 0) +
                          ((userList != null && userList.isNotEmpty) ? 1 : 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          if (userList != null && userList.isNotEmpty) {
                            return userListView;
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: 16.h,
                                bottom: 8.h,
                                left: 12.w,
                              ),
                              child: Text(
                                '相关动态',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                      fontSize: 19.sp,
                                    ),
                              ),
                            );
                          }
                        }
                        if (userList != null &&
                            userList.isNotEmpty &&
                            index == 1) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: 16.h,
                              bottom: 8.h,
                              left: 12.w,
                            ),
                            child: Text(
                              '相关动态',
                              style: context.textTheme.caption.copyWith(
                                fontSize: 19.sp,
                              ),
                            ),
                          );
                        } else if (index == postList.length + 1) {
                          if (_canLoadMore) {
                            search(context, _controller.text, isMore: true);
                          }
                          return PostCard(
                            postList[index - 2],
                            isDetail: false,
                            parentContext: context,
                          );
                        } else if (index == postList.length + 2) {
                          return LoadMoreIndicator(canLoadMore: _canLoadMore);
                        } else {
                          return PostCard(
                            postList[index - 1],
                            isDetail: false,
                            parentContext: context,
                          );
                        }
                      },
                    )
                  : Center(
                      child: Text(
                        '没有搜索到动态内容~\n🧐',
                        style: TextStyle(fontSize: 30.sp),
                        textAlign: TextAlign.center,
                      ),
                    )
              : const SizedBox.shrink()
          : const Center(
              child: LoadMoreSpinningIcon(isRefreshing: true),
            ),
    );
  }
}
