import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class CommonWebPage extends StatefulWidget {
  final String title;
  final String url;

  const CommonWebPage({Key key, @required this.title, @required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new CommonWebPageState();
  }
}

class CommonWebPageState extends State<CommonWebPage> {
  String title;
  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  double progress = 0.0;
  bool loading = true;

  Widget refreshIndicator = new Container(
    width: 56.0,
    padding: EdgeInsets.all(16.0),
    child: Platform.isAndroid
      ? new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        strokeWidth: 3.0,
      )
      : new CupertinoActivityIndicator()
  );


  @override
  void initState() {
    super.initState();
    title = widget.title;
    flutterWebViewPlugin.onStateChanged.listen((state) async {
      if (state.type == WebViewState.finishLoad) {
        setState(() {
          loading = false;
        });
        String script = 'window.document.title';
        String title = await flutterWebViewPlugin.evalJavascript(script);
        setState(() {
          this.title = title.substring(1, title.length - 1);
        });
      } else if (state.type == WebViewState.startLoad) {
        setState(() {
          loading = true;
        });
      }
    });
//    flutterWebViewPlugin.onProgressChanged.listen((progress) {
//      setState(() {
//        progress = progress;
//      });
//      print("Page progress: $progress");
//    });
    flutterWebViewPlugin.onUrlChanged.listen((url) {
      setState(() {
        loading = false;
      });
    });
  }

  Widget progressBar() {
    if (progress == 1.0) {
      return new Container();
    } else {
      return new Container(
        height: 1.0,
        child: new LinearProgressIndicator(value: progress / 1.0)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (title == "@defaultTitle_jxt") {
      title = widget.title;
    }
    Widget trailing = loading
        ? refreshIndicator
        : new Container(
        width: 56.0,
        child: new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: () {
              flutterWebViewPlugin.reload();
            }
        )
    );
    return new WebviewScaffold(
        url: widget.url,
        allowFileURLs: true,
        appBar: new AppBar(
          title: new Text(
            title,
            style: new TextStyle(color: ThemeUtils.currentColorTheme),
          ),
          centerTitle: true,
          actions: <Widget>[trailing],
          iconTheme: new IconThemeData(color: ThemeUtils.currentColorTheme),
          brightness: ThemeUtils.currentBrightness,
        ),
        enableAppScheme: true,
        withJavascript: true,
        withLocalStorage: true,
        withZoom: true,
      );
  }
}
