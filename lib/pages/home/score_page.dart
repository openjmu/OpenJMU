import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:openjmu/constants/constants.dart';

class ScorePage extends StatelessWidget {
  void gotoEvaluate() {
    String url;
    if (UserAPI.currentUser.isCY) {
      url = 'http://cyjwgl.jmu.edu.cn/';
    } else {
      url = 'http://sso.jmu.edu.cn/imapps/1070?sid=${currentUser.sid}';
    }
    API.launchWeb(url: url, title: '教学评测');
  }

  Widget errorWidget(ScoresProvider provider) {
    final String error = provider.errorString;

    String result;
    if (error.contains('The method \'transform\' was called on null')) {
      result = '电波暂时无法到达成绩业务的门口\n😰';
    } else {
      result = '成绩好像还没有准备好呢\n🤒';
    }

    return Center(
      child: Text(
        result,
        style: TextStyle(
          fontSize: 23.sp,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget get noScoreWidget => Center(
        child: Text(
          '暂时还没有你的成绩\n🤔',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30.sp),
        ),
      );

  Widget evaluateTips(BuildContext context) {
    final Widget dot = Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      width: 14.w,
      height: 14.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).textTheme.caption.color,
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: <Widget>[
          dot,
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(text: '请及时完成 '),
                  TextSpan(
                    text: '教学评测',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = gotoEvaluate,
                  ),
                  const TextSpan(text: ' (校园内网)\n未教学评测的科目成绩将不予显示'),
                ],
              ),
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(fontSize: 19.sp),
              textAlign: TextAlign.center,
            ),
          ),
          dot,
        ],
      ),
    );
  }

  Widget _term(BuildContext context, String term, int index) {
    final String _term = term;
    final int currentYear = _term.substring(0, 4).toInt();
    final int currentTerm = _term.substring(4, 5).toInt();
    return Consumer<ScoresProvider>(
      builder: (BuildContext _, ScoresProvider provider, Widget __) {
        final String selectedTerm = provider.selectedTerm;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => provider.selectTerm(index),
          child: AnimatedContainer(
            duration: 200.milliseconds,
            margin: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.w),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 5.0, color: Theme.of(context).canvasColor),
              ],
              color: _term == selectedTerm
                  ? currentThemeColor
                  : Theme.of(context).canvasColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
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
                      fontSize: 18.sp,
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
                      fontSize: 20.sp,
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
        padding: EdgeInsets.symmetric(vertical: 5.h),
        width: Screens.width,
        height: 86.h,
        child: Center(
          child: Selector<ScoresProvider, List<String>>(
            selector: (BuildContext _, ScoresProvider provider) =>
                provider.terms,
            builder: (BuildContext context, List<String> terms, Widget __) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: terms.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0 || index == terms.length + 1) {
                    return SizedBox(width: 10.w);
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

  Widget _name(BuildContext context, Score score) {
    return Text(
      score.courseName,
      style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 24.sp),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _score(BuildContext context, Score score) {
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: score.formattedScore,
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: !score.isPass
                  ? Colors.red
                  : Theme.of(context).textTheme.headline6.color,
            ),
          ),
          const TextSpan(text: ' / '),
          TextSpan(text: '${score.scorePoint}'),
        ],
        style:
            Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 20.sp),
      ),
    );
  }

  Widget _timeAndPoint(BuildContext context, Score score) {
    return Text(
      '学时: ${score.creditHour}　'
      '学分: ${score.credit.toStringAsFixed(1)}',
      style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 20.sp),
    );
  }

  Widget get scoreGrid {
    return Selector<ScoresProvider, List<Score>>(
      selector: (BuildContext _, ScoresProvider provider) =>
          provider.filteredScores,
      builder: (BuildContext context, List<Score> filteredScores, Widget __) {
        return GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          children: List<Widget>.generate(
            filteredScores.length,
            (int i) => Card(
              child: Padding(
                padding: EdgeInsets.all(12.w),
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
  }

  Widget refreshIndicator(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: const AbsorbPointer(child: SpinKitWidget()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoresProvider>(
      builder: (BuildContext _, ScoresProvider provider, Widget __) {
        return Stack(
          children: <Widget>[
            if (provider.loaded)
              Column(
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
              )
            else
              const SpinKitWidget(),
            if (provider.loaded && provider.loading) refreshIndicator(context),
          ],
        );
      },
    );
  }
}
