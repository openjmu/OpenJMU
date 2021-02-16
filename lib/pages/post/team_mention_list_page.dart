///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-24 04:39
///
import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class TeamMentionListPage extends StatefulWidget {
  const TeamMentionListPage({Key key}) : super(key: key);

  @override
  _TeamMentionListPageState createState() => _TeamMentionListPageState();
}

class _TeamMentionListPageState extends State<TeamMentionListPage>
    with AutomaticKeepAliveClientMixin {
  bool _shouldInit = true;
  bool loading = true, canLoadMore = true;

  int page = 1, total;

  List<TeamMentionItem> mentionedList = <TeamMentionItem>[];

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
    TeamPostAPI.getMentionedList(page: page).then(
      (Response<Map<String, dynamic>> response) {
        final Map<String, dynamic> data = response.data;
        for (final dynamic item in data['list'] as List<dynamic>) {
          final Map<String, dynamic> _item = item as Map<String, dynamic>;
          mentionedList.add(TeamMentionItem.fromJson(_item));
        }
        total = data['total'].toString().toIntOrNull();
        canLoadMore = data['count'].toString().toIntOrNull() == 0;
      },
    ).whenComplete(
      () {
        loading = false;
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _header(BuildContext context, int index, TeamMentionItem item) {
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
                      context,
                      item.post?.postTime ?? item.comment?.postTime,
                    ),
                  ],
                ),
                Text(
                  '${mentionedList[index].scope['name']}',
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
    String time = '';
    if (postTime.day == now.day &&
        postTime.month == now.month &&
        postTime.year == now.year) {
      time += DateFormat('HH:mm').format(postTime);
    } else if (postTime.year == now.year) {
      time += DateFormat('MM-dd HH:mm').format(postTime);
    } else {
      time += DateFormat('yyyy-MM-dd HH:mm').format(postTime);
    }
    return Text(
      time,
      style: context.textTheme.caption.copyWith(
        fontSize: 17.sp,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _content(TeamMentionItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
      child: ExtendedText(
        item.post?.content ?? item.comment?.content ?? '',
        style: TextStyle(height: 1.2, fontSize: 19.sp),
        onSpecialTextTap: specialTextTapRecognizer,
        maxLines: 8,
        overflowWidget: contentOverflowWidget,
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      ),
    );
  }

  Widget mentionItemBuilder(BuildContext context, int index) {
    if (index == mentionedList.length - 1 && canLoadMore) {
      loadList(loadMore: true);
    }
    if (index == mentionedList.length) {
      return LoadMoreIndicator(canLoadMore: canLoadMore);
    }
    final TeamMentionItem item = mentionedList.elementAt(index);
    final TeamPostProvider provider = TeamPostProvider(item.post);
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuTeamPostDetail.name,
          arguments: Routes.openjmuTeamPostDetail.d(
            provider: provider,
            type: item.type == TeamMentionType.post
                ? TeamPostType.post
                : TeamPostType.comment,
            postId: item.comment?.originId,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 8.w,
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
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    if (loading) {
      return const Center(child: LoadMoreSpinningIcon(isRefreshing: true));
    }
    if (mentionedList.isEmpty) {
      return Center(
        child: Text(
          '无提到我的信息',
          style: context.textTheme.caption.copyWith(fontSize: 20.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      itemCount: mentionedList.length + 1,
      itemBuilder: mentionItemBuilder,
    );
  }
}
