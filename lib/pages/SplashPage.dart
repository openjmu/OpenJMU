import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/LoginPage.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashPage> {
  bool isUserLogin = false;

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      if (isLogin) {
        DataUtils.getTicket();
      } else {
        Constants.eventBus.fire(new TicketFailedEvent());
      }
    });
    Constants.eventBus.on<TicketGotEvent>().listen((event) {
      setState(() {
        this.isUserLogin = true;
        navigate();
      });
    });
    Constants.eventBus.on<TicketFailedEvent>().listen((event) {
      setState(() {
        this.isUserLogin = false;
        navigate();
      });
    });
  }


  void navigate() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!isUserLogin) {
        try {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
                return FadeTransition(
                    opacity: animation,
                    child: LoginPage()
                );
              })
          );
        } catch (e) {}
      } else {
        try {
          Navigator.of(context).pushReplacementNamed("/home");
        } catch (e) {}
      }
    });
  }

  Hero buildLogo() {
    return Hero(
        tag: "Logo",
        child: Container(
            margin: EdgeInsets.all(30.0),
            child: Image.asset(
              'images/ic_jmu_logo_trans.png',
              width: 120.0,
              height: 120.0,
            )
        )
    );
  }

  Text buildTitle() {
    return Text(
        "OpenJMU",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 54.0,
            letterSpacing: 4.0,
            fontFamily: "chocolate"
        )
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          body: Builder(
              builder: (context) =>
              Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
//                        gradient: LinearGradient(
//                          begin: Alignment.topLeft,
//                          end: Alignment.bottomRight,
//                          colors: <Color>[
//                            ThemeUtils.currentColorTheme,
//                            Colors.red
//                          ],
//                        ),
                        color: ThemeUtils.currentColorTheme
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.only(bottom: 100.0),
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    buildLogo(),
                                    buildTitle()
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ]
              )
          )
      );
  }
}

