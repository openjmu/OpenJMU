import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/SocketUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


class ScorePage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
    final Map<String, Map<String, double>> fiveBandScale = {
        "优秀": {
            "score": 95.0,
            "point": 4.625,
        },
        "良好": {
            "score": 85.0,
            "point": 3.875,
        },
        "中等": {
            "score": 75.0,
            "point": 3.125,
        },
        "及格": {
            "score": 65.0,
            "point": 2.375,
        },
        "不及格": {
            "score": 55.0,
            "point": 0.0,
        },
    };
    final Map<String, Map<String, double>> twoBandScale = {
        "合格": {
            "score": 80.0,
            "point": 3.5,
        },
        "不合格": {
            "score": 50.0,
            "point": 0.0,
        },
    };
    bool loading = false, socketInitialized = false;
    List terms, scores, scoresFiltered;
    String termSelected;
    String _scoreData = "";
    StreamSubscription scoresSubscription;

    @override
    void initState() {
        super.initState();
        loadScores();
    }

    @override
    void dispose() {
        super.dispose();
        unloadSocket();
    }

    void sendRequest() {
        if (SocketUtils.mSocket != null) SocketUtils.mSocket.add(utf8.encode(jsonEncode({
            "uid": "${UserAPI.currentUser.uid}",
            "sid": "${UserAPI.currentUser.sid}",
            "workid": "${UserAPI.currentUser.workId}",
        })));
    }

    void loadScores() async {
        if (!socketInitialized) {
            try {
                await SocketUtils.initSocket(API.scoreSocket);
                socketInitialized = true;
                scoresSubscription = SocketUtils.mStream
                        .transform(utf8.decoder)
                        .listen(onReceive);
            } catch (e) {
                debugPrint("$e");
            }
        }
        sendRequest();
    }

    void unloadSocket() {
        socketInitialized = false;
        scoresSubscription?.cancel();
        SocketUtils.unInitSocket();
    }

    void onReceive(data) async {
        _scoreData += data;
        if (_scoreData.endsWith("]}}")) try {
            Map<String, dynamic> response = json.decode(_scoreData)['obj'];
            terms = response['terms'];
            termSelected = terms.last;
            scores = response['scores'];
            scoresFiltered = List.from(scores);
            if (scoresFiltered.length > 0) scoresFiltered.removeWhere((score) {
                return score['termId'].toString() != (termSelected != null ? termSelected : terms.last);
            });
            setState(() {
                loading = false;
            });
        } catch (e) {
            debugPrint("$e");
        }
    }

    void selectTerm(int index) {
        if (termSelected != terms[index]) setState(() {
            termSelected = terms[index];
            scoresFiltered = List.from(scores);
            if (scoresFiltered.length > 0) scoresFiltered.removeWhere((score) {
                return score['termId'].toString() != (termSelected != null ? termSelected : terms.last);
            });
        });
    }

    bool isPass(score) {
        bool result;
        if (double.tryParse(score) != null) {
            if (double.parse(score) < 60.0) {
                result = false;
            } else {
                result = true;
            }
        } else {
            if (fiveBandScale.containsKey(score)) {
                if (fiveBandScale[score]['score'] >= 60.0) {
                    result = true;
                } else {
                    result = false;
                }
            } else if (twoBandScale.containsKey(score)) {
                if (twoBandScale[score]['score'] >= 60.0) {
                    result = true;
                } else {
                    result = false;
                }
            } else {
                result = false;
            }
        }
        return result;
    }

    Widget _term(term, index) {
        String _term = term.toString();
        int currentYear = int.parse(_term.substring(0, 4));
        int currentTerm = int.parse(_term.substring(4, 5));
        return GestureDetector(
            onTap: () {
                selectTerm(index);
            },
            child: Container(
                padding: EdgeInsets.all(Constants.suSetSp(6.0)),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Constants.suSetSp(10.0)),
                        boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 5.0,
                                color: Theme.of(context).canvasColor,
                            ),
                        ],
                        color: _term == termSelected
                                ? ThemeUtils.currentThemeColor
                                : Theme.of(context).canvasColor
                        ,
                    ),
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Constants.suSetSp(8.0),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                Text(
                                    "$currentYear-${currentYear+1}",
                                    style: TextStyle(
                                        color: _term == termSelected
                                                ? Colors.white
                                                : Theme.of(context).textTheme.body1.color
                                        ,
                                        fontWeight: _term == termSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal
                                        ,
                                        fontSize: Constants.suSetSp(16.0),
                                    ),
                                ),
                                Text(
                                    "第$currentTerm学期",
                                    style: TextStyle(
                                        color: _term == termSelected
                                                ? Colors.white
                                                : Theme.of(context).textTheme.body1.color
                                        ,
                                        fontWeight: _term == termSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal
                                        ,
                                        fontSize: Constants.suSetSp(18.0),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
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
        var _score = score['score'];
        bool pass = isPass(_score);
        double _scorePoint;
        if (double.tryParse(_score) != null) {
            _score = double.parse(_score).toStringAsFixed(1);
            _scorePoint = (double.parse(_score) - 50) / 10;
            if (_scorePoint < 1.0) _scorePoint = 0.0;
        } else {
            if (fiveBandScale.containsKey(_score)) {
                _scorePoint = fiveBandScale[_score]['point'];
            } else if (twoBandScale.containsKey(_score)) {
                _scorePoint = twoBandScale[_score]['point'];
            } else {
                _scorePoint = 0.0;
            }
        }

        return RichText(
            text: TextSpan(
                children: <TextSpan>[
                    TextSpan(
                        text: "$_score",
                        style: Theme.of(context).textTheme.title.copyWith(
                            fontSize: Constants.suSetSp(36.0),
                            fontWeight: FontWeight.bold,
                            color: !pass ? Colors.red : Theme.of(context).textTheme.title.color
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
                        text: "$_scorePoint",
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
            "学时: ${score['creditHour']}　"
            "学分: ${double.parse(score['credit']).toStringAsFixed(1)}",
            style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: Constants.suSetSp(20.0),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return loading ? Center(child: Constants.progressIndicator())
                :
        SingleChildScrollView(
            child: Column(
                children: <Widget>[
                    if (terms != null) Center(child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: Constants.suSetSp(5.0),
                        ),
                        height: Constants.suSetSp(80.0),
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: terms.length + 2,
                            itemBuilder: (context, index) {
                                if (index == 0 || index == terms.length + 1) {
                                    return SizedBox(width: Constants.suSetSp(5.0));
                                } else {
                                    return _term(
                                        terms[terms.length - index ],
                                        terms.length - index,
                                    );
                                }
                            },
                        ),
                    )),
                    GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        children: <Widget>[
                            if (scoresFiltered != null) for (int i = 0; i < scoresFiltered.length; i++) Card(
                                child: Padding(
                                    padding: EdgeInsets.all(Constants.suSetSp(10.0)),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                            _name(scoresFiltered[i]),
                                            _score(scoresFiltered[i]),
                                            _timeAndPoint(scoresFiltered[i]),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }
}
