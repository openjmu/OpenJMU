import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

double get _dialogWidth => 300.w;

double get _dialogHeight => 380.w;

class CourseSchedulePage extends StatefulWidget {
  const CourseSchedulePage({@required Key key}) : super(key: key);

  @override
  CourseSchedulePageState createState() => CourseSchedulePageState();
}

class CourseSchedulePageState extends State<CourseSchedulePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  /// Refresh indicator key to refresh courses display.
  /// 用于显示课表刷新状态的的刷新指示器Key
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();

  /// Duration for any animation.
  /// 所有动画/过渡的时长
  final Duration animateDuration = 300.milliseconds;

  /// Week widget width in switcher.
  /// 周数切换内的每周部件宽度
  final double weekSize = 80.0;

  /// Week widget height in switcher.
  /// 周数切换器部件宽度
  double get weekSwitcherHeight => (weekSize / 1.25).h;

  /// Current month / course time widget's width on the left side.
  /// 左侧月份日期及课时部件的宽度
  final double monthWidth = 36.0;

  /// Weekday indicator widget's height.
  /// 天数指示器高度
  final double weekdayIndicatorHeight = 64.0;

  /// Week switcher animation controller.
  /// 周数切换器的动画控制器
  AnimationController weekSwitcherAnimationController;

  /// Week switcher scroll controller.
  /// 周数切换器的滚动控制器
  ScrollController weekScrollController;

  TabController weekTabController;

  CoursesProvider get coursesProvider => currentContext.read<CoursesProvider>();

  bool get firstLoaded => coursesProvider.firstLoaded;

  bool get hasCourses => coursesProvider.hasCourses;

  bool get showError => coursesProvider.showError;

  bool get isOuterError => coursesProvider.isOuterError;

  DateTime get now => coursesProvider.now;

  Map<int, Map<dynamic, dynamic>> get courses => coursesProvider.courses;

  DateProvider get dateProvider => currentContext.read<DateProvider>();

  int currentWeek;

  /// Week duration between current and selected.
  /// 选中的周数与当前周的相差时长
  Duration get selectedWeekDaysDuration =>
      (7 * (currentWeek - dateProvider.currentWeek)).days;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    weekSwitcherAnimationController = AnimationController.unbounded(
      vsync: this,
      duration: animateDuration,
      value: 0,
    );

    currentWeek = dateProvider.currentWeek;
    updateScrollController();

    Instances.eventBus
      ..on<CourseScheduleRefreshEvent>().listen(
        (CourseScheduleRefreshEvent event) {
          if (mounted) {
            refreshIndicatorKey.currentState.show();
          }
        },
      )
      ..on<CurrentWeekUpdatedEvent>().listen(
        (CurrentWeekUpdatedEvent event) {
          if (currentWeek == null) {
            currentWeek = dateProvider.currentWeek ?? 0;
            updateScrollController();
            if (mounted) {
              setState(() {});
            }
            if ((weekScrollController?.hasClients ?? false) &&
                hasCourses &&
                currentWeek > 0) {
              scrollToWeek(currentWeek);
            }
            if (Instances.schoolWorkPageStateKey.currentState.mounted) {
              Instances.schoolWorkPageStateKey.currentState.setState(() {});
            }
          }
        },
      );
  }

  /// Update week switcher scroll controller with the current week.
  /// 以当前周更新周数切换器的位置
  void updateScrollController() {
    if (coursesProvider.firstLoaded) {
      final int week = dateProvider.currentWeek;
      final double offset = currentWeekOffset(week);
      weekScrollController ??= ScrollController(
        initialScrollOffset: week != null ? offset : 0.0,
      );

      /// Theoretically it doesn't require setState here, but it only
      /// takes effect if the setState is called.
      /// This needs more investigation.
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Scroll to specified week.
  /// 周数切换器滚动到指定周
  void scrollToWeek(int week) {
    currentWeek = week;
    if (mounted) {
      setState(() {});
    }
    if (weekScrollController?.hasClients ?? false) {
      weekScrollController.animateTo(
        currentWeekOffset(currentWeek),
        duration: animateDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Show remark detail.
  /// 显示班级备注详情
  void showRemarkDetail(BuildContext context) {
    ConfirmationDialog.show(
      context,
      title: '班级备注',
      content: context.read<CoursesProvider>().remark,
      cancelLabel: '返回',
    );
  }

  /// Return scroll offset according to given week.
  /// 根据给定的周数返回滚动偏移量
  double currentWeekOffset(int week) {
    return math.max(0, (week - 0.5) * weekSize.w - Screens.width / 2);
  }

  /// Calculate courses max weekday.
  /// 计算最晚的一节课在周几
  int get maxWeekDay {
    int _maxWeekday = 5;
    for (final int count in courses[6].keys.cast<int>()) {
      if ((courses[6][count] as List<dynamic>).isNotEmpty) {
        if (_maxWeekday != 7) {
          _maxWeekday = 6;
        }
        break;
      }
    }
    for (final int count in courses[7].keys.cast<int>()) {
      if ((courses[7][count] as List<dynamic>).isNotEmpty) {
        _maxWeekday = 7;
        break;
      }
    }
    return _maxWeekday;
  }

  String _weekday(int i) => DateFormat('EEE', 'zh_CN').format(
        now.add(selectedWeekDaysDuration).subtract((now.weekday - 1 - i).days),
      );

  String _date(int i) => DateFormat('MM/dd').format(
        now.add(selectedWeekDaysDuration).subtract((now.weekday - 1 - i).days),
      );

  /// Week widget in week switcher.
  /// 周数切换器内的周数组件
  Widget _week(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        scrollToWeek(index + 1);
      },
      child: Container(
        width: weekSize.w,
        padding: EdgeInsets.all(10.w),
        child: Selector<DateProvider, int>(
          selector: (_, DateProvider provider) => provider.currentWeek,
          builder: (_, int week, __) {
            final bool isSelected = currentWeek == index + 1;
            final bool isCurrentWeek = week == index + 1;
            return AnimatedContainer(
              duration: animateDuration,
              alignment: Alignment.center,
              child: AnimatedDefaultTextStyle(
                duration: animateDuration,
                style: TextStyle(
                  color: isSelected
                      ? currentThemeColor
                      : isCurrentWeek
                          ? context.textTheme.bodyText2.color
                          : context.textTheme.caption.color,
                  fontSize: 18.w,
                  fontWeight: isSelected || isCurrentWeek
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                child: Text('第${index + 1}周'),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Remark widget.
  /// 课程备注部件
  Widget get remarkWidget => Tapper(
        onTap: () => showRemarkDetail(context),
        child: Container(
          alignment: Alignment.center,
          width: Screens.width,
          constraints: BoxConstraints(maxHeight: 54.h),
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          color: context.theme.canvasColor,
          child: Selector<CoursesProvider, String>(
            selector: (_, CoursesProvider provider) => provider.remark,
            builder: (_, String remark, __) => Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(
                    text: '班级备注: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: remark),
                ],
                style: context.textTheme.bodyText2.copyWith(
                  fontSize: 20.sp,
                ),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

  /// Week switcher widget.
  /// 周数切换器部件
  Widget weekSelection(BuildContext context) {
    if (weekTabController == null) {
      weekTabController = TabController(length: 20, vsync: this);
    } else if (weekTabController.index != currentWeek - 1) {
      weekTabController
        ..index = math.min(19, currentWeek - 1)
        ..animateTo(math.min(19, currentWeek - 1));
    }
    return AnimatedBuilder(
      animation: weekSwitcherAnimationController,
      builder: (_, __) => Container(
        width: Screens.width,
        height: moreThanZero(
          math.min(
            weekSwitcherHeight,
            weekSwitcherAnimationController.value,
          ),
        ).toDouble(),
        color: adaptiveSurfaceColor,
        child: TabBar(
          controller: weekTabController,
          isScrollable: true,
          indicatorWeight: 4.w,
          tabs: List<Widget>.generate(20, (int i) => _week(context, i)),
          labelPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// The toggle button to expand/collapse week switcher.
  /// 触发周数切换器显示隐藏的按钮
  Widget _weekSwitcherToggleButton(BuildContext context) {
    return Tapper(
      onTap: () {
        weekSwitcherAnimationController.animateTo(
          weekSwitcherAnimationController.value > weekSwitcherHeight / 2
              ? 0
              : weekSwitcherHeight,
          duration: animateDuration * 0.75,
          curve: Curves.easeOutQuart,
        );
      },
      child: Container(
        width: monthWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.w),
            bottomRight: Radius.circular(10.w),
          ),
          color: currentThemeColor,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('第', textAlign: TextAlign.center),
              Text(
                '$currentWeek',
                style: TextStyle(fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
              const Text('周', textAlign: TextAlign.center),
              VGap(4.w),
              AnimatedBuilder(
                animation: weekSwitcherAnimationController,
                builder: (_, __) => RotatedBox(
                  quarterTurns: weekSwitcherAnimationController.value >
                          weekSwitcherHeight / 2
                      ? 3
                      : 1,
                  child: SvgPicture.asset(
                    R.ASSETS_ICONS_SELF_PAGE_AVATAR_CORNER_SVG,
                    height: 10.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The current week's weekday indicator.
  /// 本周的天数指示器
  Widget get weekDayIndicator {
    return Container(
      color: Theme.of(context).canvasColor,
      height: weekdayIndicatorHeight.h,
      child: Row(
        children: <Widget>[
          _weekSwitcherToggleButton(context),
          for (int i = 0; i < maxWeekDay; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  // color: i == 2 ? currentThemeColor.withOpacity(0.35) : null,
                  color: DateFormat('MM/dd').format(
                            now.subtract(selectedWeekDaysDuration +
                                (now.weekday - 1 - i).days),
                          ) ==
                          DateFormat('MM/dd').format(now)
                      ? currentThemeColor.withOpacity(0.35)
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _weekday(i),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      VGap(5.w),
                      Text(
                        _date(i),
                        style: context.textTheme.caption.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Course time column widget on the left side.
  /// 左侧的课时组件
  Widget courseTimeColumn(int maxDay) {
    return Container(
      color: Theme.of(context).canvasColor,
      width: monthWidth,
      child: Column(
        children: List<Widget>.generate(
          maxDay,
          (int i) => Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    (i + 1).toString(),
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CourseAPI.getCourseTime(i + 1),
                    style: context.textTheme.caption.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Courses widgets.
  /// 课程系列组件
  Widget courseLineGrid(BuildContext context) {
    bool hasEleven = false;
    int _maxCoursesPerDay = 8;

    /// Judge max courses per day.
    /// 判断每天最多课时
    for (final int day in courses.keys) {
      final List<Course> list9 =
          (courses[day][9] as List<dynamic>).cast<Course>();
      final List<Course> list11 =
          (courses[day][11] as List<dynamic>).cast<Course>();
      if (list9.isNotEmpty && _maxCoursesPerDay < 10) {
        _maxCoursesPerDay = 10;
      } else if (list9.isNotEmpty &&
          list9.where((Course course) => course.isEleven).isNotEmpty &&
          _maxCoursesPerDay < 11) {
        hasEleven = true;
        _maxCoursesPerDay = 11;
      } else if (list11.isNotEmpty && _maxCoursesPerDay < 12) {
        _maxCoursesPerDay = 12;
        break;
      }
    }

    return Expanded(
      child: Row(
        children: <Widget>[
          courseTimeColumn(_maxCoursesPerDay),
          for (int day = 1; day < maxWeekDay + 1; day++)
            Expanded(
              child: Column(
                children: <Widget>[
                  for (int count = 1; count < _maxCoursesPerDay; count++)
                    if (count.isOdd)
                      CourseWidget(
                        courseList: courses[day]
                            .cast<int, List<dynamic>>()[count]
                            .cast<Course>(),
                        hasEleven: hasEleven && count == 9,
                        currentWeek: currentWeek,
                        coordinate: <int>[day, count],
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget get errorTips {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.w, color: context.theme.dividerColor),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              R.ASSETS_PLACEHOLDERS_COURSE_NOT_READY_SVG,
              width: 50.w,
              color: context.theme.iconTheme.color,
            ),
            VGap(20.w),
            Text(
              '课程表未就绪',
              style: TextStyle(
                color: context.textTheme.caption.color,
                fontSize: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: coursesProvider.updateCourses,
      child: Column(
        children: <Widget>[
          weekSelection(context),
          Expanded(
            child: Consumer<CoursesProvider>(
              builder: (BuildContext c, CoursesProvider p, __) {
                return AnimatedCrossFade(
                  duration: animateDuration,
                  crossFadeState: !firstLoaded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: const Center(
                    child: LoadMoreSpinningIcon(isRefreshing: true),
                  ),
                  secondChild: Column(
                    children: <Widget>[
                      if (p.remark != null) remarkWidget,
                      if (p.firstLoaded &&
                          p.hasCourses &&
                          !(p.showError && !p.isOuterError))
                        weekDayIndicator,
                      if (p.firstLoaded &&
                          p.hasCourses &&
                          !(p.showError && !p.isOuterError))
                        courseLineGrid(context),
                      if (p.firstLoaded &&
                          !p.hasCourses &&
                          !(p.showError && !p.isOuterError))
                        errorTips,
                      if (p.firstLoaded && (p.showError && !p.isOuterError))
                        errorTips,
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CourseWidget extends StatelessWidget {
  const CourseWidget({
    Key key,
    @required this.courseList,
    @required this.coordinate,
    this.hasEleven,
    this.currentWeek,
  })  : assert(coordinate.length == 2, 'Invalid course coordinate'),
        super(key: key);

  final List<Course> courseList;
  final List<int> coordinate;
  final bool hasEleven;
  final int currentWeek;

  bool get isOutOfTerm => currentWeek < 1 || currentWeek > 20;

  void showCoursesDetail(BuildContext context) {
    showModal<void>(
        context: context,
        builder: (BuildContext _) {
          if (courseList.length == 1) {
            if (courseList[0].isCustom) {
              return _CustomCourseDetailDialog(
                course: courseList[0],
                currentWeek: currentWeek,
                coordinate: coordinate,
              );
            } else {
              return _CourseDetailDialog(
                course: courseList[0],
                currentWeek: currentWeek,
              );
            }
          } else {
            return _CourseListDialog(
              courseList: courseList,
              currentWeek: currentWeek,
              coordinate: coordinate,
            );
          }
        });
  }

  Widget courseCustomIndicator(Course course) {
    return Positioned(
      bottom: 1.5,
      left: 1.5,
      child: Container(
        width: 24.w,
        height: 24.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.w),
            bottomLeft: Radius.circular(5.w),
          ),
          color: currentThemeColor.withOpacity(0.35),
        ),
        child: Center(
          child: Text(
            '✍️',
            style: TextStyle(
              color: !CourseAPI.inCurrentWeek(
                course,
                currentWeek: currentWeek,
              )
                  ? Colors.grey
                  : Colors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget get courseCountIndicator {
    return Positioned(
      bottom: 1.5,
      right: 1.5,
      child: Container(
        width: 24.w,
        height: 24.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.w),
            bottomRight: Radius.circular(5.w),
          ),
          color: currentThemeColor.withOpacity(0.35),
        ),
        child: Center(
          child: Text(
            '${courseList.length}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget courseContent(BuildContext context, Course course) {
    Widget child;
    if (course != null) {
      child = Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: course.name.substring(
                0,
                math.min(10, course.name.length),
              ),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            if (course.isCustom
                ? course.name.length > 20
                : course.name.length > 10)
              const TextSpan(text: '...'),
            if (!course.isCustom)
              TextSpan(text: '\n${course.startWeek}-${course.endWeek}周'),
            if (course.location != null)
              TextSpan(text: '\n📍${course.location.notBreak}'),
          ],
        ),
        style: context.textTheme.bodyText2.copyWith(
          color: !CourseAPI.inCurrentWeek(course, currentWeek: currentWeek) &&
                  !isOutOfTerm
              ? Colors.grey
              : Colors.black,
          fontSize: 13.sp,
        ),
        overflow: TextOverflow.fade,
      );
    } else {
      child = Icon(
        Icons.add,
        color: context.iconTheme.color,
      );
    }
    return SizedBox.expand(child: child);
  }

  @override
  Widget build(BuildContext context) {
    bool isEleven = false;
    Course course;
    if (courseList != null && courseList.isNotEmpty) {
      course = courseList.firstWhere(
        (Course c) => CourseAPI.inCurrentWeek(c, currentWeek: currentWeek),
        orElse: () => null,
      );
    }
    if (course == null && courseList.isNotEmpty) {
      course = courseList[0];
    }
    if (hasEleven) {
      isEleven = course?.isEleven ?? false;
    }
    return Expanded(
      flex: hasEleven ? 3 : 2,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      splashFactory: InkSplash.splashFactory,
                      hoverColor: Colors.black,
                      onTap: () {
                        if (courseList.isNotEmpty) {
                          showCoursesDetail(context);
                        }
                      },
                      onLongPress: courseList.isEmpty
                          ? () {
                              showModal<void>(
                                context: context,
                                builder: (_) => CourseEditDialog(
                                  course: null,
                                  coordinate: coordinate,
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: courseList.isNotEmpty
                              ? CourseAPI.inCurrentWeek(course,
                                          currentWeek: currentWeek) ||
                                      isOutOfTerm
                                  ? course.color.withOpacity(0.85)
                                  : Theme.of(context).dividerColor
                              : null,
                        ),
                        child: courseContent(context, course),
                      ),
                    ),
                  ),
                ),
                if (courseList
                    .where((Course course) => course.isCustom)
                    .isNotEmpty)
                  courseCustomIndicator(course),
                if (courseList.length > 1) courseCountIndicator,
              ],
            ),
          ),
          if (!isEleven && hasEleven) const Spacer(),
        ],
      ),
    );
  }
}

class _CourseListDialog extends StatefulWidget {
  const _CourseListDialog({
    Key key,
    @required this.courseList,
    @required this.currentWeek,
    @required this.coordinate,
  }) : super(key: key);

  final List<Course> courseList;
  final int currentWeek;
  final List<int> coordinate;

  @override
  _CourseListDialogState createState() => _CourseListDialogState();
}

class _CourseListDialogState extends State<_CourseListDialog> {
  final double darkModeOpacity = 0.85;
  bool deleting = false;

  bool get isOutOfTerm => widget.currentWeek < 1 || widget.currentWeek > 20;

  Widget get coursesPage {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.6),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.courseList.length,
      itemBuilder: (BuildContext context, int index) {
        return Tapper(
          onTap: Navigator.of(context).maybePop,
          child: Center(
            child: IgnorePointer(
              child: _CourseDetailDialog(
                course: widget.courseList[index],
                currentWeek: widget.currentWeek,
                isDialog: false,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: coursesPage,
    );
  }
}

class _CourseColorIndicator extends StatelessWidget {
  const _CourseColorIndicator({
    Key key,
    @required this.course,
    @required this.currentWeek,
  }) : super(key: key);

  final Course course;
  final int currentWeek;

  bool get isOutOfTerm => currentWeek < 1 || currentWeek > 20;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0.0,
      bottom: 0.0,
      left: 0.0,
      width: 8.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: maxBorderRadius,
          color: CourseAPI.inCurrentWeek(course, currentWeek: currentWeek) ||
                  isOutOfTerm
              ? course.color.withOpacity(currentIsDark ? 0.85 : 1.0)
              : Colors.grey,
        ),
      ),
    );
  }
}

class _CourseInfoRowWidget extends StatelessWidget {
  const _CourseInfoRowWidget({
    Key key,
    @required this.name,
    @required this.value,
  })  : assert(name != null),
        assert(value != null),
        super(key: key);

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.caption.copyWith(
        fontSize: 18.sp,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Text(name),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: context.textTheme.bodyText2.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseDetailDialog extends StatelessWidget {
  const _CourseDetailDialog({
    Key key,
    @required this.course,
    @required this.currentWeek,
    this.isDialog = true,
  }) : super(key: key);

  final Course course;
  final int currentWeek;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    Widget widget = Container(
      width: _dialogWidth,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: context.theme.colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 16.w),
            child: Stack(
              children: <Widget>[
                _CourseColorIndicator(
                  course: course,
                  currentWeek: currentWeek,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 24.w),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      course.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (course.location != null)
            _CourseInfoRowWidget(
              name: '教室',
              value: course.location,
            ),
          if (course.teacher != null)
            _CourseInfoRowWidget(
              name: '教师',
              value: course.teacher,
            ),
          _CourseInfoRowWidget(
            name: '周数',
            value: course.weekDurationString,
          ),
        ],
      ),
    );
    if (isDialog) {
      widget = Material(
        type: MaterialType.transparency,
        child: Center(child: widget),
      );
    }
    return widget;
  }
}

class _CustomCourseDetailDialog extends StatefulWidget {
  const _CustomCourseDetailDialog({
    Key key,
    @required this.course,
    @required this.currentWeek,
    @required this.coordinate,
  })  : assert(course != null),
        assert(currentWeek != null),
        super(key: key);

  final Course course;
  final int currentWeek;
  final List<int> coordinate;

  @override
  _CustomCourseDetailDialogState createState() =>
      _CustomCourseDetailDialogState();
}

class _CustomCourseDetailDialogState extends State<_CustomCourseDetailDialog> {
  bool deleting = false;

  Course get course => widget.course;

  int get currentWeek => widget.currentWeek;

  void deleteCourse() {
    setState(() {
      deleting = true;
    });
    final Course _course = widget.course;
    Future.wait<Response<Map<String, dynamic>>>(
      <Future<Response<Map<String, dynamic>>>>[
        CourseAPI.setCustomCourse(<String, dynamic>{
          'content': Uri.encodeComponent(''),
          'couDayTime': _course.day,
          'coudeTime': _course.time,
        }),
        if (_course.shouldUseRaw)
          CourseAPI.setCustomCourse(<String, dynamic>{
            'content': Uri.encodeComponent(''),
            'couDayTime': _course.rawDay,
            'coudeTime': _course.rawTime,
          }),
      ],
      eagerError: true,
    ).then((List<Response<Map<String, dynamic>>> responses) {
      bool isOk = true;
      for (final Response<Map<String, dynamic>> response in responses) {
        if (!(response.data['isOk'] as bool)) {
          isOk = false;
          break;
        }
      }
      if (isOk) {
        navigatorState.popUntil((_) => _.isFirst);
        Instances.eventBus.fire(CourseScheduleRefreshEvent());
      }
    }).catchError((dynamic e) {
      showToast('删除课程失败');
      LogUtils.e('Failed in deleting custom course: $e');
    }).whenComplete(() {
      deleting = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget closeButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.close),
      iconSize: 30.w,
      onPressed: Navigator.of(context).pop,
      constraints: BoxConstraints(minWidth: 30.w),
    );
  }

  Widget get editButton {
    return MaterialButton(
      elevation: 0.0,
      highlightElevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      disabledElevation: 0.0,
      padding: EdgeInsets.zero,
      minWidth: double.maxFinite,
      height: 64.w,
      color: Colors.grey[500],
      child: Text(
        '编辑',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        showModal<void>(
          context: context,
          builder: (_) => CourseEditDialog(
            course: course,
            coordinate: widget.coordinate,
          ),
        );
      },
    );
  }

  Widget get deleteButton {
    return MaterialButton(
      elevation: 0.0,
      highlightElevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      disabledElevation: 0.0,
      padding: EdgeInsets.zero,
      minWidth: double.maxFinite,
      height: 64.w,
      color: defaultLightColor,
      child: Text(
        '删除',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: deleteCourse,
    );
  }

  Widget header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.w),
      child: Row(
        children: <Widget>[
          Text('自定义课程', style: TextStyle(fontSize: 20.sp)),
          const Spacer(),
          closeButton(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: SizedBox(
            width: _dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  color: context.theme.colorScheme.surface,
                  padding: EdgeInsets.all(30.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      header(context),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.w),
                        child: Stack(
                          children: <Widget>[
                            _CourseColorIndicator(
                              course: course,
                              currentWeek: currentWeek,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 24.w),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  course.name,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                editButton,
                deleteButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CourseEditDialog extends StatefulWidget {
  const CourseEditDialog({
    Key key,
    @required this.course,
    @required this.coordinate,
  }) : super(key: key);

  final Course course;
  final List<int> coordinate;

  @override
  _CourseEditDialogState createState() => _CourseEditDialogState();
}

class _CourseEditDialogState extends State<CourseEditDialog> {
  final double darkModeOpacity = 0.85;

  TextEditingController _controller;
  String content;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    content = widget.course?.name;
    _controller = TextEditingController(text: content);
  }

  void editCourse() {
    loading = true;
    if (mounted) {
      setState(() {});
    }
    Future<Response<Map<String, dynamic>>> editFuture;

    if (widget.course?.shouldUseRaw ?? false) {
      editFuture = CourseAPI.setCustomCourse(<String, dynamic>{
        'content': Uri.encodeComponent(content),
        'couDayTime': widget.course?.rawDay ?? widget.coordinate[0],
        'coudeTime': widget.course?.rawTime ?? widget.coordinate[1],
      });
    } else {
      editFuture = CourseAPI.setCustomCourse(<String, dynamic>{
        'content': Uri.encodeComponent(content),
        'couDayTime': widget.course?.day ?? widget.coordinate[0],
        'coudeTime': widget.course?.time ?? widget.coordinate[1],
      });
    }
    editFuture.then((Response<Map<String, dynamic>> response) {
      loading = false;
      if (mounted) {
        setState(() {});
      }
      if (response.data['isOk'] as bool) {
        navigatorState.popUntil((_) => _.isFirst);
      }
      Instances.eventBus.fire(CourseScheduleRefreshEvent());
    }).catchError((dynamic e) {
      LogUtils.e('Failed when editing custom course: $e');
      showCenterErrorToast('编辑自定义课程失败');
      loading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget get courseEditField => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.w),
          color: widget.course != null
              ? widget.course.color
                  .withOpacity(currentIsDark ? darkModeOpacity : 1.0)
              : Theme.of(context).dividerColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Screens.width / 2),
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !loading,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26.sp,
                    height: 1.5,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  textAlign: TextAlign.center,
                  cursorColor: currentThemeColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '自定义内容',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 24.sp,
                      height: 1.5,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  maxLines: null,
                  maxLength: 30,
                  buildCounter: emptyCounterBuilder,
                  onChanged: (String value) {
                    content = value;
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );

  Widget closeButton(BuildContext context) => Positioned(
        top: 0.0,
        right: 0.0,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: Navigator.of(context).pop,
        ),
      );

  Widget updateButton(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          splashFactory: InkSplash.splashFactory,
        ),
        child: Positioned(
          bottom: 8.h,
          left: Screens.width / 7,
          right: Screens.width / 7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              MaterialButton(
                padding: EdgeInsets.zero,
                minWidth: 48.w,
                height: 48.h,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Screens.width / 2),
                ),
                child: loading
                    ? const Center(
                        child: LoadMoreSpinningIcon(
                          isRefreshing: true,
                          size: 30,
                        ),
                      )
                    : Icon(
                        Icons.check,
                        color: content == widget.course?.name
                            ? Colors.black.withOpacity(0.15)
                            : Colors.black,
                      ),
                onPressed: content == widget.course?.name || loading
                    ? null
                    : editCourse,
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      contentPadding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          width: _dialogWidth,
          height: _dialogHeight,
          child: Stack(
            children: <Widget>[
              courseEditField,
              closeButton(context),
              updateButton(context),
            ],
          ),
        ),
      ],
    );
  }
}
