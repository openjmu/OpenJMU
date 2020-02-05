///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-31 22:29
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: "openjmu://changelog-page", routeName: "版本履历")
class ChangeLogPage extends StatefulWidget {
  @override
  _ChangeLogPageState createState() => _ChangeLogPageState();
}

class _ChangeLogPageState extends State<ChangeLogPage> with TickerProviderStateMixin {
  final _pageController = PageController();
  double _currentPage = 0.0;

  Set changeLogs = HiveBoxes.changelogBox.values.toSet();
  bool error = false;
  bool displayBack = true;
  bool animating = false;

  double _blurOpacity = 0.0;
  Animation<double> _blurOpacityAnimation;
  AnimationController _blurOpacityController;

  @override
  void initState() {
    super.initState();
    if (changeLogs == null) OTAUtils.checkUpdate();
  }

  void blurAnimate(bool forward) {
    animating = forward;
    if (mounted) setState(() {});

    _blurOpacityController = AnimationController(duration: 1.seconds, vsync: this);
    final _blurOpacityCurve = CurvedAnimation(
      parent: _blurOpacityController,
      curve: Curves.ease,
    );
    _blurOpacityAnimation = Tween(
      begin: forward ? 0.0 : _blurOpacity,
      end: forward ? 1.0 : 0.0,
    ).animate(_blurOpacityCurve)
      ..addListener(() {
        _blurOpacity = _blurOpacityAnimation.value;
        if (mounted) setState(() {});
      });

    _blurOpacityController
      ..stop()
      ..forward();
  }

