import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/api/CourseAPI.dart';
import 'package:OpenJMU/api/DateAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/constants/Screens.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


class TestCourseSchedulePage extends StatefulWidget {
    @override
    _TestCourseSchedulePageState createState() => _TestCourseSchedulePageState();
}

class _TestCourseSchedulePageState extends State<TestCourseSchedulePage> {
    final ScrollController _termScrollController = ScrollController();
    final Duration _showTermDuration = const Duration(milliseconds: 300);
    final Curve _showTermCurve = Curves.fastOutSlowIn;
    final DateTime now = DateTime.now();
    final double termSize = 100.0;

    bool _loading = false, _showTerm = false;
    double monthWidth = 40.0;
    double indicatorHeight = 60.0;
    int currentWeek = DateAPI.currentWeek;

    int maxCoursesPerDay = 12;
    Map<int, Map<int, List<Course>>> courses;

    @override
    void initState() {
        getCourses();
        super.initState();
    }

    @override
    void dispose() {
        resetCourse();
        super.dispose();
    }

    void resetCourse() {
        if (_showTerm) _showTerm = false;
        courses = {
            for (int i = 1; i < 7+1; i++)
                i: {
                    for (int i = 1; i < maxCoursesPerDay+1; i++) i: []
                }
            ,
        };
        for (int key in courses.keys) courses[key] = {
            for (int i = 1; i < maxCoursesPerDay+1; i++) i: []
        };
    }

    void getCourses() async {
        if (!_loading) {
            _loading = true;
            resetCourse();
            if (mounted) setState(() {});

            Map<String, dynamic> data = jsonDecode((await CourseAPI.getCourse()).data);
            List _courses = data['courses'];
            _courses.forEach((course) {
                Course _c = Course.fromJson(course);
                addCourse(_c);
            });
            _loading = false;
            if (mounted) setState(() {});
            scrollToWeek(currentWeek);
        }
    }

