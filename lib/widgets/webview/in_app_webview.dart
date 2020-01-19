import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

@FFRoute(
  name: "openjmu://inappbrowser",
  routeName: "网页浏览",
  argumentNames: [
    "url",
    "title",
    "app",
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
  final WebApp app;
  final bool withCookie;
  final bool withAppBar;
  final bool withAction;
  final bool withScaffold;
  final bool keepAlive;

  const InAppBrowserPage({
    Key key,
    @required this.url,
    this.title,
    this.app,
    this.withCookie = true,
    this.withAppBar = true,
    this.withAction = true,
    this.withScaffold = true,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  _InAppBrowserPageState createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends State<InAppBrowserPage> with AutomaticKeepAliveClientMixin {
  InAppWebViewController _webViewController;
  String title = '', url = 'about:blank';
  double progress = 0;

  String get urlDomain => url?.split('//')[1]?.split('/')[0];

  @override
  bool get wantKeepAlive => widget.keepAlive ?? false;

  @override
  void initState() {
    url = (widget.url ?? url).trim();
    title = (widget.title ?? title).trim();

    if (url.startsWith(API.labsHost) && currentIsDark) {
      url += "&night=1";
    }

    Instances.eventBus
      ..on<CourseScheduleRefreshEvent>().listen((event) {
        if (mounted) loadCourseSchedule();
      });
    super.initState();
  }

  @override
  void dispose() {
//    try {
//      _webViewController.stopLoading();
//    } catch (e) {
//      debugPrint("$e");
//    }
    super.dispose();
  }

  void loadCourseSchedule() {
    try {
      _webViewController.loadUrl(
        url: "${currentUser.isTeacher ? API.courseScheduleTeacher : API.courseSchedule}"
            "?sid=${UserAPI.currentUser.sid}"
            "&night=${currentIsDark ? 1 : 0}",
      );
    } catch (e) {
      debugPrint("$e");
    }
  }

  Widget get _domainProvider => Padding(
        padding: EdgeInsets.only(bottom: suSetHeight(10.0)),
        child: Text(
          "网页由 $urlDomain 提供",
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: suSetSp(18.0)),
        ),
      );

  Widget _moreAction({
    @required BuildContext context,
    @required IconData icon,
    @required String text,
    VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: suSetWidth(30.0),
        top: suSetHeight(10.0),
        bottom: suSetHeight(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: onTap != null
                ? () {
                    Navigator.of(context).pop();
                    onTap();
                  }
                : null,
            child: Container(
              width: suSetWidth(64.0),
              height: suSetWidth(64.0),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(suSetWidth(16.0)),
              ),
              child: Center(child: Icon(icon, size: suSetWidth(30.0))),
            ),
          ),
          SizedBox(height: suSetHeight(10.0)),
          Text(
            text,
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: suSetSp(15.0)),
          ),
        ],
      ),
    );
  }

  Future showMore(context) async {
    return await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(suSetWidth(20.0)),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: suSetHeight(16.0)),
              width: suSetWidth(40.0),
              height: suSetHeight(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: Theme.of(context).iconTheme.color.withOpacity(0.7),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: suSetHeight(10.0)),
              child: Row(
                children: <Widget>[
                  _moreAction(
                    context: context,
                    icon: Icons.content_copy,
                    text: "复制链接",
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: url));
                      showToast("已复制网址到剪贴板");
                    },
                  ),
                  _moreAction(
                    context: context,
                    icon: Icons.open_in_browser,
                    text: "浏览器打开",
                    onTap: _launchURL,
                  ),
                ],
              ),
            ),
            if (urlDomain != null) _domainProvider,
            SizedBox(height: Screens.bottomSafeHeight),
          ],
        );
      },
    );
  }

  Future<JsPromptResponse> jsPromptHandler(
    InAppWebViewController controller,
    String message,
    String defaultValue,
  ) async {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text("$message"),
          content: SelectableText("$defaultValue"),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("确定"),
              textStyle: TextStyle(
                color: currentThemeColor,
                fontSize: suSetSp(18.0),
                fontWeight: FontWeight.normal,
              ),
              onPressed: Navigator.of(_).pop,
            ),
          ],
        );
      },
    );
    return JsPromptResponse(handledByClient: true);
  }

  Future<Null> _launchURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showCenterErrorToast('无法打开$url');
    }
  }

  Widget get appBar => PreferredSize(
        preferredSize: Size.fromHeight(suSetHeight(kAppBarHeight)),
        child: Container(
          height: Screens.topSafeHeight + suSetHeight(kAppBarHeight),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.close),
                        onPressed: Navigator.of(context).pop,
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              if (widget.app != null) AppIcon(app: widget.app, size: 60.0),
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.title.color,
                                    fontSize: suSetSp(22.0),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_horiz),
                        onPressed: () => showMore(context),
                      ),
                    ],
                  ),
                ),
                progressBar,
              ],
            ),
          ),
        ),
      );

  Widget get refreshIndicator => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: PlatformProgressIndicator(strokeWidth: 3.0),
          ),
        ),
      );

  Widget get progressBar => PreferredSize(
        child: SizedBox(
          height: suSetHeight(2.0),
          child: LinearProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
            value: progress,
          ),
        ),
        preferredSize: null,
      );

  List<Widget> get persistentFooterButtons => <Widget>[
        SizedBox(
          width: Screens.width,
          height: suSetHeight(32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: currentThemeColor,
                  size: suSetWidth(32.0),
                ),
                onPressed: _webViewController?.goBack,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.keyboard_arrow_right,
                  color: currentThemeColor,
                  size: suSetWidth(32.0),
                ),
                onPressed: _webViewController?.goForward,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.refresh,
                  color: currentThemeColor,
                  size: suSetWidth(32.0),
                ),
                onPressed: _webViewController?.reload,
              ),
            ],
          ),
        ),
      ];

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: (widget.withAppBar ?? true) ? appBar : null,
      body: InAppWebView(
        initialUrl: url,
        initialOptions: InAppWebViewWidgetOptions(
          crossPlatform: InAppWebViewOptions(
            applicationNameForUserAgent: 'openjmu-webview',
            cacheEnabled: widget.withCookie ?? true,
            clearCache: widget.withCookie ?? false,
            javaScriptCanOpenWindowsAutomatically: true,
            transparentBackground: true,
            useOnDownloadStart: true,
          ),
          android: AndroidInAppWebViewOptions(
            allowUniversalAccessFromFileURLs: true,
            safeBrowsingEnabled: false,
            supportMultipleWindows: true,
          ),
          ios: IOSInAppWebViewOptions(
            isFraudulentWebsiteWarningEnabled: false,
            sharedCookiesEnabled: true,
          ),
        ),
        onJsPrompt: jsPromptHandler,
        onLoadStart: (InAppWebViewController controller, String url) {
          debugPrint("Webview onLoadStart: $url");
        },
        onLoadStop: (InAppWebViewController controller, String url) async {
          this.url = url;
          final _title = (await controller.getTitle())?.trim();
          if (_title != null && _title.isNotEmpty && _title != this.url) {
            title = _title;
          } else {
            final ogTitle = await controller.evaluateJavascript(
              source: 'var ogTitle = document.querySelector(\'[property="og:title"]\');\n'
                  'if (ogTitle != undefined) ogTitle.content;',
            );
            if (ogTitle != null) {
              title = ogTitle;
            }
          }
          if (this.mounted) setState(() {});
          Future.delayed(500.milliseconds, () {
            this.progress = 0.0;
            if (this.mounted) setState(() {});
          });
        },
        onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          debugPrint("Console message: "
              "${consoleMessage.messageLevel.toString()}"
              " - "
              "${consoleMessage.message}");
        },
        onDownloadStart: (InAppWebViewController controller, String url) {
          debugPrint("WebView started download from: $url");
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          this.progress = progress / 100;
          if (this.mounted) setState(() {});
        },
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
      ),
      persistentFooterButtons: (widget.withAction ?? true) ? persistentFooterButtons : null,
    );
  }
}
