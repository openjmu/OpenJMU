import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:OpenJMU/api/TeamAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/cards/TeamPostCard.dart';


class TeamPostController {
    final bool isMore;
    final Function lastTimeStamp;
    final Map<String, dynamic> additionAttrs;

    TeamPostController({
        @required this.isMore,
        @required this.lastTimeStamp,
        this.additionAttrs,
    });

    _TeamPostListState _postListState;

    Future reload({bool needLoader}) => _postListState._refreshData();
}

class TeamPostList extends StatefulWidget {
    final TeamPostController _teamPostController;
    final bool needRefreshIndicator;

    TeamPostList(this._teamPostController, {Key key, this.needRefreshIndicator = true}) : super(key: key);

    @override
    State createState() => _TeamPostListState();

    TeamPostList newController(_controller) => TeamPostList(_controller);
}

class _TeamPostListState extends State<TeamPostList> with AutomaticKeepAliveClientMixin {
    GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    final ScrollController _scrollController = ScrollController();
    Color currentColorTheme = ThemeUtils.currentThemeColor;

    int _lastTimeStamp = 0;
    bool _isLoading = false;
    bool _canLoadMore = true;
    bool _firstLoadComplete = false;
    bool _showLoading = true;

    Widget _itemList;

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
        widget._teamPostController._postListState = this;
        Constants.eventBus
            ..on<PostChangeEvent>().listen((event) {
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
            })
            ..on<ChangeThemeEvent>().listen((event) {
                if (mounted) {
                    setState(() {
                        currentColorTheme = event.color;
                    });
                }
            })
            ..on<PostDeletedEvent>().listen((event) {
                debugPrint("PostDeleted: ${event.postId} / ${event.page} / ${event.index}");
                if (mounted && (event.page == "user") && event.index != null) {
                    setState(() {
                        _postList.removeAt(event.index);
                    });
                }
            });

        _emptyChild = GestureDetector(
            onTap: () {
                setState(() {
                    _isLoading = false;
                    _showLoading = true;
                    _refreshData();
                });
            },
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
                _itemList = ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: ListView.separated(
                        padding: EdgeInsets.zero,
                        separatorBuilder: (context, index) => Container(
                            color: Theme.of(context).canvasColor,
                            height: Constants.suSetSp(8.0),
                        ),
                        itemBuilder: (context, index) {
                            if (index == _postList.length) {
                                if (this._canLoadMore) {
                                    _loadData();
                                    return Container(
                                        height: Constants.suSetSp(40.0),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                                SizedBox(
                                                    width: Constants.suSetSp(15.0),
                                                    height: Constants.suSetSp(15.0),
                                                    child: Platform.isAndroid
                                                            ? CircularProgressIndicator(strokeWidth: 2.0)
                                                            : CupertinoActivityIndicator(),
                                                ),
                                                Text("　正在加载", style: TextStyle(fontSize: Constants.suSetSp(14.0))),
                                            ],
                                        ),
                                    );
                                } else {
                                    return Container(
                                        height: Constants.suSetSp(50.0),
                                        color: Theme.of(context).canvasColor,
                                        child: Center(
                                            child: Text(Constants.endLineTag, style: TextStyle(
                                                fontSize: Constants.suSetSp(14.0),
                                            )),
                                        ),
                                    );
                                }
                            } else if (index < _postList.length) {
                                return TeamPostCard(_postList[index], fromPage: "team", index: index, isDetail: false);
                            } else {
                                return Container();
                            }
                        },
                        itemCount: _postList.length + 1,
                        controller: _scrollController,
                    ),
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
                    child: CircularProgressIndicator(),
                ),
            );
        }
    }

    Future<Null> _loadData() async {
        _firstLoadComplete = true;
        if (!_isLoading && _canLoadMore) {
            _isLoading = true;

            Map result = (await TeamPostAPI.getPostList(
                isMore: true,
                lastTimeStamp: _lastTimeStamp,
                additionAttrs: widget._teamPostController.additionAttrs,
            )).data;

            List<Post> postList = [];
            List _topics = result['topics'] ?? result['data'];
            int _total = int.parse(result['total'].toString());
            int _count = int.parse(result['count'].toString());

            for (var postData in _topics) {
                postList.add(TeamPostAPI.createPost(postData['topic']));
            }
            _postList.addAll(postList);

            if (mounted) {
                setState(() {
                    _showLoading = false;
                    _firstLoadComplete = true;
                    _isLoading = false;
                    _canLoadMore = _postList.length < _total && _count != 0;
                    _lastTimeStamp = int.parse(result['min_ts']);
                });
            }
        }
    }

    Future<Null> _refreshData({bool needLoader}) async {
        if (!_isLoading) {
            _isLoading = true;
            _lastTimeStamp = 0;

            Map result = (await TeamPostAPI.getPostList(
                isMore: false,
                lastTimeStamp: _lastTimeStamp,
                additionAttrs: widget._teamPostController.additionAttrs,
            )).data;

            List<Post> postList = [];
            List _topics = result['topics'] ?? result['data'];
            int _total = int.parse(result['total'].toString());
            int _count = int.parse(result['count'].toString());

            for (var postData in _topics) {
                if (postData != null && postData != "") {
                    postList.add(TeamPostAPI.createPost(postData));
                }
            }
            _postList = postList;

            if (mounted) {
                setState(() {
                    _showLoading = false;
                    _firstLoadComplete = true;
                    _isLoading = false;
                    _canLoadMore = _postList.length < _total && _count != 0;
                    _lastTimeStamp = int.parse(result['min_ts']);
                });
            }
        }
    }
}
