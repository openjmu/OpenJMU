///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-24 06:52
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class TeamReplyListPage extends StatefulWidget {
  @override
  _TeamReplyListPageState createState() => _TeamReplyListPageState();
}

class _TeamReplyListPageState extends State<TeamReplyListPage> {
  bool _shouldInit = true;
  bool loading = true, canLoadMore = true;

  int page = 1, total;

  List<TeamReplyItem> replyList = <TeamReplyItem>[];

  @override
  void initState() {
    super.initState();
    if (_shouldInit) {
      loadList();
    }
    _shouldInit = false;
  }

  void loadList({bool loadMore = false}) {
    if (loadMore) {
      ++page;
    }
    TeamCommentAPI.getReplyList(page: page).then(
      (Response<Map<String, dynamic>> response) {
        final Map<String, dynamic> data = response.data;
        for (final dynamic _item in data['list']) {
          final Map<String, dynamic> item = _item as Map<String, dynamic>;
          replyList.add(TeamReplyItem.fromJson(item));
        }
        total = int.tryParse(data['total'].toString());
        canLoadMore = int.tryParse(data['count'].toString()) == 0;
      },
    ).whenComplete(() {
      loading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _header(BuildContext context, int index, TeamReplyItem item) {
    return Container(
      height: suSetHeight(80.0),
      padding: EdgeInsets.symmetric(vertical: suSetHeight(8.0)),
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
                    const Spacer(),
                    _postTime(
                        context, item.post?.postTime ?? item.comment?.postTime),
                  ],
                ),
                Text(
                  replyList[index].scope['name'] as String,
                  style: TextStyle(color: Colors.blue, fontSize: suSetSp(17.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _postTime(BuildContext context, DateTime postTime) {
    final DateTime now = currentTime;
    final DateTime _postTime = postTime;
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
      time,
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(18.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget _content(TeamReplyItem item) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(6.0),
        ),
        child: ExtendedText(
          item.post?.content ?? item.comment?.content ?? '',
          style: TextStyle(fontSize: suSetSp(21.0)),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 8,
          overflowWidget: TextOverflowWidget(
            child: Text(
              '全文',
              style: TextStyle(color: currentThemeColor),
            ),
          ),
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  Widget _rootContent(TeamReplyItem item) => Container(
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(vertical: suSetHeight(6.0)),
        padding: EdgeInsets.all(suSetWidth(8.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
          color: Theme.of(context).canvasColor,
        ),
        child: ExtendedText(
          item.toPost.content,
          style: TextStyle(fontSize: suSetSp(20.0)),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(
            prefixSpans: <InlineSpan>[
              TextSpan(
                text: item.type == TeamReplyType.post ? '回复我的帖子：' : '评论我的回帖：',
                style: TextStyle(
                    color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      );

  Widget replyItemBuilder(BuildContext context, int index) {
    if (index == replyList.length - 1 && canLoadMore) {
      loadList(loadMore: true);
    }
    if (index == replyList.length) {
      return LoadMoreIndicator(
        canLoadMore: canLoadMore,
      );
    }
    final TeamReplyItem item = replyList.elementAt(index);
    TeamPostProvider provider;
    if (item.post == null) {
      provider = TeamPostProvider(item.toPost);
    } else if (item.comment == null) {
      provider = TeamPostProvider(item.post);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            navigatorState.pushNamed(
              Routes.openjmuTeamPostDetail,
              arguments: <String, dynamic>{
                'provider': provider,
                'type': TeamPostType.comment
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
                _rootContent(item),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: !loading
          ? replyList.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: replyList.length + 1,
                  itemBuilder: replyItemBuilder,
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
          : const SpinKitWidget(),
    );
  }
}

class TeamReplyItem {
  TeamReplyItem({
    this.post,
    this.comment,
    this.toPost,
    this.scope,
    this.fromUserId,
    this.fromUsername,
    this.type,
  });

  factory TeamReplyItem.fromJson(Map<String, dynamic> json) {
    final TeamPost toPost =
        TeamPost.fromJson(json['to_post_info'] as Map<String, dynamic>);
    final Map<String, dynamic> user = json['user_info'] as Map<String, dynamic>;
    return TeamReplyItem(
      post: TeamPost.fromJson(json['post_info'] as Map<String, dynamic>),
      comment: TeamPostComment.fromJson(
        json['reply_info'] as Map<String, dynamic>,
      ),
      toPost: toPost,
      scope: json['to_post_info']['scope'] as Map<String, dynamic>,
      fromUserId: user['uid'].toString().toInt(),
      fromUsername: user['nickname'] as String,
      type: json['to_post_info']['type'] == 'first'
          ? TeamReplyType.post
          : TeamReplyType.thread,
    );
  }

  final TeamPost post;
  final TeamPostComment comment;
  final TeamPost toPost;
  final Map<String, dynamic> scope;
  final int fromUserId;
  final String fromUsername;
  final TeamReplyType type;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'post': post,
      'comment': comment,
      'toPost': toPost,
      'scope': scope,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'type': type,
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}

enum TeamReplyType { post, thread }
