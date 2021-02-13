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
    with AutomaticKeepAliveClientMixin, RouteAware {
  final FocusNode _focusNode = FocusNode();
  final List<User> userList = <User>[];

  TextEditingController _controller = TextEditingController();

  List<Post> postList;

  final ValueNotifier<bool> _canClear = ValueNotifier<bool>(false),
      _autoFocus = ValueNotifier<bool>(true),
      _loaded = ValueNotifier<bool>(false),
      _loading = ValueNotifier<bool>(false),
      _canLoadMore = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _controller.addListener(canClearListener);
  }

  @override
  void dispose() {
    Instances.routeObserver.unsubscribe(this);
    _controller?.removeListener(canClearListener);
    _controller?.dispose();
    _focusNode
      ..unfocus()
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.content?.trim()?.isNotEmpty ?? false) {
      _autoFocus.value = false;
      _controller?.removeListener(canClearListener);
      _controller = TextEditingController(text: widget.content);
      search(context, widget.content);
    }
    Instances.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didPushNext() {
    _focusNode.unfocus();
  }

  void canClearListener() {
    _canClear.value = _controller.text.isNotEmpty;
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
        _canLoadMore.value = false;
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
      _loading.value = true;
      if (!isMore) {
        _loaded.value = false;
        _canLoadMore.value = true;
        userList?.clear();
        postList = null;
      }
      Future.wait<void>(<Future<void>>[
        getUsers(content),
        getPosts(content),
      ]).then((dynamic _) {
        _loaded.value = !_loaded.value;
        _loading.value = false;
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

  Widget get searchButton {
    return Tapper(
      onTap: () {
        search(context, _controller.text);
      },
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.themeColor,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          R.ASSETS_ICONS_SELF_PAGE_SEARCH_SVG,
          width: 40.w,
          color: adaptiveButtonColor(),
        ),
      ),
    );
  }

  Widget clearButton(BuildContext context) {
    return Tapper(
      onTap: () {
        _controller.clear();
        _focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SvgPicture.asset(
          R.ASSETS_ICONS_CLEAR_SVG,
          width: 20.w,
          color: context.iconTheme.color,
        ),
      ),
    );
  }

  Widget searchTextField(BuildContext context, {String content}) {
    if (content != null) {
      _controller = TextEditingController(text: content);
    }
    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: Row(
        children: <Widget>[
          ValueListenableBuilder2<bool, bool>(
            firstNotifier: _autoFocus,
            secondNotifier: _loaded,
            builder: (_, bool autoFocus, bool isLoaded, __) => Expanded(
              child: TextField(
                autofocus: autoFocus && !isLoaded,
                controller: _controller,
                cursorColor: currentThemeColor,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: ' 输入要搜索的内容...',
                ),
                focusNode: _focusNode,
                keyboardType: TextInputType.text,
                style: TextStyle(height: 1.25, fontSize: 20.sp),
                textInputAction: TextInputAction.search,
                onSubmitted: (String text) {
                  search(context, text);
                },
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _canClear,
            builder: (BuildContext c, bool value, __) {
              if (value) {
                return clearButton(c);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget get userListView {
    if (userList == null || userList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
          child: Text(
            '相关用户 (${userList.length})',
            style: TextStyle(
              color: context.textTheme.bodyText2.color.withOpacity(0.625),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 132.w,
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                width: 1.w,
                color: context.theme.dividerColor,
              ),
            ),
            color: context.theme.colorScheme.surface,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: userList.length,
            itemBuilder: (_, int index) => Container(
              width: Screens.width / 6,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  VGap(2.w),
                  UserAvatar(uid: userList[index].id, size: 56),
                  VGap(12.w),
                  Text(
                    userList[index].nickname.notBreak,
                    style: TextStyle(height: 1.2, fontSize: 18.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultListView(BuildContext context) {
    return ListView.builder(
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
                style: context.textTheme.caption.copyWith(
                  fontSize: 19.sp,
                ),
              ),
            );
          }
        }
        if (userList != null && userList.isNotEmpty && index == 1) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.w,
            ).copyWith(bottom: 4.w),
            child: Text(
              '相关动态',
              style: TextStyle(
                color: context.textTheme.bodyText2.color.withOpacity(0.625),
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else if (index == postList.length + 1) {
          if (_canLoadMore.value) {
            search(context, _controller.text, isMore: true);
          }
          return PostCard(
            postList[index - 2],
            isDetail: false,
            parentContext: context,
          );
        } else if (index == postList.length + 2) {
          return LoadMoreIndicator(canLoadMore: _canLoadMore.value);
        } else {
          return PostCard(
            postList[index - 1],
            isDetail: false,
            parentContext: context,
          );
        }
      },
    );
  }

  Widget _emptyWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          R.ASSETS_PLACEHOLDERS_SEARCH_NO_RESULT_SVG,
          width: 50.w,
          color: context.theme.iconTheme.color,
        ),
        VGap(20.w),
        Text(
          '无搜索结果',
          style: TextStyle(
            color: context.textTheme.caption.color,
            fontSize: 22.sp,
          ),
        ),
      ],
    );
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          centerTitle: false,
          title: searchTextField(context),
          actions: <Widget>[searchButton],
          actionsPadding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        body: ValueListenableBuilder2<bool, bool>(
          firstNotifier: _loading,
          secondNotifier: _loaded,
          builder: (_, bool isLoading, bool isLoaded, __) {
            if (isLoading) {
              return const Center(
                child: LoadMoreSpinningIcon(isRefreshing: true),
              );
            }
            if (isLoaded) {
              if ((postList != null && postList.isNotEmpty) ||
                  (userList != null && userList.isNotEmpty)) {
                return _resultListView(context);
              }
              return _emptyWidget(context);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
