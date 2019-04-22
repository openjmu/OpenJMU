import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/cards/PraiseCard.dart';

class PraiseAPI {
  static getPraiseList(bool isMore, int lastValue, {additionAttrs}) async {
    String _praiseUrl;
    if (isMore) {
      _praiseUrl = "${Api.praiseList}/id_max/$lastValue";
    } else {
      _praiseUrl = "${Api.praiseList}";
    }
    return NetUtils.getWithCookieAndHeaderSet(_praiseUrl);
  }
  static getPraiseInPostList(postId) {
    return NetUtils.getWithCookieAndHeaderSet("${Api.postPraisesList}$postId");
  }


  static requestPraise(id, isPraise) async {
    if (isPraise) {
      return NetUtils.postWithCookieAndHeaderSet("${Api.postRequestPraise}$id")
          .catchError((e) {
            print(e.response);
          });
    } else {
      return NetUtils.deleteWithCookieAndHeaderSet("${Api.postRequestPraise}$id")
          .catchError((e) {
            print(e.response);
          });
    }
  }


  static Praise createPraiseInPost(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f100";
    String _praiseTime = new DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
      .toString()
      .substring(0,16);
    Praise _praise = new Praise(
      itemData['id'],
      itemData['user']['uid'],
      _avatar,
      null,
      _praiseTime,
      itemData['user']['nickname'],
      null,
      null,
      null,
      null,
    );
    return _praise;

  }
  static Praise createPraise(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f100";
    String _praiseTime = new DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
        .toString()
        .substring(0,16);
    Praise _praise = new Praise(
      itemData['id'],
      itemData['user']['uid'],
      _avatar,
      int.parse(itemData['topic']['tid']),
      _praiseTime,
      itemData['user']['nickname'],
      itemData['topic'],
      int.parse(itemData['topic']['user']['uid']),
      itemData['topic']['user']['nickname'],
      itemData['topic']['image'],
    );
    return _praise;
  }

}

class PraiseController {
  final bool isMore;
  final Function lastValue;
  final Map<String, dynamic> additionAttrs;

  PraiseController({
    @required this.isMore,
    @required this.lastValue,
    this.additionAttrs
  });
}

class PraiseList extends StatefulWidget {
  final PraiseController _praiseController;
  final bool needRefreshIndicator;

  PraiseList(this._praiseController, {
    Key key, this.needRefreshIndicator = true
  }) : super(key: key);

  @override
  State createState() => _PraiseListState();
}

class _PraiseListState extends State<PraiseList> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = new ScrollController();
  Color currentColorTheme = ThemeUtils.currentColorTheme;

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
    child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme)
    ),
  );

  List<Praise> _praiseList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
      if ( this.mounted && event.type == "Praise" ) {
        _scrollController.animateTo(0, duration: new Duration(milliseconds: 500), curve: Curves.ease);
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
          child: Text('加载失败，轻触重试', style: TextStyle(color: ThemeUtils.currentColorTheme)),
        ),
      ),
    );

    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showLoading) {
      if (_firstLoadComplete) {
        _itemList = ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          itemBuilder: (context, index) {
            if (index == _praiseList.length) {
              if (this._canLoadMore) {
                _loadData();
                return Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                            width: 15.0,
                            height: 15.0,
                            child: Platform.isAndroid
                                ? CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(currentColorTheme)
                            )
                                : CupertinoActivityIndicator()
                        ),
                        Text("　正在加载", style: TextStyle(fontSize: 14.0))
                      ],
                    )
                );
              } else {
                return Container(height: 40.0, child: Center(child: Text("没有更多了~")));
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
          child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(currentColorTheme)
          ),
        ),
      );
    }
  }

  Future<Null> _loadData() async {
    _firstLoadComplete = true;
    if (!_isLoading && _canLoadMore) {
      _isLoading = true;

      var result = await PraiseAPI.getPraiseList(
          true,
          _lastValue,
          additionAttrs: widget._praiseController.additionAttrs
      );
      List<Praise> praiseList = [];
      List _topics = jsonDecode(result)['topics'];
      for (var praiseData in _topics) {
        praiseList.add(PraiseAPI.createPraise(praiseData));
      }
      _praiseList.addAll(praiseList);
//      error = !result['success'];

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _topics.isNotEmpty;
          _lastValue = _praiseList.isEmpty
              ? 0
              : widget._praiseController.lastValue(_praiseList.last);
        });
      }
    }
  }

  Future<Null> _refreshData() async {
    if (!_isLoading) {
      _isLoading = true;
      _praiseList.clear();

      _lastValue = 0;

      var result = await PraiseAPI.getPraiseList(
          false,
          _lastValue,
          additionAttrs: widget._praiseController.additionAttrs
      );
      List<Praise> praiseList = [];
      List _topics = jsonDecode(result)['topics'];
      for (var praiseData in _topics) {
        praiseList.add(PraiseAPI.createPraise(praiseData));
      }
      _praiseList.addAll(praiseList);
//      error = !result['success'] ?? false;

      if (mounted) {
        setState(() {
          _showLoading = false;
          _firstLoadComplete = true;
          _isLoading = false;
          _canLoadMore = _topics.isNotEmpty;
          _lastValue = _praiseList.isEmpty
              ? 0
              : widget._praiseController.lastValue(_praiseList.last);

        });
      }
    }
  }
}


class PraiseInPostController {
  _PraiseInPostListState _praiseInPostListState;

  void reload() {
    _praiseInPostListState?._refreshData();
  }
}

class PraiseInPostList extends StatefulWidget {
  final Post post;
  final PraiseInPostController praiseInPostController;

  PraiseInPostList(this.post, this.praiseInPostController, {Key key}) : super(key: key);

  @override
  State createState() => _PraiseInPostListState();
}

class _PraiseInPostListState extends State<PraiseInPostList> {
  List<Praise> _praises = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getPraiseList();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      _praises = [];
    });
    _getPraiseList();
  }

  Future<Null> _getPraiseList() async {
    setState(() {
      isLoading = true;
    });
    var list = await PraiseAPI.getPraiseInPostList(widget.post.id);
    List<dynamic> response = jsonDecode(list)['praisors'];
    List<Praise> praises = [];
    response.forEach((praise) {
      praises.add(PraiseAPI.createPraiseInPost(praise));
    });
    if (this.mounted) {
      setState(() {
        isLoading = false;
        _praises = praises;
        Constants.eventBus.fire(new PraiseInPostUpdatedEvent(widget.post.id, praises.length));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Theme.of(context).cardColor,
        width: MediaQuery.of(context).size.width,
        padding: isLoading
            ? EdgeInsets.symmetric(vertical: 42)
            : EdgeInsets.zero,
        child: isLoading
            ? Center(child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme)
        ))
            : PraiseCardInPost(_praises)
    );
  }

}