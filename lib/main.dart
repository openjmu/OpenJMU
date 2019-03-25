import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jxt/pages/SplashPage.dart';
import 'package:jxt/utils/ThemeUtils.dart';

void main() {
  runApp(new JMUAppClient());
}

class JMUAppClient extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new JMUAppClientState();
}

class JMUAppClientState extends State<JMUAppClient> {
  bool isUserLogin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "集小通",
        theme: new ThemeData(
          accentColor: ThemeUtils.currentColorTheme,
//          primaryColor: ThemeUtils.currentColorTheme,
//          splashColor: ThemeUtils.currentColorTheme,
          primaryIconTheme: const IconThemeData(color: Colors.white),
          brightness: Brightness.light,
        ),
        home: new SplashPage()
    );
  }

}
