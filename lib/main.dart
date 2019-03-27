import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jxt/constants/Constants.dart';
import 'package:jxt/events/ChangeBrightnessEvent.dart';
import 'package:jxt/pages/SplashPage.dart';
import 'package:jxt/utils/DataUtils.dart';

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
    DataUtils.getBrightness().then((isDark) {
      if (isDark == null) {
        DataUtils.setBrightness(false).then((whatever) {
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
        title: "集小通",
        theme: new ThemeData(
          accentColor: currentPrimaryColor,
          primaryColor: currentPrimaryColor,
          primaryColorBrightness: Brightness.dark,
//          splashColor: currentPrimaryColor,
          primaryIconTheme: new IconThemeData(color: currentPrimaryColor),
          brightness: currentBrightness,
        ),
        home: new SplashPage()
    );
  }


}
