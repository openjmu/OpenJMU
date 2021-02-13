import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:openjmu/constants/constants.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({
    Key key,
    @required this.url,
    this.title,
    this.app,
    this.withCookie = true,
    this.withAppBar = true,
    this.withAction = true,
    this.withScaffold = true,
    this.keepAlive = false,
  })  : assert(url != null),
        super(key: key);

  final String url;
  final String title;
  final WebApp app;
  final bool withCookie;
  final bool withAppBar;
  final bool withAction;
  final bool withScaffold;
  final bool keepAlive;

  static final Tween<Offset> _positionTween = Tween<Offset>(
    begin: const Offset(0, 1),
    end: const Offset(0, 0),
  );

  static Future<void> launch({
    @required String url,
    String title,
    WebApp app,
    bool withCookie = true,
    bool withAppBar = true,
    bool withAction = true,
    bool withScaffold = true,
    bool keepAlive = false,
  }) {
    return navigatorState.push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return SlideTransition(
            position: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            ).drive(_positionTween),
            child: child,
          );
        },
        pageBuilder: (_, __, ___) => AppWebView(
          url: url,
          title: title,
          app: app,
          withCookie: withCookie,
          withAppBar: withAppBar,
          withAction: withAction,
          withScaffold: withScaffold,
          keepAlive: keepAlive,
        ),
      ),
    );
  }

  @override
  _AppWebViewState createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView>
    with AutomaticKeepAliveClientMixin {
  final StreamController<double> progressController =
      StreamController<double>.broadcast();

  InAppWebViewController _webViewController;
  String title = '', url = 'about:blank';

  String get urlDomain => Uri.parse(url).host ?? url;

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
        .on<CourseScheduleRefreshEvent>()
        .listen((CourseScheduleRefreshEvent event) {
      if (mounted) {
        loadCourseSchedule();
      }
    });
  }

  @override
  void dispose() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    progressController.close();
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
      LogUtils.d('$e');
    }
  }

  bool checkSchemeLoad(InAppWebViewController controller, String url) {
    final RegExp protocolRegExp = RegExp(r'(http|https):\/\/([\w.]+\/?)\S*');
    if (!url.startsWith(protocolRegExp) && url.contains('://')) {
      LogUtils.d('Found scheme when load: $url');
      if (Platform.isAndroid) {
        Future<void>.delayed(1.microseconds, () async {
          controller.stopLoading();
          LogUtils.d('Try to launch intent...');
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
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: '即将打开应用\n'),
              TextSpan(
                text: applicationLabel,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          style: const TextStyle(fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
      ),
      showConfirm: true,
      confirmLabel: '允许',
    );
  }

  final Widget refreshIndicator = const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: 24.0,
        height: 24.0,
        child: PlatformProgressIndicator(strokeWidth: 3.0),
      ),
    ),
  );

  Widget _domainProvider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.w),
      child: Text(
        '网页由 $urlDomain 提供',
        style: context.textTheme.caption.copyWith(height: 1.2, fontSize: 15.sp),
      ),
    );
  }

  Widget _moreAction({
    @required BuildContext context,
    @required IconData icon,
    @required String text,
    VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.w).copyWith(left: 30.w),
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
              width: 64.w,
              height: 64.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(16.w),
              ),
              child: Icon(
                icon,
                size: 30.w,
                color: context.textTheme.bodyText2.color,
              ),
            ),
          ),
          VGap(12.w),
          Text(
            text,
            style: context.textTheme.caption.copyWith(
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  void showMore(BuildContext context) {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.w),
          topRight: Radius.circular(20.w),
        ),
      ),
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 16.h),
              width: 40.w,
              height: 8.w,
              decoration: BoxDecoration(
                borderRadius: maxBorderRadius,
                color: context.iconTheme.color.withOpacity(0.7),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
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
            if (urlDomain != null) _domainProvider(context),
            VGap(Screens.bottomSafeHeight),
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

  FixedAppBar appBar(BuildContext context) {
    return FixedAppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.app != null)
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 10.w),
              child: WebAppIcon(app: widget.app, size: 42.0),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: widget.app == null ? 16.w : 0),
              child: Text(
                title,
                style: TextStyle(
                  height: 1.2,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w),
      actions: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.w),
            color: context.theme.canvasColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Tapper(
                onTap: () => showMore(context),
                child: SizedBox.fromSize(
                  size: Size.square(56.w),
                  child: Center(
                    child: SvgPicture.asset(
                      R.ASSETS_ICONS_POST_ACTIONS_MORE_SVG,
                      width: 20.w,
                      color: context.textTheme.bodyText2.color,
                    ),
                  ),
                ),
              ),
              Tapper(
                onTap: context.navigator.pop,
                child: SizedBox.fromSize(
                  size: Size.square(56.w),
                  child: Center(
                    child: SvgPicture.asset(
                      R.ASSETS_ICONS_CLEAR_SVG,
                      width: 20.w,
                      color: context.textTheme.bodyText2.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget get progressBar {
    return PositionedDirectional(
      start: 0,
      end: 0.0,
      top: 0,
      height: 2.w,
      child: StreamBuilder<double>(
        initialData: 0.0,
        stream: progressController.stream,
        builder: (BuildContext c, AsyncSnapshot<double> data) {
          return LinearProgressIndicator(
            backgroundColor: c.theme.primaryColor,
            value: data.data,
          );
        },
      ),
    );
  }

  List<Widget> get persistentFooterButtons {
    return <Widget>[
      SizedBox(
        width: Screens.width,
        height: 32.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: currentThemeColor,
                size: 32.w,
              ),
              onPressed: _webViewController?.goBack,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.keyboard_arrow_right,
                color: currentThemeColor,
                size: 32.w,
              ),
              onPressed: _webViewController?.goForward,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.refresh,
                color: currentThemeColor,
                size: 32.w,
              ),
              onPressed: _webViewController?.reload,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController?.canGoBack() == true) {
          _webViewController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: FixedAppBarWrapper(
          appBar: (widget.withAppBar ?? true) ? appBar(context) : null,
          body: Stack(
            children: <Widget>[
              InAppWebView(
                initialUrl: url,
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    applicationNameForUserAgent: 'openjmu-webview',
                    cacheEnabled: widget.withCookie ?? true,
                    clearCache: !widget.withCookie ?? false,
                    horizontalScrollBarEnabled: false,
                    javaScriptCanOpenWindowsAutomatically: true,
                    supportZoom: true,
                    transparentBackground: true,
                    useOnDownloadStart: true,
                    useShouldOverrideUrlLoading: true,
                    verticalScrollBarEnabled: false,
                  ),
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
                  CreateWindowRequest createWindowRequest,
                ) async {
                  if (Uri.tryParse(createWindowRequest.url) != null) {
                    await controller.loadUrl(url: createWindowRequest.url);
                    return true;
                  }
                  return false;
                },
                onLoadStart: (_, String url) {
                  LogUtils.d('Webview onLoadStart: $url');
                },
                onLoadStop:
                    (InAppWebViewController controller, String url) async {
                  controller.evaluateJavascript(
                    source: 'window.onbeforeunload=null',
                  );

                  this.url = url;
                  final String _title = (await controller.getTitle())?.trim();
                  if (_title != null &&
                      _title.isNotEmpty &&
                      _title != this.url) {
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
                  Future<void>.delayed(500.milliseconds, () {
                    if (!progressController.isClosed) {
                      progressController?.add(0.0);
                    }
                  });
                },
                onProgressChanged: (_, int progress) {
                  progressController?.add(progress / 100);
                },
                onConsoleMessage: (_, ConsoleMessage consoleMessage) {
                  LogUtils.d(
                    'Console message: '
                    '${consoleMessage.messageLevel.toString()}'
                    ' - '
                    '${consoleMessage.message}',
                  );
                },
                onDownloadStart: (_, String url) {
                  LogUtils.d('WebView started download from: $url');
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
              progressBar,
            ],
          ),
        ),
      ),
    );
  }
}
