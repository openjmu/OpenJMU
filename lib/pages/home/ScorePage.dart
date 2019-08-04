import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/SocketUtils.dart';


class ScorePage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
    bool loading = false, socketInitialized = false;
    List<String> terms = ["20151", "20152"];
    List<Map<String, dynamic>> scores = [
        {
            "term": "20151",
            "courseId": "123456",
            "courseName": "测试课程",
            "courseTime": 24,
            "coursePoint": 3.0,
            "examScore": 75.0,
            "examPoint": 2.5,
        },
    ];
    StreamSubscription scoresSubscription;

    @override
    void initState() {
        super.initState();
//        loadScores();
    }

    @override
    void dispose() {
        super.dispose();
        scoresSubscription?.cancel();
//        SocketUtils.unInitSocket();
    }

    void loadScores() async {
        if (!socketInitialized) {
            try {
                await SocketUtils.initSocket(API.scoreSocket);
                socketInitialized = true;
                scoresSubscription = SocketUtils.mStream.listen(onReceive);
                SocketUtils.mSocket.add(utf8.encode(jsonEncode({
                    "uid": "${UserAPI.currentUser.uid}",
                    "sid": "${UserAPI.currentUser.sid}",
                    "workid": "${UserAPI.currentUser.workId}",
                })));
            } catch (e) {
                debugPrint("$e");
            }
        }
    }

    void onReceive(List<int> data) async {
        try {
            print("接收到的数据: ${utf8.decode(data)}");
            scores = jsonDecode(utf8.decode(data));
            setState(() {
                loading = false;
            });
        } catch (e) {
            debugPrint("$e");
        }
    }

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
                                    double.parse(score['examScore'].toString()) != null
                                        &&
                                    double.parse(score['examScore'].toString()) < 60.0
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
        return loading ? Center(child: Constants.progressIndicator())
                :
        Column(
            children: <Widget>[
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: Constants.suSetSp(6.0),
                            horizontal: Constants.suSetSp(12.0),
                        ),
                        child: Row(
                            children: <Widget>[
                                Text("20151"),
                            ],
                        ),
                    ),
                    onTap: () {},
                ),
                GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    children: <Widget>[
                        if (scores != null) for (int i = 0; i < scores.length; i++) Card(
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
                ),
            ],
        );
    }
}
