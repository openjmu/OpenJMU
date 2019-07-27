import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';

import 'package:OpenJMU/api/PraiseAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/widgets/cards/PraiseCard.dart';

class PraiseController {
    final bool isMore;
    final Function lastValue;
    final Map<String, dynamic> additionAttrs;

    PraiseController({@required this.isMore, @required this.lastValue, this.additionAttrs});
}

class PraiseList extends StatefulWidget {
    final PraiseController _praiseController;
    final bool needRefreshIndicator;

    PraiseList(this._praiseController, {Key key, this.needRefreshIndicator = true}) : super(key: key);

    @override
    State createState() => _PraiseListState();
}

class _PraiseListState extends State<PraiseList> with AutomaticKeepAliveClientMixin {
    final ScrollController _scrollController = ScrollController();
    Color currentColorTheme = ThemeUtils.currentThemeColor;

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

    List<Praise> _praiseList = [];

    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        super.initState();
        Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
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
                        style: TextStyle(color: ThemeUtils.currentThemeColor),
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
                    child: Text('加载失败，轻触重试', style: TextStyle(color: ThemeUtils.currentThemeColor)),
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
                if (!UserAPI.blacklist.contains(int.parse(praiseData['topic']['user']['uid'].toString()))) {
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
                    _lastValue = _praiseList.isEmpty ? 0 : widget._praiseController.lastValue(_praiseList.last);
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
                if (!UserAPI.blacklist.contains(int.parse(praiseData['topic']['user']['uid'].toString()))) {
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
                    _lastValue = _praiseList.isEmpty ? 0 : widget._praiseController.lastValue(_praiseList.last);
                });
            }
        }
    }

    @mustCallSuper
    Widget build(BuildContext context) {
        super.build(context);
        if (!_showLoading) {
            if (_firstLoadComplete) {
                _itemList = ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: Constants.suSetSp(4.0)),
                    separatorBuilder: (context, index) => Container(
                        color: Theme.of(context).canvasColor,
                        height: Constants.suSetSp(8.0),
                    ),
                    itemBuilder: (context, index) {
                        if (index == _praiseList.length) {
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
                                            Text("　正在加载", style: TextStyle(fontSize: Constants.suSetSp(14.0)))
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
                        } else {
                            return PraiseCard(_praiseList[index]);
                        }
                    },
                    itemCount: _praiseList.length + 1,
                    controller: _scrollController,
                );

                if (widget.needRefreshIndicator) {
                    _body = RefreshIndicator(
                        color: currentColorTheme,
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
    PraiseListInPost(this.post, {Key key}) : super(key: key);

    @override
    State createState() => _PraiseListInPostState();
}

class _PraiseListInPostState extends State<PraiseListInPost> {
    List<Praise> _praises = [];

    bool isLoading = true;
    bool canLoadMore = false;
    bool firstLoadComplete = false;

    int lastValue;

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
        setState(() {
            isLoading = true;
            _praises = [];
        });
        _refreshList();
    }

    Future<Null> _loadList() async {
        isLoading = true;
        try {
            Map<String, dynamic> response = (await PraiseAPI.getPraiseInPostList(
                widget.post.id,
                isMore: true,
                lastValue: lastValue,
            ))?.data;
            List<dynamic> list = response['praisors'];
            int total = response['total'] as int;
            if (_praises.length + list.length < total) {
                canLoadMore = true;
            } else {
                canLoadMore = false;
            }
            List<Praise> praises = [];
            list.forEach((praise) { praises.add(PraiseAPI.createPraiseInPost(praise)); });
            if (this.mounted) {
                setState(() {
                    Constants.eventBus.fire(PraiseInPostUpdatedEvent(
                        id: widget.post.id,
                        count: total,
                        type: "normal",
                    ));
                    _praises.addAll(praises);
                });
                isLoading = false;
                lastValue = _praises.isEmpty ? 0 : _praises.last.id;
            }
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
        setState(() { isLoading = true; });
        try {
            Map<String, dynamic> response = (await PraiseAPI.getPraiseInPostList(widget.post.id))?.data;
            List<dynamic> list = response['praisors'];
            int total = response['total'] as int;
            if (response['count'] as int < total) canLoadMore = true;
            List<Praise> praises = [];
            list.forEach((praise) { praises.add(PraiseAPI.createPraiseInPost(praise)); });
            if (this.mounted) {
                setState(() {
                    Constants.eventBus.fire(PraiseInPostUpdatedEvent(
                        id: widget.post.id,
                        count: total,
                        type: "normal",
                    ));
                    _praises = praises;
                    isLoading = false;
                    firstLoadComplete = true;
                });
                lastValue = _praises.isEmpty ? 0 : _praises.last.id;
            }
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

    GestureDetector getPostAvatar(context, praise) {
        return GestureDetector(
            child: Container(
                width: Constants.suSetSp(44.0),
                height: Constants.suSetSp(44.0),
                margin: EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0), vertical: Constants.suSetSp(10.0)),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFECECEC),
                    image: DecorationImage(
                        image: UserAPI.getAvatarProvider(uid: praise.uid),
                        fit: BoxFit.cover,
                    ),
                ),
            ),
            onTap: () { UserPage.jump(context, praise.uid); },
        );
    }

    Text getPostNickname(context, praise) {
        return Text(
            praise.nickname,
            style: TextStyle(
                color: Theme.of(context).textTheme.body1.color,
                fontSize: Constants.suSetSp(18.0),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Theme.of(context).cardColor,
            width: MediaQuery.of(context).size.width,
            padding: isLoading ? EdgeInsets.symmetric(vertical: Constants.suSetSp(42)) : EdgeInsets.zero,
            child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.zero,
                child: firstLoadComplete ? ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Container(
                        color: Theme.of(context).dividerColor,
                        height: Constants.suSetSp(1.0),
                    ),
                    itemCount: _praises.length + 1,
                    itemBuilder: (context, index) {
                        if (index == _praises.length) {
                            if (canLoadMore && !isLoading) {
                                _loadList();
                                return Container(
                                    height: Constants.suSetSp(40.0),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            SizedBox(
                                                width: Constants.suSetSp(15.0),
                                                height: Constants.suSetSp(15.0),
                                                child: Platform.isAndroid
                                                        ? CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                )
                                                        : CupertinoActivityIndicator(),
                                            ),
                                            Text("　正在加载", style: TextStyle(fontSize: Constants.suSetSp(14.0))),
                                        ],
                                    ),
                                );
                            } else {
                                return Container();
                            }
                        } else if (index < _praises.length) {
                            return Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    getPostAvatar(context, _praises[index]),
                                    Expanded(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                getPostNickname(context, _praises[index]),
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
                    height: Constants.suSetSp(120.0),
                    child: Center(
                        child: Text(
                            "暂无内容",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: Constants.suSetSp(18.0),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}
