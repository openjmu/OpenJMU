import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity/connectivity.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/LoginPage.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


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
            ..on<TicketGotEvent>().listen((event) {
                debugPrint("Ticket Got.");
                if (this.mounted) {
                    setState(() {
                        this.isUserLogin = true;
                        navigate();
                    });
                }
            })
            ..on<TicketFailedEvent>().listen((event) {
                if (this.mounted) {
                    setState(() {
                        this.isUserLogin = false;
                        navigate();
                    });
                }
            });
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        ThemeUtils.setDark(true);
        ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
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
            setState(() {
                if (event.type != ConnectivityResult.none) {
                    this.isOnline = true;
                    DataUtils.isLogin().then((isLogin) {
                        if (isLogin) {
                            DataUtils.recoverLoginInfo();
                        } else {
                            Constants.eventBus.fire(TicketFailedEvent());
                        }
                    });
                } else {
                    this.isOnline = false;
                }
            });
        }
    }

    void navigate() {
        Future.delayed(const Duration(seconds: 2), () {
            if (!isUserLogin) {
                try {
                    Navigator.of(context).pushAndRemoveUntil(PageRouteBuilder(
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
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
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
            child: Image.asset(
                'images/ic_jmu_logo_trans.png',
                width: Constants.suSetSp(120.0),
                height: Constants.suSetSp(120.0),
            ),
        ),
    );

    Widget loginWidget() => Column(
        children: <Widget>[
            Container(
                margin: EdgeInsets.only(bottom: Constants.suSetSp(20.0)),
                width: Constants.suSetSp(24.0),
                height: Constants.suSetSp(24.0),
                child: Platform.isAndroid ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ) : CupertinoActivityIndicator(),
            ),
            Text(
                "正在登录",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Constants.suSetSp(20.0),
                ),
            )
        ],
    );

    Widget warningWidget() => Column(
        children: <Widget>[
            Container(
                margin: EdgeInsets.only(bottom: Constants.suSetSp(20.0)),
                height: Constants.suSetSp(24.0),
                child: Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: Constants.suSetSp(40.0),
                ),
            ),
            Text(
                "请检查联网状态",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Constants.suSetSp(20.0),
                ),
            )
        ],
    );

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: ThemeUtils.currentThemeColor,
            body: Padding(
                padding: EdgeInsets.only(bottom: Constants.suSetSp(100.0)),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            logo(),
                            Constants.emptyDivider(height: Constants.suSetSp(20.0)),
                            if (showLoading && isOnline != null)
                                isOnline ? loginWidget() : warningWidget(),
                            if (!showLoading) SizedBox(height: Constants.suSetSp(68.0)),
                        ],
                    ),
                ),
            ),
        );
    }
}
