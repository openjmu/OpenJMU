import 'dart:async';

import 'package:extended_list/extended_list.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/praise_card.dart';

class PraiseController {
  const PraiseController({
    required this.isMore,
    required this.lastValue,
    this.additionAttrs,
  });

  final bool isMore;
  final int Function(int) lastValue;
  final Map<String, dynamic>? additionAttrs;
}

class PraiseList extends StatefulWidget {
  const PraiseList(
    this.praiseController, {
    Key? key,
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

  late final Widget _emptyChild = const Center(child: Text('无点赞信息'));

  late final Widget _errorChild = Tapper(
    onTap: () {
      setState(() {
        _isLoading = false;
        _showLoading = true;
        _refreshData();
      });
    },
    child: const Center(child: Text('加载失败，轻触重试')),
  );
  bool error = false;

  final List<Praise> _praiseList = <Praise>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      final Response<Map<String, dynamic>> res = await PraiseAPI.getPraiseList(
        isMore: true,
        lastValue: _lastValue,
      );
      final Map<String, dynamic> result = res.data!;

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

      _showLoading = false;
      _firstLoadComplete = true;
      _isLoading = false;
      _canLoadMore = _praiseList.length < _total && _count != 0;
      _lastValue = _praiseList.isEmpty
          ? 0
          : widget.praiseController.lastValue(_praiseList.last.id);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _refreshData() async {
    if (!_isLoading) {
      _isLoading = true;
      _praiseList.clear();

      _lastValue = 0;

      final Response<Map<String, dynamic>> r = await PraiseAPI.getPraiseList();
      final Map<String, dynamic> result = r.data!;

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

      _showLoading = false;
      _firstLoadComplete = true;
      _isLoading = false;
      _canLoadMore = _praiseList.length < _total && _count != 0;
      _lastValue = _praiseList.isEmpty
          ? 0
          : widget.praiseController.lastValue(_praiseList.last.id);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_showLoading || !_firstLoadComplete) {
      return const Center(
        child: LoadMoreSpinningIcon(isRefreshing: true),
      );
    }
    Widget _body;
    final Widget _itemList = ExtendedListView.builder(
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

    _body = DefaultTextStyle.merge(
      style: context.textTheme.caption?.copyWith(
        fontSize: 20.sp,
      ),
      child:
          _praiseList.isEmpty ? (error ? _errorChild : _emptyChild) : _itemList,
    );
    if (widget.needRefreshIndicator) {
      _body = RefreshIndicator(
        color: currentThemeColor,
        onRefresh: _refreshData,
        child: _body,
      );
    }
    return _body;
  }
}

class PraiseListInPost extends StatefulWidget {
  const PraiseListInPost(this.post, {Key? key}) : super(key: key);

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

  int lastValue = 0;

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

  Future<void> _loadList() async {
    isLoading = true;
    try {
      final Response<Map<String, dynamic>> r =
          await PraiseAPI.getPraiseInPostList(
        widget.post.id,
        isMore: true,
        lastValue: lastValue,
      );
      final Map<String, dynamic> response = r.data!;
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
      LogUtils.e(e.response?.data ?? e.message);
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
      final Response<Map<String, dynamic>> r =
          await PraiseAPI.getPraiseInPostList(widget.post.id);
      final Map<String, dynamic> response = r.data!;
      final List<Map<String, dynamic>> list =
          (response['praisors'] as List<dynamic>).cast<Map<String, dynamic>>();
      final int total = response['total'] as int;
      canLoadMore = response['count'] as int < total;

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
      LogUtils.e(e.response?.data ?? e.message);
    } catch (e) {
      LogUtils.e(e);
    }
  }

  Widget getPostNickname(BuildContext context, Praise praise) {
    return Text(
      praise.nickname,
      style: TextStyle(
        height: 1.2,
        fontSize: 19.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) {
      return const Center(
        child: LoadMoreSpinningIcon(isRefreshing: true),
      );
    }
    if (!firstLoadComplete) {
      return const LoadMoreIndicator(canLoadMore: false);
    }
    return ExtendedListView.separated(
      padding: EdgeInsets.zero,
      separatorBuilder: (_, __) => const LineDivider(),
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
          final Praise _praise = _praises[index];
          return ColoredBox(
            color: context.surfaceColor,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 10.h,
                  ),
                  child: UserAvatar(
                    uid: _praise.uid,
                    isSysAvatar: _praise.user.sysAvatar,
                  ),
                ),
                Flexible(child: getPostNickname(context, _praise)),
                if (Constants.developerList.contains(_praise.uid))
                  Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: const DeveloperTag(),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
