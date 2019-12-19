///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-17 10:56
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:OpenJMU/constants/Constants.dart';

class ThemesProvider with ChangeNotifier {
  Color _currentColor = defaultColor;
  Color get currentColor => _currentColor;
  set currentColor(Color value) {
    if (_currentColor == value) return;
    _currentColor = value;
    notifyListeners();
  }

  bool _dark = false;
  bool get dark => _dark;
  set dark(bool value) {
    if (_dark == value) return;
    DataUtils.setBrightnessDark(value);
    _dark = value;
    notifyListeners();
  }

  // ignore: non_constant_identifier_names
  bool _AMOLEDDark = false;
  // ignore: non_constant_identifier_names
  bool get AMOLEDDark => _AMOLEDDark;
  // ignore: non_constant_identifier_names
  set AMOLEDDark(bool value) {
    if (_AMOLEDDark == value) return;
    DataUtils.setAMOLEDDark(value);
    _AMOLEDDark = value;
    notifyListeners();
  }

  bool _platformBrightness = false;
  bool get platformBrightness => _platformBrightness;
  set platformBrightness(bool value) {
    if (_platformBrightness == value) return;
    DataUtils.setBrightnessPlatform(value);
    _platformBrightness = value;
    notifyListeners();
  }

  void initTheme() {
    _currentColor = supportColors[DataUtils.getColorThemeIndex()];
    _dark = DataUtils.getBrightnessDark();
    _AMOLEDDark = DataUtils.getAMOLEDDark();
    _platformBrightness = DataUtils.getBrightnessPlatform();
  }

  void resetTheme() {
    _currentColor = defaultColor;
    _dark = false;
    _AMOLEDDark = false;
    _platformBrightness = false;
    notifyListeners();
  }

  void updateThemeColor(int themeIndex) {
    DataUtils.setColorTheme(themeIndex);
    currentColor = supportColors[themeIndex];
    notifyListeners();
  }

  void setSystemUIDark(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  ThemeData get lightTheme => ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        primaryColorBrightness: Brightness.light,
        primaryColorLight: Colors.white,
        primaryColorDark: Colors.white,
        accentColor: currentColor,
        accentColorBrightness: Brightness.light,
        canvasColor: Colors.grey[200],
        scaffoldBackgroundColor: Colors.white,
        bottomAppBarColor: Colors.white,
        cardColor: Colors.white,
        highlightColor: Colors.transparent,
        splashFactory: const NoSplashFactory(),
        toggleableActiveColor: currentColor,
        cursorColor: currentColor,
        textSelectionColor: currentColor.withAlpha(100),
        textSelectionHandleColor: currentColor,
        indicatorColor: currentColor,
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          elevation: 1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        primaryIconTheme: IconThemeData(
          color: Colors.black,
        ),
        tabBarTheme: TabBarTheme(
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
        ),
        buttonColor: currentColor,
      );

  ThemeData get darkTheme => ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: AMOLEDDark ? Colors.black : Colors.grey[900],
        primaryColorBrightness: Brightness.dark,
        primaryColorLight: AMOLEDDark ? Colors.black : Colors.grey[900],
        primaryColorDark: AMOLEDDark ? Colors.black : Colors.grey[900],
        accentColor: currentColor,
        accentColorBrightness: Brightness.dark,
        canvasColor: AMOLEDDark ? Color(0xFF111111) : Colors.grey[850],
        scaffoldBackgroundColor: AMOLEDDark ? Colors.black : Colors.grey[900],
        bottomAppBarColor: AMOLEDDark ? Colors.black : Colors.grey[900],
        cardColor: AMOLEDDark ? Colors.black : Colors.grey[900],
        highlightColor: Colors.transparent,
        splashFactory: const NoSplashFactory(),
        toggleableActiveColor: currentColor,
        cursorColor: currentColor,
        textSelectionColor: currentColor.withAlpha(100),
        textSelectionHandleColor: currentColor,
        indicatorColor: currentColor,
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          elevation: 0,
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[350],
        ),
        primaryIconTheme: IconThemeData(
          color: Colors.grey[350],
        ),
        tabBarTheme: TabBarTheme(
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.grey[200],
          unselectedLabelColor: Colors.grey[200],
        ),
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.grey[350],
          ),
          body1: TextStyle(
            color: Colors.grey[350],
          ),
          body2: TextStyle(
            color: Colors.grey[500],
          ),
          button: TextStyle(
            color: Colors.grey[350],
          ),
          caption: TextStyle(
            color: Colors.grey[500],
          ),
          subhead: TextStyle(
            color: Colors.grey[500],
          ),
          display4: TextStyle(
            color: Colors.grey[500],
          ),
          display3: TextStyle(
            color: Colors.grey[500],
          ),
          display2: TextStyle(
            color: Colors.grey[500],
          ),
          display1: TextStyle(
            color: Colors.grey[500],
          ),
          headline: TextStyle(
            color: Colors.grey[350],
          ),
          overline: TextStyle(
            color: Colors.grey[350],
          ),
        ),
        buttonColor: currentColor,
      );
}

/// Getter for screen's brightness.
Brightness get _defaultBrightness =>
    Screen.mediaQuery.platformBrightness ?? Brightness.light;
Brightness get _configuredBrightness =>
    DataUtils.getBrightnessDark() ? Brightness.dark : Brightness.light;
Brightness get brightness => DataUtils.getBrightnessPlatform()
    ? _defaultBrightness
    : _configuredBrightness;
bool get isDark => brightness == Brightness.dark;

const defaultColor = Color(0xFFE5322D);

final supportColors = <Color>[
  Color(0xFFE5322D),
  Colors.red[900],
  Colors.red[500],
  Colors.red[300],
  Colors.pink[900],
  Colors.pink[700],
  Colors.pink[500],
  Colors.pink[400],
  Colors.purple[900],
  Colors.purple[700],
  Colors.purple[500],
  Colors.purple[400],
  Colors.deepPurple[900],
  Colors.deepPurple[700],
  Colors.deepPurple[500],
  Colors.deepPurple[400],
  Colors.indigo[900],
  Colors.indigo[700],
  Colors.indigo[500],
  Colors.indigo[400],
  Colors.blue[900],
  Colors.blue[700],
  Colors.blue[500],
  Colors.blue[400],
  Colors.lightBlue[900],
  Colors.lightBlue[700],
  Colors.lightBlue[500],
  Colors.lightBlue[400],
  Colors.cyan[900],
  Colors.cyan[700],
  Colors.cyan[500],
  Colors.cyan[400],
  Colors.teal[900],
  Colors.teal[700],
  Colors.teal[500],
  Colors.teal[400],
  Colors.green[900],
  Colors.green[700],
  Colors.green[500],
  Colors.green[400],
  Colors.lightGreen[900],
  Colors.lightGreen[700],
  Colors.lightGreen[500],
  Colors.lightGreen[400],
  Colors.lime[900],
  Colors.lime[700],
  Colors.lime[500],
  Colors.lime[400],
  Colors.yellow[900],
  Colors.yellow[700],
  Colors.yellow[500],
  Colors.yellow[400],
  Colors.orange[900],
  Colors.orange[700],
  Colors.orange[500],
  Colors.orange[400],
  Colors.deepOrange[900],
  Colors.deepOrange[700],
  Colors.deepOrange[500],
  Colors.deepOrange[400],
  Colors.grey[800],
  Colors.grey[700],
];
