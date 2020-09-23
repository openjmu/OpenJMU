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
  final _scrollController = ScrollController();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool loaded = false, loading = true, canLoadMore = true;
  Set<TeamPost> posts = {};
  String lastTimeStamp;

  @override
  void initState() {
    super.initState();
    getPostList();

    Instances.eventBus
      ..on<ScrollToTopEvent>().listen((event) {
        if (this.mounted && ((event.tabIndex == 0) || (event.type == '首页'))) {
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
  }

  void collectGarbageHandler(List<int> garbage) {
    garbage.forEach((index) {
      if (posts.length >= index + 1 && index < 4) {
        final element = posts.elementAt(index);
        final pics = element.pics;
        if (pics != null) {
          pics.forEach((pic) {
            ExtendedNetworkImageProvider(
              API.teamFile(fid: int.parse(pic['fid'].toString())),
            ).evict();
          });
        }
      }
    });
  }

  Future<void> getPostList({bool more = false}) async {
    try {
      final Map<String, dynamic> data = (await TeamPostAPI.getPostList(
        isMore: more,
        lastTimeStamp: lastTimeStamp,
      ))
          .data;
      lastTimeStamp = data['min_ts'];
      if (!more) posts.clear();
      if (data['data'] != null) {
        data['data'].forEach((postData) {
          final post = TeamPost.fromJson(postData);
          posts.add(post);
        });
      }
      loaded = true;
    } catch (e) {
      trueDebugPrint('Get market post list failed: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

  Widget get publishButton => MaterialButton(
        color: currentThemeColor,
        minWidth: suSetWidth(120.0),
        height: suSetHeight(50.0),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(13.0)),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: suSetWidth(6.0)),
              child: SvgPicture.asset(
                R.ASSETS_ICONS_SEND_SVG,
                height: suSetHeight(22.0),
                color: Colors.white,
              ),
            ),
            Text(
              '发动态',
              style: TextStyle(
                color: Colors.white,
                fontSize: suSetSp(20.0),
                height: 1.24,
              ),
            ),
          ],
        ),
        onPressed: () {
          navigatorState.pushNamed(Routes.openjmuPublishTeamPost);
        },
      );

  Widget get notificationButton => Consumer<NotificationProvider>(
        builder: (_, provider, __) {
          return SizedBox(
            width: suSetWidth(60.0),
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  top: suSetHeight(kToolbarHeight / 5),
                  right: suSetWidth(2.0),
                  child: Visibility(
                    visible: provider.showTeamNotification,
                    child: ClipRRect(
                      borderRadius: maxBorderRadius,
                      child: Container(
                        width: suSetWidth(12.0),
                        height: suSetWidth(12.0),
                        color: currentThemeColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: SvgPicture.asset(
                    R.ASSETS_ICONS_LIUYAN_LINE_SVG,
                    color: currentTheme.iconTheme.color,
                    width: suSetWidth(32.0),
                    height: suSetWidth(32.0),
                  ),
                  onPressed: () async {
                    provider.stopNotification();
                    await navigatorState.pushNamed(
                      Routes.openjmuNotifications,
                      arguments: <String, dynamic>{'initialPage': '集市'},
                    );
                    provider.initNotification();
                  },
                ),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        automaticallyImplyLeading: false,
        elevation: 1.0,
        title: Padding(
          padding: EdgeInsets.only(right: 20.0.w),
          child: Row(
            children: <Widget>[
              MainPage.selfPageOpener(context),
              const Spacer(),
              notificationButton,
            ],
          ),
        ),
        actions: <Widget>[
          notificationButton,
          publishButton,
        ],
        actionsPadding: EdgeInsets.only(right: 20.0.w),
      ),
      body: Container(
        color: Theme.of(context).canvasColor,
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: getPostList,
          child: loaded
              ? ExtendedListView.builder(
                  padding: EdgeInsets.symmetric(vertical: suSetWidth(6.0)),
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
                    return ChangeNotifierProvider.value(
                      value: TeamPostProvider(posts.elementAt(index)),
                      child: TeamPostPreviewCard(
                        key: ValueKey(
                            'marketPost-${posts.elementAt(index).tid}'),
                      ),
                    );
                  },
                )
              : SpinKitWidget(),
        ),
      ),
    );
  }
}
