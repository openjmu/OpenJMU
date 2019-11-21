///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-17 02:55
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/cards/TeamPostPreviewCard.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: getPostList,
        child: loaded
            ? ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == posts.length - 1) {
                    getPostList(more: true);
                  }
                  if (index == posts.length) {
                    return SizedBox(
                      height: suSetHeight(60.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Constants.progressIndicator(),
                          Text(
                            "正在加载",
                            style: TextStyle(
                              fontSize: suSetSp(15.0),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return TeamPostPreviewCard(
                    key: ValueKey("marketPost-${posts.elementAt(index).tid}"),
                    post: posts.elementAt(index),
                  );
                },
              )
            : Center(child: Constants.progressIndicator()),
      ),
    );
  }
}

class SliverStrictMemoryChildDelegate extends SliverChildDelegate {
  @override
  Widget build(BuildContext context, int index) {
    return null;
  }

  @override
  int get estimatedChildCount => 1;

  @override
  bool shouldRebuild(SliverChildDelegate oldDelegate) {
    return true;
  }

}