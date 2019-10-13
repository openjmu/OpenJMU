import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity/connectivity.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Configs.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/LoginPage.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SplashPage extends StatefulWidget {
    final int initIndex;

    SplashPage({Key key, this.initIndex}) : super(key: key);

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
        super.initState();
        Future.delayed(const Duration(seconds: 5), () {
            if (this.mounted) setState(() { showLoading = true; });
        });
        checkConnectivity().then((ConnectivityResult result) {
            if (result != ConnectivityResult.none) {
                checkOnline(ConnectivityChangeEvent(result));
            }
        });
        Constants.eventBus
            ..on<ConnectivityChangeEvent>().listen((event) {
                if (this.mounted && isOnline != null) checkOnline(event);
            })
            ..on<TicketGotEvent>().listen((event) async {
                debugPrint("Ticket Got.");
                if (!event.isWizard) {}
                if (this.mounted) {
                    setState(() {
                        this.isUserLogin = true;
                    });
                    await navigate();
                }
            })
            ..on<TicketFailedEvent>().listen((event) async {
                debugPrint("Ticket Failed.");
                if (this.mounted) {
                    setState(() {
                        this.isUserLogin = false;
                    });
                    await navigate();
                }
            });
    }

    @override
    void didChangeDependencies() {
        ThemeUtils.setDark(true);
        ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
        super.didChangeDependencies();
    }

    Future<ConnectivityResult> checkConnectivity() async {
        try {
            ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
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
                    this.isOnline = true;
                    if (DataUtils.isLogin()) {
                        DataUtils.recoverLoginInfo();
                    } else {
                        Constants.eventBus.fire(TicketFailedEvent());
                    }
                } else {
                    this.isOnline = false;
                }
        }
        if (mounted) setState(() {});
    }

    Future getAnnouncement() async {
        Map<String, dynamic> data = jsonDecode((await NetUtils.get(API.announcement)).data);
        Configs.announcementsEnabled = data['enabled'];
        Configs.announcements = data['announcements'];
    }

    Future navigate() async {
        await getAnnouncement();
        Future.delayed(const Duration(seconds: 2), () {
            if (!isUserLogin) {
                try {
                    Constants.navigatorKey.currentState.pushAndRemoveUntil(PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 1000),
                        pageBuilder: (
                            BuildContext context,
                            Animation animation,
                            Animation secondaryAnimation
                        ) => FadeTransition(
                            opacity: animation,
                            child: LoginPage(),
                        ),
                    ), (Route<dynamic> route) => false);
                } catch (e) {}
            } else {
                try {
                    Constants.navigatorKey.currentState.pushAndRemoveUntil(MaterialPageRoute(
                        builder: (_) => MainPage(initIndex: widget.initIndex),
                    ), (Route<dynamic> route) => false);
                } catch (e) {
                    debugPrint("$e");
                }
            }
        });
    }

    Widget logo() => Container(
        margin: EdgeInsets.all(Constants.suSetSp(30.0)),
        child: Hero(
            tag: "Logo",
            child: SvgPicture.asset(
                "images/splash_page_logo.svg",
                width: Constants.suSetSp(150.0),
                height: Constants.suSetSp(150.0),
            ),
        ),
    );

    Widget get loginWidget => Column(
        children: <Widget>[
            Expanded(
                child: Center(
                    child: Container(
                        margin: EdgeInsets.only(bottom: Constants.suSetSp(10.0)),
                        width: Constants.suSetSp(28.0),
                        height: Constants.suSetSp(28.0),
                        child: Constants.progressIndicator(color: Colors.white),
                    ),
                ),
            ),
            Expanded(
                child: Center(
                    child: Text(
                        "正在登录",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.suSetSp(20.0),
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
                        size: Constants.suSetSp(40.0),
                    ),
                ),
            ),
            Expanded(
                child: Center(
                    child: Text(
                        "请检查联网状态",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.suSetSp(20.0),
                        ),
                    ),
                ),
            )
        ],
    );

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: ThemeUtils.currentThemeColor,
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        logo(),
                        AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                                top: Constants.suSetSp(showLoading && isOnline != null ? 20.0 : 0.0),
                            ),
                            height: Constants.suSetSp(showLoading && isOnline != null ? 80.0 : 0.0),
                            child: Center(
                                child: showLoading && isOnline != null ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[Expanded(
                                        child: isOnline ? loginWidget : warningWidget,
                                    )],
                                ) : null,
                            ),
                        )
                    ],
                ),
            ),
        );
    }
}
