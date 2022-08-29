///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-24 06:52
///
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class TeamReplyListPage extends StatefulWidget {
  const TeamReplyListPage({Key? key}) : super(key: key);

  @override
  _TeamReplyListPageState createState() => _TeamReplyListPageState();
}

class _TeamReplyListPageState extends State<TeamReplyListPage>
    with AutomaticKeepAliveClientMixin {
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
          UserAvatar(uid: item.fromUserId, isSysAvatar: item.user.sysAvatar),
          Gap.h(16.w),
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

  Widget _content(TeamReplyItem item) {
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

  Widget _rootContent(BuildContext context, TeamReplyItem item) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 8.w, bottom: 12.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: context.theme.canvasColor,
      ),
      child: ExtendedText(
        item.toPost.content,
        style: TextStyle(height: 1.2, fontSize: 18.sp),
        onSpecialTextTap: specialTextTapRecognizer,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(
          prefixSpans: <InlineSpan>[
            TextSpan(
              text: item.type == TeamReplyType.post ? '回复我的帖子：' : '评论我的回帖：',
              style: TextStyle(color: context.textTheme.caption.color),
            ),
          ],
        ),
      ),
    );
  }

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
    if (item.type == TeamReplyType.post || item.post == null) {
      provider = TeamPostProvider(item.toPost);
    } else if (item.comment == null) {
      provider = TeamPostProvider(item.post);
    }
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuTeamPostDetail.name,
          arguments: Routes.openjmuTeamPostDetail.d(
            provider: provider,
            type: item.type == TeamReplyType.post
                ? TeamPostType.post
                : TeamPostType.comment,
            shouldReload: item.type == TeamReplyType.post,
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
          color: context.surfaceColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(context, index, item),
            _content(item),
            _rootContent(context, item),
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
    if (replyList.isEmpty) {
      return Center(
        child: Text(
          '无评论信息',
          style: context.textTheme.caption.copyWith(fontSize: 20.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      itemCount: replyList.length + 1,
      itemBuilder: replyItemBuilder,
    );
  }
}
