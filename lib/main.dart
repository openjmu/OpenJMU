import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/LogoutEvent.dart';
import 'package:OpenJMU/events/ChangeBrightnessEvent.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

// Routes Pages
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/pages/LoginPage.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/ChangeThemePage.dart';
import 'package:OpenJMU/pages/PublishPostPage.dart';
import 'package:OpenJMU/pages/Test.dart';

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

  @override
  void initState() {
    super.initState();
    listenToBrightness();
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
            ThemeUtils.currentBrightness = Brightness.dark;
            ThemeUtils.currentPrimaryColor = Colors.grey[850];
            currentBrightness = Brightness.dark;
            currentPrimaryColor = Colors.grey[850];
          });
        } else {
          setState(() {
            ThemeUtils.currentBrightness = Brightness.light;
            ThemeUtils.currentPrimaryColor = Colors.white;
            currentBrightness = Brightness.light;
            currentPrimaryColor = Colors.white;
          });
        }
      }
    });
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      setState(() {
        ThemeUtils.currentBrightness = Brightness.light;
        ThemeUtils.currentPrimaryColor = Colors.white;
        currentBrightness = Brightness.light;
        currentPrimaryColor = Colors.white;
      });
    });
    Constants.eventBus.on<ChangeBrightnessEvent>().listen((event) {
      setState(() {
        ThemeUtils.currentBrightness = event.brightness;
        ThemeUtils.currentPrimaryColor = event.primaryColor;
        currentBrightness = event.brightness;
        currentPrimaryColor = event.primaryColor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: <String,WidgetBuilder>{
          "/splash": (BuildContext context) => new SplashPage(),
          "/login": (BuildContext context) => new LoginPage(),
          "/home": (BuildContext context) => new MainPage(),
          "/changeTheme": (BuildContext context) => new ChangeThemePage(),
          "/publishPost": (BuildContext context) => new PublishPostPage(),
          "/test": (BuildContext context) => new TestPage(),
        },
        title: "OpenJMU",
        theme: new ThemeData(
          accentColor: currentPrimaryColor,
          primaryColor: currentPrimaryColor,
          primaryColorBrightness: Brightness.dark,
          primaryIconTheme: new IconThemeData(color: currentPrimaryColor),
          brightness: currentBrightness,
        ),
        home: new SplashPage()
    );
  }
}
