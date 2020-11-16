import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/login_page.dart';
import 'package:openjmu/pages/main_page.dart';

@FFRoute(
  name: 'openjmu://splash',
  routeName: '启动页',
  argumentNames: <String>['initAction'],
)
class SplashPage extends StatefulWidget {
  const SplashPage({
    Key key,
    this.initAction,
  }) : super(key: key);

  final int initAction;

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashPage> {
  bool firstFramed = false;
  bool isOnline;
  bool isInLoginProcess = false;
  bool isUserLogin = false;
  bool showLoading = false;

  Timer _forceToLoginTimer;
  Timer _showLoginIndicatorTimer;

  @override
  void initState() {
    super.initState();
    Instances.webViewCookieManager.deleteAllCookies();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        firstFramed = true;
      });

      PackageUtils.checkUpdate();
      Provider.of<DateProvider>(currentContext, listen: false).getCurrentWeek();

      _forceToLoginTimer = Timer(30.seconds, () {
        if (mounted) {
          navigate(forceToLogin: !isUserLogin);
        }
      });
      _showLoginIndicatorTimer = Timer(5.seconds, () {
        showLoading = true;
        if (mounted) {
          setState(() {});
        }
      });
    });

    Instances.eventBus
      ..on<ConnectivityChangeEvent>().listen((ConnectivityChangeEvent event) {
        if (mounted) {
          checkOnline();
        }
      })
      ..on<TicketGotEvent>().listen((TicketGotEvent event) {
        if (!event.isWizard) {}
        isUserLogin = true;
        if (mounted) {
          setState(() {});
          navigate();
        }
      })
      ..on<TicketFailedEvent>().listen((TicketFailedEvent event) {
        isUserLogin = false;
        if (mounted) {
          setState(() {});
          navigate();
        }
      });
  }

  @override
  void dispose() {
    _forceToLoginTimer?.cancel();
    _showLoginIndicatorTimer?.cancel();
    super.dispose();
  }

  void checkOnline() {
    if (!isInLoginProcess) {
      if (Instances.connectivityResult != null &&
          Instances.connectivityResult != ConnectivityResult.none) {
        isOnline = true;
        if (DataUtils.isLogin()) {
          DataUtils.reFetchTicket();
          isInLoginProcess = true;
        } else {
          Future<void>.delayed(2.seconds, navigate);
        }
      } else {
        isOnline = false;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  void navigate({bool forceToLogin = false}) {
    try {
      navigatorState.pushAndRemoveUntil<void>(
        PageRouteBuilder<void>(
          transitionDuration:
              !isUserLogin || forceToLogin ? 1.seconds : 500.milliseconds,
          pageBuilder: (_, Animation<double> animation, __) => FadeTransition(
            opacity: animation,
            child: !isUserLogin || forceToLogin
                ? LoginPage()
                : MainPage(initAction: widget.initAction),
          ),
        ),
        (_) => false,
      );
      _forceToLoginTimer?.cancel();
      _showLoginIndicatorTimer?.cancel();
    } catch (e) {
      LogUtils.e('Error when navigating: $e');
    }
  }

  Widget get logo => Container(
        margin: EdgeInsets.all(30.w),
        child: Hero(
          tag: 'Logo',
          child: SvgPicture.asset(
            R.IMAGES_SPLASH_PAGE_LOGO_SVG,
            width: 150.w,
            height: 150.h,
            color: currentIsDark ? currentThemeColor : Colors.white,
          ),
        ),
      );

  Widget get loginWidget => Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: 10.h,
              ),
              child: SpinKitWidget(
                color: currentIsDark ? currentThemeColor : Colors.white,
                size: 36.0,
              ),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      );

  Widget get warningWidget => Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 10.h),
              child: Center(
                child: Icon(
                  Icons.signal_wifi_off,
                  color: currentIsDark ? currentThemeColor : Colors.white,
                  size: 48.w,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30.h,
            child: Center(
              child: Text(
                '请检查联网状态',
                style: TextStyle(
                  color: currentIsDark ? currentThemeColor : Colors.white,
                  fontSize: 24.sp,
                ),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: AnimatedOpacity(
          duration: 500.milliseconds,
          curve: Curves.easeInOut,
          opacity: firstFramed ? 1.0 : 0.0,
          child: Scaffold(
            backgroundColor: currentIsDark
                ? Theme.of(context).scaffoldBackgroundColor
                : currentThemeColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                logo,
                AnimatedContainer(
                  duration: 200.milliseconds,
                  margin: EdgeInsets.only(
                    top: suSetHeight(
                        showLoading && isOnline != null ? 20.0 : 0.0),
                  ),
                  width: Screens.width,
                  height: suSetHeight(
                      showLoading && isOnline != null ? 100.0 : 0.0),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      height: suSetHeight(
                          showLoading && isOnline != null ? 100.0 : 0.0),
                      child: AnimatedSwitcher(
                        duration: 300.milliseconds,
                        child: showLoading && isOnline != null
                            ? AnimatedSwitcher(
                                duration: 300.milliseconds,
                                child: isOnline ? loginWidget : warningWidget,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
