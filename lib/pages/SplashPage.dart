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
  SplashState createState() => new SplashState();
}

class SplashState extends State<SplashPage> {
  Timer timer;
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

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void navigate() {
    timer = new Timer(const Duration(milliseconds: 2000), () {
      if (!isUserLogin) {
        try {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
                return new FadeTransition(
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
    return new Hero(
        tag: "Logo",
        child: Container(
            margin: EdgeInsets.all(30.0),
            child: new Image.asset(
              'images/ic_jmu_logo_trans.png',
              width: 120.0,
              height: 120.0,
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
      return new Scaffold(
          body: Builder(
              builder: (context) =>
              new Stack(
                  children: <Widget>[
                    new Container(
                      decoration: BoxDecoration(
//                      gradient: const LinearGradient(
//                        begin: Alignment.topLeft,
//                        end: Alignment.bottomCenter,
//                        colors: const <Color>[
//                          ThemeUtils.defaultColor,
//                          Colors.red
//                        ],
//                      ),
                          color: ThemeUtils.currentColorTheme
                      ),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                              padding: const EdgeInsets.all(10.0),
                              child: new Center(
                                child: new Column(
                                  children: <Widget>[
                                    buildLogo(),
//                                  new Text(
//                                      "OpenJMU",
//                                      textAlign: TextAlign.center,
//                                      style: new TextStyle(
//                                        color: Colors.white,
//                                        fontSize: 48.0,
//                                        letterSpacing: 4.0
//                                      )
//                                  ),
                                    SizedBox(height: 90.0),
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

