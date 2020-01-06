import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/common_web_page.dart';

class ScorePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> with AutomaticKeepAliveClientMixin {
  final Map<String, Map<String, double>> fiveBandScale = {
    "优秀": {"score": 95.0, "point": 4.625},
    "良好": {"score": 85.0, "point": 3.875},
    "中等": {"score": 75.0, "point": 3.125},
    "及格": {"score": 65.0, "point": 2.375},
    "不及格": {"score": 55.0, "point": 0.0},
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
  bool loading = true, socketInitialized = false, noScore = false, loadError = false;
  List<String> terms;
  List<Score> scores = [], scoresFiltered;
  String termSelected;
  String _scoreData = "";
  Widget errorWidget = SizedBox();

  StreamSubscription scoresSubscription;

  DateTime startTime;
  DateTime endTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loadScores();
    Instances.eventBus
      ..on<ScoreRefreshEvent>().listen((event) {
        resetScores();
        loading = true;
        loadScores();
        if (this.mounted) setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    unloadSocket();
    super.dispose();
  }

  void sendRequest() {
    startTime = DateTime.now();
    SocketUtils.mSocket?.add(utf8.encode(jsonEncode({
      "uid": "${UserAPI.currentUser.uid}",
      "sid": "${UserAPI.currentUser.sid}",
      "workid": "${UserAPI.currentUser.workId}",
    })));
  }

  void loadScores() async {
    if (!socketInitialized) {
      try {
        if (SocketUtils.mStream == null) {
          await SocketUtils.initSocket(SocketConfig(API.openjmuHost, 4000));
          socketInitialized = true;
        }
        scoresSubscription = utf8.decoder.bind(SocketUtils.mStream).listen(onReceive);
        sendRequest();
      } catch (e) {
        debugPrint("Socket connect error: $e");
        fetchError(e.toString());
      }
    } else {
      debugPrint("Socket already initialized.");
      sendRequest();
    }
  }

  void resetScores() {
    unloadSocket();
    terms = null;
    scores.clear();
    scoresFiltered = null;
    _scoreData = "";
  }

  void unloadSocket() {
    socketInitialized = false;
    scoresSubscription?.cancel();
    SocketUtils.unInitSocket();
  }

  void onReceive(data) async {
    _scoreData += data;
    if (_scoreData.endsWith("]}}")) {
      try {
        Map<String, dynamic> response = json.decode(_scoreData)['obj'];
        if (response['terms'].length == 0 || response['scores'].length == 0) {
          noScore = true;
        } else {
          terms = List<String>.from(response['terms']);
          termSelected = terms.last;
          List _scores = response['scores'];
          _scores.forEach((score) {
            scores.add(Score.fromJson(score));
          });
          scoresFiltered = List.from(scores);
          if (scoresFiltered.length > 0)
            scoresFiltered.removeWhere((score) {
              return score.termId != (termSelected != null ? termSelected : terms.last);
            });
        }
        loading = false;
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint("$e");
      }
      endTime = DateTime.now();
    }
  }

  void selectTerm(int index) {
    if (termSelected != terms[index])
      setState(() {
        termSelected = terms[index];
        scoresFiltered = List.from(scores);
        if (scoresFiltered.length > 0)
          scoresFiltered.removeWhere((score) {
            return score.termId != (termSelected != null ? termSelected : terms.last);
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

  void fetchError(String error) {
    String result;

    if (error.contains("The method 'transform' was called on null")) {
      result = "电波暂时无法到达成绩业务的门口\n😰";
    } else {
      result = "成绩好像还没有准备好呢\n🤒";
    }

    loading = false;
    loadError = true;
    errorWidget = Center(
      child: Text(
        result,
        style: TextStyle(
          fontSize: suSetSp(23.0),
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
    if (mounted) setState(() {});
  }

  void evaluate() {
    String url;
    if (UserAPI.currentUser.isCY) {
      url = "http://cyjwb.jmu.edu.cn/";
    } else {
      url = "http://sso.jmu.edu.cn/imapps/1070?sid=${UserAPI.currentUser.sid}";
    }
    CommonWebPage.jump(url, "教学评测");
  }

  Widget get evaluateTips => Container(
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(20.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: suSetWidth(30.0),
              ),
              width: suSetWidth(14.0),
              height: suSetHeight(14.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).textTheme.caption.color,
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "请及时完成",
                    ),
                    TextSpan(
                      text: "教学评测",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = evaluate,
                    ),
                    TextSpan(
                      text: "\n未教学评测的科目成绩将不予显示",
                    ),
                  ],
                ),
                style: Theme.of(context).textTheme.caption.copyWith(
                      fontSize: suSetSp(19.0),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: suSetWidth(30.0),
              ),
              width: suSetWidth(14.0),
              height: suSetHeight(14.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).textTheme.caption.color,
              ),
            ),
          ],
        ),
      );

  Widget _term(term, index) {
    String _term = term.toString();
    int currentYear = int.parse(_term.substring(0, 4));
    int currentTerm = int.parse(_term.substring(4, 5));
    return GestureDetector(
      onTap: () {
        selectTerm(index);
      },
      child: Container(
        padding: EdgeInsets.all(suSetSp(6.0)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetSp(10.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 5.0,
                color: Theme.of(context).canvasColor,
              ),
            ],
            color: _term == termSelected ? currentThemeColor : Theme.of(context).canvasColor,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: suSetSp(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "$currentYear-${currentYear + 1}",
                  style: TextStyle(
                    color: _term == termSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.body1.color,
                    fontWeight: _term == termSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: suSetSp(18.0),
                  ),
                ),
                Text(
                  "第$currentTerm学期",
                  style: TextStyle(
                    color: _term == termSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.body1.color,
                    fontWeight: _term == termSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: suSetSp(20.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _name(Score score) {
    return Text(
      "${score.courseName}",
      style: Theme.of(context).textTheme.title.copyWith(
            fontSize: suSetSp(24.0),
          ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _score(Score score) {
    var _score = score.score;
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
                  fontSize: suSetSp(36.0),
                  fontWeight: FontWeight.bold,
                  color: !pass ? Colors.red : Theme.of(context).textTheme.title.color,
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
                  fontSize: suSetSp(20.0),
                ),
          ),
        ],
      ),
    );
  }

  Widget _timeAndPoint(Score score) {
    return Text(
      "学时: ${score.creditHour}　"
      "学分: ${score.credit.toStringAsFixed(1)}",
      style: Theme.of(context).textTheme.body1.copyWith(
            fontSize: suSetSp(20.0),
          ),
    );
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return loading
        ? Center(child: PlatformProgressIndicator())
        : Column(
            children: <Widget>[
              Expanded(
                child: loadError
                    ? errorWidget
                    : noScore
                        ? Center(
                            child: Text(
                            "暂时还没有你的成绩\n🤔",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: suSetSp(30.0)),
                          ))
                        : Column(
                            children: <Widget>[
                              if (terms != null)
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: suSetSp(5.0),
                                    ),
                                    height: suSetSp(80.0),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: terms.length + 2,
                                      itemBuilder: (context, index) {
                                        if (index == 0 || index == terms.length + 1) {
                                          return SizedBox(width: suSetSp(5.0));
                                        } else {
                                          return _term(
                                            terms[terms.length - index],
                                            terms.length - index,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: GridView.count(
                                  padding: EdgeInsets.zero,
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.5,
                                  children: <Widget>[
                                    if (scoresFiltered != null)
                                      for (int i = 0; i < scoresFiltered.length; i++)
                                        Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(suSetSp(10.0)),
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
                              ),
                            ],
                          ),
              ),
              evaluateTips,
            ],
          );
  }
}
