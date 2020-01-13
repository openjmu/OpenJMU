import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/splash_page.dart';
import 'package:openjmu/openjmu_route.dart';
import 'package:openjmu/openjmu_route_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  await HiveBoxes.openBoxes();
  await DeviceUtils.getModel();
  NotificationUtils.initSettings();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));

  runApp(OpenJMUApp());
}

class OpenJMUApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OpenJMUAppState();
}

class OpenJMUAppState extends State<OpenJMUApp> with WidgetsBindingObserver {
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

  String initAction;
  Brightness get _platformBrightness => Screens.mediaQuery.platformBrightness ?? Brightness.light;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Instances.eventBus
      ..on<LogoutEvent>().listen((event) async {
        navigatorState.pushNamedAndRemoveUntil(
          "openjmu://login",
          (_) => false,
          arguments: {"initAction": initAction},
        );
        DataUtils.logout();
        if (mounted) setState(() {});
      })
      ..on<TicketGotEvent>().listen((event) {
        Provider.of<MessagesProvider>(
          currentContext,
          listen: false,
        ).initMessages();
      })
      ..on<ActionsEvent>().listen((event) {
        initAction = _quickActions.firstWhere((action) {
          return action[0] == event.type;
        })[1];
      })
      ..on<HasUpdateEvent>().listen((event) {
        showToastWidget(
          OTAUtils.updateDialog(event),
          dismissOtherToast: true,
          handleTouch: true,
          duration: 1.days,
        );
      });

    initSettings();
    NetUtils.initConfig();
    initQuickActions();

    debugPrint("Current platform is: ${Platform.operatingSystem}");

    super.initState();
  }

  @override
  void dispose() {
    debugPrint("Main dart disposed.");
    WidgetsBinding.instance.removeObserver(this);
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("AppLifecycleState change to: ${state.toString()}");
    Instances.appLifeCycleState = state;
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) setState(() {});
  }

  void initSettings() async {
    if (DataUtils.isLogin()) {
      DataUtils.recoverLoginInfo();
    } else {
      Instances.eventBus.fire(TicketFailedEvent());
    }

    if (mounted) setState(() {});
  }

  void initQuickActions() {
    final quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      debugPrint("QuickActions triggered: $shortcutType");
      Instances.eventBus.fire(ActionsEvent(shortcutType));
    });
    quickActions.setShortcutItems(List<ShortcutItem>.generate(
      _quickActions.length,
      (index) => ShortcutItem(
        type: _quickActions[index][0],
        icon: _quickActions[index][0],
        localizedTitle: _quickActions[index][1],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer2<ThemesProvider, SettingsProvider>(
        builder: (_, themesProvider, settingsProvider, __) {
          final isDark = themesProvider.platformBrightness
              ? _platformBrightness == Brightness.dark
              : themesProvider.dark;
          final theme = (isDark ? themesProvider.darkTheme : themesProvider.lightTheme).copyWith(
            textTheme:
                (isDark ? Theme.of(context).typography.white : Theme.of(context).typography.black)
                    .copyWith(
              subhead: TextStyle(textBaseline: TextBaseline.alphabetic),
            ),
          );
          return AnnotatedRegion(
            value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: Theme(
              data: theme,
              child: OKToast(
                child: MaterialApp(
                  navigatorKey: Instances.navigatorKey,
                  builder: (c, w) {
                    ScreenUtil.instance = ScreenUtil.getInstance()
                      ..allowFontScaling = true
                      ..init(c);
                    return NoScaleTextWidget(child: w);
                  },
                  title: "OpenJMU",
                  theme: theme,
                  home: SplashPage(initAction: initAction),
                  navigatorObservers: [
                    FFNavigatorObserver(
                      showStatusBarChange: (bool showStatusBar) {
                        SystemChrome.setEnabledSystemUIOverlays(
                          showStatusBar ? SystemUiOverlay.values : [],
                        );
                      },
                    ),
                  ],
                  onGenerateRoute: (RouteSettings settings) {
                    final routeResult = getRouteResult(
                      name: settings.name,
                      arguments: settings.arguments,
                    );
                    if (routeResult.showStatusBar != null || routeResult.routeName != null) {
                      settings = FFRouteSettings(
                        name: settings.name,
                        isInitialRoute: settings.isInitialRoute,
                        routeName: routeResult.routeName,
                        arguments: settings.arguments,
                        showStatusBar: routeResult.showStatusBar,
                      );
                    }
                    final page = routeResult.widget ?? SplashPage(initAction: initAction);

                    if (settings.arguments != null && settings.arguments is Map<String, dynamic>) {
                      RouteBuilder builder =
                          (settings.arguments as Map<String, dynamic>)['routeBuilder'];
                      if (builder != null) return builder(page);
                    }

                    switch (routeResult.pageRouteType) {
                      case PageRouteType.material:
                        return MaterialPageRoute(settings: settings, builder: (c) => page);
                      case PageRouteType.cupertino:
                        return CupertinoPageRoute(settings: settings, builder: (c) => page);
                      case PageRouteType.transparent:
                        return FFTransparentPageRoute(
                          settings: settings,
                          pageBuilder: (_, __, ___) => page,
                        );
                      default:
                        return Platform.isIOS
                            ? CupertinoPageRoute(settings: settings, builder: (c) => page)
                            : MaterialPageRoute(settings: settings, builder: (c) => page);
                    }
                  },
                  localizationsDelegates: Constants.localizationsDelegates,
                  supportedLocales: Constants.supportedLocales,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

typedef RouteBuilder = PageRoute Function(Widget page);
