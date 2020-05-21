///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-24 08:23
///
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_post_detail_page.dart';

class TeamPraiseListPage extends StatefulWidget {
  @override
  _TeamPraiseListPageState createState() => _TeamPraiseListPageState();
}

class _TeamPraiseListPageState extends State<TeamPraiseListPage> {
  bool _shouldInit = true;
  bool loading = true, canLoadMore = true;

  int page = 1, total;

  List<TeamPraiseItem> praiseList = [];

  @override
  void initState() {
    super.initState();
    if (_shouldInit) loadList();
    _shouldInit = false;
  }

  void loadList({bool loadMore = false}) {
    if (loadMore) ++page;
    TeamPraiseAPI.getPraiseList(page: page).then((response) {
      final data = response.data;
      data['list'].forEach((item) {
        praiseList.add(TeamPraiseItem.fromJson(item));
      });
      total = int.tryParse(data['total'].toString());
      canLoadMore = int.tryParse(data['count'].toString()) == 0;
    }).whenComplete(() {
      loading = false;
      if (mounted) setState(() {});
    });
  }

  Widget _header(context, int index, TeamPraiseItem item) {
    return Container(
      height: suSetHeight(80.0),
      padding: EdgeInsets.symmetric(
        vertical: suSetHeight(8.0),
      ),
      child: Row(
        children: <Widget>[
          UserAPI.getAvatar(size: 54.0, uid: item.fromUserId),
          SizedBox(width: suSetWidth(16.0)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      item.fromUsername ?? item.fromUserId.toString(),
                      style: TextStyle(fontSize: suSetSp(22.0)),
                    ),
                    if (Constants.developerList.contains(item.fromUserId))
                      Container(
                        margin: EdgeInsets.only(left: suSetWidth(14.0)),
                        child: DeveloperTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetWidth(8.0),
                            vertical: suSetHeight(4.0),
                          ),
                        ),
                      ),
                    Spacer(),
                    _postTime(context, item.time),
                  ],
                ),
                Text(
                  praiseList[index].scope['name'],
                  style: TextStyle(color: Colors.blue, fontSize: suSetSp(17.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _postTime(context, DateTime postTime) {
    final now = DateTime.now();
    DateTime _postTime = postTime;
    String time = '';
    if (_postTime.day == now.day &&
        _postTime.month == now.month &&
        _postTime.year == now.year) {
      time += DateFormat('HH:mm').format(_postTime);
    } else if (_postTime.year == now.year) {
      time += DateFormat('MM-dd HH:mm').format(_postTime);
    } else {
      time += DateFormat('yyyy-MM-dd HH:mm').format(_postTime);
    }
    return Text(
      '$time',
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(18.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget _content(TeamPraiseItem item) => Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(6.0)),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: '赞了我的帖子 '),
              WidgetSpan(
                alignment: ui.PlaceholderAlignment.middle,
                child: Icon(
                  Icons.thumb_up,
                  size: suSetWidth(21.0),
                  color: currentThemeColor,
                ),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: suSetSp(21.0),
          ),
        ),
      );

  Widget _rootContent(TeamPraiseItem item) => Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(
          top: suSetHeight(6.0),
          bottom: suSetHeight(12.0),
        ),
        padding: EdgeInsets.all(suSetWidth(8.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
          color: Theme.of(context).canvasColor,
        ),
        child: ExtendedText(
          item.post.content,
          style: TextStyle(
            fontSize: suSetSp(18.0),
          ),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: !loading
          ? praiseList.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: praiseList.length + 1,
                  itemBuilder: (_, index) {
                    if (index == praiseList.length - 1 && canLoadMore) {
                      loadList(loadMore: true);
                    }
                    if (index == praiseList.length) {
                      return LoadMoreIndicator(canLoadMore: canLoadMore);
                    }
                    final item = praiseList.elementAt(index);
                    final provider = TeamPostProvider(item.post);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            navigatorState.pushNamed(
                              Routes.openjmuTeamPostDetail,
                              arguments: {
                                'provider': provider,
                                'type': TeamPostType.post,
                              },
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: suSetWidth(12.0),
                              vertical: suSetHeight(6.0),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: suSetWidth(24.0),
                              vertical: suSetHeight(8.0),
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(suSetWidth(10.0)),
                              color: Theme.of(context).cardColor,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _header(context, index, item),
                                _content(item),
                                _rootContent(item),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Center(
                  child: Text(
                    '暂无内容',
                    style: TextStyle(
                      color: currentThemeColor,
                      fontSize: suSetSp(24.0),
                    ),
                  ),
                )
          : SpinKitWidget(),
    );
  }
}

class TeamPraiseItem {
  TeamPost post;
  String from;
  DateTime time;
  Map scope;
  int fromUserId;
  String fromUsername;

  TeamPraiseItem({
    this.post,
    this.from,
    this.time,
    this.scope,
    this.fromUserId,
    this.fromUsername,
  });

  factory TeamPraiseItem.fromJson(Map<String, dynamic> json) {
    final post = TeamPost.fromJson(json['post_info']);
    final user = json['user_info'];
    return TeamPraiseItem(
      post: post,
      from: json['from'],
      time: DateTime.fromMillisecondsSinceEpoch(
          int.parse(json['post_time'].toString())),
      scope: json['post_info']['scope'],
      fromUserId: int.parse(user['uid'].toString()),
      fromUsername: user['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post': post,
      'from': from,
      'time': time.toString(),
      'scope': scope,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
    };
  }

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }
}
