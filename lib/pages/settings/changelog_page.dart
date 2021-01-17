///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-31 22:29
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://changelog-page', routeName: '版本履历')
class ChangeLogPage extends StatefulWidget {
  @override
  _ChangeLogPageState createState() => _ChangeLogPageState();
}

class _ChangeLogPageState extends State<ChangeLogPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  double _currentPage = 0.0;

  final Set<ChangeLog> changeLogs = HiveBoxes.changelogBox.values.toSet();
  bool error = false;
  bool displayBack = true;
  bool animating = false;

  double _blurOpacity = 0.0;
  Animation<double> _blurOpacityAnimation;
  AnimationController _blurOpacityController;

  @override
  void initState() {
    super.initState();
    if (changeLogs == null) {
      PackageUtils.checkUpdate();
    }
  }

  void blurAnimate(bool forward) {
    animating = forward;
    if (mounted) {
      setState(() {});
    }

    _blurOpacityController =
        AnimationController(duration: 1.seconds, vsync: this);
    final CurvedAnimation _blurOpacityCurve = CurvedAnimation(
      parent: _blurOpacityController,
      curve: Curves.ease,
    );
    _blurOpacityAnimation = Tween<double>(
      begin: forward ? 0.0 : _blurOpacity,
      end: forward ? 1.0 : 0.0,
    ).animate(_blurOpacityCurve)
      ..addListener(() {
        _blurOpacity = _blurOpacityAnimation.value;
        if (mounted) {
          setState(() {});
        }
      });

    _blurOpacityController
      ..stop()
      ..forward();
  }

  Widget get goBackButton => Container(
        margin: EdgeInsets.symmetric(vertical: 20.h),
        child: MaterialButton(
          elevation: 0.0,
          highlightElevation: 0.0,
          hoverElevation: 0.0,
          focusElevation: 0.0,
          color: currentThemeColor.withOpacity(0.2),
          shape: const RoundedRectangleBorder(borderRadius: maxBorderRadius),
          onPressed: () {
            blurAnimate(true);
            Future<void>.delayed(3.seconds, () {
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
            crossFadeState: displayBack
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Text(
              '回到梦开始的地方 →',
              style: TextStyle(
                color: currentThemeColor,
                fontSize: 20.sp,
              ),
            ),
            secondChild: Text(
              '← 踏上新旅途',
              style: TextStyle(
                color: currentThemeColor,
                fontSize: 20.sp,
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
        height: 10.h,
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
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: <Widget>[
          if (log.buildNumber == PackageUtils.buildNumber)
            Expanded(
              flex: 3,
              child: Center(
                child: Text('📍', style: TextStyle(fontSize: 40.sp)),
              ),
            )
          else
            const Spacer(flex: 2),
          versionInfo(log),
          VGap(12.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              dateInfo(log),
              buildNumberInfo(log),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget versionInfo(ChangeLog log) {
    return Text(
      log.version,
      style: context.textTheme.headline6.copyWith(
        fontSize:
            suSetSp(log.buildNumber == PackageUtils.buildNumber ? 45.0 : 50.0),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget dateInfo(ChangeLog log) {
    return Text(
      '${log.date} ',
      style: context.textTheme.caption.copyWith(
        fontSize: 20.sp,
      ),
    );
  }

  Widget buildNumberInfo(ChangeLog log) {
    return Text(
      '(${log.buildNumber})',
      style: context.textTheme.caption.copyWith(
        fontSize: 20.sp,
      ),
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
                if (index != 0) _logLine(true) else const Spacer(),
                _logVersion(log),
                if (index != changeLogs.length - 1)
                  _logLine(false)
                else
                  const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Transform(
              transform: Matrix4.translationValues(parallaxOffset, 0.0, 0.0),
              child: Container(
                margin: EdgeInsets.only(
                  left: 40.w,
                  right: 40.w,
                  bottom: 60.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.w),
                  color: Theme.of(context).cardColor,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
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
          (int i) => contentColumn(sections, i),
        ),
      ),
      style: context.textTheme.bodyText2.copyWith(fontSize: 20.sp),
    );
  }

  TextSpan contentColumn(Map<String, dynamic> sections, int index) {
    final String name = sections.keys.elementAt(index);
    return TextSpan(
      children: List<TextSpan>.generate(
        (sections[name] as List<dynamic>).length + 1,
        (int j) => j == 0
            ? TextSpan(
                text: '[$name]\n',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
            borderRadius: BorderRadius.circular(20.w),
            child: Image.asset(
              R.IMAGES_LOGO_1024_PNG,
              width: 150.w,
              height: 150.w,
            ),
          ),
          VGap(50.h),
          Text(
            'Open The Sky',
            style: TextStyle(
              color: defaultLightColor,
              fontFamily: 'chocolate',
              fontSize: 50.sp,
            ),
          ),
          VGap(20.h),
          Text(
            '2019.03.17',
            style: TextStyle(
              fontFamily: 'chocolate',
              fontSize: 30.sp,
            ),
          ),
          VGap(80.h),
        ],
      );

  Widget get emptyTips => Padding(
        padding: EdgeInsets.all(60.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SpinKitWidget(),
            VGap(40.h),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(
                    text: '履历跑得太快，程序已经追不上它了...待会儿它就会回来的\n',
                  ),
                  TextSpan(
                    text: '🚀',
                    style: TextStyle(fontSize: 50.sp),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 25.sp),
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
            child: const Text(' '),
          ),
        ),
      );

  Widget logWidgetBuilder({
    int index,
    BoxConstraints constraints,
  }) {
    if (index != changeLogs.length) {
      return detailWidget(
        index,
        changeLogs.elementAt(index),
        parallaxOffset: constraints.maxWidth / 2.0 * (index - _currentPage),
      );
    } else {
      return startWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: const FixedAppBar(title: Text('版本履历')),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: changeLogs != null
                  ? LayoutBuilder(
                      builder: (_, BoxConstraints constraints) {
                        return NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            _currentPage = _pageController.page;
                            if (notification.metrics.axisDirection ==
                                    AxisDirection.right &&
                                _currentPage > 2.0) {
                              displayBack = false;
                            } else {
                              displayBack = true;
                            }
                            if (mounted) {
                              setState(() {});
                            }
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
                                    (_, int index) => logWidgetBuilder(
                                      index: index,
                                      constraints: constraints,
                                    ),
                                    childCount: changeLogs.length + 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : emptyTips,
            ),
            backdrop,
          ],
        ),
      ),
    );
  }
}
