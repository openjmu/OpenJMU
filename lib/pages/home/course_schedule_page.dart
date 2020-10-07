import 'dart:math' as math;

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
  final double weekSize = 100.0;

  /// Week widget height in switcher.
  /// 周数切换器部件宽度
  double get weekSwitcherHeight => (weekSize / 1.25).h;

  /// Current month / course time widget's width on the left side.
  /// 左侧月份日期及课时部件的宽度
  final double monthWidth = 36.0;

  /// Weekday indicator widget's height.
  /// 天数指示器高度
  final double weekdayIndicatorHeight = 60.0;

  /// Week switcher animation controller.
  /// 周数切换器的动画控制器
  AnimationController weekSwitcherAnimationController;

  /// Week switcher scroll controller.
  /// 周数切换器的滚动控制器
  ScrollController weekScrollController;

  CoursesProvider get coursesProvider => currentContext.read<CoursesProvider>();

  bool get firstLoaded => coursesProvider.firstLoaded;

  bool get hasCourse => coursesProvider.hasCourses;

  bool get showError => coursesProvider.showError;

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
                hasCourse &&
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

  /// Listener for pointer move.
  /// 触摸点移动时的监听
  ///
  /// Sum delta in the event to update week switcher's height.
  /// 将事件的位移与动画控制器的值相加，变换切换器的高度
  void weekSwitcherPointerMoveListener(PointerMoveEvent event) {
    weekSwitcherAnimationController.value += event.delta.dy;
  }

  /// Listener for pointer up.
  /// 触摸点抬起时的监听
  ///
  /// When the pointer is up, calculate current height's distance between 0 and
  /// the switcher's max height. if current height was under 1/2 of the
  /// max height, then collapse the widget. Otherwise, expand it.
  /// 当触摸点抬起时，计算当前切换器的高度偏差。
  /// 如果小于最大高度的二分之一，则收缩部件，反之扩大。
  void weekSwitcherPointerUpListener(PointerUpEvent event) {
    final double percent = math.max(
      0.000001,
      math.min(
        0.999999,
        weekSwitcherAnimationController.value / weekSwitcherHeight,
      ),
    );
    final double currentHeight = weekSwitcherAnimationController.value;
    if (currentHeight < weekSwitcherHeight / 2) {
      weekSwitcherAnimationController.animateTo(
        0,
        duration: animateDuration * percent,
      );
    } else {
      weekSwitcherAnimationController.animateTo(
        weekSwitcherHeight,
        duration: animateDuration * (percent - 0.5),
      );
    }
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

  String get _month => DateFormat('MMM', 'zh_CN').format(
        now.add(selectedWeekDaysDuration).subtract((now.weekday - 1).days),
      );

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
        padding: EdgeInsets.all(10.0.w),
        child: Selector<DateProvider, int>(
          selector: (BuildContext _, DateProvider provider) =>
              provider.currentWeek,
          builder: (BuildContext _, int week, Widget __) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0.w),
                border: (week == index + 1 && currentWeek != week)
                    ? Border.all(
                        color: currentThemeColor.withOpacity(0.35),
                        width: 2.0,
                      )
                    : null,
                color: currentWeek == index + 1
                    ? currentThemeColor.withOpacity(0.35)
                    : null,
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      const TextSpan(text: '第'),
                      TextSpan(
                        text: '${index + 1}',
                        style: TextStyle(fontSize: 30.0.sp),
                      ),
                      const TextSpan(text: '周'),
                    ],
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 18.0.w),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Remark widget.
  /// 课程备注部件
  Widget get remarkWidget => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showRemarkDetail(context),
        child: Container(
          width: Screens.width,
          constraints: BoxConstraints(maxHeight: 54.0.h),
          child: Stack(
            children: <Widget>[
              AnimatedBuilder(
                animation: weekSwitcherAnimationController,
                builder: (BuildContext _, Widget child) {
                  final double percent = moreThanZero(
                        math.min(weekSwitcherHeight,
                            weekSwitcherAnimationController.value),
                      ) /
                      weekSwitcherHeight;
                  return Opacity(
                    opacity: percent,
                    child: SizedBox.expand(
                      child: Container(color: Theme.of(context).primaryColor),
                    ),
                  );
                },
              ),
              AnimatedContainer(
                duration: animateDuration,
                padding: EdgeInsets.symmetric(
                  horizontal: 30.0.w,
                ),
                child: Center(
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
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: 20.0.sp,
                            ),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// Week switcher widget.
  /// 周数切换器部件
  Widget weekSelection(BuildContext context) {
    return AnimatedBuilder(
      animation: weekSwitcherAnimationController,
      builder: (BuildContext _, Widget child) {
        return Container(
          width: Screens.width,
          height: moreThanZero(
            math.min(weekSwitcherHeight, weekSwitcherAnimationController.value),
          ).toDouble(),
          color: Theme.of(context).primaryColor,
          child: ListView.builder(
            controller: weekScrollController,
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 20,
            itemBuilder: _week,
          ),
        );
      },
    );
  }

  /// The current week's weekday indicator.
  /// 本周的天数指示器
  Widget get weekDayIndicator => Container(
        color: Theme.of(context).canvasColor,
        height: weekdayIndicatorHeight.h,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: monthWidth,
              child: Center(
                child: Text(
                  '${_month.substring(0, _month.length - 1)}'
                  '\n'
                  '${_month.substring(_month.length - 1, _month.length)}',
                  style: TextStyle(fontSize: 18.0.sp),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            for (int i = 0; i < maxWeekDay; i++)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0.w),
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
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0.sp,
                          ),
                        ),
                        Text(
                          _date(i),
                          style: TextStyle(fontSize: 14.0.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

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
                      fontSize: 17.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    CourseAPI.getCourseTime(i + 1),
                    style: TextStyle(fontSize: 12.0.sp),
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
      child: ColoredBox(
        color: Theme.of(context).primaryColor,
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
      ),
    );
  }

  Widget get emptyTips => Expanded(
        child: Center(
          child: Text(
            '没有课的日子\n往往就是这么的朴实无华\n且枯燥\n😆',
            style: TextStyle(fontSize: 30.0.sp),
            strutStyle: const StrutStyle(height: 1.8),
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget get errorTips => Expanded(
        child: Center(
          child: Text(
            '课表看起来还未准备好\n不如到广场放松一下？\n🤒',
            style: TextStyle(fontSize: 30.0.sp),
            strutStyle: const StrutStyle(height: 1.8),
            textAlign: TextAlign.center,
          ),
        ),
      );

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Listener(
      onPointerUp: weekSwitcherPointerUpListener,
      onPointerMove: weekSwitcherPointerMoveListener,
      child: RefreshIndicator(
        key: refreshIndicatorKey,
        onRefresh: coursesProvider.updateCourses,
        child: Column(
          children: <Widget>[
            weekSelection(context),
            Expanded(
              child: AnimatedCrossFade(
                duration: animateDuration,
                crossFadeState: !firstLoaded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: const SpinKitWidget(),
                secondChild: Selector<CoursesProvider, String>(
                  selector: (_, CoursesProvider provider) => provider.remark,
                  builder: (_, String remark, __) => Column(
                    children: <Widget>[
                      if (remark != null) remarkWidget,
                      if (firstLoaded && hasCourse && !showError)
                        weekDayIndicator,
                      if (firstLoaded && hasCourse && !showError)
                        courseLineGrid(context),
                      if (firstLoaded && !hasCourse && !showError) emptyTips,
                      if (firstLoaded && showError) errorTips,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
    showDialog<void>(
      context: context,
      builder: (BuildContext _) => CoursesDialog(
        courseList: courseList,
        currentWeek: currentWeek,
        coordinate: coordinate,
      ),
    );
  }

  Widget courseCustomIndicator(Course course) {
    return Positioned(
      bottom: 1.5,
      left: 1.5,
      child: Container(
        width: 24.0.w,
        height: 24.0.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0.w),
            bottomLeft: Radius.circular(5.0.w),
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
              fontSize: 12.0.sp,
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
        width: 24.0.w,
        height: 24.0.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0.w),
            bottomRight: Radius.circular(5.0.w),
          ),
          color: currentThemeColor.withOpacity(0.35),
        ),
        child: Center(
          child: Text(
            '${courseList.length}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget courseContent(BuildContext context, Course course) {
    return SizedBox.expand(
      child: () {
        if (course != null) {
          return Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: course.name.substring(
                    0,
                    math.min(10, course.name.length),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (course.name.length > 10) const TextSpan(text: '...'),
                if (!course.isCustom)
                  TextSpan(text: '\n${course.startWeek}-${course.endWeek}周'),
                if (course.location != null)
                  TextSpan(text: '\n📍${course.location}'),
              ],
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: !CourseAPI.inCurrentWeek(course,
                                currentWeek: currentWeek) &&
                            !isOutOfTerm
                        ? Colors.grey
                        : Colors.black,
                    fontSize: 18.0.sp,
                  ),
            ),
            overflow: TextOverflow.fade,
          );
        } else {
          Icon(
            Icons.add,
            color: Theme.of(context)
                .iconTheme
                .color
                .withOpacity(0.15)
                .withRed(180)
                .withBlue(180)
                .withGreen(180),
          );
        }
      }(),
    );
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
                  padding: const EdgeInsets.all(1.5),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      splashFactory: InkSplash.splashFactory,
                      hoverColor: Colors.black,
                      onTap: () {
                        if (courseList.isNotEmpty) {
                          showCoursesDetail(context);
                        }
                      },
                      onLongPress: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) => CourseEditDialog(
                            course: null,
                            coordinate: coordinate,
                          ),
                          barrierDismissible: false,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.0.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0.w),
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

class CoursesDialog extends StatefulWidget {
  const CoursesDialog({
    Key key,
    @required this.courseList,
    @required this.currentWeek,
    @required this.coordinate,
  }) : super(key: key);

  final List<Course> courseList;
  final int currentWeek;
  final List<int> coordinate;

  @override
  _CoursesDialogState createState() => _CoursesDialogState();
}

class _CoursesDialogState extends State<CoursesDialog> {
  final double darkModeOpacity = 0.85;
  bool deleting = false;

  void showCoursesDetail(BuildContext context, Course course) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => CoursesDialog(
        courseList: <Course>[course],
        currentWeek: widget.currentWeek,
        coordinate: widget.coordinate,
      ),
    );
  }

  void deleteCourse() {
    setState(() {
      deleting = true;
    });
    final Course _course = widget.courseList[0];
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
        Future<void>.delayed(400.milliseconds, () {
          widget.courseList.removeAt(0);
        });
      }
    }).catchError((dynamic e) {
      showToast('删除课程失败');
      trueDebugPrint('Failed in deleting custom course: $e');
    }).whenComplete(() {
      deleting = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  bool get isOutOfTerm => widget.currentWeek < 1 || widget.currentWeek > 20;

  Widget courseContent(int index) {
    final Course course = widget.courseList[index];
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        children: <Widget>[
          courseColorIndicator(course),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (course.isCustom)
                    Text(
                      '[自定义]',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0.sp,
                        height: 1.5,
                      ),
                    ),
                  Text(
                    course.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!course.isCustom)
                    Text(
                      '📅 '
                      '${course.startWeek}'
                      '-'
                      '${course.endWeek}'
                      '周',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0.sp,
                        height: 1.5,
                      ),
                    ),
                  if (course.location != null)
                    Text(
                      '📍${course.location}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0.sp,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  Widget get coursesPage => PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.courseList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 0.2 * 0.7 * Screens.height / 3 + 10.0,
            ),
            child: GestureDetector(
              onTap: () {
                showCoursesDetail(context, widget.courseList[index]);
              },
              child: courseContent(index),
            ),
          );
        },
      );

  Widget courseDetail(Course course) {
    final TextStyle style = TextStyle(
      color: Colors.black,
      fontSize: 24.0.sp,
      height: 1.8,
    );
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: EdgeInsets.all(12.0.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0.w),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (course.isCustom) Text('[自定义]', style: style),
            Text(
              widget.courseList[0].name,
              style: style.copyWith(
                fontSize: 28.0.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (course.location != null)
              Text('📍 ${course.location}', style: style),
            if (course.startWeek != null && course.endWeek != null)
              Text(
                '📅 ${course.startWeek}'
                '-'
                '${course.endWeek}'
                '${course.oddEven == 1 ? '单' : course.oddEven == 2 ? '双' : ''}周',
                style: style,
              ),
            Text(
              '⏰ ${shortWeekdays[course.day]} '
              '${CourseAPI.courseTimeChinese[course.time]}',
              style: style,
            ),
            if (course.teacher != null)
              Text('🎓 ${course.teacher}', style: style),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }

  Widget closeButton(BuildContext context) => Positioned(
        top: 0.0,
        right: 0.0,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: Navigator.of(context).pop,
        ),
      );

  Widget get deleteButton => MaterialButton(
        padding: EdgeInsets.zero,
        minWidth: 60.0.w,
        height: 60.0.w,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Screens.width / 2),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.black,
          size: 32.0.w,
        ),
        onPressed: deleteCourse,
      );

  Widget get editButton => MaterialButton(
        padding: EdgeInsets.zero,
        minWidth: 60.0.w,
        height: 60.0.w,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Screens.width / 2),
        ),
        child: Icon(Icons.edit, color: Colors.black, size: 32.0.w),
        onPressed: !deleting
            ? () {
                showDialog<void>(
                  context: context,
                  builder: (_) => CourseEditDialog(
                    course: widget.courseList[0],
                    coordinate: widget.coordinate,
                  ),
                  barrierDismissible: false,
                );
              }
            : null,
      );

  Positioned courseColorIndicator(Course course) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      height: 30.w,
      child: ColoredBox(
        color: widget.courseList.isNotEmpty
            ? CourseAPI.inCurrentWeek(course,
                        currentWeek: widget.currentWeek) ||
                    isOutOfTerm
                ? course.color.withOpacity(currentIsDark ? 0.85 : 1.0)
                : Colors.grey
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDetail = widget.courseList.length == 1;
    final Course firstCourse = widget.courseList[0];
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      children: <Widget>[
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.w),
          ),
          child: SizedBox(
            width: _dialogWidth,
            height: _dialogHeight,
            child: Stack(
              children: <Widget>[
                if (isDetail) courseColorIndicator(firstCourse),
                if (isDetail) courseDetail(firstCourse) else coursesPage,
                if (!isDetail) closeButton(context),
                if (isDetail && widget.courseList[0].isCustom)
                  Theme(
                    data: Theme.of(context)
                        .copyWith(splashFactory: InkSplash.splashFactory),
                    child: Positioned(
                      bottom: 10.0.h,
                      left: Screens.width / 7,
                      right: Screens.width / 7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          if (deleting)
                            SizedBox.fromSize(
                              size: Size.square(60.0.w),
                              child: const SpinKitWidget(size: 30),
                            )
                          else
                            deleteButton,
                          editButton,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
      trueDebugPrint('Failed when editing custom course: $e');
      showCenterErrorToast('编辑自定义课程失败');
      loading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget get courseEditField => Container(
        padding: EdgeInsets.all(12.0.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0.w),
          color: widget.course != null
              ? widget.course.color
                  .withOpacity(currentIsDark ? darkModeOpacity : 1.0)
              : Theme.of(context).dividerColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0.h),
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
                    fontSize: 26.0.sp,
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
                      fontSize: 24.0.sp,
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
          bottom: 8.0.h,
          left: Screens.width / 7,
          right: Screens.width / 7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              MaterialButton(
                padding: EdgeInsets.zero,
                minWidth: 48.0.w,
                height: 48.0.h,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Screens.width / 2),
                ),
                child: loading
                    ? const SpinKitWidget(size: 30)
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
