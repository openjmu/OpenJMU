import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_list/extended_list.dart';
import 'package:dio/dio.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/praise_card.dart';

class PraiseController {
  const PraiseController({
    @required this.isMore,
    @required this.lastValue,
    this.additionAttrs,
  });

  final bool isMore;
  final int Function(int) lastValue;
  final Map<String, dynamic> additionAttrs;
}

class PraiseList extends StatefulWidget {
  const PraiseList(
    this.praiseController, {
    Key key,
    this.needRefreshIndicator = true,
  }) : super(key: key);

  final PraiseController praiseController;
  final bool needRefreshIndicator;

  @override
  State createState() => _PraiseListState();
}

class _PraiseListState extends State<PraiseList>
    with AutomaticKeepAliveClientMixin {
  int _lastValue = 0;
  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  Widget _itemList;

  Widget _emptyChild;
  Widget _errorChild;
  bool error = false;

  final List<Praise> _praiseList = <Praise>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

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
          child: Text(
            '加载失败，轻触重试',
            style: TextStyle(color: currentThemeColor),
          ),
        ),
      ),
    );

    _refreshData();
  }

  Future<void> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      final Map<String, dynamic> result = (await PraiseAPI.getPraiseList(
        true,
        _lastValue,
      ))
          .data;

      final List<Praise> praiseList = <Praise>[];
      final List<Map<String, dynamic>> _topics =
          (result['topics'] as List<dynamic>).cast<Map<String, dynamic>>();
      final int _total = result['total'].toString().toInt();
      final int _count = result['count'].toString().toInt();

      for (final Map<String, dynamic> praiseData in _topics) {
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': praiseData['topic']['user']['uid'].toString(),
            'username': praiseData['topic']['user']['nickname'],
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
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
          _lastValue = _praiseList.isEmpty
              ? 0
              : widget.praiseController.lastValue(_praiseList.last.id);
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (!_isLoading) {
      _isLoading = true;
      _praiseList.clear();

      _lastValue = 0;

      final Map<String, dynamic> result = (await PraiseAPI.getPraiseList(
        false,
        _lastValue,
      ))
          .data;

      final List<Praise> praiseList = <Praise>[];
      final List<Map<String, dynamic>> _topics =
          (result['topics'] as List<dynamic>).cast<Map<String, dynamic>>();
      final int _total = result['total'].toString().toInt();
      final int _count = result['count'].toString().toInt();

      for (final Map<String, dynamic> praiseData in _topics) {
        final BlacklistUser user = BlacklistUser.fromJson(
          <String, dynamic>{
            'uid': praiseData['topic']['user']['uid'].toString(),
            'username': praiseData['topic']['user']['nickname'],
          },
        );
        if (!UserAPI.blacklist.contains(user)) {
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
          _lastValue = _praiseList.isEmpty
              ? 0
              : widget.praiseController.lastValue(_praiseList.last.id);
        });
      }
    }
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      Widget _body;
      if (_firstLoadComplete) {
        _itemList = ExtendedListView.builder(
          padding: EdgeInsets.symmetric(vertical: 6.w),
          extendedListDelegate: const ExtendedListDelegate(),
          itemBuilder: (BuildContext context, int index) {
            if (index == _praiseList.length) {
              if (_canLoadMore) {
                _loadData();
                return const LoadMoreIndicator();
              }
              return LoadMoreIndicator(canLoadMore: _canLoadMore);
            } else {
              return PraiseCard(_praiseList[index]);
            }
          },
          itemCount: _praiseList.length + 1,
        );

        if (widget.needRefreshIndicator) {
          _body = RefreshIndicator(
            color: currentThemeColor,
            onRefresh: _refreshData,
            child: _praiseList.isEmpty
                ? (error ? _errorChild : _emptyChild)
                : _itemList,
          );
        } else {
          _body = _praiseList.isEmpty
              ? (error ? _errorChild : _emptyChild)
              : _itemList;
        }
      }
      return _body;
    } else {
      return const SpinKitWidget();
    }
  }
}

class PraiseListInPost extends StatefulWidget {
  const PraiseListInPost(
    this.post, {
    Key key,
  }) : super(key: key);

  final Post post;

  @override
  PraiseListInPostState createState() => PraiseListInPostState();
}

class PraiseListInPostState extends State<PraiseListInPost>
    with AutomaticKeepAliveClientMixin {
  final List<Praise> _praises = <Praise>[];

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

  @override
  void dispose() {
    super.dispose();
    _praises.clear();
  }

  void _refreshData() {
    isLoading = true;
    _praises.clear();
    if (mounted) {
      setState(() {});
    }
    _refreshList();
  }

  Future<void> _loadList() async {
    isLoading = true;
    try {
      final Map<String, dynamic> response =
          (await PraiseAPI.getPraiseInPostList(
        widget.post.id,
        isMore: true,
        lastValue: lastValue,
      ))
              ?.data;
      final List<Map<String, dynamic>> list =
          (response['praisors'] as List<dynamic>).cast<Map<String, dynamic>>();
      final int total = response['total'] as int;
      if (_praises.length + list.length < total) {
        canLoadMore = true;
      } else {
        canLoadMore = false;
      }

      for (final Map<String, dynamic> praiseData in list) {
        _praises.add(PraiseAPI.createPraiseInPost(praiseData));
      }

      isLoading = false;
      lastValue = _praises.isEmpty ? 0 : _praises.last.id;

      if (mounted) {
        setState(() {});
      }
    } on DioError catch (e) {
      if (e.response != null) {
        LogUtils.e(e.response.data);
      }
      LogUtils.e(e.request);
      LogUtils.e(e.message);
      return;
    } catch (e) {
      LogUtils.e(e);
    }
  }

  Future<void> _refreshList() async {
    setState(() {
      isLoading = true;
    });
    _praises.clear();
    try {
      final Map<String, dynamic> response =
          (await PraiseAPI.getPraiseInPostList(widget.post.id))?.data;
      final List<Map<String, dynamic>> list =
          (response['praisors'] as List<dynamic>).cast<Map<String, dynamic>>();
      final int total = response['total'] as int;
      if (response['count'] as int < total) {
        canLoadMore = true;
      }

      for (final Map<String, dynamic> praiseData in list) {
        _praises.add(PraiseAPI.createPraiseInPost(praiseData));
      }

      isLoading = false;
      firstLoadComplete = true;
      lastValue = _praises.isEmpty ? 0 : _praises.last.id;

      if (mounted) {
        setState(() {});
      }
    } on DioError catch (e) {
      if (e.response != null) {
        LogUtils.e(e.response.data);
      }
      LogUtils.e(e.request);
      LogUtils.e(e.message);
      return;
    } catch (e) {
      LogUtils.e(e);
    }
  }

  Widget getPostNickname(BuildContext context, Praise praise) {
    return Text(
      praise.nickname,
      style: TextStyle(fontSize: 20.sp),
    );
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? const SpinKitWidget()
        : firstLoadComplete
            ? ExtendedListView.separated(
                padding: EdgeInsets.zero,
                separatorBuilder: (BuildContext context, int index) => Divider(
                  color: Theme.of(context).dividerColor,
                  height: 1.h,
                ),
                extendedListDelegate: const ExtendedListDelegate(),
                itemCount: _praises.length + 1,
                itemBuilder: (BuildContext context, int index) {
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
                            horizontal: 24.w,
                            vertical: 10.h,
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
            : const LoadMoreIndicator(canLoadMore: false);
  }
}
