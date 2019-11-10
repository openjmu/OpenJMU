import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/widgets/NoScaleTextWidget.dart';

void main() async {
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
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool isUserLogin = false;
  String initAction;

  Color currentThemeColor = ThemeUtils.currentThemeColor;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      Instances.eventBus.fire(ConnectivityChangeEvent(result));
      debugPrint("Current connectivity: $result");
    });

    Instances.eventBus
      ..on<ChangeThemeEvent>().listen((event) {
        currentThemeColor = event.color;
        if (mounted) setState(() {});
      })
      ..on<LogoutEvent>().listen((event) async {
        Constants.navigatorKey.currentState.pushNamedAndRemoveUntil(
          "/login",
          (_) => false,
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
    Color color = ThemeUtils.supportColors[DataUtils.getColorThemeIndex()];
    currentThemeColor = ThemeUtils.currentThemeColor = color;
    Instances.eventBus.fire(ChangeThemeEvent(color));
    ThemeUtils.isDark = DataUtils.getBrightnessDark();

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
    final theme =
        (ThemeUtils.isDark ? ThemeUtils.dark() : ThemeUtils.light()).copyWith(
      textTheme: (ThemeUtils.isDark
              ? Theme.of(context).typography.white
              : Theme.of(context).typography.black)
          .copyWith(
        subhead: TextStyle(
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
    return MultiProvider(
      providers: providers,
      child: Theme(
        data: theme,
        child: OKToast(
          child: MaterialApp(
            navigatorKey: Constants.navigatorKey,
            builder: (c, w) {
              ScreenUtil.instance = ScreenUtil.getInstance()..init(c);
              return NoScaleTextWidget(child: w);
            },
            routes: RouteUtils.routes,
            title: "OpenJMU",
            theme: theme,
            home: SplashPage(initAction: initAction),
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
