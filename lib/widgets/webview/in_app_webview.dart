import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: 'openjmu://inappbrowser',
  routeName: '网页浏览',
  argumentNames: [
    'url',
    'title',
    'app',
    'withCookie',
    'withAppBar',
    'withAction',
    'withScaffold',
    'keepAlive',
  ],
)
class InAppBrowserPage extends StatefulWidget {
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

  final String url;
  final String title;
  final WebApp app;
  final bool withCookie;
  final bool withAppBar;
  final bool withAction;
  final bool withScaffold;
  final bool keepAlive;

  @override
  _InAppBrowserPageState createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends State<InAppBrowserPage>
    with AutomaticKeepAliveClientMixin {
  StreamController<double> progressController =
      StreamController<double>.broadcast();

  InAppWebViewController _webViewController;
  String title = '', url = 'about:blank';

  String get urlDomain => Uri.parse(url).host;

  @override
  bool get wantKeepAlive => widget.keepAlive ?? false;

  @override
  void initState() {
    super.initState();

    url = (widget.url ?? url).trim();
    title = (widget.app?.name ?? widget.title ?? title).trim();

    if (url.startsWith(API.labsHost) && currentIsDark) {
      url += '&night=1';
    }

    Instances.eventBus
      ..on<CourseScheduleRefreshEvent>()
          .listen((CourseScheduleRefreshEvent event) {
        if (mounted) {
          loadCourseSchedule();
        }
      });
  }

  @override
  void dispose() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    progressController.close().whenComplete(() {
      progressController = null;
    });
    super.dispose();
  }

  void loadCourseSchedule() {
    try {
      _webViewController.loadUrl(
        url:
            '${currentUser.isTeacher ? API.courseScheduleTeacher : API.courseSchedule}'
            '?sid=${currentUser.sid}'
            '&night=${currentIsDark ? 1 : 0}',
      );
    } catch (e) {
      trueDebugPrint('$e');
    }
  }

