///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-17 02:55
///
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/team_post_preview_card.dart';

class MarketingPage extends StatefulWidget {
  @override
  _MarketingPageState createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  final _scrollController = ScrollController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool loaded = false, loading = true, canLoadMore = true;
  Set<TeamPost> posts = {};
  String lastTimeStamp;

  @override
  void initState() {
    getPostList();

    Instances.eventBus
      ..on<ScrollToTopEvent>().listen((event) {
        if (this.mounted && ((event.tabIndex == 0) || (event.type == "首页"))) {
          _scrollController.jumpTo(0.0);
          Future.delayed(const Duration(milliseconds: 50), () {
            _refreshIndicatorKey.currentState.show();
          });
        }
      })
      ..on<TeamPostDeletedEvent>().listen((event) {
        posts.removeWhere((post) => post.tid == event.postId);
        if (mounted) setState(() {});
      });
    super.initState();
  }

  Future getPostList({bool more = false}) async => TeamPostAPI.getPostList(
        isMore: more,
        lastTimeStamp: lastTimeStamp,
      ).then((response) {
        final data = response.data;
        lastTimeStamp = data['min_ts'];
        if (!more) posts.clear();
        if (data['data'] != null) {
          data['data'].forEach((postData) {
            final post = TeamPost.fromJson(postData);
            posts.add(post);
          });
        }
        loaded = true;
        if (mounted) setState(() {});
      }).catchError((e) {
        debugPrint("Get market post list failed: $e");
      });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: getPostList,
      child: loaded
          ? ExtendedListView.builder(
              padding: EdgeInsets.symmetric(vertical: suSetWidth(6.0)),
              extendedListDelegate: ExtendedListDelegate(
                collectGarbage: (List<int> garbage) {
                  garbage.forEach((index) {
                    if (posts.length >= index + 1 && index < 4) {
                      final element = posts.elementAt(index);
                      final pics = element.pics;
                      if (pics != null) {
                        pics.forEach((pic) {
                          ExtendedNetworkImageProvider(
                            API.teamFile(
                              fid: int.parse(pic['fid'].toString()),
                            ),
                          ).evict();
                        });
                      }
                    }
                  });
                },
              ),
              controller: _scrollController,
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == posts.length - 1 && canLoadMore) {
                  getPostList(more: true);
                }
                if (index == posts.length) {
                  return LoadMoreIndicator(canLoadMore: canLoadMore);
                }
                return ChangeNotifierProvider.value(
                  value: TeamPostProvider(posts.elementAt(index)),
                  child: TeamPostPreviewCard(
                    key: ValueKey('marketPost-${posts.elementAt(index).tid}'),
                  ),
                );
              },
            )
          : Center(child: PlatformProgressIndicator()),
    );
  }
}
