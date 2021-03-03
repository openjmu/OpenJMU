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
            if (await waitForConfirmation(appName)) {
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

  Future<bool> waitForConfirmation(String applicationLabel) {
    return ConfirmationDialog.show(
      context,
      title: '即将跳转至外部应用',
      content: applicationLabel,
      showConfirm: true,
      confirmLabel: '允许跳转',
    );
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
    final String uri = Uri.encodeFull(url ?? this.url);
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
            value,
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
          preferredContentMode: useDesktopMode
              ? UserPreferredContentMode.DESKTOP
              : UserPreferredContentMode.RECOMMENDED,
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
          mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          safeBrowsingEnabled: false,
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
      onLoadStop: (InAppWebViewController controller, String url) async {
        controller.evaluateJavascript(
          source: 'window.onbeforeunload=null',
        );

        this.url = url;
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
        Future<void>.delayed(2.seconds, () {
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
