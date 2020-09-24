///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-17 10:56
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:openjmu/constants/constants.dart';

class ThemesProvider with ChangeNotifier {
  ThemesProvider() {
    initTheme();
  }

  ThemeGroup _currentThemeGroup = defaultThemeGroup;

  ThemeGroup get currentThemeGroup => _currentThemeGroup;

  set currentThemeGroup(ThemeGroup value) {
    assert(value != null);
    if (_currentThemeGroup == value) return;
    _currentThemeGroup = value;
    notifyListeners();
  }

  bool _dark = false;

  bool get dark => _dark;

  set dark(bool value) {
    assert(value != null);
    if (_dark == value) return;
    HiveFieldUtils.setBrightnessDark(value);
    _dark = value;
    notifyListeners();
  }

  bool _amoledDark = false;

  bool get amoledDark => _amoledDark;

  set amoledDark(bool value) {
    assert(value != null);
    if (_amoledDark == value) return;
    HiveFieldUtils.setAMOLEDDark(value);
    _amoledDark = value;
    notifyListeners();
  }

  bool _platformBrightness = true;

  bool get platformBrightness => _platformBrightness;

  set platformBrightness(bool value) {
    assert(value != null);
    if (_platformBrightness == value) return;
    HiveFieldUtils.setBrightnessPlatform(value);
    _platformBrightness = value;
    notifyListeners();
  }

  Future<void> initTheme() async {
    int themeIndex = HiveFieldUtils.getColorThemeIndex();
    if (themeIndex >= supportThemeGroups.length) {
      HiveFieldUtils.setColorTheme(0);
      themeIndex = 0;
    }
    _currentThemeGroup = supportThemeGroups[themeIndex];
    _dark = HiveFieldUtils.getBrightnessDark();
    _amoledDark = HiveFieldUtils.getAMOLEDDark();
    _platformBrightness = HiveFieldUtils.getBrightnessPlatform();
  }

  void resetTheme() {
    HiveFieldUtils.setColorTheme(0);
    HiveFieldUtils.setAMOLEDDark(false);
    HiveFieldUtils.setBrightnessDark(false);
    HiveFieldUtils.setBrightnessPlatform(true);
    _currentThemeGroup = defaultThemeGroup;
    _dark = false;
    _amoledDark = false;
    _platformBrightness = true;
    notifyListeners();
  }

  void updateThemeColor(int themeIndex) {
    HiveFieldUtils.setColorTheme(themeIndex);
    _currentThemeGroup = supportThemeGroups[themeIndex];
    notifyListeners();
  }

