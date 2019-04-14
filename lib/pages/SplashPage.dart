import 'dart:async';
import 'package:flutter/material.dart';
import 'package:OpenJMU/constants/Constants.dart';
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
  Color currentThemeColor;

  @override
  void initState() {
    super.initState();
    DataUtils.getColorThemeIndex().then((index) {
      setState(() {
        if (index != null) {
          currentThemeColor = ThemeUtils.supportColors[index];
        } else {
          currentThemeColor = ThemeUtils.defaultColor;
        }
      });
    });
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
    timer.cancel();
    super.dispose();
  }

  void navigate() {
    timer = new Timer(const Duration(milliseconds: 2000), () {
      if (!isUserLogin) {
        try {
          Navigator.of(context).pushReplacementNamed("/login");
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
        child: Padding(
            padding: EdgeInsets.all(30.1),
            child: new Image.asset(
              './images/ic_jmu_logo_trans.png',
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
                          color: currentThemeColor
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

