import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/LoginPage.dart';

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
  bool isOnline;
  bool isUserLogin = false;
  bool showLoading = false;
  bool isInLoginProcess = false;

  @override
  void initState() {
    OTAUtils.checkUpdate(fromHome: true);

    Future.delayed(const Duration(seconds: 5), () {
      showLoading = true;
      if (this.mounted) setState(() {});
    });

    checkConnectivity().then((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        checkOnline(ConnectivityChangeEvent(result));
      }
    });

    Instances.eventBus
      ..on<ConnectivityChangeEvent>().listen((event) {
        if (this.mounted && isOnline != null) checkOnline(event);
      })
      ..on<TicketGotEvent>().listen((event) async {
        debugPrint("Ticket Got.");
        if (!event.isWizard) {}
        this.isUserLogin = true;
        if (this.mounted) {
          setState(() {});
          await navigate();
        }
      })
      ..on<TicketFailedEvent>().listen((event) async {
        debugPrint("Ticket Failed.");
        this.isUserLogin = false;
        if (this.mounted) {
          setState(() {});
          await navigate();
        }
      });
    super.initState();
  }

  Future<ConnectivityResult> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != null &&
          connectivityResult != ConnectivityResult.none) {
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
        this.isOnline = true;
        DataUtils.reFetchTicket();
      } else {
        this.isOnline = false;
      }
    }
    if (mounted) setState(() {});
  }

  Future getAnnouncement() async {
    Map<String, dynamic> data =
        jsonDecode((await NetUtils.get(API.announcement)).data);
    Configs.announcementsEnabled = data['enabled'];
    Configs.announcements = data['announcements'];
  }

  Future navigate() async {
    await getAnnouncement();
    Future.delayed(const Duration(seconds: 2), () {
      if (!isUserLogin) {
        try {
          navigatorState.pushAndRemoveUntil(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 1000),
                pageBuilder: (_, animation, __) => FadeTransition(
                  opacity: animation,
                  child: LoginPage(initAction: widget.initAction),
                ),
              ),
              (Route<dynamic> route) => false);
        } catch (e) {}
      } else {
        try {
          navigatorState.pushNamedAndRemoveUntil(
            "openjmu://home",
            (Route<dynamic> route) => false,
            arguments: {"initAction": widget.initAction},
          );
        } catch (e) {
          debugPrint("$e");
        }
      }
    });
  }

  Widget get logo => Container(
        margin: EdgeInsets.all(suSetWidth(30.0)),
        child: Hero(
          tag: "Logo",
          child: SvgPicture.asset(
            "images/splash_page_logo.svg",
            width: suSetWidth(150.0),
            height: suSetHeight(150.0),
          ),
        ),
      );

  Widget get loginWidget => Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: suSetHeight(10.0),
                ),
                width: suSetWidth(28.0),
                height: suSetHeight(28.0),
                child: PlatformProgressIndicator(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "正在登录",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: suSetSp(20.0),
                ),
              ),
            ),
          )
        ],
      );

  Widget get warningWidget => Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Icon(
                Icons.warning,
                color: Colors.white,
                size: suSetWidth(40.0),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "请检查联网状态",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: suSetSp(20.0),
                ),
              ),
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ThemeUtils.currentThemeColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              logo,
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  top: suSetWidth(
                    showLoading && isOnline != null ? 20.0 : 0.0,
                  ),
                ),
                height: suSetHeight(
                  showLoading && isOnline != null ? 80.0 : 0.0,
                ),
                child: Center(
                  child: showLoading && isOnline != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: isOnline ? loginWidget : warningWidget,
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
