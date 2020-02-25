import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:openjmu/constants/constants.dart' hide PageRouteType;
import 'package:openjmu/pages/splash_page.dart';
import 'package:openjmu/pages/no_route_page.dart';
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
  await PackageUtils.initPackageInfo();
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
  StreamSubscription connectivitySubscription;

  int initAction;

  Brightness get _platformBrightness => Screens.mediaQuery.platformBrightness ?? Brightness.light;

  ToastFuture connectivityToastFuture;

  @override
  void initState() {
    debugPrint('Current platform is: ${Platform.operatingSystem}');
    WidgetsBinding.instance.addObserver(this);
    tryRecoverLoginInfo();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Connectivity().checkConnectivity().then(connectivityHandler);
    });
    connectivitySubscription = Connectivity().onConnectivityChanged.listen(connectivityHandler);

    Instances.eventBus
      ..on<TicketGotEvent>().listen((event) {
        if (!currentUser.isTeacher) {
          if (!currentUser.isPostgraduate) {
            Provider.of<CoursesProvider>(currentContext, listen: false).initCourses();
            Provider.of<ScoresProvider>(currentContext, listen: false).initScore();
          }
        }
        Provider.of<MessagesProvider>(currentContext, listen: false).initMessages();
        Provider.of<ReportRecordsProvider>(currentContext, listen: false).initRecords();
        Provider.of<WebAppsProvider>(currentContext, listen: false).initApps();
      })
      ..on<LogoutEvent>().listen((event) {
        navigatorState.pushNamedAndRemoveUntil(
          Routes.OPENJMU_LOGIN,
          (_) => false,
          arguments: {'initAction': initAction},
        );
        if (!currentUser.isTeacher) {
          if (!currentUser.isPostgraduate) {
            Provider.of<CoursesProvider>(currentContext, listen: false).unloadCourses();
            Provider.of<ScoresProvider>(currentContext, listen: false).unloadScore();
          }
        }
        Provider.of<MessagesProvider>(currentContext, listen: false).unloadMessages();
        Provider.of<ReportRecordsProvider>(currentContext, listen: false).unloadRecords();
        Provider.of<WebAppsProvider>(currentContext, listen: false).unloadApps();
        Future.delayed(250.milliseconds, () {
          Provider.of<ThemesProvider>(currentContext, listen: false).resetTheme();
          Provider.of<SettingsProvider>(currentContext, listen: false).reset();
        });
        DataUtils.logout();
      })
      ..on<ActionsEvent>().listen((event) {
        initAction = Constants.quickActionsList.keys
            .toList()
            .indexOf(Constants.quickActionsList.keys.firstWhere((action) => action == event.type));
      })
      ..on<HasUpdateEvent>().listen(PackageUtils.showUpdateDialog);

    super.initState();
  }

  @override
  void dispose() {
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

  void connectivityHandler(ConnectivityResult result) {
    checkIfNoConnectivity(result);
    Instances.eventBus.fire(ConnectivityChangeEvent(result));
    Instances.connectivityResult = result;
    debugPrint('Current connectivity: $result');
  }

  void checkIfNoConnectivity(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      connectivityToastFuture ??= showNoConnectivityDialog;
    } else {
      connectivityToastFuture?.dismiss(showAnim: true);
      if (connectivityToastFuture != null) {
        connectivityToastFuture = null;
      }
    }
  }

  ToastFuture get showNoConnectivityDialog => showToastWidget(
        noConnectivityWidget,
        duration: 999.weeks,
        handleTouch: true,
      );

  Widget get noConnectivityWidget => Material(
        color: Colors.black26,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Center(
            child: Container(
              width: Screens.width / 2,
              height: Screens.width / 2,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.router,
                    size: Screens.width / 6,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(height: Screens.width / 20),
                  Text(
                    '检查网络连接',
                    style: Theme.of(context).textTheme.body1.copyWith(fontSize: 20.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

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
