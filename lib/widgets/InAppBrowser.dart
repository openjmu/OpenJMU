//import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
//import 'package:OpenJMU/utils/DataUtils.dart';
//import 'package:OpenJMU/utils/ThemeUtils.dart';

//class JMUInAppBrowser extends InAppBrowser {
//    @override
//    Future onLoadStart(String url) async {
//        debugPrint("\n\nStarted $url\n\n");
//    }
//
//    @override
//    Future onLoadStop(String url) async {
//        debugPrint("\n\nStopped $url\n\n");
//    }
//
//    @override
//    void onLoadError(String url, int code, String message) {
//        debugPrint("\n\nCan't load $url.. Error: $message\n\n");
//    }
//
//    @override
//    void onExit() {
//        debugPrint("\n\nBrowser closed!\n\n");
//    }
//}
//
//JMUInAppBrowser inAppBrowserFallback = JMUInAppBrowser();
//
//class JMUChromeSafariBrowser extends ChromeSafariBrowser {
//
//    JMUChromeSafariBrowser(browserFallback) : super(browserFallback);
//
//    @override
//    void onOpened() {
//        debugPrint("ChromeSafari browser opened");
//    }
//
//    @override
//    void onLoaded() {
//        debugPrint("ChromeSafari browser loaded");
//    }
//
//    @override
//    void onClosed() {
//        debugPrint("ChromeSafari browser closed");
//    }
//}
//
//JMUChromeSafariBrowser chromeSafariBrowser = JMUChromeSafariBrowser(inAppBrowserFallback);
//
//class InAppBrowserUtils {
//    static void open(url) {
//        DataUtils.getBrightnessDark().then((isDark) {
//            String colorStr = ThemeUtils.currentThemeColor.toString();
//            if (isDark) {
//                colorStr = "000000";
//            } else {
//                colorStr.length > 18 ? colorStr = colorStr.substring(39, 45) : colorStr = colorStr.substring(10, 16);
//            }
//            chromeSafariBrowser.open(
//                url,
//                options: {
//                    "addShareButton": false,
//                    "toolbarBackgroundColor": "#$colorStr",
//                    "dismissButtonStyle": 1,
//                    "preferredBarTintColor": "#$colorStr",
//                },
//                optionsFallback: {
//                    "toolbarTopBackgroundColor": "#$colorStr",
//                    "closeButtonCaption": "Close"
//                },
//            );
//        });
//    }
//}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';

class InAppBrowserPage extends StatefulWidget {
    final String url;
    final String title;
    final bool withCookie;
    final bool withAppBar;
    final bool withAction;
    final bool withScaffold;
    final bool keepAlive;

    InAppBrowserPage({
        Key key,
        @required this.url,
        @required this.title,
        this.withCookie,
        this.withAppBar,
        this.withAction,
        this.withScaffold,
        this.keepAlive,
    }) : super(key: key);

    @override
    _InAppBrowserPageState createState() => _InAppBrowserPageState();

    static void open(BuildContext context, String url, String title) {
        Navigator.of(context).push(platformPageRoute(builder: (context) {
            return InAppBrowserPage(
                url: url,
                title: title,
            );
        }));
    }
}

class _InAppBrowserPageState extends State<InAppBrowserPage> with AutomaticKeepAliveClientMixin {
    Widget _webView;
    InAppWebViewController _webViewController;
    String title, url;
    double progress = 0;

    @override
    bool get wantKeepAlive => widget.keepAlive ?? false;

    @override
    void initState() {
        super.initState();
        url = widget.url;
        title = widget.title;
        _webView = InAppWebView(
            initialUrl: url,
            initialOptions: {'safeBrowsingEnabled': false},
            onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
            },
            onLoadStart: (InAppWebViewController controller, String url) {
                if (this.mounted) setState(() {
                    this.url = url;
                });
            },
            onLoadStop: (InAppWebViewController controller, String url) {
                if (this.mounted) controller.getTitle().then((title) {
                    setState(() { this.title = title; });
                });
            },
            onProgressChanged: (InAppWebViewController controller, int progress) {
                if (this.mounted) setState(() {
                    this.progress = progress / 100;
                });
            },
        );
        if (widget.withScaffold ?? false) {
            _webView = Scaffold(
                appBar: (widget.withAppBar ?? false) ? AppBar(
                    title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text(title,
                                style: TextStyle(color: ThemeUtils.currentThemeColor),
                            ),
                            Text(url,
                                style: TextStyle(color: ThemeUtils.currentThemeColor, fontSize: Constants.suSetSp(14.0)),
                            ),
                        ],
                    ),
                    bottom: (progress != 1.0) ? progressBar(context) : null,
                ) : null,
                body: Container(
                    child: Column(
                        children: <Widget>[
                            Expanded(
                                child: Container(
                                    child: _webView,
                                ),
                            ),
                            if (widget.withAction ?? false) SizedBox(
                                height: Constants.suSetSp(24.0),
                                child: ButtonBar(
                                    alignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                        IconButton(
                                            icon: Icon(Icons.arrow_back, color: ThemeUtils.currentThemeColor),
                                            onPressed: () {
                                                if (_webViewController != null) { _webViewController.goBack(); }
                                            },
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.arrow_forward, color: ThemeUtils.currentThemeColor),
                                            onPressed: () {
                                                if (_webViewController != null) { _webViewController.goForward(); }
                                            },
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.refresh, color: ThemeUtils.currentThemeColor),
                                            onPressed: () {
                                                if (_webViewController != null) { _webViewController.reload(); }
                                            },
                                        ),
                                    ],
                                ),
                            ),
                        ].where((Object o) => o != null).toList(),
                    ),
                ),
            );
        }
        Constants.eventBus
            ..on<ChangeBrightnessEvent>().listen((event) {
                Iterable<Match> matches = Api.courseSchedule.allMatches(url);
                String result;
                for (Match m in matches) result = m.group(0);
                if (this.mounted && result != null) loadCourseSchedule();
            })
            ..on<CourseScheduleRefreshEvent>().listen((event) {
                if (this.mounted) loadCourseSchedule();
            });
    }

    void loadCourseSchedule() {
        _webViewController.loadUrl(
            "${UserAPI.currentUser.isTeacher ? Api.courseScheduleTeacher : Api.courseSchedule}"
                    "?sid=${UserAPI.currentUser.sid}"
                    "&night=${ThemeUtils.isDark ? 1 : 0}"
            ,
        );
    }
    PreferredSize progressBar(context) {
        return PreferredSize(
            child: SizedBox(
                height: Constants.suSetSp(2.0),
                child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    value: progress,
                ),
            ),
            preferredSize: null,
        );
    }

    @mustCallSuper
    Widget build(BuildContext context) {
        super.build(context);
        return _webView;
    }
}