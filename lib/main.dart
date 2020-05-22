import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:openjmu/constants/constants.dart' hide PageRouteType;
import 'package:openjmu/pages/splash_page.dart';
import 'package:openjmu/pages/no_route_page.dart';

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

  Brightness get _platformBrightness =>
      Screens.mediaQuery.platformBrightness ?? Brightness.light;

  ToastFuture connectivityToastFuture;

  @override
  void initState() {
    trueDebugPrint('Current platform is: ${Platform.operatingSystem}');
    WidgetsBinding.instance.addObserver(this);
    tryRecoverLoginInfo();

    /// Set default display mode to compatible with 90/120Hz
    /// refresh rate on OnePlus devices.
    /// 在一加手机上设置默认显示模式以适配90/120赫兹显示
    if (Platform.isAndroid &&
        DeviceUtils.deviceModel.toLowerCase().contains('oneplus')) {
      FlutterDisplayMode.setDeviceDefault();
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Connectivity().checkConnectivity().then(connectivityHandler);
    });
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(connectivityHandler);

    Instances.eventBus
      ..on<TicketGotEvent>().listen((event) {
        initPushService();
        MessageUtils.initMessageSocket();
        if (!currentUser.isTeacher) {
          if (!currentUser.isPostgraduate) {
            currentContext.read<CoursesProvider>().initCourses();
            currentContext.read<ScoresProvider>().initScore();
          }
        }
        currentContext.read<MessagesProvider>().initMessages();
        currentContext.read<NotificationProvider>().initNotification();
        currentContext.read<ReportRecordsProvider>().initRecords();
        currentContext.read<SettingsProvider>().getCloudSettings();
        currentContext.read<SignProvider>().getSignStatus();
        currentContext.read<WebAppsProvider>().initApps();
        if (UserAPI.backpackItemTypes.isEmpty) {
          UserAPI.getBackpackItemType();
        }
      })
      ..on<LogoutEvent>().listen((event) {
        navigatorState.pushNamedAndRemoveUntil(
          Routes.openjmuLogin,
          (_) => false,
          arguments: {'initAction': initAction},
        );
        if (!currentUser.isTeacher) {
          if (!currentUser.isPostgraduate) {
            currentContext.read<CoursesProvider>().unloadCourses();
            currentContext.read<ScoresProvider>().unloadScore();
          }
        }
        currentContext.read<MessagesProvider>().unloadMessages();
        currentContext.read<NotificationProvider>().stopNotification();
        currentContext.read<ReportRecordsProvider>().unloadRecords();
        currentContext.read<SignProvider>().resetSignStatus();
        currentContext.read<WebAppsProvider>().unloadApps();
        UserAPI.backpackItemTypes.clear();
        Future.delayed(250.milliseconds, () {
          currentContext.read<ThemesProvider>().resetTheme();
          currentContext.read<SettingsProvider>().reset();
        });
        DataUtils.logout();
      })
      ..on<ActionsEvent>().listen((event) {
        initAction = Constants.quickActionsList.keys.toList().indexOf(Constants
            .quickActionsList.keys
            .firstWhere((action) => action == event.type));
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
    trueDebugPrint('\nAppLifecycleState change to: ${state.toString()}\n');
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
      trueDebugPrint('QuickActions triggered: $shortcutType');
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
    trueDebugPrint('Current connectivity: $result');
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

  void initPushService() {
    try {
      final Map<String, dynamic> data = <String, dynamic>{
        'token': DeviceUtils.devicePushToken,
        'date': DateFormat('yyyy/MM/dd HH:mm:ss', 'en').format(DateTime.now()),
        'uid': '${currentUser.uid}',
        'name': '${currentUser.name ?? currentUser.uid}',
        'workid': '${currentUser.workId ?? currentUser.uid}',
        'buildnumber': PackageUtils.buildNumber,
        'uuid': DeviceUtils.deviceUuid,
        'platform': Platform.isIOS ? 'ios' : 'android',
      };
      trueDebugPrint('Push data: $data');
      NetUtils.post<void>(API.pushUpload, data: data).then((dynamic _) {
        trueDebugPrint('Push service info upload success.');
      }).catchError((dynamic e) {
        trueDebugPrint('Push service upload error: $e');
      });
    } catch (e) {
      trueDebugPrint('Push service init error: $e');
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontSize: 20.0),
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
        builder: (
          BuildContext _,
          ThemesProvider themesProvider,
          SettingsProvider settingsProvider,
          Widget __,
        ) {
          final isDark = themesProvider.platformBrightness
              ? _platformBrightness == Brightness.dark
              : themesProvider.dark;
          final theme =
              (isDark ? themesProvider.darkTheme : themesProvider.lightTheme)
                  .copyWith(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
              },
            ),
          );
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: Theme(
              data: theme,
              child: OKToast(
                child: MaterialApp(
                  navigatorKey: Instances.navigatorKey,
                  builder: (BuildContext c, Widget w) {
                    ScreenUtil.init(c, allowFontScaling: true);
                    return ScrollConfiguration(
                      behavior: const NoGlowScrollBehavior(),
                      child: NoScaleTextWidget(child: w),
                    );
                  },
                  title: 'OpenJMU',
                  theme: theme,
                  home: SplashPage(initAction: initAction),
                  navigatorObservers: [FFNavigatorObserver()],
                  onGenerateRoute: (RouteSettings settings) =>
                      onGenerateRouteHelper(
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