  bool checkSchemeLoad(InAppWebViewController controller, String url) {
    final RegExp protocolRegExp = RegExp(r'(http|https):\/\/([\w.]+\/?)\S*');
    if (!url.startsWith(protocolRegExp) && url.contains('://')) {
      trueDebugPrint('Found scheme when load: $url');
      if (Platform.isAndroid) {
        Future<void>.delayed(1.microseconds, () async {
          unawaited(controller.stopLoading());
          trueDebugPrint('Try to launch intent...');
          final String appName = await ChannelUtils.getSchemeLaunchAppName(url);
          if (appName != null) {
            final bool shouldLaunch = await waitForConfirmation(appName);
            if (shouldLaunch) {
              await _launchURL(url: url);
            }
          }
        });
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> waitForConfirmation(String applicationLabel) async {
    return ConfirmationDialog.show(
      context,
      title: '跳转外部应用',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: '即将打开应用\n'),
              TextSpan(
                text: '$applicationLabel',
                style: TextStyle(
                    fontSize: suSetSp(20.0), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          style: TextStyle(fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
      showConfirm: true,
      confirmLabel: '允许',
    );
  }

  Widget get _domainProvider => Padding(
        padding: EdgeInsets.only(bottom: suSetHeight(10.0)),
        child: Text(
          '网页由 $urlDomain 提供',
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(fontSize: suSetSp(18.0)),
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
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(fontSize: suSetSp(15.0)),
          ),
        ],
      ),
    );
  }

  void showMore(BuildContext context) {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(suSetWidth(20.0)),
          topRight: Radius.circular(suSetWidth(20.0)),
        ),
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
                borderRadius: maxBorderRadius,
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
                    text: '复制链接',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: url));
                      showToast('已复制网址到剪贴板');
                    },
                  ),
                  _moreAction(
                    context: context,
                    icon: Icons.open_in_browser,
                    text: '浏览器打开',
                    onTap: () => _launchURL(forceSafariVC: false),
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

  Future<void> _launchURL({String url, bool forceSafariVC = true}) async {
    final String uri = Uri.encodeFull(url ?? this.url);
    if (await canLaunch(uri)) {
      await launch(uri, forceSafariVC: Platform.isIOS && forceSafariVC);
    } else {
      showCenterErrorToast('无法打开网址: $uri');
    }
  }

  PreferredSizeWidget get appBar => PreferredSize(
        preferredSize: Size.fromHeight(suSetHeight(kAppBarHeight)),
        child: Container(
          height: Screens.topSafeHeight + suSetHeight(kAppBarHeight),
          padding: EdgeInsets.only(top: Screens.topSafeHeight),
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: suSetHeight(kAppBarHeight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close),
                      onPressed: Navigator.of(context).pop,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (widget.app != null)
                            WebAppIcon(app: widget.app, size: 60.0),
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(fontSize: suSetSp(22.0)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
      );

  Widget get progressBar => Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: SizedBox(
          height: suSetHeight(2.0),
          child: StreamBuilder<double>(
            initialData: 0.0,
            stream: progressController.stream,
            builder: (BuildContext context, AsyncSnapshot<double> data) =>
                LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
              value: data.data,
            ),
          ),
        ),
      );

  Widget get refreshIndicator => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: PlatformProgressIndicator(strokeWidth: 3.0),
          ),
        ),
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

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: (widget.withAppBar ?? true) ? appBar : null,
      body: InAppWebView(
        initialUrl: url,
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            applicationNameForUserAgent: 'openjmu-webview',
            cacheEnabled: widget.withCookie ?? true,
            clearCache: !widget.withCookie ?? false,
            horizontalScrollBarEnabled: false,
            javaScriptCanOpenWindowsAutomatically: true,
            transparentBackground: true,
            useOnDownloadStart: true,
            useShouldOverrideUrlLoading: true,
            verticalScrollBarEnabled: false,
          ),
          // TODO(AlexVincent525): Currently zoom control in android was broken, need to find the root cause.
          android: AndroidInAppWebViewOptions(
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            builtInZoomControls: true,
            displayZoomControls: false,
            forceDark: currentIsDark
                ? AndroidForceDark.FORCE_DARK_ON
                : AndroidForceDark.FORCE_DARK_OFF,
            loadWithOverviewMode: true,
            mixedContentMode:
                AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            safeBrowsingEnabled: false,
            supportZoom: true,
            useWideViewPort: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsAirPlayForMediaPlayback: true,
            allowsBackForwardNavigationGestures: true,
            allowsLinkPreview: true,
            allowsPictureInPictureMediaPlayback: true,
            isFraudulentWebsiteWarningEnabled: false,
            sharedCookiesEnabled: true,
          ),
        ),
        onCreateWindow: (
          InAppWebViewController controller,
          OnCreateWindowRequest onCreateWindowRequest,
        ) {
          if (Uri.tryParse(onCreateWindowRequest.url) != null) {
            controller.loadUrl(url: onCreateWindowRequest.url);
          }
        },
        onLoadStart: (InAppWebViewController controller, String url) {
          trueDebugPrint('Webview onLoadStart: $url');
        },
        onLoadStop: (InAppWebViewController controller, String url) async {
          unawaited(controller.evaluateJavascript(
            source: 'window.onbeforeunload=null',
          ));

          this.url = url;
          final String _title = (await controller.getTitle())?.trim();
          if (_title != null && _title.isNotEmpty && _title != this.url) {
            title = _title;
          } else {
            final String ogTitle = await controller.evaluateJavascript(
              source:
                  'var ogTitle = document.querySelector(\'[property="og:title"]\');\n'
                  'if (ogTitle != undefined) ogTitle.content;',
            ) as String;
            if (ogTitle != null) {
              title = ogTitle;
            }
          }
          if (mounted) {
            setState(() {});
          }
          Future.delayed(500.milliseconds, () {
            progressController?.add(0.0);
          });
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          progressController?.add(progress / 100);
        },
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          trueDebugPrint('Console message: '
              '${consoleMessage.messageLevel.toString()}'
              ' - '
              '${consoleMessage.message}');
        },
        onDownloadStart: (InAppWebViewController controller, String url) {
          trueDebugPrint('WebView started download from: $url');
          NetUtils.download(url);
        },
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
        shouldOverrideUrlLoading: (
          InAppWebViewController controller,
          ShouldOverrideUrlLoadingRequest request,
        ) async {
          if (checkSchemeLoad(controller, request.url)) {
            return ShouldOverrideUrlLoadingAction.CANCEL;
          } else {
            return ShouldOverrideUrlLoadingAction.ALLOW;
          }
        },
      ),
      persistentFooterButtons:
          (widget.withAction ?? true) ? persistentFooterButtons : null,
    );
  }
}
