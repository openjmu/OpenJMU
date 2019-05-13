import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:connectivity/connectivity.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/localications/cupertino_zh.dart';
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
    StreamSubscription<ConnectivityResult> connectivitySubscription;
    bool isUserLogin = false;
    int initIndex;

    Brightness currentBrightness;
    Color currentPrimaryColor;
    Color currentThemeColor;

    @override
    void initState() {
        super.initState();
        connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
            NetUtils.currentConnectivity = result;
            Constants.eventBus.fire(new ConnectivityChangeEvent(result));
            debugPrint("Connectity: $result");
        });
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
        Constants.eventBus.on<ActionsEvent>().listen((event) {
            if (event.type == "action_home") {
                initIndex = 0;
            } else if (event.type == "action_apps") {
                initIndex = 1;
            } else if (event.type == "action_discover") {
                initIndex = 2;
            } else if (event.type == "action_mine") {
                initIndex = 3;
            }
        });
        listenToBrightness();
        NetUtils.initConfig();
        initQuickActions();
    }

    @override
    void dispose() {
        connectivitySubscription?.cancel();
        print("Main dart disposed.");
        super.dispose();
    }

    void initQuickActions() {
        final QuickActions quickActions = const QuickActions();
        quickActions.initialize((String shortcutType) {
            main();
            debugPrint("QuickActions triggered: $shortcutType");
            Constants.eventBus.fire(new ActionsEvent(shortcutType));
        });
        quickActions.setShortcutItems(<ShortcutItem>[
            const ShortcutItem(type: 'action_home', localizedTitle: '主页', icon: 'actions_home'),
            const ShortcutItem(type: 'action_apps', localizedTitle: '应用', icon: 'actions_home'),
            const ShortcutItem(type: 'action_discover', localizedTitle: '发现', icon: 'actions_home'),
            const ShortcutItem(type: 'action_mine', localizedTitle: '我的', icon: 'actions_home'),
//            const ShortcutItem(type: 'action_publish', localizedTitle: '发布新动态', icon: 'actions_home'),
        ]);

    }

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
                    iconTheme: IconThemeData(color: Colors.white),
                ),
                buttonTheme: ButtonThemeData(
                    textTheme: ButtonTextTheme.primary,
                    splashColor: currentThemeColor,
                    highlightColor: currentThemeColor,
                ),
            ),
            home: SplashPage(initIndex: initIndex),
            localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                ChineseCupertinoLocalizations.delegate,
            ],
            supportedLocales: Platform.isIOS
                    ? [
                const Locale('en'),
                const Locale('zh'),
            ]
                    : [
                const Locale('zh'),
                const Locale('en'),
            ],
        );
    }
}
