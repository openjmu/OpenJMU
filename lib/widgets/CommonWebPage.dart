import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppIcon.dart';

class CommonWebPage extends StatefulWidget {
  final String url;
  final String title;
  final WebApp app;
  final bool withCookie;
  final bool withAppBar;
  final bool withAction;

  const CommonWebPage({
    Key key,
    @required this.url,
    @required this.title,
    this.app,
    this.withCookie,
    this.withAppBar,
    this.withAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CommonWebPageState();

  static void jump(
    String url,
    String title, {
    WebApp app,
    bool withCookie,
  }) {
    Constants.navigatorKey.currentState.push(
      platformPageRoute(
        context: Constants.navigatorKey.currentContext,
        builder: (context) {
          return CommonWebPage(
            url: url,
            title: title,
            app: app,
            withCookie: withCookie,
          );
        },
      ),
    );
  }
}

class CommonWebPageState extends State<CommonWebPage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  bool isLoading = true;
  String _url, _title;
  Color currentThemeColor = ThemeUtils.currentThemeColor;
  double currentProgress = 0.0;

  @override
  void initState() {
    _url = widget.url;
    _title = widget.title;
    flutterWebViewPlugin.onStateChanged.listen((state) async {
      if (state.type == WebViewState.finishLoad) {
        String script = 'window.document.title';
        String title = await flutterWebViewPlugin.evalJavascript(script);
        if (Platform.isAndroid) {
          this._title = title.substring(1, title.length - 1);
        } else {
          this._title = title;
        }
        if (this.mounted) setState(() {});
        Future.delayed(const Duration(milliseconds: 500), () {
          isLoading = false;
          currentProgress = 0.0;
          if (this.mounted) setState(() {});
        });
      } else if (state.type == WebViewState.startLoad) {
        isLoading = true;
        if (this.mounted) setState(() {});
      }
    });
    flutterWebViewPlugin.onProgressChanged.listen((progress) {
      currentProgress = progress;
      if (this.mounted) setState(() {});
    });
    flutterWebViewPlugin.onUrlChanged.listen((url) {
      if (this.mounted)
        setState(() {
          _url = url;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (this.mounted)
              setState(() {
                isLoading = false;
              });
          });
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    flutterWebViewPlugin?.hide();
    flutterWebViewPlugin?.close();
    flutterWebViewPlugin?.dispose();
    super.dispose();
  }

  Future<Null> _launchURL() async {
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      showCenterErrorShortToast('无法打开$_url');
    }
  }

  Widget refreshIndicator() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: Constants.progressIndicator(strokeWidth: 3.0),
          ),
        ),
      );

  Future<bool> waitForClose() async {
    await flutterWebViewPlugin.close();
    return true;
  }

  PreferredSize progressBar(context) => PreferredSize(
        child: Container(
          height: suSetSp(2.0),
          color: !(currentProgress == 0.0) ? currentThemeColor : null,
          child: LinearProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
            value: currentProgress,
            valueColor: AlwaysStoppedAnimation<Color>(currentThemeColor),
          ),
        ),
        preferredSize: Size.fromHeight(suSetSp(3.0)),
      );

  @override
  Widget build(BuildContext context) {
    bool _clear;
    if (widget.withCookie != null && !widget.withCookie) {
      _clear = true;
    } else {
      _clear = false;
    }
    return WillPopScope(
      onWillPop: waitForClose,
      child: WebviewScaffold(
        url: widget.url,
        allowFileURLs: true,
        clearCache: _clear,
        clearCookies: _clear,
        enableAppScheme: true,
        withJavascript: true,
        withLocalStorage: true,
        withZoom: true,
        resizeToAvoidBottomInset: true,
        appBar: !(widget.withAppBar ?? false)
            ? AppBar(
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: Navigator.of(context).pop,
                ),
                title: GestureDetector(
                  onLongPress: () {
                    _launchURL();
                  },
                  onDoubleTap: () {
                    Clipboard.setData(ClipboardData(text: _url));
                    showShortToast("已复制网址到剪贴板");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      if (widget.app != null)
                        AppIcon(app: widget.app, size: 40.0),
                      Text(
                        _title,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.title.color,
                          fontSize: suSetSp(20.0),
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                actions: <Widget>[
                  isLoading ? refreshIndicator() : SizedBox(width: 56.0),
                ],
                bottom: progressBar(context),
              )
            : null,
        initialChild: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).canvasColor,
          child: isLoading
              ? Center(child: Constants.progressIndicator())
              : SizedBox.shrink(),
        ),
        persistentFooterButtons: !(widget.withAction ?? false)
            ? <Widget>[
                Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width - 16,
                  height: suSetSp(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.keyboard_arrow_left,
                          color: currentThemeColor,
                          size: suSetSp(24.0),
                        ),
                        onPressed: flutterWebViewPlugin.goBack,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.keyboard_arrow_right,
                          color: currentThemeColor,
                          size: suSetSp(24.0),
                        ),
                        onPressed: flutterWebViewPlugin.goForward,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.refresh,
                          color: currentThemeColor,
                          size: suSetSp(24.0),
                        ),
                        onPressed: flutterWebViewPlugin.reload,
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
