///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-24 06:52
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class TeamReplyListPage extends StatefulWidget {
  const TeamReplyListPage({Key key}) : super(key: key);

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
      height: 70.w,
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: Row(
        children: <Widget>[
          UserAPI.getAvatar(uid: item.fromUserId),
          Gap(16.w),
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
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (Constants.developerList.contains(item.fromUserId))
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: const DeveloperTag(),
                      ),
                    const Spacer(),
                    _postTime(
                        context, item.post?.postTime ?? item.comment?.postTime),
                  ],
                ),
                Text(
                  replyList[index].scope['name'] as String,
                  style: TextStyle(color: Colors.blue, fontSize: 17.sp),
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
      style: context.textTheme.caption.copyWith(
        fontSize: 17.sp,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _content(TeamReplyItem item) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: ExtendedText(
          item.post?.content ?? item.comment?.content ?? '',
          style: TextStyle(fontSize: 19.sp),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 8,
          overflowWidget: contentOverflowWidget,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  Widget _rootContent(TeamReplyItem item) => Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(top: 6.h, bottom: 12.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: Theme.of(context).canvasColor,
        ),
        child: ExtendedText(
          item.toPost.content,
          style: TextStyle(fontSize: 18.sp),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(
            prefixSpans: <InlineSpan>[
              TextSpan(
                text: item.type == TeamReplyType.post ? '回复我的帖子：' : '评论我的回帖：',
                style: TextStyle(
                  color: context.iconTheme.color.withOpacity(0.5),
                ),
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
              Routes.openjmuTeamPostDetail.name,
              arguments: Routes.openjmuTeamPostDetail
                  .d(provider: provider, type: TeamPostType.comment),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
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
    if (loading) {
      return const SpinKitWidget();
    }
    if (replyList.isEmpty) {
      return Center(
        child: Text(
          '暂无内容',
          style: TextStyle(
            color: currentThemeColor,
            fontSize: 24.sp,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: replyList.length + 1,
      itemBuilder: replyItemBuilder,
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
      fromUserId: user['uid'].toString(),
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
  final String fromUserId;
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
