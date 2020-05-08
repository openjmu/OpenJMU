import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:openjmu/constants/constants.dart';

class ScorePage extends StatelessWidget {
  Widget errorWidget(ScoresProvider provider) {
    final error = provider.errorString;

    String result;
    if (error.contains('The method \'transform\' was called on null')) {
      result = '电波暂时无法到达成绩业务的门口\n😰';
    } else {
      result = '成绩好像还没有准备好呢\n🤒';
    }

    return Center(
      child: Text(
        result,
        style:
            TextStyle(fontSize: suSetSp(23.0), fontWeight: FontWeight.normal),
        textAlign: TextAlign.center,
      ),
    );
  }

  void gotoEvaluate() {
    String url;
    if (UserAPI.currentUser.isCY) {
      url = 'http://cyjwgl.jmu.edu.cn/';
    } else {
      url = 'http://sso.jmu.edu.cn/imapps/1070?sid=${currentUser.sid}';
    }
    API.launchWeb(url: url, title: '教学评测');
  }

  Widget get noScoreWidget => Center(
        child: Text(
          '暂时还没有你的成绩\n🤔',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: suSetSp(30.0)),
        ),
      );

  Widget evaluateTips(context) {
    final dot = Container(
      margin: EdgeInsets.symmetric(horizontal: suSetWidth(30.0)),
      width: suSetWidth(14.0),
      height: suSetHeight(14.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).textTheme.caption.color,
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: suSetHeight(12.0)),
      child: Row(
        children: <Widget>[
          dot,
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: '请及时完成 '),
                  TextSpan(
                    text: '教学评测',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = gotoEvaluate,
                  ),
                  TextSpan(text: ' (校园内网)\n未教学评测的科目成绩将不予显示'),
                ],
              ),
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(fontSize: suSetSp(19.0)),
              textAlign: TextAlign.center,
            ),
          ),
          dot,
        ],
      ),
    );
  }

  Widget _term(context, String term, int index) {
    String _term = term.toString();
    int currentYear = int.parse(_term.substring(0, 4));
    int currentTerm = int.parse(_term.substring(4, 5));
    return Consumer<ScoresProvider>(
      builder: (_, provider, __) {
        final selectedTerm = provider.selectedTerm;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => provider.selectTerm(index),
          child: AnimatedContainer(
            duration: 200.milliseconds,
            margin: EdgeInsets.all(suSetWidth(6.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(suSetWidth(15.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 5.0, color: Theme.of(context).canvasColor),
              ],
              color: _term == selectedTerm
                  ? currentThemeColor
                  : Theme.of(context).canvasColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: suSetSp(8.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$currentYear-${currentYear + 1}',
                    style: TextStyle(
                      color: _term == selectedTerm
                          ? Colors.white
                          : Theme.of(context)
                              .textTheme
                              .caption
                              .color
                              .withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                      fontSize: suSetSp(18.0),
                    ),
                  ),
                  Text(
                    '第$currentTerm学期',
                    style: TextStyle(
                      color: _term == selectedTerm
                          ? Colors.white
                          : Theme.of(context)
                              .textTheme
                              .caption
                              .color
                              .withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                      fontSize: suSetSp(20.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get termsWidget => Container(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(5.0)),
        width: Screens.width,
        height: suSetHeight(86.0),
        child: Center(
          child: Selector<ScoresProvider, List<String>>(
            selector: (_, provider) => provider.terms,
            builder: (context, terms, __) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: terms.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0 || index == terms.length + 1) {
                    return SizedBox(width: suSetWidth(10.0));
                  } else {
                    return _term(
                      context,
                      terms[terms.length - index],
                      terms.length - index,
                    );
                  }
                },
              );
            },
          ),
        ),
      );

  Widget _name(context, Score score) {
    return Text(
      '${score.courseName}',
      style: Theme.of(context)
          .textTheme
          .headline6
          .copyWith(fontSize: suSetSp(24.0)),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _score(context, Score score) {
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: '${score.score}',
            style: TextStyle(
              fontSize: suSetSp(36.0),
              fontWeight: FontWeight.bold,
              color: !score.isPass
                  ? Colors.red
                  : Theme.of(context).textTheme.headline6.color,
            ),
          ),
          TextSpan(text: ' / '),
          TextSpan(text: '${score.scorePoint}'),
        ],
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(fontSize: suSetSp(20.0)),
      ),
    );
  }

  Widget _timeAndPoint(context, Score score) {
    return Text(
      '学时: ${score.creditHour}　'
      '学分: ${score.credit.toStringAsFixed(1)}',
      style: Theme.of(context)
          .textTheme
          .bodyText2
          .copyWith(fontSize: suSetSp(20.0)),
    );
  }

  Widget get scoreGrid => Selector<ScoresProvider, List<Score>>(
        selector: (_, provider) => provider.filteredScores,
        builder: (context, filteredScores, __) {
          return GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            children: List<Widget>.generate(
              filteredScores.length,
              (i) => Card(
                child: Padding(
                  padding: EdgeInsets.all(suSetWidth(12.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _name(context, filteredScores[i]),
                      _score(context, filteredScores[i]),
                      _timeAndPoint(context, filteredScores[i]),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget refreshIndicator(context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AbsorbPointer(child: SpinKitWidget()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoresProvider>(
      builder: (_, provider, __) {
        return Stack(
          children: <Widget>[
            !provider.loaded
                ? SpinKitWidget()
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: provider.loadError
                            ? errorWidget(provider)
                            : provider.hasScore
                                ? Column(
                                    children: <Widget>[
                                      if (provider.terms != null) termsWidget,
                                      Expanded(
                                        child: provider.filteredScores != null
                                            ? scoreGrid
                                            : noScoreWidget,
                                      ),
                                    ],
                                  )
                                : noScoreWidget,
                      ),
                      evaluateTips(context),
                    ],
                  ),
            if (provider.loaded && provider.loading) refreshIndicator(context),
          ],
        );
      },
    );
  }
}