  Widget get goBackButton => Container(
        margin: EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
        child: MaterialButton(
          elevation: 0.0,
          highlightElevation: 0.0,
          hoverElevation: 0.0,
          focusElevation: 0.0,
          color: currentThemeColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: maxBorderRadius),
          onPressed: () {
            blurAnimate(true);
            Future.delayed(3.seconds, () {
              blurAnimate(false);
            });
            _pageController.animateToPage(
              displayBack ? changeLogs.length : 0,
              duration: 4.seconds,
              curve: Curves.fastOutSlowIn,
            );
          },
          child: AnimatedCrossFade(
            duration: 300.milliseconds,
            crossFadeState: displayBack ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Text(
              '回到梦开始的地方 →',
              style: TextStyle(
                color: currentThemeColor,
                fontSize: suSetSp(20.0),
              ),
            ),
            secondChild: Text(
              '← 踏上新旅途',
              style: TextStyle(
                color: currentThemeColor,
                fontSize: suSetSp(20.0),
              ),
            ),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

  Widget _logLine(bool left) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: suSetHeight(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(left ? 0 : 999),
            right: Radius.circular(!left ? 0 : 999),
          ),
          color: currentThemeColor,
        ),
      ),
    );
  }

  Widget _logVersion(ChangeLog log) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: suSetWidth(40.0)),
      child: Column(
        children: <Widget>[
          log.buildNumber == OTAUtils.buildNumber
              ? Expanded(
                  flex: 3,
                  child: Center(child: Text('📍', style: TextStyle(fontSize: suSetSp(40.0)))),
                )
              : Spacer(flex: 2),
          versionInfo(log),
          SizedBox(height: suSetHeight(12.0)),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              dateInfo(log),
              buildNumberInfo(log),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget versionInfo(ChangeLog log) {
    return Text(
      '${log.version}',
      style: Theme.of(context).textTheme.title.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: suSetSp(log.buildNumber == OTAUtils.buildNumber ? 45.0 : 50.0),
          ),
    );
  }

  Widget dateInfo(ChangeLog log) {
    return Text(
      '${log.date} ',
      style: Theme.of(context).textTheme.caption.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  Widget buildNumberInfo(ChangeLog log) {
    return Text(
      '(${log.buildNumber})',
      style: Theme.of(context).textTheme.caption.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  Widget detailWidget(
    int index,
    ChangeLog log, {
    double parallaxOffset,
  }) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            width: Screens.width,
            height: Screens.height / 6,
            child: Row(
              children: <Widget>[
                index == 0 ? Spacer() : _logLine(true),
                _logVersion(log),
                index == changeLogs.length - 1 ? Spacer() : _logLine(false),
              ],
            ),
          ),
          Expanded(
            child: Transform(
              transform: Matrix4.translationValues(parallaxOffset, 0.0, 0.0),
              child: Container(
                margin: EdgeInsets.only(
                  left: suSetWidth(40.0),
                  right: suSetWidth(40.0),
                  bottom: suSetHeight(60.0),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(suSetWidth(15.0)),
                  color: Theme.of(context).canvasColor,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(suSetWidth(20.0)),
                  physics: const BouncingScrollPhysics(),
                  child: sectionWidget(log.sections),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionWidget(Map<String, dynamic> sections) {
    return Text.rich(
      TextSpan(
        children: List<TextSpan>.generate(
          sections.keys.length,
          (i) => contentColumn(sections, i),
        ),
      ),
      style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  TextSpan contentColumn(Map<String, dynamic> sections, int index) {
    final name = sections.keys.elementAt(index);
    return TextSpan(
      children: List<TextSpan>.generate(
        sections[name].length + 1,
        (j) => j == 0
            ? TextSpan(
                text: '[$name]\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : TextSpan(
                text: '${j == 1 ? '\n' : ''}'
                    '·  ${sections[name][j - 1]}\n'
                    '${j == sections[name].length ? '\n' : ''}',
              ),
      ),
    );
  }

  Widget get startWidget => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(suSetWidth(20.0)),
            child: Image.asset(
              'images/logo_1024.png',
              width: suSetWidth(150.0),
              height: suSetWidth(150.0),
            ),
          ),
          SizedBox(height: suSetHeight(50.0)),
          Text(
            'Open The Sky',
            style: TextStyle(
              color: defaultColor,
              fontFamily: 'chocolate',
              fontSize: suSetSp(50.0),
            ),
          ),
          SizedBox(height: suSetHeight(20.0)),
          Text(
            '2019.03.17',
            style: TextStyle(
              fontFamily: 'chocolate',
              fontSize: suSetSp(30.0),
            ),
          ),
          SizedBox(height: suSetHeight(80.0)),
        ],
      );

  Widget get emptyTips => Padding(
        padding: EdgeInsets.all(suSetWidth(60.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SpinKitWidget(),
            SizedBox(height: suSetHeight(40.0)),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: '履历跑得太快，程序已经追不上它了...待会儿它就会回来的\n'),
                  TextSpan(text: '🚀', style: TextStyle(fontSize: suSetSp(50.0))),
                ],
              ),
              style: TextStyle(fontSize: suSetSp(25.0)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget get backdrop => Positioned.fill(
        child: IgnorePointer(
          ignoring: !animating,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 2.0 * _blurOpacity,
              sigmaY: 2.0 * _blurOpacity,
            ),
            child: Text(' '),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(title: Text('版本履历')),
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: changeLogs != null
                      ? LayoutBuilder(
                          builder: (context, constraints) => NotificationListener(
                            onNotification: (ScrollNotification notification) {
                              _currentPage = _pageController.page;
                              if (notification.metrics.axisDirection == AxisDirection.right &&
                                  _currentPage > 2.0) {
                                displayBack = false;
                              } else {
                                displayBack = true;
                              }
                              if (mounted) setState(() {});
                              return true;
                            },
                            child: Column(
                              children: <Widget>[
                                goBackButton,
                                Expanded(
                                  child: PageView.custom(
                                    controller: _pageController,
                                    physics: const BouncingScrollPhysics(),
                                    childrenDelegate: SliverChildBuilderDelegate(
                                      (context, index) => index == changeLogs.length
                                          ? startWidget
                                          : detailWidget(
                                              index,
                                              changeLogs.elementAt(index),
                                              parallaxOffset: constraints.maxWidth /
                                                  2.0 *
                                                  (index - _currentPage),
                                            ),
                                      childCount: changeLogs.length + 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : emptyTips,
                ),
                backdrop,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
