///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-17 10:56
///
part of 'providers.dart';

class ThemesProvider with ChangeNotifier {
  ThemesProvider() {
    initTheme();
  }

  ThemeGroup _currentThemeGroup = defaultThemeGroup;

  ThemeGroup get currentThemeGroup => _currentThemeGroup;

  set currentThemeGroup(ThemeGroup value) {
    assert(value != null);
    if (_currentThemeGroup == value) {
      return;
    }
    _currentThemeGroup = value;
    notifyListeners();
  }

  bool _dark = false;

  bool get dark => _dark;

  set dark(bool value) {
    assert(value != null);
    if (_dark == value) {
      return;
    }
    HiveFieldUtils.setBrightnessDark(value);
    _dark = value;
    notifyListeners();
  }

  bool _platformBrightness = true;

  bool get platformBrightness => _platformBrightness;

  set platformBrightness(bool value) {
    assert(value != null);
    if (_platformBrightness == value) {
      return;
    }
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
    _platformBrightness = HiveFieldUtils.getBrightnessPlatform();
  }

  void resetTheme() {
    HiveFieldUtils.setColorTheme(0);
    HiveFieldUtils.setBrightnessDark(false);
    HiveFieldUtils.setBrightnessPlatform(true);
    _currentThemeGroup = defaultThemeGroup;
    _dark = false;
    _platformBrightness = true;
    notifyListeners();
  }

  void updateThemeColor(int themeIndex) {
    HiveFieldUtils.setColorTheme(themeIndex);
    _currentThemeGroup = supportThemeGroups[themeIndex];
    notifyListeners();
    showToast('已更换主题色');
  }

  void setSystemUIDark(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  Future<void> syncFromCloudSettings(CloudSettingsModel model) async {
    _dark = model.isDark;
    _platformBrightness = model.platformBrightness;
    await HiveFieldUtils.setBrightnessDark(_dark);
    await HiveFieldUtils.setBrightnessPlatform(_platformBrightness);
    notifyListeners();
  }

  ThemeData get lightTheme {
    final Color currentColor = currentThemeGroup.lightThemeColor;
    final Color primaryColor = currentThemeGroup.lightPrimaryColor;
    final Color backgroundColor = currentThemeGroup.lightBackgroundColor;
    final Color iconColor = currentThemeGroup.lightIconUnselectedColor;
    final Color dividerColor = currentThemeGroup.lightDividerColor;
    final Color primaryTextColor = currentThemeGroup.lightPrimaryTextColor;
    final Color secondaryTextColor = currentThemeGroup.lightSecondaryTextColor;
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primaryColorBrightness: Brightness.light,
      primaryColorLight: primaryColor,
      primaryColorDark: backgroundColor,
      canvasColor: backgroundColor,
      dividerColor: dividerColor,
      scaffoldBackgroundColor: backgroundColor,
      bottomAppBarColor: primaryColor,
      cardColor: primaryColor,
      highlightColor: Colors.transparent,
      splashFactory: const NoSplashFactory(),
      toggleableActiveColor: currentColor,
      indicatorColor: currentColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        color: primaryColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      ),
      iconTheme: IconThemeData(color: iconColor),
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
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: currentColor,
        selectionColor: currentColor.withOpacity(0.5),
        selectionHandleColor: currentColor,
      ),
    );
  }

  ThemeData get darkTheme {
    final Color currentColor = currentThemeGroup.darkThemeColor;
    final Color primaryColor = currentThemeGroup.darkPrimaryColor;
    final Color backgroundColor = currentThemeGroup.darkBackgroundColor;
    final Color iconColor = currentThemeGroup.darkIconUnselectedColor;
    final Color dividerColor = currentThemeGroup.darkDividerColor;
    final Color primaryTextColor = currentThemeGroup.darkPrimaryTextColor;
    final Color secondaryTextColor = currentThemeGroup.darkSecondaryTextColor;
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primaryColorBrightness: Brightness.dark,
      primaryColorLight: backgroundColor,
      primaryColorDark: primaryColor,
      canvasColor: backgroundColor,
      dividerColor: dividerColor,
      scaffoldBackgroundColor: backgroundColor,
      bottomAppBarColor: primaryColor,
      cardColor: primaryColor,
      highlightColor: Colors.transparent,
      splashFactory: const NoSplashFactory(),
      toggleableActiveColor: currentColor,
      indicatorColor: currentColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        color: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
      ),
      iconTheme: IconThemeData(color: iconColor),
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
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: currentColor,
        selectionColor: currentColor.withOpacity(0.5),
        selectionHandleColor: currentColor,
      ),
    );
  }
}

const List<ThemeGroup> supportThemeGroups = <ThemeGroup>[
  defaultThemeGroup, // This is the default theme group.
  ThemeGroup(
    lightThemeColor: Color(0xfff06292),
    darkThemeColor: Color(0xffcc537c),
  ),
  ThemeGroup(
    lightThemeColor: Color(0xffba68c8),
    darkThemeColor: Color(0xff9e58aa),
  ),
  ThemeGroup(
    lightThemeColor: Color(0xff2196f3),
    darkThemeColor: Color(0xff1c7ece),
  ),
  ThemeGroup(
    lightThemeColor: Color(0xff00bcd4),
    darkThemeColor: Color(0xff00a0b4),
  ),
  ThemeGroup(
    lightThemeColor: Color(0xff26a69a),
    darkThemeColor: Color(0xff208d83),
  ),
  ThemeGroup(
    lightThemeColor: Color(0xffffeb3b),
    darkThemeColor: Color(0xffd9c832),
    lightButtonTextColor: Colors.black,
    darkButtonTextColor: Colors.black,
  ),
  ThemeGroup(
    lightThemeColor: Color(0xffff7043),
    darkThemeColor: Color(0xffd95f39),
  ),
];
