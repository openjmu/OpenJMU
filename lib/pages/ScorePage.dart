import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';


class ScorePage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
    List<Map<String, dynamic>> scores = [
        {
            'courseCode' : "22026450",
            'courseName' : "环境科学导论",
            'courseTime' : 24,
            'coursePoint': 1.50,
            'courseType' : "基础必修",
            'examType'   : "正常",
            'examStatus' : "正常",
            'examScore'  : "良好",
            'examPoint'  : 3.00,
        },
        {
            'courseCode' : "E008630",
            'courseName' : "毛泽东思想和中国特色社会主义理论体系概论",
            'courseTime' : 56,
            'coursePoint': 3.50,
            'courseType' : "通识必修",
            'examType'   : "正常",
            'examStatus' : "正常",
            'examScore'  : "94",
            'examPoint'  : 4.40,
        },
        {
            'courseCode' : "E000520",
            'courseName' : "思政课实践(一)",
            'courseTime' : 0,
            'coursePoint': 1.50,
            'courseType' : "实践教学",
            'examType'   : "补考",
            'examStatus' : "正常",
            'examScore'  : "不合格",
            'examPoint'  : 0.00,
        },
    ];

//    Future _futureBuilderFuture;

    @override
    void initState() {
        super.initState();
//        _futureBuilderFuture = getScoreList();
    }

//    Future getAppList() async => NetUtils.getWithCookieSet(Api.webAppLists);

    Widget _name(score) {
        return Text(
            "${score['courseName']}",
            style: Theme.of(context).textTheme.title.copyWith(
                fontSize: Constants.suSetSp(24.0),
            ),
            overflow: TextOverflow.ellipsis,
        );
    }

    Widget _score(score) {
        return RichText(
            text: TextSpan(
                children: <TextSpan>[
                    TextSpan(
                        text: "${score['examScore']}",
                        style: Theme.of(context).textTheme.title.copyWith(
                            fontSize: Constants.suSetSp(36.0),
                            fontWeight: FontWeight.bold,
                            color: (
                                score['examScore'] == "不合格"
                                    ||
                                (
                                    double.tryParse(score['examScore']) != null
                                        &&
                                    double.tryParse(score['examScore']) < 60.0
                                )
                            )
                                    ? Colors.red
                                    : Theme.of(context).textTheme.title.color
                            ,
                        ),
                    ),
                    TextSpan(
                        text: " / ",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.body1.color,
                        ),
                    ),
                    TextSpan(
                        text: "${score['examPoint']}",
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                            fontSize: Constants.suSetSp(20.0),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _timeAndPoint(score) {
        return Text(
            "学时: ${score['courseTime']}　学分: ${score['coursePoint']}",
            style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: Constants.suSetSp(20.0),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            children: <Widget>[
                for (int i = 0; i < scores.length; i++) Card(
                    child: Padding(
                        padding: EdgeInsets.all(Constants.suSetSp(10.0)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                                _name(scores[i]),
                                _score(scores[i]),
                                _timeAndPoint(scores[i]),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }
}
