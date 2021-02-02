///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-24 08:23
///
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class TeamPraiseListPage extends StatefulWidget {
  const TeamPraiseListPage({Key key}) : super(key: key);

  @override
  _TeamPraiseListPageState createState() => _TeamPraiseListPageState();
}

class _TeamPraiseListPageState extends State<TeamPraiseListPage> {
  bool _shouldInit = true;
  bool loading = true, canLoadMore = true;

  int page = 1, total;

  List<TeamPraiseItem> praiseList = <TeamPraiseItem>[];

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
    TeamPraiseAPI.getPraiseList(page: page).then(
      (Response<Map<String, dynamic>> response) {
        final Map<String, dynamic> data = response.data;
        for (final dynamic _item in data['list']) {
          final Map<String, dynamic> item = _item as Map<String, dynamic>;
          praiseList.add(TeamPraiseItem.fromJson(item));
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

  Widget _header(BuildContext context, int index, TeamPraiseItem item) {
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
                    _postTime(context, item.time),
                  ],
                ),
                Text(
                  praiseList[index].scope['name'] as String,
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

  Widget _content(TeamPraiseItem item) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: '赞了我的帖子 '),
              WidgetSpan(
                alignment: ui.PlaceholderAlignment.middle,
                child: Icon(
                  Icons.thumb_up,
                  size: 19.sp,
                  color: currentThemeColor,
                ),
              ),
            ],
          ),
          style: TextStyle(fontSize: 19.sp),
        ),
      );

  Widget _rootContent(TeamPraiseItem item) => Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(top: 6.h, bottom: 12.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: Theme.of(context).canvasColor,
        ),
        child: ExtendedText(
          item.post.content,
          style: TextStyle(fontSize: 18.sp),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  Widget praiseItemBuilder(BuildContext context, int index) {
    if (index == praiseList.length - 1 && canLoadMore) {
      loadList(loadMore: true);
    }
    if (index == praiseList.length) {
      return LoadMoreIndicator(canLoadMore: canLoadMore);
    }
    final TeamPraiseItem item = praiseList.elementAt(index);
    final TeamPostProvider provider = TeamPostProvider(item.post);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            navigatorState.pushNamed(
              Routes.openjmuTeamPostDetail.name,
              arguments: Routes.openjmuTeamPostDetail.d(
                provider: provider,
                type: TeamPostType.post,
              ),
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
      return const Center(child: LoadMoreSpinningIcon(isRefreshing: true));
    }
    if (praiseList.isEmpty) {
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
      itemCount: praiseList.length + 1,
      itemBuilder: praiseItemBuilder,
    );
  }
}

@immutable
class TeamPraiseItem {
  const TeamPraiseItem({
    this.post,
    this.from,
    this.time,
    this.scope,
    this.fromUserId,
    this.fromUsername,
  });

  factory TeamPraiseItem.fromJson(Map<String, dynamic> json) {
    final TeamPost post =
        TeamPost.fromJson(json['post_info'] as Map<String, dynamic>);
    final Map<String, dynamic> user = json['user_info'] as Map<String, dynamic>;
    return TeamPraiseItem(
      post: post,
      from: json['from'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(
        json['post_time'].toString().toInt(),
      ),
      scope: json['post_info']['scope'] as Map<String, dynamic>,
      fromUserId: user['uid'].toString(),
      fromUsername: user['nickname'] as String,
    );
  }

  final TeamPost post;
  final String from;
  final DateTime time;
  final Map<String, dynamic> scope;
  final String fromUserId;
  final String fromUsername;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
