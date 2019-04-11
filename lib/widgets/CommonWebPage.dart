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

  const CommonWebPage({Key key, @required this.url, @required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new CommonWebPageState();
  }

  static void jump(BuildContext context, String url, String title) {
    Navigator.of(context).push(platformPageRoute(builder: (context) {
      return CommonWebPage(
          url: url,
          title: title
      );
    }));
  }
}

class CommonWebPageState extends State<CommonWebPage> {
  bool loading = true;
  Timer _timer;
  String _url, _title;
  Color primaryColor = Colors.white;
  double currentProgress = 0.0;

  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    _url = widget.url;
    _title = widget.title;
    flutterWebViewPlugin.onStateChanged.listen((state) async {
      if (state.type == WebViewState.finishLoad) {
        setState(() {
          loading = false;
        });
        _timer = new Timer(const Duration(milliseconds: 500), () {
          setState(() {
            currentProgress = 0.0;
          });
        });
        String script = 'window.document.title';
        String title = await flutterWebViewPlugin.evalJavascript(script);
        setState(() {
          _title = title.substring(1, title.length-1);
        });
      } else if (state.type == WebViewState.startLoad) {
        setState(() {
          loading = true;
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
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget refreshIndicator = new Container(
      width: 56.0,
      padding: EdgeInsets.all(16.0),
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
            color: ThemeUtils.currentColorTheme,
            height: 2.0,
            child: new LinearProgressIndicator(
                backgroundColor: ThemeUtils.currentColorTheme,
                value: currentProgress,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor)
            )
        ),
        preferredSize: null
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget trailing = loading
        ? refreshIndicator
        : new Container(width: 56.0);
    return new WillPopScope(
        onWillPop: waitForClose,
        child: new WebviewScaffold(
            url: widget.url,
            allowFileURLs: true,
            appBar: new AppBar(
              backgroundColor: ThemeUtils.currentColorTheme,
              leading: new IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              ),
              title: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(_title,
                        style: new TextStyle(color: primaryColor)
                    ),
                    new Text(_url,
                        style: new TextStyle(color: primaryColor, fontSize: 14.0)
                    )
                  ]
              ),
              actions: <Widget>[trailing],
              bottom: progressBar(),
              iconTheme: new IconThemeData(color: primaryColor),
              brightness: Brightness.dark,
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
                                color: ThemeUtils.currentColorTheme
                            ),
                            onPressed: () {
                              flutterWebViewPlugin.goBack();
                            }
                        ),
                        new IconButton(
                            padding: EdgeInsets.zero,
                            icon: new Icon(
                                Icons.keyboard_arrow_right,
                                color: ThemeUtils.currentColorTheme
                            ),
                            onPressed: () {
                              flutterWebViewPlugin.goForward();
                            }
                        ),
                        new IconButton(
                            padding: EdgeInsets.zero,
                            icon: new Icon(
                                Icons.refresh,
                                color: ThemeUtils.currentColorTheme
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
            withZoom: true,
            resizeToAvoidBottomInset: true
        )
    );
  }
}
