import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
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
    bool _showTerm = false;

    @override
    void initState() {
        super.initState();
    }

    @override
    void dispose() {
        super.dispose();
    }

    void showTermWidget() {
        _showTerm = !_showTerm;
        setState(() {});
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
                                Text(index.toString()),
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
            color: ThemeUtils.currentThemeColor.withAlpha(50),
            height: Constants.suSetSp(80.0),
            child: Row(
                children: <Widget>[
                    SizedBox(
                        width: 50.0,
                        child: Center(
                            child: Text(
                                _mmm(),
                                style: TextStyle(
                                    fontSize: Constants.suSetSp(16),
                                ),
                            ),
                        ),
                    ),
                    for (int i = 0; i < 7; i++)
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
                                        )
                                    ],
                                ),
                            ),
                        )
                    ,
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
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
                        icon: Icon(Icons.add),
                        onPressed: () {},
                    ),
                ],
            ),
            body: Column(
                children: <Widget>[
                    termSelection(context),
                    weekDayIndicator(context),
                ],
            ),
        );
    }
}
