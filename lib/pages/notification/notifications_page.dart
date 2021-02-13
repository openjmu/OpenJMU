///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/2/26 22:50
///
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as ex;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_mention_list_page.dart';
import 'package:openjmu/pages/post/team_praise_list_page.dart';
import 'package:openjmu/pages/post/team_reply_list_page.dart';

class _Section {
  const _Section({
    @required this.notification,
    @required this.fields,
  })  : assert(notification != null),
        assert(fields != null);

  final dynamic notification;
  final List<_Field> fields;
}

class _Field {
  const _Field({
    @required this.name,
    @required this.field,
    @required this.action,
    @required this.select,
    @required this.index,
  })  : assert(name != null),
        assert(field != null),
        assert(action != null),
        assert(select != null),
        assert(index != null);

  final String name;
  final int Function() field;
  final VoidCallback action;
  final Function(int index) select;
  final int index;
}

@FFRoute(
  name: 'openjmu://notifications',
  routeName: '通知页',
  pageRouteType: PageRouteType.transparent,
)
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    Key key,
    @required this.initialPage,
  })  : assert(initialPage != null),
        super(key: key);

  final String initialPage;

  @override
  State<StatefulWidget> createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  final Duration duration = 200.milliseconds;

  final double maximumOpacity = 0.4;

  double get maximumSheetHeight => Screens.height * 0.75;

  double get minimumHeaderHeight => Screens.height - maximumSheetHeight;

  double get shouldPopOffset => maximumSheetHeight / 2;

  Map<String, _Section> get sections {
    return <String, _Section>{
      '广场': _Section(
        notification: provider.notifications,
        fields: <_Field>[
          _Field(
            name: '赞',
            field: () => provider.notifications.praise,
            action: provider.readPraise,
            select: selectSquareIndex,
            index: _squareIndex,
          ),
          _Field(
            name: '评论',
            field: () => provider.notifications.comment,
            action: provider.readReply,
            select: selectSquareIndex,
            index: _squareIndex,
          ),
          _Field(
            name: '@我的动态',
            field: () => provider.notifications.tAt,
            action: provider.readPostMention,
            select: selectSquareIndex,
            index: _squareIndex,
          ),
          _Field(
            name: '@我的评论',
            field: () => provider.notifications.cmtAt,
            action: provider.readCommentMention,
            select: selectSquareIndex,
            index: _squareIndex,
          ),
        ],
      ),
      '集市': _Section(
        notification: provider.teamNotifications,
        fields: <_Field>[
          _Field(
            name: '赞',
            field: () => provider.teamNotifications.praise,
            action: provider.readTeamPraise,
            select: selectTeamIndex,
            index: _teamIndex,
          ),
          _Field(
            name: '评论',
            field: () => provider.teamNotifications.reply,
            action: provider.readTeamReply,
            select: selectTeamIndex,
            index: _teamIndex,
          ),
          _Field(
            name: '提到我',
            field: () => provider.teamNotifications.mention,
            action: provider.readTeamMention,
            select: selectTeamIndex,
            index: _teamIndex,
          ),
        ],
      ),
    };
  }

  final ScrollController scrollController = ScrollController();
  final NotificationProvider provider =
      currentContext.read<NotificationProvider>();

  int _index = 0, _squareIndex = 0, _teamIndex = 0;
  bool animating = true, tapping = false;

  AnimationController backgroundOpacityController;

  @override
  void initState() {
    super.initState();
    backgroundOpacityController = AnimationController.unbounded(
      value: 0.0,
      duration: duration,
      vsync: this,
    );

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

    _squareIndex = provider.initialIndex;
    _teamIndex = provider.teamInitialIndex;

    SchedulerBinding.instance.addPostFrameCallback((Duration _) async {
      await scrollController.animateTo(
        maximumSheetHeight,
        duration: 250.milliseconds,
        curve: Curves.easeInOut,
      );
      animating = false;
      if (mounted) {
        sections[widget.initialPage]
            .fields[_index == 0 ? _squareIndex : _teamIndex]
            .action();
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
        break;
      case 1:
        keyString += '$_teamIndex';
        break;
    }
    return Key(keyString);
  }

  Future<void> canAnimate() async {
    if (scrollController.offset < shouldPopOffset) {
      onWillPop();
    } else if (scrollController.offset != maximumSheetHeight) {
      animating = true;
      await scrollController.animateTo(
        maximumSheetHeight,
        curve: Curves.easeOut,
        duration: math
            .max(
              50,
              (maximumSheetHeight - scrollController.offset) /
                  maximumSheetHeight *
                  300,
            )
            .milliseconds,
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
        curve: Curves.easeOut,
        duration: math
            .max(50, scrollController.offset / maximumSheetHeight * 250)
            .milliseconds,
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

  Widget get backButton {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: navigatorState.maybePop,
        behavior: HitTestBehavior.opaque,
        child: SvgPicture.asset(
          R.ASSETS_ICONS_CLEAR_SVG,
          color: context.iconTheme.color,
          width: 20.w,
        ),
      ),
    );
  }

  Widget get actionBar {
    return Row(
      children: List<Widget>.generate(
        sections[widget.initialPage].fields.length,
        (int j) {
          final _Field field = sections[widget.initialPage].fields[j];
          final int count = field.field();
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              field
                ..select(j)
                ..action();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: badgeIcon(
                content: count,
                icon: getActionName(j),
                showBadge: count != 0,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getActionName(int actionIndex) {
    final _Field item = sections[widget.initialPage].fields[actionIndex];
    final bool isSelected = item.index == actionIndex;
    return AnimatedDefaultTextStyle(
      duration: kThemeAnimationDuration,
      child: Text(item.name),
      style: TextStyle(
        color: isSelected ? currentThemeColor : context.textTheme.caption.color,
        height: 1.2,
        fontSize: 18.sp,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _squareStack(BuildContext context) {
    return IndexedStack(
      index: _squareIndex,
      children: <Widget>[
        ex.NestedScrollViewInnerScrollPositionKeyWidget(
          const Key('List-0-0'),
          praiseList,
        ),
        ex.NestedScrollViewInnerScrollPositionKeyWidget(
          const Key('List-0-1'),
          commentByReply,
        ),
        ex.NestedScrollViewInnerScrollPositionKeyWidget(
          const Key('List-0-2'),
          postByMention,
        ),
        ex.NestedScrollViewInnerScrollPositionKeyWidget(
          const Key('List-0-3'),
          commentByMention,
        ),
      ],
    );
  }

  Widget _teamStack(BuildContext context) {
    return IndexedStack(
      index: _teamIndex,
      children: const <Widget>[
        ex.NestedScrollViewInnerScrollPositionKeyWidget(
          Key('List-1-0'),
          TeamPraiseListPage(),
        ),
        ex.NestedScrollViewInnerScrollPositionKeyWidget(
          Key('List-1-1'),
          TeamReplyListPage(),
        ),
        ex.NestedScrollViewInnerScrollPositionKeyWidget(
          Key('List-1-2'),
          TeamMentionListPage(),
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
            child: ex.NestedScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (_, __) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: navigatorState.maybePop,
                      child: VGap(Screens.height),
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
                  constraints: BoxConstraints(
                    minHeight: kAppBarHeight.w,
                    maxHeight: maximumSheetHeight,
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: kAppBarHeight.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        color: context.theme.colorScheme.surface,
                        child: Row(
                          children: <Widget>[
                            actionBar,
                            const Spacer(),
                            backButton,
                          ],
                        ),
                      ),
                      Divider(thickness: 1.w, height: 1.w),
                      Expanded(
                        child: ColoredBox(
                          color: Theme.of(context).canvasColor,
                          child: IndexedStack(
                            index: _index,
                            children: <Widget>[
                              _squareStack(context),
                              _teamStack(context),
                            ],
                          ),
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
