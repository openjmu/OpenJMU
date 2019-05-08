import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/RouteUtils.dart';

void main() {
  runApp(JMUAppClient());
}

class JMUAppClient extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JMUAppClientState();
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
    DataUtils.getHomeSplashIndex().then((index) {
      Constants.homeSplashIndex = index ?? 0;
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          currentThemeColor = event.color;
        });
      }
    });
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      setState(() {
        currentBrightness = Brightness.light;
        currentPrimaryColor = Colors.white;
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: RouteUtils.routes,
      title: "OpenJMU",
      theme: ThemeData(
          platform: TargetPlatform.iOS,
          brightness: currentBrightness,
          accentColor: currentThemeColor,
          buttonColor: currentThemeColor,
          cursorColor: currentThemeColor,
          primaryColor: currentThemeColor,
          primaryColorLight: currentThemeColor,
          primaryColorDark: currentThemeColor,
          primaryColorBrightness: currentBrightness,
          textSelectionColor: currentThemeColor,
          textSelectionHandleColor: currentThemeColor,
          primaryIconTheme: IconThemeData(color: Colors.white),
          appBarTheme: AppBarTheme(
              color: currentThemeColor,
              brightness: Brightness.dark,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white)
          ),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              splashColor: currentThemeColor,
              highlightColor: currentThemeColor
          )
      ),
      home: SplashPage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('zh', 'CN'),
        const Locale('en', 'US')
      ],
    );
  }
}