    void scrollToWeek(int week) {
        _termScrollController.animateTo(
            math.max(
                    0,
                    (week - 0.5)
                            *
                            Constants.suSetSp(termSize)
                            - Screen.width / 2
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
        );
    }

    void addCourse(Course course) {
        switch (course.time) {
            case "12":
                courses[course.day][1].add(course);
                break;
            case "34":
                courses[course.day][3].add(course);
                break;
            case "56":
                courses[course.day][5].add(course);
                break;
            case "78":
                courses[course.day][7].add(course);
                break;
            case "90":
            case "911":
                courses[course.day][9].add(course);
                break;
            case "11":
                courses[course.day][11].add(course);
                break;
        }
    }

    void showTermWidget() {
        _showTerm = !_showTerm;
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

    Widget _term(context, int index) {
        return Container(
            width: Constants.suSetSp(termSize),
            height: _showTerm ? Constants.suSetSp(termSize) : 0.0,
            padding: EdgeInsets.all(Constants.suSetSp(10.0)),
            child: InkWell(
                onTap: () {
                    currentWeek = index + 1;
                    if (mounted) setState(() {});
                    scrollToWeek(index + 1);
                },
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Constants.suSetSp(10.0)),
                        color: currentWeek == index + 1
                                ? ThemeUtils.currentThemeColor.withAlpha(100)
                                : null
                        ,
                    ),
                    child: Center(
                        child: Stack(
//                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                SizedBox.expand(child: Center(
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
                                )),
                                if (DateAPI.currentWeek == index + 1)
                                    Positioned(
                                        bottom: Constants.suSetSp(2.0),
                                        left: 0.0,
                                        right: 0.0,
                                        child: Text(
                                            "本周",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.caption,
                                        ),
                                    ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget termSelection(context) {
        return AnimatedContainer(
            curve: _showTermCurve,
            duration: const Duration(milliseconds: 300),
            height: _showTerm ? Constants.suSetSp(termSize) : 0.0,
            child: ListView.builder(
                controller: _termScrollController,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 20,
                itemBuilder: _term,
            ),
        );
    }

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
                                        )}"
                                ,
                                style: TextStyle(
                                    fontSize: Constants.suSetSp(16),
                                ),
                                textAlign: TextAlign.center,
                            ),
                        ),
                    ),
                    for (int i = 0; i < maxWeekDay(); i++)
                        Expanded(
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
                        )
                    ,
                ],
            ),
        );
    }

    Widget courseLineGrid(context) {
        final MediaQueryData _m = MediaQuery.of(context);
        final double totalHeight = Screen.height - _m.padding.top
                - kToolbarHeight - Constants.suSetSp(indicatorHeight)
        ;

        bool hasEleven = false;
        int _maxCoursesPerDay = 10;
        for (int day in courses.keys) {
            if (
                courses[day][9].isNotEmpty
                    &&
                courses[day][9].where((course) => course.isEleven).isNotEmpty
            ) {
                hasEleven = true;
            } else if (courses[day][11].isNotEmpty) {
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
                                for (int i = 0; i < _maxCoursesPerDay + (hasEleven ? 1 : 0); i++)
                                    Expanded(
                                        child: Center(
                                            child: Text(
                                                (i + 1).toString(),
                                                style: TextStyle(
                                                    fontSize: Constants.suSetSp(16),
                                                ),
                                            ),
                                        ),
                                    )
                                ,
                            ],
                        ),
                    ),
                    for (int day = 1; day < maxWeekDay() + 1; day++)
                        Expanded(
                            child: Column(
                                children: <Widget>[
                                    for (int count = 1; count < _maxCoursesPerDay+1; count++)
                                        if (count.isEven) CourseWidget(
                                            courseList: courses[day][count - 1],
                                            count: hasEleven && count == 10 ? 10 : null,
                                            currentWeek: currentWeek,
                                        )
                                    ,
                                ],
                            ),
                        )
                    ,
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        final MediaQueryData _m = MediaQuery.of(context);
        return Scaffold(
            appBar: AppBar(
                title: GestureDetector(
                    onTap: showTermWidget,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Expanded(child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[],
                            )),
                            Text(
                                "测试课表",
                                style: Theme.of(context).textTheme.title.copyWith(
                                    fontSize: Constants.suSetSp(23.0),
                                ),
                            ),
                            Expanded(child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                    AnimatedCrossFade(
                                        firstChild: Icon(Icons.keyboard_arrow_down),
                                        secondChild: Icon(Icons.keyboard_arrow_up),
                                        crossFadeState: _showTerm
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst
                                        ,
                                        duration: _showTermDuration,
                                    ),
                                ],
                            )),
                        ],
                    ),
                ),
                centerTitle: true,
                actions: <Widget>[
                    IconButton(
                        padding: const EdgeInsets.all(16.0),
                        icon: Icon(Icons.refresh),
                        onPressed: getCourses,
                    ),
                ],
            ),
            body: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _loading
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond
                ,
                firstChild: Center(child: Constants.progressIndicator()),
                secondChild: SizedBox(
                    height: Screen.height - _m.padding.top - kToolbarHeight,
                    child: Column(
                        children: <Widget>[
                            termSelection(context),
                            weekDayIndicator(context),
                            courseLineGrid(context),
                        ],
                    ),
                ),
            ),
        );
    }
}


class CourseWidget extends StatelessWidget {
    final List<Course> courseList;
    final int count;
    final int currentWeek;

    const CourseWidget({
        Key key,
        @required this.courseList,
        this.count,
        this.currentWeek,
    }) : super(key: key);

