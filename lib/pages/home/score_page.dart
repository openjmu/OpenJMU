import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:openjmu/constants/constants.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({Key key}) : super(key: key);

  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void gotoEvaluate() {
    String url;
    if (UserAPI.currentUser.isCY) {
      url = 'http://cyjwgl.jmu.edu.cn/';
    } else {
      url = 'http://sso.jmu.edu.cn/imapps/1070?sid=${currentUser.sid}';
    }
    API.launchWeb(
      url: NetUtils.shouldUseWebVPN ? API.replaceWithWebVPN(url) : url,
      title: '教学评测',
    );
  }

  Widget get errorWidget {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          R.ASSETS_PLACEHOLDERS_COURSE_NOT_READY_SVG,
          width: 50.w,
          color: context.theme.iconTheme.color,
        ),
        VGap(20.w),
        Text(
          '成绩未就绪',
          style: TextStyle(
            color: context.textTheme.caption.color,
            fontSize: 22.sp,
          ),
        ),
      ],
    );
  }

  Widget get noScoreWidget {
    return Container(
      decoration: BoxDecoration(border: Border(top: dividerBS(context))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            R.ASSETS_PLACEHOLDERS_NO_MESSAGE_SVG,
            width: 50.w,
            color: context.theme.iconTheme.color,
          ),
          VGap(20.w),
          Text(
            '暂无成绩',
            style: TextStyle(
              color: context.textTheme.caption.color,
              fontSize: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget evaluateTips(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: dividerBS(context),
        ),
        color: context.appBarTheme.color,
      ),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            const TextSpan(text: '未进行 '),
            TextSpan(
              text: '教学评测 (内网)',
              style: TextStyle(
                color: currentThemeColor,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()..onTap = gotoEvaluate,
            ),
            const TextSpan(text: ' 的科目成绩将不予显示'),
          ],
        ),
        style: context.textTheme.caption.copyWith(height: 1.2, fontSize: 19.sp),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _term(BuildContext context, String term) {
    final int currentYear = term.substring(0, 4).toInt();
    final int currentTerm = term.substring(4, 5).toInt();

    return Selector<ScoresProvider, String>(
      selector: (_, ScoresProvider p) => p.selectedTerm,
      builder: (_, String selectedTerm, __) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$currentYear-${currentYear + 1}'),
            Text('第$currentTerm学期'),
          ],
        ),
      ),
    );
  }

  Widget termsWidget(BuildContext context) {
    return Selector<ScoresProvider, List<String>>(
      selector: (_, ScoresProvider p) => p.terms,
      builder: (_, List<String> terms, __) {
        if (terms?.isEmpty != false) {
          return const SizedBox.shrink();
        }
        return Container(
          height: 80.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: dividerBS(context),
            ),
            color: context.appBarTheme.color,
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            physics: const BouncingScrollPhysics(),
            labelStyle: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
            labelColor: context.themeColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 4.w,
            tabs: List<Widget>.generate(
              terms.length,
              (int index) => _term(
                context,
                terms[terms.length - index - 1],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget scoreGrid(BuildContext context) {
    return Selector<ScoresProvider, List<String>>(
      selector: (_, ScoresProvider p) => p.terms,
      builder: (_, List<String> terms, __) => TabBarView(
        controller: _tabController,
        children: List<Widget>.generate(
          terms.length,
          (int i) => _ScoresGridView(term: terms[terms.length - i - 1]),
        ),
      ),
    );
  }

  Widget refreshIndicator(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: const AbsorbPointer(
            child: Center(
              child: LoadMoreSpinningIcon(isRefreshing: true),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoresProvider>(
      builder: (_, ScoresProvider provider, __) {
        if (provider.hasScore) {
          if (_tabController == null ||
              _tabController.length != provider.terms.length) {
            _tabController = TabController(
              length: provider.terms.length,
              vsync: this,
            );
          }
        }
        return Stack(
          children: <Widget>[
            if (provider.loaded)
              Column(
                children: <Widget>[
                  Expanded(
                    child: provider.loadError
                        ? errorWidget
                        : provider.hasScore
                            ? Column(
                                children: <Widget>[
                                  termsWidget(context),
                                  Expanded(
                                    child: provider.filteredScores != null
                                        ? scoreGrid(context)
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

class _ScoresGridView extends StatelessWidget {
  const _ScoresGridView({
    Key key,
    @required this.term,
  })  : assert(term != null),
        super(key: key);

  final String term;

  Widget _name(BuildContext context, Score score) {
    return Text(
      score.courseName,
      style: context.textTheme.headline6.copyWith(fontSize: 20.sp),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
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
                  : context.textTheme.headline6.color,
            ),
          ),
          const TextSpan(text: ' / '),
          TextSpan(text: '${score.scorePoint}'),
        ],
        style: context.textTheme.subtitle2.copyWith(
          height: 1.2,
          fontSize: 20.sp,
        ),
      ),
    );
  }

  Widget _timeAndPoint(BuildContext context, Score score) {
    return Text(
      '学时: ${score.creditHour}　'
      '学分: ${score.credit.toStringAsFixed(1)}',
      style: context.textTheme.caption.copyWith(fontSize: 20.sp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Score> scores =
        context.watch<ScoresProvider>().scoresByTerm(term);
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.w),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      children: List<Widget>.generate(
        scores.length,
        (int i) => Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            color: context.surfaceColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _name(context, scores[i]),
              _score(context, scores[i]),
              _timeAndPoint(context, scores[i]),
            ],
          ),
        ),
      ),
    );
  }
}
