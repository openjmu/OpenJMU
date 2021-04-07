///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-17 02:55
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/widgets/cards/team_post_preview_card.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({Key key}) : super(key: key);

  @override
  _MarketingPageState createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  final LoadingBase loadingBase = LoadingBase(
    request: (int id) => TeamPostAPI.getPostList(
      isMore: id != 0,
      lastTimeStamp: id.toString(),
    ),
    contentFieldName: 'data',
    lastIdBuilder: (Map<String, dynamic> data) {
      return data['min_ts'].toString().toInt();
    },
  );

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<ScrollToTopEvent>().listen((ScrollToTopEvent event) {
      if (mounted && (event.tabIndex == 1 && event.type == '集市')) {
        _scrollController.jumpTo(0.0);
        Future<void>.delayed(
          const Duration(milliseconds: 50),
          loadingBase.refresh,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(right: 20.w),
          child: Row(
            children: <Widget>[
              MainPage.selfPageOpener,
              MainPage.outerNetworkIndicator(context),
            ],
          ),
        ),
        actions: <Widget>[
          MainPage.notificationButton(context: context, isTeam: true),
          Gap(16.w),
          MainPage.publishButton(
            context: context,
            route: Routes.openjmuPublishTeamPost.name,
          ),
        ],
      ),
      body: RefreshListWrapper(
        loadingBase: loadingBase,
        controller: _scrollController,
        itemBuilder: (Map<String, dynamic> model) {
          final TeamPost post = TeamPost.fromJson(model);
          return ChangeNotifierProvider<TeamPostProvider>.value(
            value: TeamPostProvider(post),
            child: TeamPostPreviewCard(
              key: ValueKey<String>('marketPost-${post.tid}'),
            ),
          );
        },
      ),
    );
  }
}
