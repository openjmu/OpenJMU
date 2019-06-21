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
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


class SplashPage extends StatefulWidget {
    final int initIndex;

    SplashPage({Key key, this.initIndex}) : super(key: key);

    @override
    SplashState createState() => SplashState();
}

class SplashState extends State<SplashPage> {
    bool isOnline, isUserLogin = false, showLoading = false;

    @override
    void initState() {
        super.initState();
        if (NetUtils.currentConnectivity != null && NetUtils.currentConnectivity != ConnectivityResult.none) {
            debugPrint("${NetUtils.currentConnectivity}");
            this.isOnline = true;
        } else {
            DataUtils.isLogin().then((isLogin) {
                if (isLogin) {
                    DataUtils.getTicket();
                } else {
                    Constants.eventBus.fire(new TicketFailedEvent());
                }
            });
        }
        Future.delayed(Duration(seconds: 5), () {
            if (this.mounted) setState(() {showLoading = true;});
        });
        Constants.eventBus
            ..on<ConnectivityChangeEvent>().listen((event) {
                if (this.mounted) checkOnline(event);
            })
            ..on<TicketGotEvent>().listen((event) {
                print("Ticket Got.");
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

    void checkOnline(event) {
        setState(() {
            if (event.type != ConnectivityResult.none) {
                this.isOnline = true;
            } else {
                this.isOnline = false;
            }
        });
    }

    void navigate() {
        Future.delayed(const Duration(seconds: 2), () {
            if (!isUserLogin) {
                try {
                    Navigator.of(context).pushAndRemoveUntil(PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 500),
                        pageBuilder: (
                                BuildContext context,
                                Animation animation,
                                Animation secondaryAnimation,
                                ) {
                            return FadeTransition(
                                opacity: animation,
                                child: LoginPage(),
                            );
                        },
                    ), (Route<dynamic> route) => false);
                } catch (e) {}
            } else {
                try {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                        builder: (_) => MainPage(initIndex: widget.initIndex),
                    ), (Route<dynamic> route) => false);
                } catch (e) {
                    print(e);
                }
            }
        });
    }

    Hero buildLogo() {
        return Hero(
            tag: "Logo",
            child: Container(
                margin: EdgeInsets.all(Constants.suSetSp(30.0)),
                child: Image.asset(
                    'images/ic_jmu_logo_trans.png',
                    width: Constants.suSetSp(120.0),
                    height: Constants.suSetSp(120.0),
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Builder(
                builder: (context) => Stack(
                    children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
//                                gradient: LinearGradient(
//                                    begin: Alignment.topLeft,
//                                    end: Alignment.bottomRight,
//                                    colors: <Color>[
//                                        ThemeUtils.currentColorTheme,
//                                        Colors.red
//                                    ],
//                                ),
                                color: ThemeUtils.currentThemeColor,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.only(bottom: Constants.suSetSp(100.0)),
                                        child: Center(
                                            child: Column(
                                                children: <Widget>[
                                                    buildLogo(),
                                                    SizedBox(height: Constants.suSetSp(20.0)),
                                                    if (showLoading)
                                                        if (isOnline != null && isOnline) Column(
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
                                                        ) else if (isOnline != null && !isOnline) Column(
                                                            children: <Widget>[
                                                                Container(
                                                                    margin: EdgeInsets.only(bottom: Constants.suSetSp(20.0)),
                                                                    width: Constants.suSetSp(30.0),
                                                                    height: Constants.suSetSp(30.0),
                                                                    child: Icon(
                                                                        Icons.warning,
                                                                        color: Colors.white,
                                                                        size: Constants.suSetSp(24.0),
                                                                    ),
                                                                ),
                                                                Text(
                                                                    "请检查联网状态",
                                                                    style: TextStyle(color: Colors.white, fontSize: Constants.suSetSp(20.0)),
                                                                )
                                                            ],
                                                        ) else SizedBox(height: Constants.suSetSp(68.0))
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
