import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/home/course_schedule_page.dart';
import 'package:openjmu/pages/home/score_page.dart';
import 'package:openjmu/pages/main_page.dart';

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

  int currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  FixedAppBar get _appBar {
    return FixedAppBar(
      automaticallyImplyLeading: false,
      withBorder: false,
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
        _refreshIcon,
        Gap(16.w),
        switchButton,
      ],
    );
  }

  Widget get _refreshIcon {
    return Tapper(
      onTap: () {
        Instances.eventBus.fire(AppCenterRefreshEvent(currentIndex));
      },
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.theme.canvasColor,
        ),
        child: Center(
          child: SvgPicture.asset(
            R.ASSETS_ICONS_REFRESH_SVG,
            color: context.textTheme.bodyText2.color,
            width: 28.w,
          ),
        ),
      ),
    );
  }

  Widget get switchButton {
    return Tapper(
      onTap: () {
        setState(() {
          if (currentIndex == 0) {
            currentIndex = 1;
          } else {
            currentIndex = 0;
          }
        });
      },
      child: Container(
        width: 100.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.themeColor,
        ),
        child: Center(
          child: Text(
            currentIndex == 0 ? '成绩单' : '课程表',
            style: TextStyle(
              color: adaptiveButtonColor(),
              fontSize: 20.sp,
              height: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDark = context.theme.brightness == Brightness.dark;
    return ColoredBox(
      color: context.theme.canvasColor,
      child: FixedAppBarWrapper(
        appBar: _appBar,
        body: IndexedStack(
          index: currentIndex,
          children: <Widget>[
            if (tabs.contains('课程表'))
              if (currentUser?.isTeacher != null)
                if (currentUser?.isTeacher == true)
                  AppWebView(
                    url: '${API.courseScheduleTeacher}'
                        '?sid=${currentUser.sid}'
                        '&night=${isDark ? 1 : 0}',
                    title: '课程表',
                    withAppBar: false,
                    withAction: false,
                    keepAlive: true,
                  )
                else
                  CourseSchedulePage(
                    key: Instances.courseSchedulePageStateKey,
                  )
              else
                const SizedBox.shrink(),
            if (tabs.contains('成绩')) const ScorePage(),
          ],
        ),
      ),
    );
  }
}

class OuterNetworkErrorDialog extends StatelessWidget {
  const OuterNetworkErrorDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Container(
          width: 300.w,
          height: 180.w,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.signal_wifi_off, size: 42.w),
              VGap(10.w),
              Text(
                '由于外网网络限制\n无法获取最新数据\n请连接校园网后重试',
                style: TextStyle(fontSize: 20.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