    void showCoursesDetail(context) {
        showDialog(
            context: context,
            builder: (context) {
                return CoursesDialog(courseList: courseList, currentWeek: currentWeek);
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        final isEleven = count != null && count == 10;
        return Expanded(
            flex: isEleven ? 3 : 2,
            child: GestureDetector(
                onTap: courseList.isNotEmpty ? () {
                    showCoursesDetail(context);
                } : null,
                child: Container(
                    margin: const EdgeInsets.all(1.5),
                    padding: EdgeInsets.all(Constants.suSetSp(8.0)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: courseList.isNotEmpty
                                ? CourseAPI.inCurrentWeek(courseList[0], currentWeek: currentWeek)
                                ? ThemeUtils.isDark
                                ? courseList[0].color.withAlpha(200)
                                : courseList[0].color
                                : Theme.of(context).dividerColor
                                : null
                        ,
                    ),
                    child: SizedBox.expand(
                        child: courseList.isNotEmpty ? RichText(
                            text: TextSpan(
                                children: <InlineSpan>[
                                    if (!CourseAPI.inCurrentWeek(courseList[0], currentWeek: currentWeek))
                                        TextSpan(
                                            text: "[非本周]\n",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                        )
                                    ,
                                    TextSpan(
                                        text: courseList[0].name.substring(
                                            0,
                                            math.min(10, courseList[0].name.length),
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                        ),
                                    ),
                                    if (courseList[0].name.length > 10) TextSpan(text: "..."),
                                    if (courseList[0].location != null) TextSpan(text: "\n"),
                                    if (courseList[0].location != null) TextSpan(
                                        text: "📍${courseList[0].location}",
                                    ),
                                ],
                                style: Theme.of(context).textTheme.body1.copyWith(
                                    color: !CourseAPI.inCurrentWeek(
                                        courseList[0],
                                        currentWeek: currentWeek,
                                    ) ? Colors.grey : Colors.black,
                                    fontSize: Constants.suSetSp(16.0),
                                ),
                            ),
                        ) : null,
                    ),
                ),
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
            builder: (context) {
                return CoursesDialog(courseList: [course], currentWeek: currentWeek);
            },
        );
    }

    Widget get coursesPage => PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        itemCount: courseList.length,
        itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.symmetric(
                    vertical: 0.2 * 0.7 * Screen.height / 3,
                ),
                child: GestureDetector(
                    onTap: () {
                        showCoursesDetail(context, courseList[index]);
                    },
                    child: Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: courseList.isNotEmpty
                                    ? CourseAPI.inCurrentWeek(courseList[index], currentWeek: currentWeek)
                                    ? ThemeUtils.isDark
                                    ? courseList[index].color.withAlpha(darkModeAlpha)
                                    : courseList[index].color
                                    : Colors.grey
                                    : null
                            ,
                        ),
                        child: Center(
                            child: RichText(
                                text: TextSpan(
                                    children: <InlineSpan>[
                                        if (!CourseAPI.inCurrentWeek(courseList[index], currentWeek: currentWeek))
                                            TextSpan(
                                                text: "[非本周]"
                                                        "\n"
                                                ,
                                            )
                                        ,
                                        TextSpan(
                                            text: courseList[index].name,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        if (courseList[index].location != null) TextSpan(text: "\n"),
                                        if (courseList[index].location != null) TextSpan(
                                            text: "📍${courseList[index].location}",
                                        ),
                                    ],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: Constants.suSetSp(20.0),
                                        height: 1.5,
                                    ),
                                ),
                                textAlign: TextAlign.center,
                            ),
                        ),
                    ),
                ),
            );
        },
    );

    Widget courseDetail(Course course) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: courseList.isNotEmpty
                    ? CourseAPI.inCurrentWeek(course, currentWeek: currentWeek)
                    ? ThemeUtils.isDark
                    ? course.color.withAlpha(darkModeAlpha)
                    : course.color
                    : Colors.grey
                    : null
            ,
        ),
        child: Padding(
            padding: EdgeInsets.all(Constants.suSetSp(12.0)),
            child: Center(child: RichText(
                text: TextSpan(
                    children: <InlineSpan>[
                        if (!CourseAPI.inCurrentWeek(course, currentWeek: currentWeek))
                            TextSpan(
                                text: "[非本周]"
                                        "\n"
                                ,
                            )
                        ,
                        TextSpan(
                            text: "${courseList[0].name}"
                                    "\n"
                            ,
                            style: TextStyle(
                                fontSize: Constants.suSetSp(24.0),
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        if (course.location != null) TextSpan(
                            text: "📍 ${course.location}\n",
                        ),
                        TextSpan(
                            text: "📅 ${course.startWeek}"
                                    "-"
                                    "${course.endWeek}"
                                    "${course.oddEven == 1
                                    ? "单"
                                    : course.oddEven == 2
                                    ? "双"
                                    : ""
                            }周"
                                    "\n"
                            ,
                        ),
                        TextSpan(
                                text: "⏰ ${DateAPI.shortWeekdays[course.day-1]} "
                                        "${CourseAPI.courseTimeChinese[course.time]}\n"
                        ),
                        TextSpan(text: "🎓 ${course.teacher}"),
                    ],
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: Constants.suSetSp(20.0),
                        height: 2.0,
                    ),
                ),
                textAlign: TextAlign.center,
            )),
        ),
    );

    @override
    Widget build(BuildContext context) {
        final bool hasMoreThanOneCourses = courseList.length > 1;
        final Course firstCourse = courseList[0];
        return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
                SizedBox(
                    width: Screen.width / 2,
                    height: Screen.height / 3,
                    child: hasMoreThanOneCourses ? coursesPage : courseDetail(firstCourse),
                ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
            ),
        );
    }

}