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
  static List<String> get tabs => [
        if (!(currentUser?.isPostgraduate ?? false)) '课程表',
        if (!((currentUser?.isTeacher ?? false) ||
            (currentUser?.isPostgraduate ?? false)))
          '成绩',
      ];

  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final _scrollController = ScrollController();

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
      ..on<ScrollToTopEvent>().listen((event) {
        if (mounted && event.tabIndex == 1) {
          _scrollController.animateTo(0,
              duration: 500.milliseconds, curve: Curves.ease);
        }
      })
      ..on<AppCenterRefreshEvent>().listen((event) {
        switch (tabs[event.currentIndex]) {
          case '课程表':
            Instances.eventBus.fire(CourseScheduleRefreshEvent());
            break;
          case '成绩':
            Provider.of<ScoresProvider>(currentContext, listen: false)
                .requestScore();
            break;
          case '应用':
            if (_scrollController.hasClients) _scrollController.jumpTo(0.0);
            refreshIndicatorKey.currentState?.show();
            break;
        }
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Widget get _appBar => FixedAppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(right: 20.0.w),
          child: Row(
            children: <Widget>[
              MainPage.selfPageOpener(context),
              const Spacer(),
            ],
          ),
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

  Widget get switchButton => MaterialButton(
        color: currentThemeColor,
        minWidth: suSetWidth(currentIndex == 0 ? 100.0 : 120.0),
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
                R.ASSETS_ICONS_BOTTOM_NAVIGATION_SCHOOL_WORK_SVG,
                height: suSetHeight(22.0),
                color: Colors.white,
              ),
            ),
            Text(
              currentIndex == 0 ? '成绩' : '课程表',
              style: TextStyle(
                color: Colors.white,
                fontSize: suSetSp(20.0),
                height: 1.24,
              ),
            ),
          ],
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

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: FixedAppBarWrapper(
        appBar: _appBar,
        body: Selector<ThemesProvider, bool>(
          selector: (_, provider) => provider.dark,
          builder: (_, dark, __) {
            return IndexedStack(
              index: currentIndex,
              children: <Widget>[
                if (tabs.contains('课程表'))
                  currentUser.isTeacher != null
                      ? currentUser?.isTeacher ?? false
                          ? InAppBrowserPage(
                              url: '${API.courseScheduleTeacher}'
                                  '?sid=${currentUser.sid}'
                                  '&night=${dark ? 1 : 0}',
                              title: '课程表',
                              withAppBar: false,
                              withAction: false,
                              keepAlive: true,
                            )
                          : CourseSchedulePage(
                              key: Instances.courseSchedulePageStateKey,
                            )
                      : SizedBox.shrink(),
                if (tabs.contains('成绩')) ScorePage(),
              ],
            );
          },
        ),
      ),
    );
  }
}
