///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-24 08:23
///
import 'dart:ui' as ui;

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class TeamPraiseListPage extends StatefulWidget {
  const TeamPraiseListPage({Key key}) : super(key: key);

  @override
  _TeamPraiseListPageState createState() => _TeamPraiseListPageState();
}

class _TeamPraiseListPageState extends State<TeamPraiseListPage>
    with AutomaticKeepAliveClientMixin {
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
          UserAvatar(uid: item.fromUserId, isSysAvatar: item.user.sysAvatar),
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

  Widget _content(TeamPraiseItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
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
        style: TextStyle(height: 1.2, fontSize: 19.sp),
      ),
    );
  }

  Widget _rootContent(TeamPraiseItem item) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(top: 8.w, bottom: 12.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: context.theme.canvasColor,
      ),
      child: ExtendedText(
        item.post.content,
        style: TextStyle(height: 1.2, fontSize: 18.sp),
        onSpecialTextTap: specialTextTapRecognizer,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      ),
    );
  }

  Widget praiseItemBuilder(BuildContext context, int index) {
    if (index == praiseList.length - 1 && canLoadMore) {
      loadList(loadMore: true);
    }
    if (index == praiseList.length) {
      return LoadMoreIndicator(canLoadMore: canLoadMore);
    }
    final TeamPraiseItem item = praiseList.elementAt(index);
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuTeamPostDetail.name,
          arguments: Routes.openjmuTeamPostDetail.d(
            type: TeamPostType.post,
            provider: TeamPostProvider(item.post),
            shouldReload: true,
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
            _rootContent(item),
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
    if (praiseList.isEmpty) {
      return Center(
        child: Text(
          '无点赞信息',
          style: context.textTheme.caption.copyWith(fontSize: 20.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      itemCount: praiseList.length + 1,
      itemBuilder: praiseItemBuilder,
    );
  }
}
