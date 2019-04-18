import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/RouteUtils.dart';

void main() {
  runApp(new JMUAppClient());
}

class JMUAppClient extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new JMUAppClientState();
}

class JMUAppClientState extends State<JMUAppClient> {
  bool isUserLogin = false;

  Brightness currentBrightness;
  Color currentPrimaryColor;
  Color currentThemeColor;

  @override
  void initState() {
    super.initState();
    listenToBrightness();
    NetUtils.initConfig();
    DataUtils.getColorThemeIndex().then((index) {
      if (this.mounted && index != null) {
        setState(() {
          ThemeUtils.currentColorTheme = ThemeUtils.supportColors[index];
        });
        Constants.eventBus.fire(new ChangeThemeEvent(ThemeUtils.supportColors[index]));
      }
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        currentThemeColor = event.color;
      });
    });

    Constants.eventBus.on<LogoutEvent>().listen((event) {
      setState(() {
        currentBrightness = Brightness.light;
        currentPrimaryColor = Colors.white;
        currentThemeColor = ThemeUtils.defaultColor;
        print(currentThemeColor);
      });
    });
  }

  // 监听夜间模式变化
  void listenToBrightness() {
    DataUtils.getBrightnessDark().then((isDark) {
      if (isDark == null) {
        DataUtils.setBrightnessDark(false).then((whatever) {
          setState(() {
            currentBrightness = Brightness.light;
            currentPrimaryColor = Colors.white;
          });
        });
      } else {
        if (isDark) {
          setState(() {
            currentBrightness = Brightness.dark;
            currentPrimaryColor = Colors.grey[850];
          });
        } else {
          setState(() {
            currentBrightness = Brightness.light;
            currentPrimaryColor = Colors.white;
          });
        }
      }
    });
    Constants.eventBus.on<ChangeBrightnessEvent>().listen((event) {
      setState(() {
        currentBrightness = event.brightness;
        currentPrimaryColor = event.primaryColor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: RouteUtils.routes,
        title: "OpenJMU",
        theme: ThemeData(
          accentColor: currentThemeColor,
          primaryColor: currentThemeColor,
          primaryColorBrightness: currentBrightness,
          primaryIconTheme: IconThemeData(color: Colors.white),
          primarySwatch: Colors.red,
          brightness: currentBrightness,
          appBarTheme: AppBarTheme(
              color: currentThemeColor,
              brightness: ThemeUtils.currentBrightness
          )
        ),
        home: new SplashPage()
    );
  }
}
