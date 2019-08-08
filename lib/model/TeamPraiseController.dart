import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/api/TeamAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/widgets/cards/PraiseCard.dart';

class TeamPraiseController {
    final bool isMore;
    final Function lastValue;
    final Map<String, dynamic> additionAttrs;

    TeamPraiseController({@required this.isMore, @required this.lastValue, this.additionAttrs});
}

class TeamPraiseList extends StatefulWidget {
    final TeamPraiseController _praiseController;
    final bool needRefreshIndicator;

    TeamPraiseList(this._praiseController, {Key key, this.needRefreshIndicator = true}) : super(key: key);

    @override
    State createState() => _TeamPraiseListState();
}

class _TeamPraiseListState extends State<TeamPraiseList> with AutomaticKeepAliveClientMixin {
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
        child: Constants.progressIndicator(),
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
                                                child: Constants.progressIndicator(strokeWidth: 2.0),
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
                    child: Constants.progressIndicator(),
                ),
            );
        }
    }

    Future<Null> _loadData() async {
        _firstLoadComplete = true;
        if (!_isLoading && _canLoadMore) {
            _isLoading = true;

            Map result = (await TeamPraiseAPI.getPraiseList(true, _lastValue)).data;

            List<Praise> praiseList = [];
            List _topics = result['topics'];
            int _total = int.parse(result['total'].toString());
            int _count = int.parse(result['count'].toString());

            for (var praiseData in _topics) praiseList.add(TeamPraiseAPI.createPraise(praiseData));
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

            Map result = (await TeamPraiseAPI.getPraiseList(false, _lastValue)).data;

            List<Praise> praiseList = [];
            List _topics = result['topics'];
            int _total = int.parse(result['total'].toString());
            int _count = int.parse(result['count'].toString());

            for (var praiseData in _topics) praiseList.add(TeamPraiseAPI.createPraise(praiseData));
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
}


class TeamPraiseListInPost extends StatefulWidget {
    final List praisors;
    TeamPraiseListInPost(this.praisors, {Key key}) : super(key: key);

    @override
    State createState() => _TeamPraiseListInPostState();
}

class _TeamPraiseListInPostState extends State<TeamPraiseListInPost> {
    int lastValue;

    @override
    void initState() {
        super.initState();
        if (widget.praisors != null) {
            widget.praisors.forEach((praisor) {
                debugPrint("Praisor: $praisor");
            });
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
                        image: UserAPI.getAvatarProvider(uid: int.parse(praise['uid'].toString())),
                        fit: BoxFit.cover,
                    ),
                ),
            ),
            onTap: () { UserPage.jump(context, int.parse(praise['uid'].toString())); },
        );
    }

    Text getPostNickname(context, praise) {
        return Text(
            praise['nickname'],
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
            child: Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.zero,
                child: ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Container(
                        color: Theme.of(context).dividerColor,
                        height: Constants.suSetSp(1.0),
                    ),
                    itemCount: widget.praisors?.length,
                    itemBuilder: (context, index) {
                        return Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                getPostAvatar(context, widget.praisors[index]),
                                Expanded(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            getPostNickname(context, widget.praisors[index]),
                                        ],
                                    ),
                                ),
                            ],
                        );
                    },
                ),
            ),
        );
    }
}
