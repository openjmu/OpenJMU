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
  final ValueNotifier<double> _currentPage = ValueNotifier<double>(0.0);

  double get currentPage => _currentPage.value;

  final Set<ChangeLog> changeLogs = HiveBoxes.changelogBox.values.toSet();
  final ValueNotifier<bool> isError = ValueNotifier<bool>(false),
      displayBack = ValueNotifier<bool>(true),
      isAnimating = ValueNotifier<bool>(false);

  AnimationController _blurOpacityController;
  Animation<double> _blurOpacityAnimation;

  @override
  void initState() {
    super.initState();
    if (changeLogs == null) {
      PackageUtils.checkUpdate();
    }
    _pageController
        .addListener(() => _currentPage.value = _pageController.page);
    _blurOpacityController = AnimationController(
      duration: 1.seconds,
      vsync: this,
    );
    _blurOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _blurOpacityController,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    isError.dispose();
    displayBack.dispose();
    isAnimating.dispose();
    super.dispose();
  }

  void blurAnimate(bool forward) {
    isAnimating.value = forward;

    _blurOpacityController.stop();
    if (forward) {
      _blurOpacityController.forward();
    } else {
      _blurOpacityController.reverse();
    }
  }

  bool onNotification(ScrollNotification notification) {
    _currentPage.value = _pageController.page;
    if (notification.metrics.axisDirection == AxisDirection.right &&
        currentPage > 2) {
      if (displayBack.value) {
        displayBack.value = false;
      }
    } else {
      if (!displayBack.value) {
        displayBack.value = true;
      }
    }
    return true;
  }

  Widget get goBackButton {
    return Container(
      padding: EdgeInsets.only(bottom: context.bottomPadding),
      decoration: BoxDecoration(
        border: Border(top: dividerBS(context)),
        color: context.surfaceColor,
      ),
      child: Tapper(
        onTap: () {
          blurAnimate(true);
          Future<void>.delayed(3.seconds, () {
            blurAnimate(false);
          });
          _pageController.animateToPage(
            displayBack.value ? changeLogs.length : 0,
            duration: 4.seconds,
            curve: Curves.fastOutSlowIn,
          );
        },
        child: Container(
          alignment: Alignment.center,
          height: 80.w,
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
            child: ValueListenableBuilder<bool>(
              valueListenable: displayBack,
              builder: (_, bool value, __) => AnimatedCrossFade(
                duration: 300.milliseconds,
                crossFadeState: value
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: const Text('回到梦开始的地方 →'),
                secondChild: const Text('← 踏上新旅途'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logLine(bool left) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: 10.w,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
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
        fontSize: (log.buildNumber == PackageUtils.buildNumber ? 45 : 50).sp,
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
      style: context.textTheme.caption.copyWith(fontSize: 20.sp),
    );
  }

  Widget detailWidget(
    BuildContext context,
    int index,
    ChangeLog log, {
    double parallaxOffset,
  }) {
    return Column(
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
              margin: EdgeInsets.all(30.w).copyWith(top: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                color: context.surfaceColor,
              ),
              child: SizedBox.expand(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  physics: const BouncingScrollPhysics(),
                  child: sectionWidget(log.sections),
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget starterWidget(double parallaxOffset) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: Screens.width,
          height: Screens.height / 6,
          child: Row(
            children: <Widget>[
              _logLine(true),
              _logVersion(
                const ChangeLog(
                  version: '0.1.0',
                  buildNumber: 1,
                  date: '2019-03-17',
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: Transform(
            transform: Matrix4.translationValues(parallaxOffset, 0.0, 0.0),
            child: Container(
              margin: EdgeInsets.all(30.w).copyWith(top: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                color: context.surfaceColor,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(30.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    SvgPicture.asset(
                      R.IMAGES_OPENJMU_LOGO_TEXT_SVG,
                      color: defaultLightColor,
                      height: 28.w,
                    ),
                    VGap(40.w),
                    SvgPicture.asset(
                      R.ASSETS_ICONS_OPEN_THE_SKY_SVG,
                      color: context.textTheme.bodyText2.color,
                      width: Screens.width / 4,
                    ),
                    VGap(40.w),
                    Text(
                      '开发组成员',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    VGap(15.w),
                    _developersGrid(context),
                    VGap(40.w),
                    Text(
                      '© ${currentTime.year} The OpenJMU Team',
                      style: context.textTheme.caption.copyWith(
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _developersGrid(BuildContext context) {
    return GridView.count(
      childAspectRatio: 1.5,
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const <Widget>[
        _DeveloperWidget(name: '李承峻', secondaryName: 'Alex', tag: '负责人'),
        _DeveloperWidget(name: '徐崎峰', secondaryName: 'evsio0n', tag: '开发'),
        _DeveloperWidget(name: '叶佳豪', secondaryName: 'Tomcat', tag: '产品/运营'),
        _DeveloperWidget(name: '陈高仁', tag: 'UI设计'),
        _DeveloperWidget(name: '陈嘉旺', tag: '产品'),
        _DeveloperWidget(name: '兰方正', secondaryName: 'Leo', tag: '开发'),
        _DeveloperWidget(name: '潘楚坤', secondaryName: '暗云', tag: '产品/运营'),
        _DeveloperWidget(name: '李安厦', tag: 'UI设计'),
        _DeveloperWidget(name: '周妍妍', tag: 'UI设计'),
        _DeveloperWidget(name: '肖建行', secondaryName: 'joe', tag: '开发'),
        _DeveloperWidget(name: '李炜捷', tag: '产品'),
        _DeveloperWidget(name: '杜雨菲', tag: '产品'),
      ],
    );
  }

  Widget get emptyTips {
    return Padding(
      padding: EdgeInsets.all(60.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LoadMoreSpinningIcon(isRefreshing: true),
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
  }

  Widget get backdrop {
    return Positioned.fill(
      child: ValueListenableBuilder<bool>(
        valueListenable: isAnimating,
        builder: (_, bool value, Widget child) => IgnorePointer(
          ignoring: !value,
          child: child,
        ),
        child: AnimatedBuilder(
          animation: _blurOpacityAnimation,
          builder: (_, __) => BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 2 * _blurOpacityAnimation.value,
              sigmaY: 2 * _blurOpacityAnimation.value,
            ),
            child: const Text(' '),
          ),
        ),
      ),
    );
  }

  Widget logWidgetBuilder(BuildContext context, int index) {
    return ValueListenableBuilder<double>(
      valueListenable: _currentPage,
      builder: (_, double page, __) {
        final double offset = Screens.width / 2.0 * (index - page);
        if (index != changeLogs.length) {
          return detailWidget(
            context,
            index,
            changeLogs.elementAt(index),
            parallaxOffset: offset,
          );
        } else {
          return starterWidget(offset);
        }
      },
    );
  }

  Widget _contentBuilder(BuildContext context, BoxConstraints constraints) {
    return Column(
      children: <Widget>[
        Expanded(
          child: PageView.custom(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            childrenDelegate: SliverChildBuilderDelegate(
              (_, int index) => logWidgetBuilder(context, index),
              childCount: changeLogs.length + 1,
            ),
          ),
        ),
        goBackButton,
      ],
    );
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
                      builder: (_, BoxConstraints cs) =>
                          NotificationListener<ScrollNotification>(
                        onNotification: onNotification,
                        child: _contentBuilder(context, cs),
                      ),
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

class _DeveloperWidget extends StatelessWidget {
  const _DeveloperWidget({
    Key key,
    this.name,
    this.secondaryName,
    this.tag,
  }) : super(key: key);

  final String name;
  final String secondaryName;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: name,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
              ),
              if (secondaryName != null)
                TextSpan(
                  text: ' ($secondaryName)',
                  style: TextStyle(fontSize: 15.sp),
                ),
            ],
          ),
        ),
        VGap(6.w),
        Text(
          tag,
          style: context.textTheme.caption.copyWith(fontSize: 17.sp),
        ),
      ],
    );
  }
}
