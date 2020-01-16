///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-16 16:48
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: "openjmu://common-webview",
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
class CommonWebView extends StatefulWidget {
  final String url;
  final String title;
  final WebApp app;
  final bool withCookie;
  final bool withAppBar;
  final bool withAction;
  final bool withScaffold;
  final bool keepAlive;

  const CommonWebView({
    Key key,
    @required this.url,
    @required this.title,
    this.app,
    this.withCookie = true,
    this.withAppBar = true,
    this.withAction = true,
    this.withScaffold = true,
    this.keepAlive = false,
  });

  @override
  _CommonWebViewState createState() => _CommonWebViewState();
}

class _CommonWebViewState extends State<CommonWebView> {
  final _controller = Completer<WebViewController>();
  String url, title;
  bool isLoading = true;

  @override
  void initState() {
    url = widget.url;
    title = widget.title;
    super.initState();
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    );
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
                    onLongPress: _launchURL,
                    onDoubleTap: () {
                      Clipboard.setData(ClipboardData(text: url));
                      showToast("已复制网址到剪贴板");
                    },
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
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 56.0),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.withAppBar ?? true) ? appBar : null,
      body: Builder(
        builder: (BuildContext context) {
          return WebView(
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                debugPrint('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              debugPrint('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
            },
            gestureNavigationEnabled: true,
          );
        },
      ),
      persistentFooterButtons:
          (widget.withAction ?? true) ? <Widget>[NavigationControls(_controller.future)] : null,
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady = snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        await controller.goBack();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No forward history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
