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
  name: "openjmu://splash",
  routeName: "启动页",
  argumentNames: ["initAction"],
)
class SplashPage extends StatefulWidget {
  final String initAction;

  const SplashPage({
    this.initAction,
    Key key,
  }) : super(key: key);

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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        firstFramed = true;
      });

      OTAUtils.checkUpdate();
      Provider.of<DateProvider>(
        currentContext,
        listen: false,
      ).getCurrentWeek();

      _forceToLoginTimer = Timer(30.seconds, () {
        if (!isUserLogin) {
          navigate(forceToLogin: true);
        }
      });
      _showLoginIndicatorTimer = Timer(5.seconds, () {
        if (mounted) {
          setState(() {
            showLoading = true;
          });
        }
      });
    });

    checkConnectivity().then((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        checkOnline(ConnectivityChangeEvent(result));
      }
    });

    Instances.eventBus
      ..on<ConnectivityChangeEvent>().listen((event) {
        if (mounted && isOnline != null) checkOnline(event);
      })
      ..on<TicketGotEvent>().listen((event) async {
        debugPrint("Ticket Got.");
        if (!event.isWizard) {}
        isUserLogin = true;
        if (mounted) {
          setState(() {});
          await navigate();
        }
      })
      ..on<TicketFailedEvent>().listen((event) async {
        debugPrint("Ticket Failed.");
        isUserLogin = false;
        if (mounted) {
          setState(() {});
          await navigate();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _forceToLoginTimer?.cancel();
    _showLoginIndicatorTimer?.cancel();
    super.dispose();
  }

  Future<ConnectivityResult> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != null && connectivityResult != ConnectivityResult.none) {
        isOnline = true;
      } else {
        isOnline = false;
      }
      return connectivityResult;
    } catch (e) {
      debugPrint("Checking connectivity error: $e");
      return ConnectivityResult.none;
    }
  }

  void checkOnline(event) {
    if (!isInLoginProcess) {
      isInLoginProcess = true;
      if (event.type != ConnectivityResult.none) {
        isOnline = true;
        DataUtils.reFetchTicket();
      } else {
        isOnline = false;
      }
    }
    if (mounted) setState(() {});
  }

  Future navigate({bool forceToLogin = false}) async {
    _forceToLoginTimer?.cancel();
    _showLoginIndicatorTimer?.cancel();
    try {
      navigatorState.pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: !isUserLogin || forceToLogin ? 1.seconds : 500.milliseconds,
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: !isUserLogin || forceToLogin
                ? LoginPage(initAction: widget.initAction)
                : MainPage(initAction: widget.initAction),
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      debugPrint("$e");
    }
  }

  Widget get logo => Container(
        margin: EdgeInsets.all(suSetWidth(30.0)),
        child: Hero(
          tag: "Logo",
          child: SvgPicture.asset(
            "images/splash_page_logo.svg",
            width: suSetWidth(150.0),
            height: suSetHeight(150.0),
            color: currentIsDark ? currentThemeColor : Colors.white,
          ),
        ),
      );

  Widget get loginWidget => Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: suSetHeight(10.0),
              ),
              child: Center(
                child: SizedBox.fromSize(
                  size: Size.square(suSetWidth(36.0)),
                  child: PlatformProgressIndicator(
                    radius: suSetWidth(20.0),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: suSetHeight(30.0),
            child: Center(
              child: Text(
                "正在登录",
                style: TextStyle(color: Colors.white, fontSize: suSetSp(24.0)),
              ),
            ),
          ),
        ],
      );

  Widget get warningWidget => Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: suSetHeight(10.0)),
              child: Center(
                child: Icon(Icons.warning, color: Colors.white, size: suSetWidth(36.0)),
              ),
            ),
          ),
          SizedBox(
            height: suSetHeight(30.0),
            child: Center(
              child: Text(
                "请检查联网状态",
                style: TextStyle(color: Colors.white, fontSize: suSetSp(24.0)),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: AnimatedOpacity(
        duration: 500.milliseconds,
        curve: Curves.easeInOut,
        opacity: firstFramed ? 1.0 : 0.0,
        child: Scaffold(
          backgroundColor:
              currentIsDark ? Theme.of(context).scaffoldBackgroundColor : currentThemeColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              logo,
              AnimatedContainer(
                duration: 200.milliseconds,
                margin: EdgeInsets.only(
                  top: suSetHeight(showLoading && isOnline != null ? 20.0 : 0.0),
                ),
                width: Screens.width,
                height: suSetHeight(showLoading && isOnline != null ? 80.0 : 0.0),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: suSetHeight(showLoading && isOnline != null ? 80.0 : 0.0),
                    child: showLoading && isOnline != null
                        ? isOnline ? loginWidget : warningWidget
                        : SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