  void setSystemUIDark(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  Future<void> syncFromCloudSettings(CloudSettingsModel model) async {
    _dark = model.isDark;
    _amoledDark = model.amoledDark;
    _platformBrightness = model.platformBrightness;
    await HiveFieldUtils.setBrightnessDark(_dark);
    await HiveFieldUtils.setAMOLEDDark(_amoledDark);
    await HiveFieldUtils.setBrightnessPlatform(_platformBrightness);
    notifyListeners();
  }

  ThemeData get lightTheme {
    final Color currentColor = currentThemeGroup.lightThemeColor;
    final Color primaryColor = currentThemeGroup.lightPrimaryColor;
    final Color backgroundColor = currentThemeGroup.lightBackgroundColor;
    final Color dividerColor = currentThemeGroup.lightDividerColor;
    final Color primaryTextColor = currentThemeGroup.lightPrimaryTextColor;
    final Color secondaryTextColor = currentThemeGroup.lightSecondaryTextColor;
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primaryColorBrightness: Brightness.light,
      primaryColorLight: primaryColor,
      primaryColorDark: backgroundColor,
      accentColor: currentColor,
      accentColorBrightness: Brightness.light,
      canvasColor: backgroundColor,
      dividerColor: dividerColor,
      scaffoldBackgroundColor: backgroundColor,
      bottomAppBarColor: primaryColor,
      cardColor: primaryColor,
      highlightColor: Colors.transparent,
      splashFactory: const NoSplashFactory(),
      toggleableActiveColor: currentColor,
      cursorColor: currentColor,
      textSelectionColor: currentColor.withAlpha(100),
      textSelectionHandleColor: currentColor,
      indicatorColor: currentColor,
      appBarTheme: AppBarTheme(brightness: Brightness.light, elevation: 0),
      iconTheme: IconThemeData(color: secondaryTextColor),
      primaryIconTheme: IconThemeData(color: secondaryTextColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: primaryColor,
        backgroundColor: currentColor,
      ),
      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primaryTextColor,
        unselectedLabelColor: primaryTextColor,
      ),
      colorScheme: ColorScheme(
        primary: currentColor,
        primaryVariant: currentColor,
        secondary: currentColor,
        secondaryVariant: currentColor,
        surface: Colors.white,
        background: backgroundColor,
        error: defaultLightColor,
        onPrimary: currentColor,
        onSecondary: currentColor,
        onSurface: Colors.white,
        onBackground: backgroundColor,
        onError: defaultLightColor,
        brightness: Brightness.light,
      ),
      buttonColor: currentColor,
      textTheme: TextTheme(
        bodyText1: TextStyle(color: secondaryTextColor),
        bodyText2: TextStyle(color: primaryTextColor),
        button: TextStyle(color: primaryTextColor),
        caption: TextStyle(color: secondaryTextColor),
        subtitle1: TextStyle(color: secondaryTextColor),
        headline1: TextStyle(color: secondaryTextColor),
        headline2: TextStyle(color: secondaryTextColor),
        headline3: TextStyle(color: secondaryTextColor),
        headline4: TextStyle(color: secondaryTextColor),
        headline5: TextStyle(color: primaryTextColor),
        headline6: TextStyle(color: primaryTextColor),
        overline: TextStyle(color: primaryTextColor),
      ),
    );
  }

  ThemeData get darkTheme {
    final Color currentColor = currentThemeGroup.darkThemeColor;
    final Color primaryColor = amoledDark
        ? currentThemeGroup.darkerPrimaryColor
        : currentThemeGroup.darkPrimaryColor;
    final Color backgroundColor = amoledDark
        ? currentThemeGroup.darkerBackgroundColor
        : currentThemeGroup.darkBackgroundColor;
    final Color dividerColor = amoledDark
        ? currentThemeGroup.darkerDividerColor
        : currentThemeGroup.darkDividerColor;
    final Color primaryTextColor = amoledDark
        ? currentThemeGroup.darkerPrimaryTextColor
        : currentThemeGroup.darkPrimaryTextColor;
    final Color secondaryTextColor = amoledDark
        ? currentThemeGroup.darkerSecondaryTextColor
        : currentThemeGroup.darkSecondaryTextColor;
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primaryColorBrightness: Brightness.dark,
      primaryColorLight: backgroundColor,
      primaryColorDark: primaryColor,
      accentColor: currentColor,
      accentColorBrightness: Brightness.dark,
      canvasColor: backgroundColor,
      dividerColor: dividerColor,
      scaffoldBackgroundColor: backgroundColor,
      bottomAppBarColor: primaryColor,
      cardColor: primaryColor,
      highlightColor: Colors.transparent,
      splashFactory: const NoSplashFactory(),
      toggleableActiveColor: currentColor,
      cursorColor: currentColor,
      textSelectionColor: currentColor.withAlpha(100),
      textSelectionHandleColor: currentColor,
      indicatorColor: currentColor,
      appBarTheme: AppBarTheme(brightness: Brightness.dark, elevation: 0),
      iconTheme: IconThemeData(color: secondaryTextColor),
      primaryIconTheme: IconThemeData(color: secondaryTextColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.black,
        backgroundColor: currentColor,
      ),
      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primaryTextColor,
        unselectedLabelColor: primaryTextColor,
      ),
      colorScheme: ColorScheme(
        primary: currentColor,
        primaryVariant: currentColor,
        secondary: currentColor,
        secondaryVariant: currentColor,
        surface: primaryColor,
        background: backgroundColor,
        error: defaultLightColor,
        onPrimary: currentColor,
        onSecondary: currentColor,
        onSurface: primaryColor,
        onBackground: backgroundColor,
        onError: defaultLightColor,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        bodyText1: TextStyle(color: secondaryTextColor),
        bodyText2: TextStyle(color: primaryTextColor),
        button: TextStyle(color: primaryTextColor),
        caption: TextStyle(color: secondaryTextColor),
        subtitle1: TextStyle(color: secondaryTextColor),
        headline1: TextStyle(color: secondaryTextColor),
        headline2: TextStyle(color: secondaryTextColor),
        headline3: TextStyle(color: secondaryTextColor),
        headline4: TextStyle(color: secondaryTextColor),
        headline5: TextStyle(color: primaryTextColor),
        headline6: TextStyle(color: primaryTextColor),
        overline: TextStyle(color: primaryTextColor),
      ),
      buttonColor: currentColor,
    );
  }
}

final List<ThemeGroup> supportThemeGroups = <ThemeGroup>[
  defaultThemeGroup, // This is the default theme group.
  ThemeGroup(
    lightThemeColor: const Color(0xfff06292),
    darkThemeColor: const Color(0xfff06292),
  ),
  ThemeGroup(
    lightThemeColor: const Color(0xffab47bc),
    darkThemeColor: const Color(0xffab47bc),
  ),
  ThemeGroup(
    lightThemeColor: const Color(0xff1e88e5),
    darkThemeColor: const Color(0xff1e88e5),
  ),
  ThemeGroup(
    lightThemeColor: const Color(0xff00bcd4),
    darkThemeColor: const Color(0xff00bcd4),
  ),
  ThemeGroup(
    lightThemeColor: const Color(0xff009688),
    darkThemeColor: const Color(0xff009688),
  ),
  ThemeGroup(
    lightThemeColor: const Color(0xfffdd835),
    darkThemeColor: const Color(0xfffdd835),
  ),
  ThemeGroup(
    lightThemeColor: const Color(0xffff7043),
    darkThemeColor: const Color(0xffff7043),
  ),
];
