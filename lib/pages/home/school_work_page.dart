import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/pages/home/course_schedule_page.dart';
import 'package:openjmu/pages/home/score_page.dart';

class SchoolWorkPage extends StatefulWidget {
  const SchoolWorkPage({@required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SchoolWorkPageState();
}

class SchoolWorkPageState extends State<SchoolWorkPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static List<String> get tabs => <String>[
        if (!(currentUser?.isPostgraduate ?? false)) '课程表',
        if (!((currentUser?.isTeacher ?? false) ||
            (currentUser?.isPostgraduate ?? false)))
          '成绩',
      ];

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  int currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    currentIndex = Provider.of<SettingsProvider>(
      currentContext,
      listen: false,
    ).homeStartUpIndex[1];

    Instances.eventBus
        .on<AppCenterRefreshEvent>()
        .listen((AppCenterRefreshEvent event) {
      switch (tabs[event.currentIndex]) {
        case '课程表':
          Instances.eventBus.fire(CourseScheduleRefreshEvent());
          break;
        case '成绩':
          Provider.of<ScoresProvider>(currentContext, listen: false)
              .requestScore();
          break;
        case '应用':
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0.0);
          }
          refreshIndicatorKey.currentState?.show();
          break;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  FixedAppBar get _appBar => FixedAppBar(
        automaticallyImplyLeading: false,
        title: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.only(right: 20.0.w),
          child: MainPage.selfPageOpener,
        ),
        actions: <Widget>[
          _refreshIcon,
          switchButton,
        ],
        actionsPadding: EdgeInsets.only(right: 20.0.w),
      );

  Widget get _refreshIcon => SizedBox(
        width: suSetWidth(60.0),
        child: IconButton(
          alignment: Alignment.centerRight,
          icon: Icon(Icons.refresh, size: suSetWidth(32.0)),
          onPressed: () {
            Instances.eventBus.fire(AppCenterRefreshEvent(currentIndex));
          },
        ),
      );

  Widget get switchButton {
    return MaterialButton(
      color: currentThemeColor,
      elevation: 0.0,
      minWidth: 100.w,
      height: 56.w,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(suSetWidth(13.0)),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Text(
        currentIndex == 0 ? '成绩' : '课程表',
        style: TextStyle(
          color: adaptiveButtonColor(),
          fontSize: suSetSp(20.0),
          height: 1.24,
        ),
      ),
      onPressed: () {
        setState(() {
          if (currentIndex == 0) {
            currentIndex = 1;
          } else {
            currentIndex = 0;
          }
        });
      },
    );
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ColoredBox(
      color: Theme.of(context).canvasColor,
      child: FixedAppBarWrapper(
        appBar: _appBar,
        body: Selector<ThemesProvider, bool>(
          selector: (_, ThemesProvider provider) => provider.dark,
          builder: (_, bool isDark, __) {
            return IndexedStack(
              index: currentIndex,
              children: <Widget>[
                if (tabs.contains('课程表'))
                  currentUser.isTeacher != null
                      ? currentUser?.isTeacher ?? false
                          ? InAppWebViewPage(
                              url: '${API.courseScheduleTeacher}'
                                  '?sid=${currentUser.sid}'
                                  '&night=${isDark ? 1 : 0}',
                              title: '课程表',
                              withAppBar: false,
                              withAction: false,
                              keepAlive: true,
                            )
                          : CourseSchedulePage(
                              key: Instances.courseSchedulePageStateKey,
                            )
                      : const SizedBox.shrink(),
                if (tabs.contains('成绩')) ScorePage(),
              ],
            );
          },
        ),
      ),
    );
  }
}
