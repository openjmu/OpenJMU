import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: "openjmu://inappbrowser",
  routeName: "网页浏览",
  argumentNames: [
    "url",
    "title",
    "withCookie",
    "withAppBar",
    "withAction",
    "withScaffold",
    "keepAlive",
  ],
)
class InAppBrowserPage extends StatefulWidget {
  final String url;
  final String title;
  final bool withCookie;
  final bool withAppBar;
  final bool withAction;
  final bool withScaffold;
  final bool keepAlive;

  const InAppBrowserPage({
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
    navigatorState.pushNamed(
      "openjmu://inappbrowser",
      arguments: {
        "url": url,
        "title": title,
      },
    );
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
    url = widget.url;
    title = widget.title;
    _webView = InAppWebView(
      initialUrl: url,
      initialOptions: {'safeBrowsingEnabled': false},
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        if (this.mounted)
          setState(() {
            this.url = url;
          });
      },
      onLoadStop: (InAppWebViewController controller, String url) {
        controller.getTitle().then((title) {
          if (this.mounted)
            setState(() {
              this.title = title;
            });
        });
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        if (this.mounted)
          setState(() {
            this.progress = progress / 100;
          });
      },
    );
    if (widget.withScaffold ?? false) {
      _webView = Scaffold(
        appBar: (widget.withAppBar ?? false)
            ? AppBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(color: currentThemeColor),
                    ),
                    Text(
                      url,
                      style: TextStyle(color: currentThemeColor, fontSize: suSetSp(14.0)),
                    ),
                  ],
                ),
                bottom: (progress != 1.0) ? progressBar(context) : null,
              )
            : null,
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: _webView,
                ),
              ),
              if (widget.withAction ?? false)
                SizedBox(
                  height: suSetSp(24.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: currentThemeColor,
                        ),
                        onPressed: () {
                          if (_webViewController != null) {
                            _webViewController.goBack();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: currentThemeColor,
                        ),
                        onPressed: () {
                          if (_webViewController != null) {
                            _webViewController.goForward();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: currentThemeColor,
                        ),
                        onPressed: () {
                          if (_webViewController != null) {
                            _webViewController.reload();
                          }
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
    Instances.eventBus
      ..on<CourseScheduleRefreshEvent>().listen((event) {
        if (mounted) loadCourseSchedule();
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadCourseSchedule() {
    final provider = Provider.of<ThemesProvider>(currentContext, listen: false);
    try {
      _webViewController.loadUrl(
        "${UserAPI.currentUser.isTeacher ? API.courseScheduleTeacher : API.courseSchedule}"
        "?sid=${UserAPI.currentUser.sid}"
        "&night=${provider.dark ? 1 : 0}",
      );
    } catch (e) {
      debugPrint("$e");
    }
  }

  PreferredSize progressBar(context) {
    return PreferredSize(
      child: SizedBox(
        height: suSetSp(2.0),
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
