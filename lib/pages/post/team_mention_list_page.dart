///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-24 04:39
///
import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class TeamMentionListPage extends StatefulWidget {
  @override
  _TeamMentionListPageState createState() => _TeamMentionListPageState();
}

class _TeamMentionListPageState extends State<TeamMentionListPage> {
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
      height: 80.h,
      padding: EdgeInsets.symmetric(
        vertical: 8.h,
      ),
      child: Row(
        children: <Widget>[
          UserAPI.getAvatar(size: 54.0, uid: item.fromUserId),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      item.fromUsername ?? item.fromUserId.toString(),
                      style: TextStyle(fontSize: 22.sp),
                    ),
                    if (Constants.developerList.contains(item.fromUserId))
                      Container(
                        margin: EdgeInsets.only(left: 14.w),
                        child: DeveloperTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                        ),
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
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget _content(TeamMentionItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: ExtendedText(
        item.post?.content ?? item.comment?.content ?? '',
        style: TextStyle(fontSize: 21.sp),
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
                'type': item.type == TeamMentionType.post
                    ? TeamPostType.post
                    : TeamPostType.comment,
                'postId': item.comment?.originId,
              },
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
          ? mentionedList.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: mentionedList.length + 1,
                  itemBuilder: mentionItemBuilder,
                )
              : Center(
                  child: Text(
                    '暂无内容',
                    style: TextStyle(
                      color: currentThemeColor,
                      fontSize: 24.sp,
                    ),
                  ),
                )
          : const SpinKitWidget(),
    );
  }
}
