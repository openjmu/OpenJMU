///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-24 04:39
///
import 'dart:convert';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_post_detail_page.dart';

class TeamMentionListPage extends StatefulWidget {
  @override
  _TeamMentionListPageState createState() => _TeamMentionListPageState();
}

class _TeamMentionListPageState extends State<TeamMentionListPage> {
  bool _shouldInit = true;
  bool loading = true, canLoadMore = true;

  int page = 1, total;

  List<TeamMentionItem> mentionedList = [];

  @override
  void initState() {
    if (_shouldInit) loadList();
    _shouldInit = false;
    super.initState();
  }

  void loadList({bool loadMore = false}) {
    if (loadMore) ++page;
    TeamPostAPI.getMentionedList(page: page).then((response) {
      final data = response.data;
      data['list'].forEach((item) {
        mentionedList.add(TeamMentionItem.fromJson(item));
      });
      total = int.tryParse(data['total'].toString());
      canLoadMore = int.tryParse(data['count'].toString()) == 0;
    }).whenComplete(() {
      loading = false;
      if (mounted) setState(() {});
    });
  }

  Widget _header(context, int index, TeamMentionItem item) => Container(
        height: suSetHeight(80.0),
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(8.0),
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: item.fromUserId),
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
                        style: TextStyle(
                          fontSize: suSetSp(19.0),
                          fontWeight: FontWeight.bold,
                        ),
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
                      _postTime(
                        context,
                        item.post?.postTime ?? item.comment?.postTime,
                      ),
                    ],
                  ),
                  Text(
                    mentionedList[index].scope['name'],
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: suSetSp(15.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _postTime(context, DateTime postTime) {
    final now = DateTime.now();
    DateTime _postTime = postTime;
    String time = "";
    if (_postTime.day == now.day && _postTime.month == now.month && _postTime.year == now.year) {
      time += DateFormat("HH:mm").format(_postTime);
    } else if (postTime.year == now.year) {
      time += DateFormat("MM-dd HH:mm").format(_postTime);
    } else {
      time += DateFormat("yyyy-MM-dd HH:mm").format(_postTime);
    }
    return Text(
      "$time",
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(16.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget _content(TeamMentionItem item) => Padding(
        padding: EdgeInsets.only(
          bottom: suSetHeight(10.0),
        ),
        child: ExtendedText(
          item.post?.content ?? item.comment?.content ?? "",
          style: TextStyle(
            fontSize: suSetSp(18.0),
          ),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 8,
          overFlowTextSpan: OverFlowTextSpan(
            children: <TextSpan>[
              TextSpan(text: " ... "),
              TextSpan(
                text: "全文",
                style: TextStyle(
                  color: currentThemeColor,
                  fontSize: suSetSp(18.0),
                ),
              ),
            ],
          ),
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: !loading
          ? mentionedList.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: mentionedList.length + 1,
                  itemBuilder: (_, index) {
                    if (index == mentionedList.length - 1 && canLoadMore) {
                      loadList(loadMore: true);
                    }
                    if (index == mentionedList.length) {
                      return LoadMoreIndicator(canLoadMore: canLoadMore);
                    }
                    final item = mentionedList.elementAt(index);
                    final provider = TeamPostProvider(item.post);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            navigatorState.pushNamed(
                              Routes.OPENJMU_TEAM_POST_DETAIL,
                              arguments: {
                                "provider": provider,
                                "type": item.type == TeamMentionType.post
                                    ? TeamPostType.post
                                    : TeamPostType.comment,
                                "postId": item.comment?.originId,
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
                              borderRadius: BorderRadius.circular(suSetWidth(10.0)),
                              color: Theme.of(context).cardColor,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _header(context, index, item),
                                _content(item),
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
                    "暂无内容",
                    style: TextStyle(
                      color: currentThemeColor,
                      fontSize: suSetSp(24.0),
                    ),
                  ),
                )
          : Center(child: PlatformProgressIndicator()),
    );
  }
}

class TeamMentionItem {
  int postId;
  TeamPost post;
  TeamPostComment comment;
  Map scope;
  int fromUserId;
  String fromUsername;
  TeamMentionType type;

  TeamMentionItem({
    this.postId,
    this.post,
    this.comment,
    this.scope,
    this.fromUserId,
    this.fromUsername,
    this.type,
  });

  factory TeamMentionItem.fromJson(Map<String, dynamic> json) {
    final user = json['user_info'];
    return TeamMentionItem(
      postId: int.parse(json['post_id'].toString()),
      post: TeamPost.fromJson(json['post_info']),
      comment: TeamPostComment.fromJson(json['reply_info']),
      scope: json['scope'],
      fromUserId: int.parse(user['uid'].toString()),
      fromUsername: user['nickname'],
      type: json['type'] == 't' ? TeamMentionType.post : TeamMentionType.thread,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "postId": postId,
      "post": post,
      "comment": comment,
      "scope": scope,
      "fromUserId": fromUserId,
      "fromUsername": fromUsername,
      "type": type,
    };
  }

  @override
  String toString() {
    return JsonEncoder.withIndent("  ").convert(toJson());
  }
}

enum TeamMentionType { post, thread }
