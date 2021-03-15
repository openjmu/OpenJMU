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
  Timer _progressCancelTimer;

  final ValueNotifier<String> title = ValueNotifier<String>('');

  String url = 'about:blank';

  InAppWebView _webView;
  InAppWebViewController _webViewController;
  bool useDesktopMode = false;

  String get urlDomain => Uri.parse(url).host ?? url;

  @override
  bool get wantKeepAlive => widget.keepAlive ?? false;

  @override
  void initState() {
    super.initState();

    url = (widget.url ?? url).trim();
    title.value = (widget.app?.name ?? widget.title ?? title.value).trim();

    if (url.startsWith(API.labsHost) && currentIsDark) {
      url += '&night=1';
    }

    _webView = newWebView;

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
    _progressCancelTimer?.cancel();
    super.dispose();
  }

  void cancelProgress([Duration duration = const Duration(seconds: 1)]) {
    _progressCancelTimer?.cancel();
    _progressCancelTimer = Timer(duration, () {
      if (progressController?.isClosed == false) {
        progressController?.add(0.0);
      }
    });
  }

  void loadCourseSchedule() {
    try {
      _webViewController.loadUrl(
        urlRequest: URLRequest(
          url: Uri.parse(
            '${currentUser.isTeacher ? API.courseScheduleTeacher : API.courseSchedule}'
            '?sid=${currentUser.sid}'
            '&night=${currentIsDark ? 1 : 0}',
          ),
        ),
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
            if (await isAppJumpConfirm(appName)) {
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

  Future<bool> isAppJumpConfirm(String applicationLabel) {
    return ConfirmationDialog.show(
      context,
      title: '即将跳转至外部应用',
      content: applicationLabel,
      showConfirm: true,
      confirmLabel: '允许跳转',
    );
  }

  Future<void> onDownload(InAppWebViewController controller, Uri url) async {
    final String _headRes = await NetUtils.head(url.toString());
    final bool hasRealName = _headRes != null;
    String filename;
    if (hasRealName) {
      filename = _headRes;
    } else {
      filename = '$currentTimeStamp';
    }
    if (await ConfirmationDialog.show(
      context,
      title: hasRealName ? '文件下载确认' : '未知文件下载确认',
      content: '文件安全性未知，请确认下载\n\n'
          '$url 想要下载文件'
          '${hasRealName ? ' $filename' : '\n\n文件名称未知，将下载为 $filename'}',
      showConfirm: true,
      confirmLabel: '下载',
      resolveSpecialText: false,
    )) {
      LogUtils.d('WebView started download from: $url');
      NetUtils.download(url.toString(), filename);
    }
  }

  void showMore(BuildContext context) {
    ConfirmationBottomSheet.show(
      context,
      actions: <ConfirmationBottomSheetAction>[
        ConfirmationBottomSheetAction(
          text: '刷新',
          onTap: () => _webViewController?.reload(),
        ),
        ConfirmationBottomSheetAction(
          text: '复制链接',
          onTap: () {
            Clipboard.setData(ClipboardData(text: url));
            showToast('已复制网址到剪贴板');
          },
        ),
        ConfirmationBottomSheetAction(
          text: '浏览器打开',
          onTap: () => _launchURL(forceSafariVC: false),
        ),
        ConfirmationBottomSheetAction(
          text: '以${useDesktopMode ? '移动' : '桌面'}版显示',
          onTap: switchDesktopMode,
        ),
      ],
    );
  }

  void switchDesktopMode() {
    setState(() {
      useDesktopMode = !useDesktopMode;
      _webView = newWebView;
    });
  }

  Future<void> _launchURL({String url, bool forceSafariVC = true}) async {
    final String uri = Uri.parse(url ?? this.url).toString();
    if (await canLaunch(uri)) {
      await launch(uri, forceSafariVC: Platform.isIOS && forceSafariVC);
    } else {
      showCenterErrorToast('无法打开网址: $uri');
    }
  }

  Widget appBar(BuildContext context) {
    Widget _appIcon() {
      return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: WebAppIcon(app: widget.app, size: 42.0),
      );
    }

    Widget _title() {
      return Padding(
        padding: EdgeInsets.only(
          left: widget.app == null ? 16.w : 0,
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: title,
          builder: (_, String value, __) => Text(
            value.notBreak,
            style: TextStyle(height: 1.2, fontSize: 20.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    Widget _moreButton() {
      return Tapper(
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
      );
    }

    Widget _closeButton() {
      return Tapper(
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
      );
    }

    return Container(
      color: context.appBarTheme.color,
      child: Column(
        children: <Widget>[
          VGap(Screens.topSafeHeight),
          Container(
            height: kAppBarHeight.w,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: <Widget>[
                              if (widget.app != null) _appIcon(),
                              Expanded(child: _title()),
                              Gap(10.w),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13.w),
                                  color: context.theme.canvasColor,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    _moreButton(),
                                    _closeButton(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const LineDivider(),
                    ],
                  ),
                ),
                Positioned.fill(top: null, child: progressBar(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize progressBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(Screens.width, 3.w),
      child: StreamBuilder<double>(
        initialData: 0.0,
        stream: progressController.stream,
        builder: (_, AsyncSnapshot<double> data) => LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          value: data.data,
          minHeight: 4.w,
        ),
      ),
    );
  }

  InAppWebView get newWebView {
    return InAppWebView(
      key: Key(currentTimeStamp.toString()),
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
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
          preferredContentMode: useDesktopMode
              ? UserPreferredContentMode.DESKTOP
              : UserPreferredContentMode.RECOMMENDED,
          verticalScrollBarEnabled: false,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          builtInZoomControls: true,
          displayZoomControls: false,
          forceDark: currentIsDark
              ? AndroidForceDark.FORCE_DARK_ON
              : AndroidForceDark.FORCE_DARK_OFF,
          loadWithOverviewMode: true,
          mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          safeBrowsingEnabled: false,
          supportMultipleWindows: false,
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
        CreateWindowAction createWindowAction,
      ) async {
        if (createWindowAction.request.url != null) {
          await controller.loadUrl(urlRequest: createWindowAction.request);
          return true;
        }
        return false;
      },
      onLoadStart: (_, Uri url) {
        LogUtils.d('WebView onLoadStart: $url');
      },
      onLoadStop: (InAppWebViewController controller, Uri url) async {
        LogUtils.d('WebView onLoadStop: $url');
        controller.evaluateJavascript(
          source: 'window.onbeforeunload=null',
        );

        this.url = url.toString();
        final String _title = (await controller.getTitle())?.trim();
        if (_title?.isNotEmpty == true && _title != this.url) {
          title.value = _title;
        } else {
          final String ogTitle = await controller.evaluateJavascript(
            source:
                'var ogTitle = document.querySelector(\'[property="og:title"]\');\n'
                'if (ogTitle != undefined) ogTitle.content;',
          ) as String;
          if (ogTitle != null) {
            title.value = ogTitle;
          }
        }
        cancelProgress();
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
      onDownloadStart: onDownload,
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      shouldOverrideUrlLoading: (
        InAppWebViewController controller,
        NavigationAction navigationAction,
      ) async {
        if (checkSchemeLoad(
          controller,
          navigationAction.request.url?.toString(),
        )) {
          return NavigationActionPolicy.CANCEL;
        } else {
          return NavigationActionPolicy.ALLOW;
        }
      },
      onUpdateVisitedHistory: (_, Uri url, bool androidIsReload) {
        LogUtils.d('WebView onUpdateVisitedHistory: $url, $androidIsReload');
        cancelProgress();
      },
    );
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
        body: Column(
          children: <Widget>[
            appBar(context),
            Expanded(child: _webView),
          ],
        ),
      ),
    );
  }
}
