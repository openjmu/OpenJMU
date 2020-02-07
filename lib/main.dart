import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:openjmu/pages/no_route_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:openjmu/constants/constants.dart' hide PageRouteType;
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
  await DeviceUtils.initDeviceInfo();
  await OTAUtils.initPackageInfo();
  NetUtils.initConfig();
  NotificationUtils.initSettings();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
  final connectivitySubscription = Connectivity().onConnectivityChanged.listen(
    (ConnectivityResult result) {
      Instances.eventBus.fire(ConnectivityChangeEvent(result));
      debugPrint('Current connectivity: $result');
    },
  );

  int initAction;
  Brightness get _platformBrightness => Screens.mediaQuery.platformBrightness ?? Brightness.light;

  @override
  void initState() {
    debugPrint('Current platform is: ${Platform.operatingSystem}');
    WidgetsBinding.instance.addObserver(this);
    tryRecoverLoginInfo();

    Instances.eventBus
      ..on<LogoutEvent>().listen((event) {
        DataUtils.logout();
        navigatorState.pushNamedAndRemoveUntil(
          Routes.OPENJMU_LOGIN,
          (_) => false,
          arguments: {'initAction': initAction},
        );
        if (!currentUser.isTeacher) {
          Provider.of<CoursesProvider>(currentContext, listen: false).unloadCourses();
          Provider.of<ScoresProvider>(currentContext, listen: false).unloadScore();
        }
        Provider.of<MessagesProvider>(currentContext, listen: false).unloadMessages();
        Provider.of<ReportRecordsProvider>(currentContext, listen: false).unloadRecords();
        Provider.of<WebAppsProvider>(currentContext, listen: false).unloadApps();
        Future.delayed(250.milliseconds, () {
          Provider.of<ThemesProvider>(currentContext, listen: false).resetTheme();
          Provider.of<SettingsProvider>(currentContext, listen: false).reset();
        });
      })
      ..on<TicketGotEvent>().listen((event) {
        if (!currentUser.isTeacher) {
          Provider.of<CoursesProvider>(currentContext, listen: false).initCourses();
          Provider.of<ScoresProvider>(currentContext, listen: false).initScore();
        }
        Provider.of<MessagesProvider>(currentContext, listen: false).initMessages();
        Provider.of<ReportRecordsProvider>(currentContext, listen: false).initRecords();
        Provider.of<WebAppsProvider>(currentContext, listen: false).initApps();
      })
      ..on<ActionsEvent>().listen((event) {
        initAction = Constants.quickActionsList.keys
            .toList()
            .indexOf(Constants.quickActionsList.keys.firstWhere((action) => action == event.type));
      })
      ..on<HasUpdateEvent>().listen(OTAUtils.showUpdateDialog);

    super.initState();
  }

  @override
  void dispose() {
    debugPrint('Main dart disposed.');
    WidgetsBinding.instance.removeObserver(this);
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initQuickActions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('——— didChangeAppLifecycleState ———');
    debugPrint('AppLifecycleState change to: ${state.toString()}\n');
    Instances.appLifeCycleState = state;
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) setState(() {});
  }

  void tryRecoverLoginInfo() async {
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
      debugPrint('QuickActions triggered: $shortcutType');
      Instances.eventBus.fire(ActionsEvent(shortcutType));
    });
    quickActions.setShortcutItems(List<ShortcutItem>.generate(
      Constants.quickActionsList.length,
      (index) => ShortcutItem(
        type: Constants.quickActionsList.keys.elementAt(index),
        icon: Constants.quickActionsList.keys.elementAt(index),
        localizedTitle: Constants.quickActionsList.values.elementAt(index),
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
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            }),
          );
          return AnnotatedRegion(
            value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: Theme(
              data: theme,
              child: OKToast(
                child: MaterialApp(
                  navigatorKey: Instances.navigatorKey,
                  builder: (c, w) {
                    ScreenUtil.init(c, allowFontScaling: true);
                    return NoScaleTextWidget(child: w);
                  },
                  title: 'OpenJMU',
                  theme: theme,
                  home: SplashPage(initAction: initAction),
                  navigatorObservers: [FFNavigatorObserver()],
                  onGenerateRoute: (RouteSettings settings) => onGenerateRouteHelper(
                    settings,
                    notFoundFallback: NoRoutePage(route: settings.name),
                  ),
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
