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
  bool loaded = false;
  List<TeamPost> posts = [];
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

  Future getPostList() async => TeamPostAPI.getPostList().then((response) {
        final data = response.data;
        lastTimeStamp = data['min_ts'];
        if (data['data'] != null)
          data['data'].forEach((postData) {
            final post = TeamPost.fromJson(postData);
            posts.add(post);
          });
        loaded = true;
        if (mounted) setState(() {});
      }).catchError((e) {
        print(e);
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
                itemCount: posts.length,
                itemBuilder: (context, index) => TeamPostPreviewCard(
                  key: ValueKey("marketPost-${posts[index].tid}"),
                  post: posts[index],
                ),
              )
            : Center(child: Constants.progressIndicator()),
      ),
    );
  }
}
