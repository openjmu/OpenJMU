import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:OpenJMU/constants/Configs.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/DeviceUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/RouteUtils.dart';
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
    final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

    StreamSubscription<ConnectivityResult> connectivitySubscription;
    bool isUserLogin = false;
    int initIndex;

    Color currentThemeColor = ThemeUtils.currentThemeColor;

    @override
    void initState() {
        SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
        ]);
        connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
            Constants.eventBus.fire(ConnectivityChangeEvent(result));
            debugPrint("Current connectivity: $result");
        });

        Constants.eventBus
            ..on<ChangeThemeEvent>().listen((event) {
                currentThemeColor = event.color;
                if (mounted) setState(() {});
            })
            ..on<LogoutEvent>().listen((event) async {
                await DataUtils.logout();
                Constants.navigatorKey.currentState.pushNamedAndRemoveUntil(
                    "/login", (_) => true,
                );
                currentThemeColor = ThemeUtils.defaultColor;
                if (mounted) setState(() {});
            })
            ..on<ActionsEvent>().listen((event) {
                if (event.type == "action_home") {
                    initIndex = 0;
                } else if (event.type == "action_apps") {
                    initIndex = 1;
                } else if (event.type == "action_message") {
                    initIndex = 2;
                } else if (event.type == "action_mine") {
                    initIndex = 3;
                }
            })
            ..on<ChangeBrightnessEvent>().listen((event) {
                ThemeUtils.isDark = event.isDarkState;
                if (mounted) setState(() {});
            })
        ;

        initSettings();
        NetUtils.initConfig();
        initQuickActions();
        debugPrint("Android: ${Platform.isAndroid} | iOS: ${Platform.isIOS}");

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
        Constants.eventBus.fire(ChangeThemeEvent(color));
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
            Constants.eventBus.fire(ActionsEvent(shortcutType));
        });
        quickActions.setShortcutItems(<ShortcutItem>[
            const ShortcutItem(type: 'action_home', localizedTitle: '首页', icon: 'actions_home'),
            const ShortcutItem(type: 'action_apps', localizedTitle: '应用', icon: 'actions_apps'),
            const ShortcutItem(type: 'action_message', localizedTitle: '消息', icon: 'actions_message'),
            const ShortcutItem(type: 'action_mine', localizedTitle: '我的', icon: 'actions_mine'),
        ]);
    }

    @override
    Widget build(BuildContext context) {
        Constants.navigatorKey = _navigatorKey;
        return Theme(
            data: ThemeUtils.isDark ? ThemeUtils.darkTheme() : ThemeUtils.lightTheme(),
            child: OKToast(
                child: MaterialApp(
                    navigatorKey: _navigatorKey,
                    builder: (BuildContext c, Widget w) => NoScaleTextWidget(child: w),
                    debugShowCheckedModeBanner: false,
                    routes: RouteUtils.routes,
                    title: "OpenJMU",
                    theme: (ThemeUtils.isDark
                            ? ThemeUtils.darkTheme()
                            : ThemeUtils.lightTheme()
                    ).copyWith(
                        textTheme: (ThemeUtils.isDark
                                ? Theme.of(context).typography.white
                                : Theme.of(context).typography.black
                        ).copyWith(
                            subhead: TextStyle(
                                textBaseline: TextBaseline.alphabetic,
                            ),
                        )
                    ),
                    home: SplashPage(initIndex: initIndex),
                    localizationsDelegates: [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
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
        );
    }
}
