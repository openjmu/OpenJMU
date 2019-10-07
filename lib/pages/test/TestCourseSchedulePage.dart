import 'dart:convert';

import 'package:OpenJMU/api/CourseAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class TestCourseSchedulePage extends StatefulWidget {
    @override
    _TestCourseSchedulePageState createState() => _TestCourseSchedulePageState();
}

class _TestCourseSchedulePageState extends State<TestCourseSchedulePage> {
    final Duration _showTermDuration = const Duration(milliseconds: 300);
    final Curve _showTermCurve = Curves.fastOutSlowIn;
    final DateTime now = DateTime.now();
    bool loading = true;
    bool _showTerm = false;
    double monthWidth = 40.0;
    double indicatorHeight = 60.0;

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
        courses = {for (int i = 1; i < 7+1; i++) i: {for (int i = 1; i < maxCoursesPerDay+1; i++) i: []}};
        for (int key in courses.keys) courses[key] = {for (int i = 1; i < maxCoursesPerDay+1; i++) i: []};
    }

    void getCourses() async {
        if (!loading) loading = true;
        resetCourse();
        if (mounted) setState(() {});

        Map<String, dynamic> data = jsonDecode((await CourseAPI.getCourse()).data);
        List _courses = data['courses'];
        _courses.forEach((course) {
            Course _c = Course.fromJson(course);
            addCourse(_c);
        });
        loading = false;
        if (mounted) setState(() {});
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

    Widget termSelection(context) {
        return AnimatedContainer(
            curve: _showTermCurve,
            duration: const Duration(milliseconds: 300),
            height: _showTerm ? Constants.suSetSp(90.0) : 0.0,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) => Container(
                    color: Colors.grey,
                    width: 80.0,
                    height: _showTerm ? Constants.suSetSp(90.0) : 0.0,
                    child: Center(
                        child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                                Center(child: Text(index.toString())),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget weekDayIndicator(context) {
        String _mmm() => DateFormat("MMM", "zh_CN").format(
            now.subtract(Duration(days: now.weekday - 1)),
        );
        String _eee(int i) => DateFormat("EEE", "zh_CN").format(
            now.subtract(Duration(days: now.weekday - 1 - i)),
        );
        String _mmdd(int i) => DateFormat("MM/dd").format(
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
                                _mmm(),
                                style: TextStyle(
                                    fontSize: Constants.suSetSp(16),
                                ),
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
                                            _eee(i),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: Constants.suSetSp(16),
                                            ),
                                        ),
                                        Text(
                                            _mmdd(i),
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
        final double totalHeight = _m.size.height
                - _m.padding.top - _m.padding.bottom
                - kToolbarHeight - Constants.suSetSp(indicatorHeight)
        ;

        int _maxCoursesPerDay = 10;
        for (int day in courses.keys) {
            if (courses[day][11].isNotEmpty) {
                _maxCoursesPerDay = 12;
                if (mounted) setState(() {});
                break;
            }
        }

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
                                                    fontSize: Constants.suSetSp(14),
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
                                        if (count.isOdd) course(courses[day][count])
                                    ,
                                ],
                            ),
                        )
                    ,
                ],
            ),
        );
    }

    Widget course(List<Course> courseList) {
        return Expanded(
            child: Container(
                margin: const EdgeInsets.all(1.5),
                padding: EdgeInsets.all(Constants.suSetSp(4.0)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: courseList.isNotEmpty ? CourseAPI.randomCourseColor() : null,
                ),
                child: courseList.isNotEmpty ? RichText(
                    text: TextSpan(
                        children: <InlineSpan>[
                            TextSpan(
                                text: courseList[0].name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "\n"),
                            TextSpan(
                                text: "@${courseList[0].location}",
                            ),
                        ],
                        style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: Constants.suSetSp(14.0),
                        ),
                    ),
                ) : SizedBox(),
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
                                    fontSize: Constants.suSetSp(21.0),
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
                crossFadeState: loading
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond
                ,
                firstChild: Center(child: Constants.progressIndicator()),
                secondChild: SizedBox(
                    height: _m.size.height - _m.padding.top - kToolbarHeight,
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
