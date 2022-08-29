///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/2/26 22:50
///
import 'dart:async';
import 'dart:math' as math;

import 'package:badges/badges.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_mention_list_page.dart';
import 'package:openjmu/pages/post/team_praise_list_page.dart';
import 'package:openjmu/pages/post/team_reply_list_page.dart';

const double _tabHeight = 76.0;

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
  })  : assert(name != null),
        assert(field != null),
        assert(action != null);

  final String name;
  final int Function() field;
  final VoidCallback action;
}

@FFRoute(
  name: 'openjmu://notifications-page',
  routeName: '通知页',
  pageRouteType: PageRouteType.transparent,
  argumentImports: <String>["import 'package:openjmu/constants/enums.dart';"],
)
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    Key key,
    @required this.pageType,
  })  : assert(pageType != null),
        super(key: key);

  final NotificationPageType pageType;

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

  final ScrollController scrollController = ScrollController();
  final ValueNotifier<bool> animating = ValueNotifier<bool>(true);
  final NotificationProvider provider =
      currentContext.read<NotificationProvider>();

  bool tapping = false;
  TabController _tabController;
  AnimationController backgroundOpacityController;

  _Section get currentSection => sections[widget.pageType];

  List<_Field> get currentFields => currentSection.fields;

  Map<NotificationPageType, _Section> get sections {
    return <NotificationPageType, _Section>{
      NotificationPageType.square: _Section(
        notification: provider.notifications,
        fields: <_Field>[
          _Field(
            name: '赞',
            field: () => provider.notifications.praise,
            action: provider.readPraise,
          ),
          _Field(
            name: '评论',
            field: () => provider.notifications.comment,
            action: provider.readReply,
          ),
          _Field(
            name: '@我的动态',
            field: () => provider.notifications.tAt,
            action: provider.readPostMention,
          ),
          _Field(
            name: '@我的评论',
            field: () => provider.notifications.cmtAt,
            action: provider.readCommentMention,
          ),
        ],
      ),
      NotificationPageType.team: _Section(
        notification: provider.teamNotifications,
        fields: <_Field>[
          _Field(
            name: '赞',
            field: () => provider.teamNotifications.praise,
            action: provider.readTeamPraise,
          ),
          _Field(
            name: '评论',
            field: () => provider.teamNotifications.reply,
            action: provider.readTeamReply,
          ),
          _Field(
            name: '提到我',
            field: () => provider.teamNotifications.mention,
            action: provider.readTeamMention,
          ),
        ],
      ),
    };
  }

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
          !animating.value;
      if (canJump) {
        scrollController.jumpTo(maximumSheetHeight);
      }
    });

    int _initialIndex;
    switch (widget.pageType) {
      case NotificationPageType.square:
        _initialIndex = provider.initialIndex;
        break;
      case NotificationPageType.team:
        _initialIndex = provider.teamInitialIndex;
        break;
    }
    _tabController = TabController(
      initialIndex: _initialIndex,
      length: currentFields.length,
      vsync: this,
    );

    SchedulerBinding.instance.addPostFrameCallback((Duration _) async {
      currentFields[_initialIndex].action();
      await scrollController.animateTo(
        maximumSheetHeight,
        duration: 250.milliseconds,
        curve: Curves.easeInOut,
      );
      animating.value = false;
    });
  }

  @override
  void dispose() {
    backgroundOpacityController?.dispose();
    scrollController?.dispose();
    super.dispose();
  }

  Future<void> canAnimate() async {
    if (scrollController.offset < shouldPopOffset) {
      onWillPop();
    } else if (scrollController.offset.round() < maximumSheetHeight.round()) {
      animating.value = true;
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
      animating.value = false;
    }
  }

  Future<bool> onWillPop() async {
    if (!animating.value) {
      animating.value = true;
      await scrollController.animateTo(
        0,
        curve: Curves.easeOut,
        duration: math
            .max(50, scrollController.offset / maximumSheetHeight * 250)
            .milliseconds,
      );
      navigatorState.pop();
      animating.value = false;
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
      child: Tapper(
        onTap: navigatorState.maybePop,
        child: SvgPicture.asset(
          R.ASSETS_ICONS_CLEAR_SVG,
          color: context.iconTheme.color,
          width: 20.w,
        ),
      ),
    );
  }

  Widget get tabBar {
    return Expanded(
      child: SizedBox(
        height: _tabHeight.w,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (int index) => currentFields[index].action(),
          indicatorWeight: 4.w,
          labelColor: currentThemeColor,
          labelStyle: TextStyle(
            height: 1.2,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          labelPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
          ).copyWith(top: 4.w),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: List<Widget>.generate(
            currentFields.length,
            (int index) {
              return Consumer<NotificationProvider>(
                builder: (_, NotificationProvider p, __) {
                  final _Field field = currentFields[index];
                  final int count = field.field();
                  return Tab(
                    icon: badgeIcon(
                      content: count,
                      icon: getActionName(index),
                      showBadge: count != 0,
                    ),
                    iconMargin: EdgeInsets.zero,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Badge Icon. Used in notification.
  Widget badgeIcon({
    @required dynamic content,
    @required Widget icon,
    bool showBadge = true,
  }) =>
      Badge(
        padding: EdgeInsets.all(6.w),
        badgeColor: currentThemeColor,
        child: icon,
        badgeContent: Text(
          '$content',
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
        position: BadgePosition(top: -14.w, end: -18.w),
        showBadge: showBadge,
      );

  Widget getActionName(int actionIndex) {
    return Text(currentFields[actionIndex].name);
  }

  Widget _squareStack(BuildContext context) {
    return ExtendedTabBarView(
      controller: _tabController,
      children: <Widget>[
        praiseList,
        commentByReply,
        postByMention,
        commentByMention,
      ],
    );
  }

  Widget _teamStack(BuildContext context) {
    return ExtendedTabBarView(
      controller: _tabController,
      children: const <Widget>[
        TeamPraiseListPage(),
        TeamReplyListPage(),
        TeamMentionListPage(),
      ],
    );
  }

  Widget _contentBuilder(BuildContext context) {
    Widget _content;
    switch (widget.pageType) {
      case NotificationPageType.square:
        _content = _squareStack(context);
        break;
      case NotificationPageType.team:
        _content = _teamStack(context);
        break;
    }
    return ColoredBox(
      color: context.theme.canvasColor,
      child: _content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: ValueListenableBuilder<bool>(
        valueListenable: animating,
        builder: (_, bool value, Widget child) => IgnorePointer(
          ignoring: value,
          child: child,
        ),
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            animating.value = false;
            tapping = true;
          },
          onPointerUp: (PointerUpEvent event) {
            tapping = false;
            canAnimate();
          },
          child: AnimatedBuilder(
            animation: backgroundOpacityController,
            builder: (_, Widget child) => Material(
              color:
                  Colors.black.withOpacity(backgroundOpacityController.value),
              child: child,
            ),
            child: ExtendedNestedScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (_, __) => <Widget>[
                SliverToBoxAdapter(
                  child: Tapper(
                    onTap: navigatorState.maybePop,
                    child: Gap.v(Screens.height),
                  ),
                ),
              ],
              pinnedHeaderSliverHeightBuilder: () => minimumHeaderHeight,
              body: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.w),
                  topRight: Radius.circular(20.w),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: _tabHeight.w,
                    maxHeight: maximumSheetHeight,
                  ),
                  color: context.surfaceColor,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: _tabHeight.w,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        color: context.theme.colorScheme.surface,
                        child: SizedBox.expand(
                          child: Row(
                            children: <Widget>[tabBar, backButton],
                          ),
                        ),
                      ),
                      const LineDivider(),
                      Expanded(child: _contentBuilder(context)),
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
