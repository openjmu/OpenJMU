import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:extended_list/extended_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/praise_card.dart';

class PraiseController {
  final bool isMore;
  final Function lastValue;
  final Map<String, dynamic> additionAttrs;

  PraiseController({
    @required this.isMore,
    @required this.lastValue,
    this.additionAttrs,
  });
}

class PraiseList extends StatefulWidget {
  final PraiseController _praiseController;
  final bool needRefreshIndicator;

  PraiseList(
    this._praiseController, {
    Key key,
    this.needRefreshIndicator = true,
  }) : super(key: key);

  @override
  State createState() => _PraiseListState();
}

class _PraiseListState extends State<PraiseList> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  num _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  var _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  Widget _body = Center(child: PlatformProgressIndicator());

  List<Praise> _praiseList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<ScrollToTopEvent>().listen((event) {
      if (this.mounted && event.type == "Praise") {
        _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
    });

    _emptyChild = GestureDetector(
      onTap: () {},
      child: Container(
        child: Center(
          child: Text(
            '这里空空如也~',
            style: TextStyle(color: currentThemeColor),
          ),
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
          child: Text('加载失败，轻触重试', style: TextStyle(color: currentThemeColor)),
        ),
      ),
    );

    _refreshData();
  }

  Future<Null> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      Map result = (await PraiseAPI.getPraiseList(true, _lastValue)).data;

      List<Praise> praiseList = [];
      List _topics = result['topics'];
      int _total = int.parse(result['total'].toString());
      int _count = int.parse(result['count'].toString());

      for (var praiseData in _topics) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": praiseData['topic']['user']['uid'].toString(),
          "username": praiseData['topic']['user']['nickname'],
        }))) {
          praiseList.add(PraiseAPI.createPraise(praiseData));
        }
      }
      _praiseList.addAll(praiseList);

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _praiseList.length < _total && _count != 0;
          _lastValue =
              _praiseList.isEmpty ? 0 : widget._praiseController.lastValue(_praiseList.last);
        });
      }
    }
  }

  Future<Null> _refreshData() async {
    if (!_isLoading) {
      _isLoading = true;
      _praiseList.clear();

      _lastValue = 0;

      Map result = (await PraiseAPI.getPraiseList(false, _lastValue)).data;

      List<Praise> praiseList = [];
      List _topics = result['topics'];
      int _total = int.parse(result['total'].toString());
      int _count = int.parse(result['count'].toString());

      for (var praiseData in _topics) {
        if (!UserAPI.blacklist.contains(jsonEncode({
          "uid": praiseData['topic']['user']['uid'].toString(),
          "username": praiseData['topic']['user']['nickname'],
        }))) {
          praiseList.add(PraiseAPI.createPraise(praiseData));
        }
      }
      _praiseList.addAll(praiseList);

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _praiseList.length < _total && _count != 0;
          _lastValue =
              _praiseList.isEmpty ? 0 : widget._praiseController.lastValue(_praiseList.last);
        });
      }
    }
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      if (_firstLoadComplete) {
        _itemList = ListView.builder(
          padding: EdgeInsets.symmetric(vertical: suSetHeight(4.0)),
          itemBuilder: (context, index) {
            if (index == _praiseList.length) {
              if (this._canLoadMore) {
                _loadData();
                return SizedBox(
                  height: suSetHeight(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: suSetWidth(15.0),
                        height: suSetHeight(15.0),
                        child: Platform.isAndroid
                            ? CircularProgressIndicator(strokeWidth: 2.0)
                            : CupertinoActivityIndicator(),
                      ),
                      Text(
                        "　正在加载",
                        style: TextStyle(
                          fontSize: suSetSp(14.0),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Container(
                  height: suSetHeight(50.0),
                  color: Theme.of(context).canvasColor,
                  child: Center(
                    child: Text(
                      Constants.endLineTag,
                      style: TextStyle(
                        fontSize: suSetSp(14.0),
                      ),
                    ),
                  ),
                );
              }
            } else {
              return PraiseCard(_praiseList[index]);
            }
          },
          itemCount: _praiseList.length + 1,
          controller: _scrollController,
        );

        if (widget.needRefreshIndicator) {
          _body = RefreshIndicator(
            color: currentThemeColor,
            onRefresh: _refreshData,
            child: _praiseList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList,
          );
        } else {
          _body = _praiseList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList;
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
}

class PraiseListInPost extends StatefulWidget {
  final Post post;

  PraiseListInPost(
    this.post, {
    Key key,
  }) : super(key: key);

  @override
  State createState() => PraiseListInPostState();
}

class PraiseListInPostState extends State<PraiseListInPost> with AutomaticKeepAliveClientMixin {
  final _praises = <Praise>[];

  bool isLoading = true;
  bool canLoadMore = false;
  bool firstLoadComplete = false;

  int lastValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _refreshList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _praises.clear();
  }

  void _refreshData() {
    isLoading = true;
    _praises.clear();
    if (mounted) setState(() {});
    _refreshList();
  }

  Future<Null> _loadList() async {
    isLoading = true;
    try {
      final response = (await PraiseAPI.getPraiseInPostList(
        widget.post.id,
        isMore: true,
        lastValue: lastValue,
      ))
          ?.data;
      final list = response['praisors'];
      final total = response['total'] as int;
      if (_praises.length + list.length < total) {
        canLoadMore = true;
      } else {
        canLoadMore = false;
      }

      list.forEach((praise) {
        _praises.add(PraiseAPI.createPraiseInPost(praise));
      });

      isLoading = false;
      lastValue = _praises.isEmpty ? 0 : _praises.last.id;

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
    setState(() {
      isLoading = true;
    });
    _praises.clear();
    try {
      final response = (await PraiseAPI.getPraiseInPostList(widget.post.id))?.data;
      final list = response['praisors'];
      final total = response['total'] as int;
      if (response['count'] as int < total) canLoadMore = true;

      list.forEach((praise) {
        _praises.add(PraiseAPI.createPraiseInPost(praise));
      });

      isLoading = false;
      firstLoadComplete = true;
      lastValue = _praises.isEmpty ? 0 : _praises.last.id;
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

  Widget getPostNickname(context, praise) {
    return Text(
      praise.nickname,
      style: TextStyle(
        color: Theme.of(context).textTheme.body1.color,
        fontSize: suSetSp(20.0),
      ),
    );
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? Center(child: PlatformProgressIndicator())
        : Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.zero,
            child: firstLoadComplete
                ? ExtendedListView.separated(
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) => Divider(
                      color: Theme.of(context).dividerColor,
                      height: suSetHeight(1.0),
                    ),
                    itemCount: _praises.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _praises.length - 1 && canLoadMore) {
                        _loadList();
                      }
                      if (index == _praises.length) {
                        return LoadMoreIndicator(
                          canLoadMore: canLoadMore && !isLoading,
                        );
                      } else {
                        return Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: suSetWidth(24.0),
                                vertical: suSetHeight(10.0),
                              ),
                              child: UserAPI.getAvatar(
                                uid: _praises[index].uid,
                              ),
                            ),
                            Expanded(
                              child: getPostNickname(context, _praises[index]),
                            ),
                          ],
                        );
                      }
                    },
                  )
                : LoadMoreIndicator(canLoadMore: false),
          );
  }
}
