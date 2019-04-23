import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class CommonWebPage extends StatefulWidget {
  final String url;
  final String title;
  final bool withCookie;

  const CommonWebPage(
      this.url,
      this.title,
      {this.withCookie, Key key}
      ) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new CommonWebPageState();
  }

  static void jump(BuildContext context, String url, String title, {bool withCookie}) {
    Navigator.of(context).push(platformPageRoute(builder: (context) {
      return CommonWebPage(url, title, withCookie: withCookie);
    }));
  }
}

class CommonWebPageState extends State<CommonWebPage> {
  bool isLoading = true;
  String _url, _title;
  Color primaryColor = Colors.white;
  Color currentColorTheme = ThemeUtils.currentColorTheme;
  double currentProgress = 0.0;

  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    _url = widget.url;
    _title = widget.title;
    flutterWebViewPlugin.onStateChanged.listen((state) async {
      if (state.type == WebViewState.finishLoad) {
        String script = 'window.document.title';
        String title = await flutterWebViewPlugin.evalJavascript(script);
        setState(() {
          if (Platform.isAndroid) {
            this._title = title.substring(1, title.length-1);
          } else {
            this._title = title;
          }
        });
        new Timer(const Duration(milliseconds: 500), () {
          setState(() {
            isLoading = false;
            currentProgress = 0.0;
          });
        });
      } else if (state.type == WebViewState.startLoad) {
        setState(() {
          isLoading = true;
        });
      }
    });
    flutterWebViewPlugin.onProgressChanged.listen((progress) {
      setState(() {
        currentProgress = progress;
      });
    });
    flutterWebViewPlugin.onUrlChanged.listen((url) {
      setState(() {
        _url = url;
        new Timer(const Duration(milliseconds: 500), () {
          setState(() {
            isLoading = false;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    flutterWebViewPlugin?.hide();
    flutterWebViewPlugin?.close();
    flutterWebViewPlugin?.dispose();
  }

  Widget refreshIndicator = new Container(
      width: 54.0,
      padding: EdgeInsets.all(17.0),
      child: Platform.isAndroid
          ? new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3.0,
          )
          : new CupertinoActivityIndicator()
  );

  Future<bool> waitForClose() async {
    await flutterWebViewPlugin.close();
    return false;
  }

  PreferredSize progressBar() {
    return new PreferredSize(
        child: new Container(
            color: currentColorTheme,
            height: 2.0,
            child: new LinearProgressIndicator(
                backgroundColor: currentColorTheme,
                value: currentProgress,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor)
            )
        ),
        preferredSize: null
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _clear;
    if (widget.withCookie != null && !widget.withCookie) {
      _clear = true;
    } else {
      _clear = false;
    }
    Widget trailing = isLoading
        ? refreshIndicator
        : new Container(width: 56.0);
    return new WillPopScope(
        onWillPop: waitForClose,
        child: new WebviewScaffold(
            clearCache: _clear,
            clearCookies: _clear,
            url: widget.url,
            allowFileURLs: true,
            appBar: new AppBar(
              backgroundColor: currentColorTheme,
              leading: new IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              ),
              title: new Container(
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(_title,
                            style: new TextStyle(color: primaryColor)
                        ),
                        new Text(_url,
                          style: new TextStyle(color: primaryColor, fontSize: 14.0),
                          overflow: TextOverflow.fade,
                        )
                      ]
                  )
              ),
              centerTitle: true,
              actions: <Widget>[trailing],
              bottom: progressBar(),
            ),
            initialChild: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).canvasColor,
              child: isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(currentColorTheme)
                    )
                  )
                  : Container(),
            ),
            persistentFooterButtons: <Widget>[
              new Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width - 16.0,
                  height: 24.0,
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new IconButton(
                            padding: EdgeInsets.zero,
                            icon: new Icon(
                                Icons.keyboard_arrow_left,
                                color: currentColorTheme
                            ),
                            onPressed: () {
                              flutterWebViewPlugin.goBack();
                            }
                        ),
                        new IconButton(
                            padding: EdgeInsets.zero,
                            icon: new Icon(
                                Icons.keyboard_arrow_right,
                                color: currentColorTheme
                            ),
                            onPressed: () {
                              flutterWebViewPlugin.goForward();
                            }
                        ),
                        new IconButton(
                            padding: EdgeInsets.zero,
                            icon: new Icon(
                                Icons.refresh,
                                color: currentColorTheme
                            ),
                            onPressed: () {
                              flutterWebViewPlugin.reload();
                            }
                        ),
                      ]
                  )
              )
            ],
            enableAppScheme: true,
            withJavascript: true,
            withLocalStorage: true,
            resizeToAvoidBottomInset: true
        )
    );
  }
}
