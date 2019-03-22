import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/Constants.dart';
import '../events/TicketGotEvent.dart';
import '../events/TicketFailedEvent.dart';
import '../utils/DataUtils.dart';
import '../utils/ThemeUtils.dart';
import 'MainPage.dart';
import 'NewLoginPage.dart';

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
      this.isUserLogin = true;
      navigate();
    });
    Constants.eventBus.on<TicketFailedEvent>().listen((event) {
      this.isUserLogin = false;
      navigate();
    });
  }

  void navigate() {
    timer = new Timer(const Duration(milliseconds: 1500), () {
      if (!isUserLogin) {
        try {
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => new NewLoginPage()
            ),
//                    (Route route) => route == null
          );
        } catch (e) {}
      } else {
        try {
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => new MainPage()
            ),
//                    (Route route) => route == null
          );
        } catch (e) {}
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Padding buildLogo() {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Image.asset(
          './images/ic_jmu_logo.png',
          width: 100.0,
          height: 100.0,
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
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomCenter,
                          colors: const <Color>[
                            ThemeUtils.defaultColor,
                            Colors.redAccent
                          ],
                        ),
                      )
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                      top: 150.0,
                    ),
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 50.0),
                      children: <Widget>[
                        SizedBox(height: 120.0),
                        buildLogo(),
                        SizedBox(height: 30.0),
                        new Text(
                            "集小通",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 50.0,
//                    letterSpacing: 6.0
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

