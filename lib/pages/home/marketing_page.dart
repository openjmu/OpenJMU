///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-17 02:55
///
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/widgets/cards/team_post_preview_card.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({Key key}) : super(key: key);

  @override
  _MarketingPageState createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  bool loaded = false, loading = true, canLoadMore = true;
  Set<TeamPost> posts = <TeamPost>{};
  String lastTimeStamp;

  @override
  void initState() {
    super.initState();
    getPostList();

    Instances.eventBus
      ..on<ScrollToTopEvent>().listen((ScrollToTopEvent event) {
        if (mounted && (event.tabIndex == 1 && event.type == '集市')) {
          _scrollController.jumpTo(0.0);
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            _refreshIndicatorKey.currentState.show();
          });
        }
      })
      ..on<TeamPostDeletedEvent>().listen((TeamPostDeletedEvent event) {
        posts.removeWhere((TeamPost post) => post.tid == event.postId);
        if (mounted) {
          setState(() {});
        }
      });
  }

  void collectGarbageHandler(List<int> garbage) {
    for (final int index in garbage) {
      if (posts.length >= index + 1 && index < 4) {
        final TeamPost element = posts.elementAt(index);
        final List<Map<dynamic, dynamic>> pics = element.pics;
        if (pics != null) {
          for (final Map<dynamic, dynamic> pic in pics) {
            ExtendedNetworkImageProvider(
              API.teamFile(fid: int.parse(pic['fid'].toString())),
            ).evict();
          }
        }
      }
    }
  }

  Future<void> getPostList({bool more = false}) async {
    try {
      final Map<String, dynamic> data = (await TeamPostAPI.getPostList(
        isMore: more,
        lastTimeStamp: lastTimeStamp,
      ))
          .data;
      lastTimeStamp = data['min_ts'] as String;
      if (!more) {
        posts.clear();
      }
      if (data['data'] != null) {
        for (final dynamic _data in data['data'] as List<dynamic>) {
          final Map<String, dynamic> postData = _data as Map<String, dynamic>;
          final TeamPost post = TeamPost.fromJson(postData);
          posts.add(post);
        }
      }
      loaded = true;
    } catch (e) {
      LogUtils.e('Get market post list failed: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        automaticallyImplyLeading: false,
        title: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.only(right: 20.w),
          child: MainPage.selfPageOpener,
        ),
        actions: <Widget>[
          MainPage.notificationButton(context: context, isTeam: true),
          Gap(10.w),
          MainPage.publishButton(
            context: context,
            route: Routes.openjmuPublishTeamPost,
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 20.w),
      ),
      body: Container(
        color: Theme.of(context).canvasColor,
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: getPostList,
          child: loaded
              ? ExtendedListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 6.w),
                  extendedListDelegate: ExtendedListDelegate(
                    collectGarbage: collectGarbageHandler,
                  ),
                  controller: _scrollController,
                  itemCount: posts.length + 1,
                  itemBuilder: (BuildContext _, int index) {
                    if (index == posts.length - 1 && canLoadMore) {
                      getPostList(more: true);
                    }
                    if (index == posts.length) {
                      return LoadMoreIndicator(canLoadMore: canLoadMore);
                    }
                    return ChangeNotifierProvider<TeamPostProvider>.value(
                      value: TeamPostProvider(posts.elementAt(index)),
                      child: TeamPostPreviewCard(
                        key: ValueKey<String>(
                          'marketPost-${posts.elementAt(index).tid}',
                        ),
                      ),
                    );
                  },
                )
              : const SpinKitWidget(),
        ),
      ),
    );
  }
}
