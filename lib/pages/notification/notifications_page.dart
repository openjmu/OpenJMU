///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/2/26 22:50
///
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter/scheduler.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_mention_list_page.dart';
import 'package:openjmu/pages/post/team_praise_list_page.dart';
import 'package:openjmu/pages/post/team_reply_list_page.dart';

@FFRoute(
  name: 'openjmu://notifications',
  routeName: '通知页',
  argumentNames: <String>['initialPage'],
  pageRouteType: PageRouteType.transparent,
)
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    Key key,
    @required this.initialPage,
  }) : super(key: key);

  final String initialPage;

  @override
  State<StatefulWidget> createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  Duration get duration => 200.milliseconds;

  double get maximumOpacity => 0.4;

  double get maximumSheetHeight => Screens.height * 0.75;

  double get minimumHeaderHeight => Screens.height - maximumSheetHeight;

  double get shouldPopOffset => maximumSheetHeight / 2;

  List<Map<String, Map<String, dynamic>>> get actions =>
      <Map<String, Map<String, dynamic>>>[
        <String, Map<String, dynamic>>{
          '广场': <String, dynamic>{
            'icon': R.ASSETS_ICONS_ADD_BUTTON_GUANGCHANG_SVG,
            'notification': notificationProvider.notifications,
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'icon': R.ASSETS_ICONS_POST_ACTIONS_PRAISE_FILL_SVG,
                'field': notificationProvider.notifications.praise,
                'action': notificationProvider.readPraise,
                'select': selectSquareIndex,
                'index': _squareIndex,
              },
              <String, dynamic>{
                'icon': R.ASSETS_ICONS_POST_ACTIONS_COMMENT_FILL_SVG,
                'field': notificationProvider.notifications.comment,
                'action': notificationProvider.readReply,
                'select': selectSquareIndex,
                'index': _squareIndex,
              },
              <String, dynamic>{
                'icon': R.ASSETS_ICONS_POST_ACTIONS_FORWARD_FILL_SVG,
                'field': notificationProvider.notifications.at,
                'action': notificationProvider.readMention,
                'select': selectSquareIndex,
                'index': _squareIndex,
              },
            ],
          },
        },
        <String, Map<String, dynamic>>{
          '集市': <String, dynamic>{
            'icon': R.ASSETS_ICONS_ADD_BUTTON_JISHI_SVG,
            'notification': notificationProvider.teamNotifications,
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'icon': R.ASSETS_ICONS_POST_ACTIONS_PRAISE_FILL_SVG,
                'field': notificationProvider.teamNotifications.praise,
                'action': notificationProvider.readTeamPraise,
                'select': selectTeamIndex,
                'index': _teamIndex,
              },
              <String, dynamic>{
                'icon': R.ASSETS_ICONS_POST_ACTIONS_COMMENT_FILL_SVG,
                'field': notificationProvider.teamNotifications.reply,
                'action': notificationProvider.readTeamReply,
                'select': selectTeamIndex,
                'index': _teamIndex,
              },
              <String, dynamic>{
                'icon': R.ASSETS_ICONS_POST_ACTIONS_FORWARD_FILL_SVG,
                'field': notificationProvider.teamNotifications.mention,
                'action': notificationProvider.readTeamMention,
                'select': selectTeamIndex,
                'index': _teamIndex,
              },
            ],
          },
        },
      ];

  List<String> get squareMentionActions => <String>['动态', '评论'];

  final ScrollController scrollController = ScrollController();
  AnimationController backgroundOpacityController;
  NotificationProvider notificationProvider;
  int _index = 0, _squareIndex = 0, _teamIndex = 0, _mentionIndex = 0;
  bool animating = true, tapping = false;

  @override
  void initState() {
    super.initState();
    notificationProvider =
        Provider.of<NotificationProvider>(currentContext, listen: false);

    backgroundOpacityController = AnimationController.unbounded(
        value: 0.0, duration: duration, vsync: this);

    scrollController.addListener(() {
      backgroundOpacityController.value =
          scrollController.offset / maximumSheetHeight * maximumOpacity;
      final bool canJump = scrollController.offset < maximumSheetHeight &&
          !tapping &&
          !animating;
      if (canJump) {
        scrollController.jumpTo(maximumSheetHeight);
      }
    });

    switch (widget.initialPage) {
      case '广场':
        _index = 0;
        break;
      case '集市':
        _index = 1;
        break;
    }

    _squareIndex = notificationProvider.initialIndex;
    _teamIndex = notificationProvider.teamInitialIndex;

    SchedulerBinding.instance.addPostFrameCallback((Duration _) async {
      await scrollController.animateTo(
        maximumSheetHeight,
        duration: 250.milliseconds,
        curve: Curves.easeInOut,
      );
      animating = false;
      if (mounted) {
        actions[_index].values.elementAt(0)['content']
            [_index == 0 ? _squareIndex : _teamIndex]['action']();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    backgroundOpacityController?.dispose();
    scrollController?.dispose();
    super.dispose();
  }

  void selectIndex(int index) {
    if (index != _index) {
      setState(() {
        _index = index;
      });
    }
  }

  void selectSquareIndex(int index) {
    if (index != _squareIndex) {
      setState(() {
        _squareIndex = index;
      });
    }
  }

  void selectMentionIndex(int index) {
    if (index != _mentionIndex) {
      setState(() {
        _mentionIndex = index;
      });
    }
  }

  void selectTeamIndex(int index) {
    if (index != _teamIndex) {
      setState(() {
        _teamIndex = index;
      });
    }
  }

  /// Build current scroll view key for specific scroll view.
  Key innerScrollPositionKeyBuilder() {
    String keyString = 'List-$_index-';
    switch (_index) {
      case 0:
        keyString += '$_squareIndex';
        if (_squareIndex == 2) {
          keyString += '-$_mentionIndex';
        }
        break;
      case 1:
        keyString += '$_teamIndex';
        break;
    }
    return Key(keyString);
  }

  Future<void> canAnimate() async {
    if (scrollController.offset < shouldPopOffset) {
      unawaited(onWillPop());
    } else if (scrollController.offset != maximumSheetHeight) {
      animating = true;
      await scrollController.animateTo(
        maximumSheetHeight,
        duration: math
            .max(
                50,
                (maximumSheetHeight - scrollController.offset) /
                    maximumSheetHeight *
                    300)
            .milliseconds,
        curve: Curves.easeOut,
      );
      animating = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<bool> onWillPop() async {
    if (!animating) {
      animating = true;
      await scrollController.animateTo(
        0,
        duration: math
            .max(50, scrollController.offset / maximumSheetHeight * 250)
            .milliseconds,
        curve: Curves.easeOut,
      );
      navigatorState.pop();
      animating = false;
      return false;
    }
    return false;
  }

  Widget get postByMention {
    return PostList(
      PostController(
        postType: 'mention',
        isFollowed: false,
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: false,
    );
  }

  Widget get commentByMention {
    return CommentList(
      CommentController(
        commentType: 'mention',
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: false,
    );
  }

  Widget get commentByReply {
    return CommentList(
      CommentController(
        commentType: 'reply',
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: false,
    );
  }

  Widget get praiseList {
    return PraiseList(
      PraiseController(
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: false,
    );
  }

  Widget get backButton => Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: navigatorState.maybePop,
          child: Container(
            width: 76.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: maxBorderRadius,
              color: Theme.of(context).dividerColor,
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -1.w,
                  bottom: -1.w,
                  left: 0.0,
                  right: 0.0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black38,
                    size: 42.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget get actionBar => IndexedStack(
        index: _index,
        children: List<Widget>.generate(
          actions.length,
          (int i) {
            final String key = actions[i].keys.elementAt(0);
            return Row(
              children: List<Widget>.generate(
                (actions[i][key]['content'] as List<dynamic>).length,
                (int j) {
                  final Map<String, dynamic> item = actions[i]
                      .values
                      .elementAt(0)['content'][j] as Map<String, dynamic>;
                  final int count = item['field'] as int;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      (item['select'] as void Function(int index))(j);
                      (item['action'] as VoidCallback)();
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 21.w),
                      child: badgeIcon(
                        content: count == 0 ? '' : count,
                        icon: getActionIcon(i, j),
                        showBadge: count != 0,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

  Widget getActionIcon(int sectionIndex, int actionIndex) {
    final Map<String, dynamic> item = actions[sectionIndex]
        .values
        .elementAt(0)['content'][actionIndex] as Map<String, dynamic>;
    final String icon = item['icon'] as String;
    final int index = item['index'] as int;
    return AnimatedCrossFade(
      duration: duration,
      crossFadeState: index == actionIndex
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: SvgPicture.asset(
        icon,
        color: currentThemeColor,
        width: 32.w,
      ),
      secondChild: SvgPicture.asset(
        icon,
        color: Theme.of(context).dividerColor,
        width: 32.w,
      ),
    );
  }

  Widget get mentionList {
    return Column(
      children: <Widget>[
        Row(
          children: List<Widget>.generate(squareMentionActions.length, (int i) {
            return Expanded(
              child: AnimatedContainer(
                duration: duration,
                margin: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: maxBorderRadius,
                  color: _mentionIndex == i
                      ? currentThemeColor.withOpacity(currentIsDark ? 0.5 : 0.4)
                      : null,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => selectMentionIndex(i),
                  child: Center(
                    child: Text(
                      '@我的${squareMentionActions[i]}',
                      style: TextStyle(
                        color: _mentionIndex == i && !currentIsDark
                            ? currentThemeColor.withOpacity(0.75)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        Expanded(
          child: IndexedStack(
            index: _mentionIndex,
            children: <Widget>[
              NestedScrollViewInnerScrollPositionKeyWidget(
                const Key('List-0-2-0'),
                postByMention,
              ),
              NestedScrollViewInnerScrollPositionKeyWidget(
                const Key('List-0-2-1'),
                commentByMention,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: IgnorePointer(
        ignoring: animating,
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            animating = false;
            tapping = true;
          },
          onPointerUp: (PointerUpEvent event) {
            tapping = false;
            canAnimate();
          },
          child: AnimatedBuilder(
            animation: backgroundOpacityController,
            builder: (BuildContext _, Widget child) => Material(
              color:
                  Colors.black.withOpacity(backgroundOpacityController.value),
              child: child,
            ),
            child: NestedScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (_, __) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: navigatorState.maybePop,
                      child: SizedBox(height: Screens.height),
                    ),
                  ),
                ];
              },
              pinnedHeaderSliverHeightBuilder: () => minimumHeaderHeight,
              innerScrollPositionKeyBuilder: innerScrollPositionKeyBuilder,
              body: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.w),
                  topRight: Radius.circular(20.w),
                ),
                child: Container(
                  constraints: BoxConstraints(maxHeight: maximumSheetHeight),
                  padding: EdgeInsets.only(top: 20.h),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      backButton,
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20.w),
                        height: kAppBarHeight.h,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).canvasColor,
                              width: 1.w,
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child:
                            Row(children: <Widget>[const Spacer(), actionBar]),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _index,
                          children: <Widget>[
                            IndexedStack(
                              index: _squareIndex,
                              children: <Widget>[
                                NestedScrollViewInnerScrollPositionKeyWidget(
                                  const Key('List-0-0'),
                                  praiseList,
                                ),
                                NestedScrollViewInnerScrollPositionKeyWidget(
                                  const Key('List-0-1'),
                                  commentByReply,
                                ),
                                mentionList,
                              ],
                            ),
                            IndexedStack(
                              index: _teamIndex,
                              children: <Widget>[
                                NestedScrollViewInnerScrollPositionKeyWidget(
                                  const Key('List-1-0'),
                                  TeamPraiseListPage(),
                                ),
                                NestedScrollViewInnerScrollPositionKeyWidget(
                                  const Key('List-1-1'),
                                  TeamReplyListPage(),
                                ),
                                NestedScrollViewInnerScrollPositionKeyWidget(
                                  const Key('List-1-2'),
                                  TeamMentionListPage(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
