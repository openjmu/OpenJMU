import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/widgets/NoScaleTextWidget.dart';
import 'package:OpenJMU/OpenJMU_route.dart';
import 'package:OpenJMU/OpenJMU_route_helper.dart';

void main() async {
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }
  await DataUtils.initSharedPreferences();
  await DeviceUtils.getModel();
  runApp(OpenJMUApp());
}

class OpenJMUApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OpenJMUAppState();
}

class OpenJMUAppState extends State<OpenJMUApp> {
  final _quickActions = [
    ['actions_home', '首页'],
    ['actions_apps', '应用'],
    ['actions_message', '消息'],
    ['actions_mine', '我的'],
  ];

  final connectivitySubscription = Connectivity().onConnectivityChanged.listen(
    (ConnectivityResult result) {
      Instances.eventBus.fire(ConnectivityChangeEvent(result));
      debugPrint("Current connectivity: $result");
    },
  );

  bool isUserLogin = false;
  String initAction;

  Color currentThemeColor = ThemeUtils.currentThemeColor;
  Brightness brightness;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Instances.eventBus
      ..on<ChangeThemeEvent>().listen((event) {
        currentThemeColor = event.color;
        if (mounted) setState(() {});
      })
      ..on<LogoutEvent>().listen((event) async {
        currentState.pushNamedAndRemoveUntil(
          "openjmu://login",
          (_) => false,
          arguments: {"initAction": initAction},
        );
        DataUtils.logout();
        currentThemeColor = ThemeUtils.defaultColor;
        if (mounted) setState(() {});
      })
      ..on<ActionsEvent>().listen((event) {
        initAction = _quickActions.firstWhere((action) {
          return action[0] == event.type;
        })[1];
      })
      ..on<ChangeBrightnessEvent>().listen((event) {
        if (mounted) setState(() {});
      })
      ..on<ChangeAMOLEDDarkEvent>().listen((event) {
        if (mounted) setState(() {});
      });

    initSettings();
    NetUtils.initConfig();
    initQuickActions();
    debugPrint("Current platform is: ${Platform.operatingSystem}");

    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    debugPrint("Main dart disposed.");
    super.dispose();
  }

  void initSettings() async {
    final color = ThemeUtils.supportColors[DataUtils.getColorThemeIndex()];
    currentThemeColor = ThemeUtils.currentThemeColor = color;
    Instances.eventBus.fire(ChangeThemeEvent(color));
    ThemeUtils.isDark = DataUtils.getBrightness();
    ThemeUtils.isAMOLEDDark = DataUtils.getAMOLEDDark();
    ThemeUtils.isPlatformBrightness = DataUtils.getBrightnessPlatform();

    Configs.homeSplashIndex = DataUtils.getHomeSplashIndex();
    Configs.homeStartUpIndex = DataUtils.getHomeStartUpIndex();
    Configs.fontScale = DataUtils.getFontScale();
    Configs.newAppCenterIcon = DataUtils.getEnabledNewAppsIcon();

    if (mounted) setState(() {});
  }

  void initQuickActions() {
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      debugPrint("QuickActions triggered: $shortcutType");
      Instances.eventBus.fire(ActionsEvent(shortcutType));
    });
    quickActions.setShortcutItems(<ShortcutItem>[
      for (final action in _quickActions)
        ShortcutItem(
          type: action[0],
          icon: action[0],
          localizedTitle: action[1],
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (brightness != null) {
      brightness = MediaQuery.of(Constants.navigatorKey.currentContext)
          .platformBrightness;
    }
    if (ThemeUtils.isPlatformBrightness) {
      ThemeUtils.isDark = brightness == Brightness.dark;
    }

    final theme = ThemeUtils.isDark
        ? ThemeUtils.dark()
        : ThemeUtils.light().copyWith(
            textTheme: (ThemeUtils.isDark
                    ? Theme.of(context).typography.white
                    : Theme.of(context).typography.black)
                .copyWith(
            subhead: TextStyle(
              textBaseline: TextBaseline.alphabetic,
            ),
          ));

    return MultiProvider(
      providers: providers,
      child: Theme(
        data: theme,
        child: OKToast(
          child: MaterialApp(
            navigatorKey: Constants.navigatorKey,
            builder: (c, w) {
              brightness = ThemeUtils.isPlatformBrightness
                  ? MediaQuery.of(c).platformBrightness
                  : ThemeUtils.isDark ? Brightness.dark : Brightness.light;
              ScreenUtil.instance = ScreenUtil.getInstance()..init(c);
              return NoScaleTextWidget(child: w);
            },
            title: "OpenJMU",
            theme: theme,
            home: SplashPage(initAction: initAction),
            navigatorObservers: [
              FFNavigatorObserver(showStatusBarChange: (bool showStatusBar) {
                if (showStatusBar) {
                  SystemChrome.setEnabledSystemUIOverlays(
                    SystemUiOverlay.values,
                  );
                } else {
                  SystemChrome.setEnabledSystemUIOverlays([]);
                }
              })
            ],
            onGenerateRoute: (RouteSettings settings) {
              final routeResult = getRouteResult(
                name: settings.name,
                arguments: settings.arguments,
              );
              if (routeResult.showStatusBar != null ||
                  routeResult.routeName != null) {
                settings = FFRouteSettings(
                  name: settings.name,
                  isInitialRoute: settings.isInitialRoute,
                  routeName: routeResult.routeName,
                  arguments: settings.arguments,
                  showStatusBar: routeResult.showStatusBar,
                );
              }
              final page =
                  routeResult.widget ?? SplashPage(initAction: initAction);

              if (settings.arguments != null &&
                  settings.arguments is Map<String, dynamic>) {
                RouteBuilder builder = (settings.arguments
                    as Map<String, dynamic>)['routeBuilder'];
                if (builder != null) return builder(page);
              }

              switch (routeResult.pageRouteType) {
                case PageRouteType.material:
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (c) => page,
                  );
                case PageRouteType.cupertino:
                  return CupertinoPageRoute(
                    settings: settings,
                    builder: (c) => page,
                  );
                case PageRouteType.transparent:
                  return FFTransparentPageRoute(
                    settings: settings,
                    pageBuilder: (_, __, ___) => page,
                  );
                default:
                  return Platform.isIOS
                      ? CupertinoPageRoute(
                          settings: settings,
                          builder: (c) => page,
                        )
                      : MaterialPageRoute(
                          settings: settings,
                          builder: (c) => page,
                        );
              }
            },
            localizationsDelegates: [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale.fromSubtags(
                languageCode: 'zh',
              ),
              const Locale.fromSubtags(
                languageCode: 'zh',
                scriptCode: 'Hans',
              ),
              const Locale.fromSubtags(
                languageCode: 'zh',
                scriptCode: 'Hant',
              ),
              const Locale.fromSubtags(
                languageCode: 'zh',
                scriptCode: 'Hans',
                countryCode: 'CN',
              ),
              const Locale.fromSubtags(
                languageCode: 'zh',
                scriptCode: 'Hant',
                countryCode: 'TW',
              ),
              const Locale.fromSubtags(
                languageCode: 'zh',
                scriptCode: 'Hant',
                countryCode: 'HK',
              ),
              const Locale('en'),
            ],
          ),
        ),
      ),
    );
  }
}

typedef RouteBuilder = PageRoute Function(Widget page);
