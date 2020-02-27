///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/2/26 22:50
///
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

//@FFRoute(
//  name: 'openjmu://notifications',
//  routeName: '通知页',
//  pageRouteType: PageRouteType.transparent,
//)
class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> with TickerProviderStateMixin {
  List<Map<String, Map<String, dynamic>>> get actions => [
        {
          '广场': {
            'icon': R.ASSETS_ICONS_ADDBUTTON_GUANGCHANG_SVG,
            'content': [
              {
                'icon': 'praise',
                'field': provider.notifications.praise,
                'action': provider.readPraise,
                'select': selectSquareIndex,
                'index': _squareIndex,
              },
              {
                'icon': 'comment',
                'field': provider.notifications.comment,
                'action': provider.readReply,
                'select': selectSquareIndex,
                'index': _squareIndex,
              },
              {
                'icon': 'forward',
                'field': provider.notifications.at,
                'action': provider.readMention,
                'select': selectSquareIndex,
                'index': _squareIndex,
              },
            ],
          },
        },
        {
          '集市': {
            'icon': R.ASSETS_ICONS_ADDBUTTON_JISHI_SVG,
            'content': [
              {
                'icon': 'praise',
                'field': provider.teamNotifications.praise,
                'action': provider.readPraise,
                'index': _teamIndex,
              },
              {
                'icon': 'comment',
                'field': provider.teamNotifications.reply,
                'action': provider.readTeamReply,
                'index': _teamIndex,
              },
              {
                'icon': 'forward',
                'field': provider.teamNotifications.mention,
                'action': provider.readTeamMention,
                'index': _teamIndex,
              },
            ],
          },
        },
      ];

  List<String> get squareMentionActions => ['动态', '评论'];

  Duration get duration => 200.milliseconds;
  NotificationProvider provider;
  int _index = 0, _squareIndex = 0, _teamIndex = 0, _mentionIndex = 0;
  bool animating = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<NotificationProvider>(currentContext, listen: false);
    _squareIndex = provider.initialIndex;
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

  Widget postByMention() {
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

  Widget commentByMention() {
    return CommentList(
      CommentController(
        commentType: 'mention',
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: false,
    );
  }

  Widget commentByReply() {
    return CommentList(
      CommentController(
        commentType: 'reply',
        isMore: false,
        lastValue: (int id) => id,
      ),
      needRefreshIndicator: false,
    );
  }

  Widget praiseList() {
    return PraiseList(
      PraiseController(
        isMore: false,
        lastValue: (Praise praise) => praise.id,
      ),
      needRefreshIndicator: false,
    );
  }

  Widget get backButton => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: navigatorState.pop,
        child: Container(
          width: suSetWidth(76.0),
          height: suSetWidth(40.0),
          decoration: BoxDecoration(
            borderRadius: maxBorderRadius,
            color: Theme.of(context).dividerColor,
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: suSetWidth(-1.0),
                bottom: suSetWidth(-1.0),
                left: 0.0,
                right: 0.0,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black38,
                  size: suSetWidth(42.0),
                ),
              ),
            ],
          ),
        ),
      );

  Widget get sectionBar => Row(
        children: List<Widget>.generate(
          actions.length,
          (int i) {
            final String key = actions[i].keys.elementAt(0);
            return GestureDetector(
              onTap: () => selectIndex(i),
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeInOut,
                width: suSetWidth(_index == i ? 114.0 : 72.0),
                height: suSetHeight(56.0),
                margin: EdgeInsets.only(right: suSetWidth(6.0)),
                padding: EdgeInsets.symmetric(horizontal: suSetWidth(12.0)),
                decoration: BoxDecoration(
                  borderRadius: maxBorderRadius,
                  color: _index == i
                      ? currentThemeColor.withOpacity(currentIsDark ? 0.75 : 0.35)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SvgPicture.asset(
                      actions[i][key]['icon'] as String,
                      width: suSetWidth(36.0),
                      height: suSetWidth(36.0),
                      color: _index == i
                          ? Color.lerp(
                              currentThemeColor,
                              Colors.white,
                              currentIsDark ? 0.5 : 0.0,
                            )
                          : Theme.of(context).dividerColor,
                    ),
                    if (_index == i)
                      Expanded(
                        child: OverflowBox(
                          minWidth: suSetWidth(50.0),
                          maxWidth: suSetWidth(50.0),
                          child: Text(
                            key,
                            style: TextStyle(
                              color: _index == i
                                  ? Color.lerp(
                                      currentThemeColor,
                                      Colors.white,
                                      currentIsDark ? 0.5 : 0.0,
                                    )
                                  : null,
                              fontSize: suSetSp(20.0),
                              height: suSetHeight(1.25),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget get actionBar => IndexedStack(
        children: List<Widget>.generate(
          actions.length,
          (int i) {
            final String key = actions[i].keys.elementAt(0);
            return Row(
              children: List<Widget>.generate(
                (actions[i][key]['content'] as List<dynamic>).length,
                (int j) {
                  final Map<String, dynamic> item = actions[i].values.elementAt(0)['content'][j];
                  final int count = item['field'] as int;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      (item['select'] as void Function(int index))(j);
                      (item['action'] as VoidCallback)();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: suSetWidth(21.0)),
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
    final Map<String, dynamic> item =
        actions[sectionIndex].values.elementAt(0)['content'][actionIndex];
    final String icon = item['icon'] as String;
    final int index = item['index'] as int;
    return AnimatedCrossFade(
      duration: duration,
      crossFadeState: index == actionIndex ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: SvgPicture.asset(
        'assets/icons/postActions/$icon-fill.svg',
        color: currentThemeColor,
        width: suSetWidth(32.0),
      ),
      secondChild: SvgPicture.asset(
        'assets/icons/postActions/$icon-fill.svg',
        color: Theme.of(context).dividerColor,
        width: suSetWidth(32.0),
      ),
    );
  }

  Widget _mentionList() => Column(
        children: <Widget>[
          Row(
            children: List<Widget>.generate(squareMentionActions.length, (int i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: duration,
                  margin: EdgeInsets.symmetric(
                    horizontal: suSetWidth(24.0),
                    vertical: suSetHeight(10.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: suSetHeight(10.0)),
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
              children: <Widget>[commentByMention(), postByMention()],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black26,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: navigatorState.pop,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(suSetWidth(20.0)),
              topRight: Radius.circular(suSetWidth(20.0)),
            ),
            child: Container(
              constraints: BoxConstraints(maxHeight: Screens.height * 0.75),
              padding: EdgeInsets.only(top: suSetHeight(20.0)),
              color: Theme.of(context).primaryColor,
              child: Column(
                children: <Widget>[
                  backButton,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
                    height: suSetHeight(kAppBarHeight),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: suSetWidth(1.0),
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Row(children: [sectionBar, const Spacer(), actionBar]),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _index,
                      children: <Widget>[
                        IndexedStack(
                          index: _squareIndex,
                          children: <Widget>[
                            praiseList(),
                            commentByReply(),
                            _mentionList(),
                          ],
                        ),
                        SpinKitWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
