import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/login_page.dart';
import 'package:openjmu/pages/main_page.dart';
import 'package:openjmu/pages/tutorial_page.dart';

@FFRoute(name: 'openjmu://splash', routeName: '启动页')
class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashPage> {
  bool firstFramed = false;
  bool isOnline;
  bool isInLoginProcess = false;
  bool isUserLogin = false;
  bool showLoading = false;
  bool isNavigating = false;

  Timer _forceToLoginTimer;
  Timer _showLoginIndicatorTimer;

  @override
  void initState() {
    super.initState();
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

  Future<void> checkOnline() async {
    await NetUtils.testClassKit();
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
    if (isNavigating) {
      return;
    }
    isNavigating = true;
    try {
      navigatorState.pushAndRemoveUntil<void>(
        PageRouteBuilder<void>(
          transitionDuration:
              !isUserLogin || forceToLogin ? 1.seconds : 500.milliseconds,
          pageBuilder: (_, Animation<double> animation, __) {
            Widget child;
            if (!isUserLogin || forceToLogin) {
              child = const LoginPage();
              NetUtils.webViewCookieManager.deleteAllCookies();
            } else if (HiveFieldUtils.getFirstOpen() != true) {
              child = const TutorialPage();
            } else {
              child = MainPage();
            }
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (_) => false,
      );
      _forceToLoginTimer?.cancel();
      _showLoginIndicatorTimer?.cancel();
    } catch (e) {
      LogUtils.e('Error when navigating: $e');
      isNavigating = false;
      NetUtils.webViewCookieManager.deleteAllCookies();
    }
  }

  Widget get logo {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.w),
      child: SvgPicture.asset(
        R.IMAGES_OPENJMU_LOGO_TEXT_SVG,
        width: Screens.width / 3,
        color: currentThemeColor,
      ),
    );
  }

  Widget get loginWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoadMoreSpinningIcon(isRefreshing: isOnline, size: 36),
        Gap(15.w),
        DefaultTextStyle.merge(
          style: TextStyle(
            color: context.textTheme.caption.color.withOpacity(0.5),
            height: 1.2,
            fontSize: 18.sp,
          ),
          child: AnimatedSwitcher(
            duration: kThemeChangeDuration,
            child: isOnline ? const Text('正在加载…') : const Text('网络未连接'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: currentIsDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: AnimatedOpacity(
          duration: 500.milliseconds,
          curve: Curves.easeInOut,
          opacity: firstFramed ? 1.0 : 0.0,
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                logo,
                AnimatedContainer(
                  duration: 200.milliseconds,
                  margin: EdgeInsets.only(
                    top: showLoading && isOnline != null ? 10.w : 0,
                  ),
                  width: Screens.width,
                  height: showLoading && isOnline != null ? 50.w : 0,
                  child: AnimatedSwitcher(
                    duration: 300.milliseconds,
                    child: showLoading && isOnline != null
                        ? loginWidget
                        : const SizedBox.shrink(),
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
