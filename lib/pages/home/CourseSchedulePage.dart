import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/home/AppCenterPage.dart';

class CourseSchedulePage extends StatefulWidget {
  final AppCenterPageState appCenterPageState;
  const CourseSchedulePage({
    @required Key key,
    @required this.appCenterPageState,
  }) : super(key: key);

  @override
  CourseSchedulePageState createState() => CourseSchedulePageState();
}

class CourseSchedulePageState extends State<CourseSchedulePage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();
  final Duration showWeekDuration = const Duration(milliseconds: 300);
  final Curve showWeekCurve = Curves.fastOutSlowIn;
  final double weekSize = 100.0;
  ScrollController weekScrollController;

  bool firstLoaded = false;
  bool hasCourse = true;
  bool showWeek = false;
  double monthWidth = 40.0;
  double indicatorHeight = 60.0;
  int currentWeek;
  DateTime now;

  int maxCoursesPerDay = 12;
  String remark;
  Map<int, Map<int, List<Course>>> courses;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (!firstLoaded) initSchedule();

    Instances.eventBus
      ..on<CourseScheduleRefreshEvent>().listen((event) {
        if (this.mounted) {
          refreshIndicatorKey.currentState.show();
        }
      })
      ..on<CurrentWeekUpdatedEvent>().listen((event) {
        if (currentWeek == null) {
          if (now != null) firstLoaded = true;
          currentWeek = DateAPI.currentWeek;
          updateScrollController();
          if (mounted) setState(() {});
          if (weekScrollController.hasClients) scrollToWeek(currentWeek);
          if (widget.appCenterPageState.mounted) {
            widget.appCenterPageState.setState(() {});
          }
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    courses = resetCourse(courses);
    super.dispose();
  }

  Future initSchedule() async {
    if (showWeek) {
      showWeek = false;
      if (widget.appCenterPageState.mounted) {
        widget.appCenterPageState.setState(() {});
      }
    }
    return Future.wait(<Future>[
      getCourses(),
      getRemark(),
    ]).then((responses) {
      currentWeek = DateAPI.currentWeek;
      now = DateTime.now();
      if (!firstLoaded) {
        if (currentWeek != null) firstLoaded = true;
        if (widget.appCenterPageState.mounted) {
          widget.appCenterPageState.setState(() {});
        }
      }
      updateScrollController();
      if (mounted) setState(() {});
      if (DateAPI.currentWeek != null) scrollToWeek(DateAPI.currentWeek);
    });
  }

  Map<int, Map<int, List<Course>>> resetCourse(
      Map<int, Map<int, List<Course>>> courses) {
    courses = {
      for (int i = 1; i < 7 + 1; i++)
        i: {for (int i = 1; i < maxCoursesPerDay + 1; i++) i: []},
    };
    for (int key in courses.keys) {
      courses[key] = {for (int i = 1; i < maxCoursesPerDay + 1; i++) i: []};
    }
    return courses;
  }

  Future getCourses() async {
    return CourseAPI.getCourse().then((response) {
      Map<String, dynamic> data = jsonDecode(response.data);
      List _courseList = data['courses'];
      List _customCourseList = data['othCase'];
      Map<int, Map<int, List<Course>>> _courses;
      _courses = resetCourse(_courses);
      if (_courseList.length == 0) {
        hasCourse = false;
      }
      _courseList.forEach((course) {
        Course _c = Course.fromJson(course);
        addCourse(_c, _courses);
      });
      _customCourseList.forEach((course) {
        if (course['content'].trim().isNotEmpty) {
          Course _c = Course.fromJson(course, isCustom: true);
          addCourse(_c, _courses);
        }
      });
      if (courses.toString() != _courses.toString()) {
        courses = _courses;
      }
    });
  }

  Future getRemark() async {
    return CourseAPI.getRemark().then((response) {
      Map<String, dynamic> data = jsonDecode(response.data);
      String _remark;
      if (data != null) _remark = data['classScheduleRemark'];
      if (remark != _remark && _remark != "") remark = _remark;
    });
  }

  void updateScrollController() {
    weekScrollController ??= ScrollController(
      initialScrollOffset: DateAPI.currentWeek != null
          ? math.max(
              0,
              (DateAPI.currentWeek - 0.5) * Constants.suSetSp(weekSize) -
                  Screen.width / 2,
            )
          : 0.0,
    );
  }

  void scrollToWeek(int week) {
    if (weekScrollController.hasClients)
      weekScrollController.animateTo(
        math.max(
            0, (week - 0.5) * Constants.suSetSp(weekSize) - Screen.width / 2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
  }

  void addCourse(Course course, Map<int, Map<int, List<Course>>> courses) {
    if (course.time == "11") {
      courses[course.day][11].add(course);
    } else {
      courses[course.day][int.parse(course.time.substring(0, 1))].add(course);
    }
  }

  void showWeekWidget() {
    showWeek = !showWeek;
    widget.appCenterPageState.setState(() {});
    if (mounted) setState(() {});
  }

  int maxWeekDay() {
    int _maxWeekday = 5;
    for (int count in courses[6].keys) {
      if (courses[6][count].isNotEmpty) {
        if (_maxWeekday != 7) _maxWeekday = 6;
        break;
      }
    }
    for (int count in courses[7].keys) {
      if (courses[7][count].isNotEmpty) {
        _maxWeekday = 7;
        break;
      }
    }
    return _maxWeekday;
  }

  Widget _week(context, int index) {
    return InkWell(
      onTap: () {
        now = now.add(Duration(days: 7 * (index + 1 - currentWeek)));
        currentWeek = index + 1;
        if (mounted) setState(() {});
        scrollToWeek(index + 1);
      },
      child: Container(
        width: Constants.suSetSp(weekSize),
        padding: EdgeInsets.all(Constants.suSetSp(10.0)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
            border: (DateAPI.currentWeek == index + 1 &&
                    currentWeek != DateAPI.currentWeek)
                ? Border.all(
                    color: ThemeUtils.currentThemeColor.withAlpha(100),
                    width: 2.0,
                  )
                : null,
            color: currentWeek == index + 1
                ? ThemeUtils.currentThemeColor.withAlpha(100)
                : null,
          ),
          child: Center(
            child: Stack(
              children: <Widget>[
                SizedBox.expand(
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: "第",
                          ),
                          TextSpan(
                            text: "${index + 1}",
                            style: TextStyle(
                              fontSize: Constants.suSetSp(26.0),
                            ),
                          ),
                          TextSpan(
                            text: "周",
                          ),
                        ],
                        style: Theme.of(context).textTheme.body1.copyWith(
                              fontSize: Constants.suSetSp(16.0),
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get remarkWidget => AnimatedContainer(
        duration: showWeekDuration,
        width: Screen.width,
        constraints: BoxConstraints(
          maxHeight: Constants.suSetSp(64.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Constants.suSetSp(20.0),
        ),
        color: showWeek
            ? Theme.of(context).primaryColor
            : Theme.of(context).canvasColor,
        child: Center(
          child: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: "班级备注: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "$remark",
                ),
              ],
              style: Theme.of(context).textTheme.body1.copyWith(
                    fontSize: Constants.suSetSp(17.0),
                  ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget weekSelection(context) => AnimatedContainer(
        curve: showWeekCurve,
        duration: const Duration(milliseconds: 300),
        width: Screen.width,
        height: showWeek ? Constants.suSetSp(weekSize / 1.5) : 0.0,
        child: ListView.builder(
          controller: weekScrollController,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: _week,
        ),
      );

  Widget weekDayIndicator(context) {
    String _month() => DateFormat("MMM", "zh_CN").format(
          now.subtract(Duration(days: now.weekday - 1)),
        );
    String _weekday(int i) => DateFormat("EEE", "zh_CN").format(
          now.subtract(Duration(days: now.weekday - 1 - i)),
        );
    String _date(int i) => DateFormat("MM/dd").format(
          now.subtract(Duration(days: now.weekday - 1 - i)),
        );

    return Container(
      color: Theme.of(context).canvasColor,
      height: Constants.suSetSp(indicatorHeight),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: monthWidth,
            child: Center(
              child: Text(
                "${_month().substring(0, _month().length - 1)}"
                "\n"
                "${_month().substring(
                  _month().length - 1,
                  _month().length,
                )}",
                style: TextStyle(
                  fontSize: Constants.suSetSp(16),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          for (int i = 0; i < maxWeekDay(); i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Constants.suSetSp(5.0)),
                  color: DateFormat("MM/dd").format(
                            now.subtract(Duration(days: now.weekday - 1 - i)),
                          ) ==
                          DateFormat("MM/dd").format(DateTime.now())
                      ? ThemeUtils.currentThemeColor.withAlpha(100)
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
                          fontSize: Constants.suSetSp(16),
                        ),
                      ),
                      Text(
                        _date(i),
                        style: TextStyle(
                          fontSize: Constants.suSetSp(12),
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

  Widget courseLineGrid(context) {
    final double totalHeight = Screen.height -
        Screen.topSafeHeight -
        kToolbarHeight -
        Constants.suSetSp(indicatorHeight);

    bool hasEleven = false;
    int _maxCoursesPerDay = 8;
    for (int day in courses.keys) {
      if (courses[day][9].isNotEmpty && _maxCoursesPerDay < 10) {
        _maxCoursesPerDay = 10;
      } else if (courses[day][9].isNotEmpty &&
          courses[day][9].where((course) => course.isEleven).isNotEmpty &&
          _maxCoursesPerDay < 11) {
        hasEleven = true;
        _maxCoursesPerDay = 11;
      } else if (courses[day][11].isNotEmpty && _maxCoursesPerDay < 12) {
        _maxCoursesPerDay = 12;
        break;
      }
    }
    if (mounted) setState(() {});

    return Expanded(
      child: Row(
        children: <Widget>[
          Container(
            color: Theme.of(context).canvasColor,
            width: monthWidth,
            height: totalHeight,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < _maxCoursesPerDay; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        (i + 1).toString(),
                        style: TextStyle(
                          fontSize: Constants.suSetSp(16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (int day = 1; day < maxWeekDay() + 1; day++)
            Expanded(
              child: Column(
                children: <Widget>[
                  for (int count = 1; count < _maxCoursesPerDay + 1; count++)
                    if (count.isEven)
                      CourseWidget(
                        courseList: courses[day][count - 1],
                        hasEleven: hasEleven && count == 10,
                        currentWeek: currentWeek,
                        coordinate: [day, count],
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget get emptyTips => Expanded(
        child: Center(
          child: Text(
            "没有课的日子\n往往就是这么的朴实无华\n且枯燥\n😆",
            style: TextStyle(
              fontSize: Constants.suSetSp(30.0),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: refreshIndicatorKey,
      child: Container(
        width: Screen.width,
        constraints: BoxConstraints(maxWidth: Screen.width),
        color: Theme.of(context).primaryColor,
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: !firstLoaded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Center(child: Constants.progressIndicator()),
          secondChild: Column(
            children: <Widget>[
              if (remark != null) remarkWidget,
              weekSelection(context),
              if (firstLoaded && hasCourse) weekDayIndicator(context),
              if (firstLoaded && hasCourse) courseLineGrid(context),
              if (firstLoaded && !hasCourse) emptyTips,
            ],
          ),
        ),
      ),
      onRefresh: initSchedule,
    );
  }
}

class CourseWidget extends StatelessWidget {
  final List<Course> courseList;
  final List<int> coordinate;
  final bool hasEleven;
  final int currentWeek;

  const CourseWidget({
    Key key,
    @required this.courseList,
    @required this.coordinate,
    this.hasEleven,
    this.currentWeek,
  })  : assert(coordinate.length == 2, "Invalid course coordinate"),
        super(key: key);

  void showCoursesDetail(context) {
    showDialog(
      context: context,
      builder: (context) {
        return CoursesDialog(courseList: courseList, currentWeek: currentWeek);
      },
    );
  }

  Widget courseCustomIndicator(Course course) => Positioned(
        bottom: 1.5,
        left: 1.5,
        child: Container(
          width: Constants.suSetSp(24.0),
          height: Constants.suSetSp(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomLeft: Radius.circular(5.0),
            ),
            color: ThemeUtils.currentThemeColor.withAlpha(100),
          ),
          child: Center(
            child: Text(
              "✍️",
              style: TextStyle(
                color: !CourseAPI.inCurrentWeek(
                  course,
                  currentWeek: currentWeek,
                )
                    ? Colors.grey
                    : Colors.black,
                fontSize: Constants.suSetSp(12.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

  Widget get courseCountIndicator => Positioned(
        bottom: 1.5,
        right: 1.5,
        child: Container(
          width: Constants.suSetSp(24.0),
          height: Constants.suSetSp(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(5.0),
            ),
            color: ThemeUtils.currentThemeColor.withAlpha(100),
          ),
          child: Center(
            child: Text(
              "${courseList.length}",
              style: TextStyle(
                color: Colors.black,
                fontSize: Constants.suSetSp(14.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    bool isEleven = false;
    Course course;
    if (courseList != null && courseList.isNotEmpty) {
      course = courseList.firstWhere(
        (c) => CourseAPI.inCurrentWeek(c, currentWeek: currentWeek),
        orElse: () => null,
      );
    }
    if (course == null && courseList.isNotEmpty) course = courseList[0];
    if (hasEleven) isEleven = course?.isEleven ?? false;
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
                      onTap: () {
                        if (courseList.isNotEmpty) showCoursesDetail(context);
                      },
                      onLongPress: () {
                        print("longPressed at: $coordinate");
                      },
                      child: Container(
                        padding: EdgeInsets.all(Constants.suSetSp(8.0)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: courseList.isNotEmpty
                              ? CourseAPI.inCurrentWeek(course,
                                      currentWeek: currentWeek)
                                  ? course.color.withAlpha(200)
                                  : Theme.of(context).dividerColor
                              : null,
                        ),
                        child: SizedBox.expand(
                          child: course != null
                              ? RichText(
                                  text: TextSpan(
                                    children: <InlineSpan>[
                                      if (!CourseAPI.inCurrentWeek(course,
                                          currentWeek: currentWeek))
                                        TextSpan(
                                          text: "[非本周]\n",
                                        ),
                                      TextSpan(
                                        text: course.name.substring(
                                          0,
                                          math.min(10, course.name.length),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (course.name.length > 10)
                                        TextSpan(text: "..."),
                                      if (course.location != null)
                                        TextSpan(
                                          text: "\n📍${course.location}",
                                        ),
                                    ],
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                          color: !CourseAPI.inCurrentWeek(
                                            course,
                                            currentWeek: currentWeek,
                                          )
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: Constants.suSetSp(14.0),
                                        ),
                                  ),
                                  overflow: TextOverflow.fade,
                                )
                              : Icon(
                                  Icons.add,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      .withOpacity(0.15)
                                      .withRed(180)
                                      .withBlue(180)
                                      .withGreen(180),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (courseList.where((course) => course.isCustom).isNotEmpty)
                  courseCustomIndicator(course),
                if (courseList.length > 1) courseCountIndicator,
              ],
            ),
          ),
          if (!isEleven && hasEleven) Spacer(flex: 1),
        ],
      ),
    );
  }
}

class CoursesDialog extends StatelessWidget {
  final List<Course> courseList;
  final int currentWeek;

  const CoursesDialog({
    Key key,
    @required this.courseList,
    @required this.currentWeek,
  }) : super(key: key);

  final int darkModeAlpha = 200;

  void showCoursesDetail(context, Course course) {
    showDialog(
      context: context,
      builder: (context) => CoursesDialog(
        courseList: [course],
        currentWeek: currentWeek,
      ),
    );
  }

  Widget get coursesPage => PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        physics: const BouncingScrollPhysics(),
        itemCount: courseList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 0.2 * 0.7 * Screen.height / 3 + 10.0,
            ),
            child: GestureDetector(
              onTap: () {
                showCoursesDetail(context, courseList[index]);
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: courseList.isNotEmpty
                          ? CourseAPI.inCurrentWeek(
                              courseList[index],
                              currentWeek: currentWeek,
                            )
                              ? ThemeUtils.isDark
                                  ? courseList[index]
                                      .color
                                      .withAlpha(darkModeAlpha)
                                  : courseList[index].color
                              : Colors.grey
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (courseList[index].isCustom)
                            Text(
                              "[自定义]",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: Constants.suSetSp(20.0),
                                height: 1.5,
                              ),
                            ),
                          if (!CourseAPI.inCurrentWeek(
                            courseList[index],
                            currentWeek: currentWeek,
                          ))
                            Text(
                              "[非本周]",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: Constants.suSetSp(20.0),
                                height: 1.5,
                              ),
                            ),
                          Text(
                            courseList[index].name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: Constants.suSetSp(20.0),
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                          if (courseList[index].location != null)
                            Text(
                              "📍${courseList[index].location}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: Constants.suSetSp(20.0),
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget courseDetail(Course course) {
    final style = TextStyle(
      color: Colors.black,
      fontSize: Constants.suSetSp(20.0),
      height: 1.8,
    );
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: EdgeInsets.all(Constants.suSetSp(12.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: courseList.isNotEmpty
            ? CourseAPI.inCurrentWeek(course, currentWeek: currentWeek)
                ? ThemeUtils.isDark
                    ? course.color.withAlpha(darkModeAlpha)
                    : course.color
                : Colors.grey
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (course.isCustom)
              Text(
                "[自定义]",
                style: style,
              ),
            if (!CourseAPI.inCurrentWeek(
              course,
              currentWeek: currentWeek,
            ))
              Text(
                "[非本周]",
                style: style,
              ),
            Text(
              "${courseList[0].name}",
              style: style.copyWith(
                fontSize: Constants.suSetSp(24.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (course.location != null)
              Text(
                "📍 ${course.location}",
                style: style,
              ),
            if (course.startWeek != null && course.endWeek != null)
              Text(
                "📅 ${course.startWeek}"
                "-"
                "${course.endWeek}"
                "${course.oddEven == 1 ? "单" : course.oddEven == 2 ? "双" : ""}周",
                style: style,
              ),
            Text(
              "⏰ ${DateAPI.shortWeekdays[course.day - 1]} "
              "${CourseAPI.courseTimeChinese[course.time]}",
              style: style,
            ),
            if (course.teacher != null)
              Text(
                "🎓 ${course.teacher}",
                style: style,
              ),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }

  Widget closeButton(context) => Positioned(
        top: 0.0,
        right: 0.0,
        child: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bool isDetail = courseList.length == 1;
    final Course firstCourse = courseList[0];
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      contentPadding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          width: Screen.width / 2,
          height: Constants.suSetSp(370.0),
          child: Stack(
            children: <Widget>[
              !isDetail ? coursesPage : courseDetail(firstCourse),
              closeButton(context),
              if (isDetail && courseList[0].isCustom)
                Positioned(
                  bottom: 10.0,
                  left: Screen.width / 7,
                  right: Screen.width / 7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      MaterialButton(
                        splashColor: Colors.grey[600],
                        padding: EdgeInsets.zero,
                        minWidth: 40.0,
                        height: 40.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Screen.width / 2),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                      MaterialButton(
                        splashColor: Colors.grey[600],
                        padding: EdgeInsets.zero,
                        minWidth: 40.0,
                        height: 40.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Screen.width / 2),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
